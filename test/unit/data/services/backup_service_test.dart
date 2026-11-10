import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/database/database_location.dart';
import 'package:mymediascanner/data/services/backup_service.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// Backups must be consistent SQLite snapshots and restores must never
/// replace the file under an open connection (#131). These tests use
/// real SQLite databases: the previous ones wrote strings such as
/// "sqlite3-bytes", so they could not see WAL loss or a wrong path.
void main() {
  late Directory home;
  late Directory dest;
  late File liveFile;
  late AppDatabase db;
  late BackupService service;

  AppDatabase openLive() => AppDatabase.forTesting(NativeDatabase(
        liveFile,
        setup: (raw) => raw.execute('PRAGMA journal_mode=WAL'),
      ));

  Future<void> insertTag(AppDatabase target, String id, String name) =>
      target.tagsDao.insertTag(TagsTableCompanion(
        id: Value(id),
        name: Value(name),
        updatedAt: const Value(1),
      ));

  List<String> tagNamesIn(String path) {
    final raw = sqlite.sqlite3.open(path, mode: sqlite.OpenMode.readOnly);
    try {
      return raw
          .select('SELECT name FROM tags ORDER BY name')
          .map((r) => r['name'] as String)
          .toList();
    } finally {
      raw.close();
    }
  }

  setUp(() async {
    home = await Directory.systemTemp.createTemp('mms_backup_home_');
    dest = await Directory.systemTemp.createTemp('mms_backup_dest_');
    liveFile = File('${home.path}/${DatabaseLocation.fileName}');
    db = openLive();
    service = BackupService(db: db, liveDatabaseFile: () async => liveFile);
  });

  tearDown(() async {
    await db.close();
    await home.delete(recursive: true);
    await dest.delete(recursive: true);
  });

  test('the live database file name matches the one drift_flutter opens',
      () async {
    // drift_flutter's default for `name: X` is `X.sqlite`; the app has
    // always stored its data there, so the name must not change.
    expect(DatabaseLocation.fileName, 'mymediascanner.db.sqlite');
    final file = await DatabaseLocation.liveDatabaseFile(
      docsDir: () async => home,
    );
    expect(file.path, liveFile.path);
  });

  group('createBackup', () {
    test('writes a SQLite snapshot holding committed rows, including '
        'ones still in the WAL', () async {
      await insertTag(db, 't1', 'Jazz');
      expect(await File('${liveFile.path}-wal').exists(), isTrue,
          reason: 'precondition: the row is in the WAL');

      final path = await service.createBackup(dest.path);

      expect(path, contains('mymediascanner_backup_'));
      expect(tagNamesIn(path), ['Jazz']);
    });

    test('a snapshot is a single self-contained file', () async {
      await insertTag(db, 't1', 'Jazz');

      final path = await service.createBackup(dest.path);

      expect(await File('$path-wal').exists(), isFalse);
      expect(await File('$path-shm').exists(), isFalse);
    });
  });

  group('stageRestore', () {
    test('rejects a missing file', () async {
      await expectLater(
        service.stageRestore('${dest.path}/nope.db'),
        throwsA(isA<BackupValidationException>()),
      );
    });

    test('rejects a file that is not a SQLite database', () async {
      final bogus = File('${dest.path}/bogus.db');
      await bogus.writeAsString('definitely not sqlite');

      await expectLater(
        service.stageRestore(bogus.path),
        throwsA(isA<BackupValidationException>()),
      );
      expect(await DatabaseLocation.pendingRestoreFile(liveFile).exists(),
          isFalse);
    });

    test('rejects a SQLite database that is not a MyMediaScanner backup',
        () async {
      sqlite.sqlite3.open('${dest.path}/other.db')
        ..execute('CREATE TABLE notes (id TEXT)')
        ..close();

      await expectLater(
        service.stageRestore('${dest.path}/other.db'),
        throwsA(isA<BackupValidationException>()),
      );
    });

    test('rejects a backup from a newer schema version', () async {
      final path = await service.createBackup(dest.path);
      sqlite.sqlite3.open(path)
        ..execute('PRAGMA user_version = ${db.schemaVersion + 1}')
        ..close();

      await expectLater(
        service.stageRestore(path),
        throwsA(isA<BackupValidationException>()),
      );
    });

    test('stages a valid backup without touching the live database',
        () async {
      await insertTag(db, 't1', 'Jazz');
      final path = await service.createBackup(dest.path);
      await insertTag(db, 't2', 'Blues');

      await service.stageRestore(path);

      expect(await DatabaseLocation.pendingRestoreFile(liveFile).exists(),
          isTrue);
      final live = await db.tagsDao.watchAll().first;
      expect(live.map((t) => t.name), unorderedEquals(['Jazz', 'Blues']));
    });
  });

  group('applyPendingRestore', () {
    test('does nothing when no restore is staged', () async {
      await insertTag(db, 't1', 'Jazz');
      await db.close();

      expect(await DatabaseLocation.applyPendingRestore(liveFile), isFalse);
      expect(tagNamesIn(liveFile.path), ['Jazz']);
      db = openLive();
    });

    test('swaps the staged backup in and keeps a rollback copy', () async {
      await insertTag(db, 't1', 'Jazz');
      final path = await service.createBackup(dest.path);
      await insertTag(db, 't2', 'Blues');
      await service.stageRestore(path);
      await db.close();

      expect(await DatabaseLocation.applyPendingRestore(liveFile), isTrue);

      expect(tagNamesIn(liveFile.path), ['Jazz']);
      expect(await DatabaseLocation.pendingRestoreFile(liveFile).exists(),
          isFalse);
      // The rollback copy keeps its WAL alongside, so it still opens
      // with every committed row of the replaced database.
      final rollback = DatabaseLocation.rollbackFile(liveFile);
      expect(tagNamesIn(rollback.path), ['Blues', 'Jazz']);

      db = openLive();
      final reopened = await db.tagsDao.watchAll().first;
      expect(reopened.map((t) => t.name), ['Jazz']);
    });
  });
}
