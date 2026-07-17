import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

/// Regression tests for the v24 migration adding
/// `rip_albums.cover_path`.
///
/// The v17 branch drops and recreates `rip_albums` from the current
/// Dart definition, so upgrades from < 17 arrive at the v24 branch
/// with the column already present — the add must be guarded.
///
/// Author: Paul Snow
/// Since: 0.0.0
void main() {
  test('fresh v24 schema exposes rip_albums.cover_path', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    expect(await _ripAlbumColumns(db), contains('cover_path'));
  });

  test('v23 → v24 upgrade adds cover_path once', () async {
    final dbFile = await _writeStubRipSchema(userVersion: 23);
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final cols = await _ripAlbumColumns(db);
    expect(cols.where((c) => c == 'cover_path').length, 1);
  });

  test('pre-v17 upgrade (drop-and-recreate path) does not duplicate '
      'cover_path', () async {
    // At user_version 16 the v17 branch recreates rip_albums from the
    // current definition (which already has cover_path); the v24
    // branch must then be a no-op instead of a duplicate-column error.
    final dbFile = await _writeStubRipSchema(userVersion: 16);
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final cols = await _ripAlbumColumns(db);
    expect(cols.where((c) => c == 'cover_path').length, 1);
  });
}

Future<List<String>> _ripAlbumColumns(AppDatabase db) async {
  final rows = await db
      .customSelect("SELECT name FROM pragma_table_info('rip_albums')")
      .get();
  return rows.map((r) => r.data['name'] as String).toList();
}

/// Minimal rip tables at their pre-cover_path shape.
Future<File> _writeStubRipSchema({required int userVersion}) async {
  final tempDir = await Directory.systemTemp.createTemp('mms_mig_v24_');
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
      deleted INTEGER NOT NULL DEFAULT 0
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
