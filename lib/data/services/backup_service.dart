// Backup + restore of the local SQLite database to a user-chosen path.
//
// Author: Paul Snow
// Since: 0.0.0

import 'dart:io';

import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:path_provider/path_provider.dart';

/// Copies the active SQLite database file to and from a user-chosen
/// destination. We deliberately copy the raw `.db` file rather than
/// `mssql.bak`-style streaming so the result is fully portable — point
/// any SQLite tool at it and read.
///
/// Drift's "share across isolates" flag and the WAL file mean the live
/// database might have unflushed work in `mymediascanner.db-wal`; we
/// copy any sibling `*.db-wal` and `*.db-shm` files alongside so the
/// snapshot remains internally consistent.
class BackupService {
  const BackupService({Future<Directory> Function()? docsDir})
      : _docsDir = docsDir ?? getApplicationDocumentsDirectory;

  /// Path resolver indirection — overrideable in tests so we don't have
  /// to mock platform plugins.
  final Future<Directory> Function() _docsDir;

  /// Returns the live database file path. Visible for testing.
  Future<File> liveDatabaseFile() async {
    final dir = await _docsDir();
    return File('${dir.path}/${AppConstants.databaseName}');
  }

  /// Copies the live database (and any WAL/SHM siblings) into a single
  /// archive directory at [targetDirectory]. Returns the path of the
  /// canonical `.db` copy.
  Future<String> createBackup(String targetDirectory) async {
    final live = await liveDatabaseFile();
    if (!await live.exists()) {
      throw StateError('No live database to back up at ${live.path}');
    }
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    final backupDir = Directory(
      '$targetDirectory/mymediascanner_backup_$timestamp',
    );
    await backupDir.create(recursive: true);

    final dbCopy = File('${backupDir.path}/${AppConstants.databaseName}');
    await live.copy(dbCopy.path);

    for (final suffix in ['-wal', '-shm']) {
      final sibling = File('${live.path}$suffix');
      if (await sibling.exists()) {
        await sibling
            .copy('${backupDir.path}/${AppConstants.databaseName}$suffix');
      }
    }
    return dbCopy.path;
  }

  /// Replaces the live database with the file at [backupFilePath]. The
  /// caller is responsible for ensuring no active connections — Drift's
  /// `AppDatabase` should be closed and re-opened on the next read.
  Future<void> restoreFromBackup(String backupFilePath) async {
    final source = File(backupFilePath);
    if (!await source.exists()) {
      throw StateError('Backup file does not exist: $backupFilePath');
    }
    final live = await liveDatabaseFile();
    // Best-effort cleanup of any stale WAL/SHM around the live file so
    // we don't combine a fresh `.db` with an older transaction tail.
    for (final suffix in ['-wal', '-shm']) {
      final sibling = File('${live.path}$suffix');
      if (await sibling.exists()) {
        await sibling.delete();
      }
    }
    await source.copy(live.path);
  }
}
