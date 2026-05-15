import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/data/services/backup_service.dart';

void main() {
  late Directory home;
  late Directory dest;
  late BackupService service;

  setUp(() async {
    home = await Directory.systemTemp.createTemp('mms_backup_home_');
    dest = await Directory.systemTemp.createTemp('mms_backup_dest_');
    service = BackupService(docsDir: () async => home);
  });

  tearDown(() async {
    await home.delete(recursive: true);
    await dest.delete(recursive: true);
  });

  Future<File> seedDb({String contents = 'sqlite3-bytes'}) async {
    final db = File('${home.path}/${AppConstants.databaseName}');
    await db.writeAsString(contents);
    return db;
  }

  test('createBackup copies the live database into a timestamped folder',
      () async {
    await seedDb(contents: 'db-payload');
    final path = await service.createBackup(dest.path);

    final copy = File(path);
    expect(await copy.exists(), isTrue);
    expect(await copy.readAsString(), 'db-payload');
    expect(path, contains('mymediascanner_backup_'));
  });

  test('createBackup also copies WAL and SHM siblings when present',
      () async {
    final db = await seedDb();
    await File('${db.path}-wal').writeAsString('wal');
    await File('${db.path}-shm').writeAsString('shm');

    final path = await service.createBackup(dest.path);
    final dir = Directory(File(path).parent.path);
    final entries = await dir.list().toList();
    final names = entries.map((e) => e.path.split('/').last).toSet();
    expect(names, contains('${AppConstants.databaseName}-wal'));
    expect(names, contains('${AppConstants.databaseName}-shm'));
  });

  test('createBackup throws when no live db exists', () async {
    expect(
      () => service.createBackup(dest.path),
      throwsStateError,
    );
  });

  test('restoreFromBackup overwrites live db and removes stale WAL/SHM',
      () async {
    final db = await seedDb(contents: 'old');
    await File('${db.path}-wal').writeAsString('stale-wal');

    final backupFile = File('${dest.path}/backup.db');
    await backupFile.writeAsString('new');

    await service.restoreFromBackup(backupFile.path);

    expect(await db.readAsString(), 'new');
    expect(await File('${db.path}-wal').exists(), isFalse);
  });

  test('restoreFromBackup throws when source file missing', () async {
    expect(
      () => service.restoreFromBackup('${dest.path}/nope.db'),
      throwsStateError,
    );
  });
}
