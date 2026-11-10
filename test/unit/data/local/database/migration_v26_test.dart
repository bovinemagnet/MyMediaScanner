import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

/// Regression tests for the v26 migration adding the `sync_conflicts`
/// table, which persists unresolved sync conflicts across restarts
/// (#131).
///
/// Author: Paul Snow
/// Since: 0.0.0
void main() {
  test('schema version is 26', () {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 26);
  });

  test('fresh schema has sync_conflicts', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await _syncConflictColumns(db), [
      'entity_type',
      'entity_id',
      'field_name',
      'local_value_json',
      'remote_value_json',
      'local_updated_at',
      'remote_updated_at',
      'detected_at',
    ]);
  });

  test('v25 → v26 upgrade creates sync_conflicts', () async {
    final dbFile = await _writeStubSchema(userVersion: 25);
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    expect(await _syncConflictColumns(db), contains('field_name'));
    expect(await db.syncConflictsDao.count(), 0);
  });
}

Future<List<String>> _syncConflictColumns(AppDatabase db) async {
  final rows = await db
      .customSelect("SELECT name FROM pragma_table_info('sync_conflicts')")
      .get();
  return rows.map((r) => r.data['name'] as String).toList();
}

/// A database at [userVersion] with only an unrelated table, so the
/// upgrade path (not onCreate) runs.
Future<File> _writeStubSchema({required int userVersion}) async {
  final tempDir = await Directory.systemTemp.createTemp('mms_mig_v26_');
  final dbFile = File('${tempDir.path}/app.sqlite');
  addTearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  final raw = sqlite3.open(dbFile.path);
  raw.execute('CREATE TABLE placeholder (id TEXT PRIMARY KEY)');
  raw.execute('PRAGMA user_version = $userVersion');
  raw.close();
  return dbFile;
}
