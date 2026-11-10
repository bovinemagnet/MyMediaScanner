import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

/// Regression tests for the v25 migration adding
/// `rip_tracks.start_ms` / `end_ms`, the offsets of a CUE track inside
/// its shared audio file (#131).
///
/// The v17 branch drops and recreates `rip_tracks` from the current
/// Dart definition, so upgrades from < 17 arrive at the v25 branch
/// with the columns already present — the add must be guarded.
///
/// Author: Paul Snow
/// Since: 0.0.0
void main() {
  test('schema version is 25', () {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 25);
  });

  test('fresh schema exposes rip_tracks start_ms and end_ms', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    expect(await _ripTrackColumns(db), containsAll(['start_ms', 'end_ms']));
  });

  test('v24 → v25 upgrade adds the offset columns once', () async {
    final dbFile = await _writeStubRipSchema(userVersion: 24);
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final cols = await _ripTrackColumns(db);
    expect(cols.where((c) => c == 'start_ms').length, 1);
    expect(cols.where((c) => c == 'end_ms').length, 1);
  });

  test('pre-v17 upgrade (drop-and-recreate path) does not duplicate '
      'the offset columns', () async {
    final dbFile = await _writeStubRipSchema(userVersion: 16);
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final cols = await _ripTrackColumns(db);
    expect(cols.where((c) => c == 'start_ms').length, 1);
    expect(cols.where((c) => c == 'end_ms').length, 1);
  });
}

Future<List<String>> _ripTrackColumns(AppDatabase db) async {
  final rows = await db
      .customSelect("SELECT name FROM pragma_table_info('rip_tracks')")
      .get();
  return rows.map((r) => r.data['name'] as String).toList();
}

/// Minimal rip tables at their pre-CUE-offset shape.
Future<File> _writeStubRipSchema({required int userVersion}) async {
  final tempDir = await Directory.systemTemp.createTemp('mms_mig_v25_');
  final dbFile = File('${tempDir.path}/app.sqlite');
  addTearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  final raw = sqlite3.open(dbFile.path);
  raw.execute('''
    CREATE TABLE rip_albums (
      id TEXT NOT NULL PRIMARY KEY,
      library_path TEXT NOT NULL,
      artist TEXT NULL,
      album_title TEXT NULL,
      barcode TEXT NULL,
      track_count INTEGER NOT NULL,
      disc_count INTEGER NOT NULL DEFAULT 1,
      total_size_bytes INTEGER NOT NULL,
      media_item_id TEXT NULL,
      last_scanned_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      cue_file_path TEXT NULL,
      gnudb_disc_id TEXT NULL,
      deleted INTEGER NOT NULL DEFAULT 0,
      cover_path TEXT NULL
    )
  ''');
  raw.execute('''
    CREATE TABLE rip_tracks (
      id TEXT NOT NULL PRIMARY KEY,
      rip_album_id TEXT NOT NULL,
      disc_number INTEGER NOT NULL DEFAULT 1,
      track_number INTEGER NOT NULL,
      title TEXT NULL,
      file_path TEXT NOT NULL,
      duration_ms INTEGER NULL,
      file_size_bytes INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  raw.execute('PRAGMA user_version = $userVersion');
  raw.close();
  return dbFile;
}
