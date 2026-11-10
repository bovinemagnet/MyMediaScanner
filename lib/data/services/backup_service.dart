// Backup + restore of the local SQLite database to a user-chosen path.
//
// Author: Paul Snow
// Since: 0.0.0

import 'dart:io';

import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/database_location.dart';
import 'package:path/path.dart' as p;

/// Thrown when a file chosen for restore is not a usable backup.
class BackupValidationException implements Exception {
  const BackupValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Creates consistent backups of the live database and restores them
/// without replacing the file under an open connection.
///
/// * **Backup** runs `VACUUM INTO` on the live connection: SQLite
///   writes a transactionally consistent, self-contained copy that
///   includes everything committed so far, including pages still in
///   the WAL. Copying the `.db`, `-wal` and `-shm` files one after
///   another (the previous approach) was not an atomic snapshot.
/// * **Restore** is two-phase. [stageRestore] validates the chosen file
///   and copies it beside the live database;
///   [DatabaseLocation.applyPendingRestore] swaps it in on the next
///   launch, before the database is opened, and keeps the replaced
///   database as a rollback copy.
class BackupService {
  BackupService({
    required AppDatabase db,
    Future<File> Function()? liveDatabaseFile,
  })  : _db = db,
        _liveDatabaseFile =
            liveDatabaseFile ?? DatabaseLocation.liveDatabaseFile;

  final AppDatabase _db;
  final Future<File> Function() _liveDatabaseFile;

  /// Writes a snapshot of the live database into [targetDirectory] and
  /// returns its path.
  Future<String> createBackup(String targetDirectory) async {
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    final target = p.join(
      targetDirectory,
      'mymediascanner_backup_$timestamp.db',
    );
    await _db.customStatement('VACUUM INTO ?', [target]);
    return target;
  }

  /// Validates [backupFilePath] and stages it to replace the live
  /// database on the next launch. Throws [BackupValidationException]
  /// when the file is missing, not a SQLite database, not a
  /// MyMediaScanner database, damaged, or from a newer app version.
  Future<void> stageRestore(String backupFilePath) async {
    final source = File(backupFilePath);
    if (!await source.exists()) {
      throw BackupValidationException(
          'Backup file does not exist: $backupFilePath');
    }
    await _validate(source);

    final live = await _liveDatabaseFile();
    final pending = DatabaseLocation.pendingRestoreFile(live);
    // Copy then rename so a crash mid-copy can never leave a partial
    // file where the next launch would pick it up.
    final partial = File('${pending.path}.partial');
    await source.copy(partial.path);
    await partial.rename(pending.path);
  }

  Future<void> _validate(File source) async {
    const alias = 'restore_candidate';
    try {
      await _db.customStatement('ATTACH DATABASE ? AS $alias', [source.path]);
    } on Exception catch (e) {
      throw BackupValidationException('Cannot open backup: $e');
    }
    try {
      final integrity = await _db
          .customSelect('PRAGMA $alias.integrity_check(1)')
          .getSingle();
      if (integrity.data.values.first != 'ok') {
        throw const BackupValidationException(
            'The backup file is damaged and cannot be restored.');
      }
      final hasMediaItems = await _db
          .customSelect(
            'SELECT 1 FROM $alias.sqlite_master '
            "WHERE type = 'table' AND name = 'media_items'",
          )
          .getSingleOrNull();
      if (hasMediaItems == null) {
        throw const BackupValidationException(
            'This file is not a MyMediaScanner backup.');
      }
      final version = await _db
          .customSelect('PRAGMA $alias.user_version')
          .getSingle();
      final backupVersion = version.data.values.first as int;
      if (backupVersion > _db.schemaVersion) {
        throw BackupValidationException(
            'This backup was made by a newer version of the app '
            '(schema $backupVersion; this version supports up to '
            '${_db.schemaVersion}).');
      }
    } on BackupValidationException {
      rethrow;
    } on Exception catch (e) {
      // e.g. "file is not a database" surfaces on first read, not on
      // ATTACH.
      throw BackupValidationException('Not a valid backup file: $e');
    } finally {
      await _db.customStatement('DETACH DATABASE $alias');
    }
  }
}
