import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

/// Regression tests for the v17 drop-and-recreate migration.
///
/// Two cohorts hit the upgrade path:
///   * Legitimate v15 users — never had `rip_albums.gnudb_disc_id`.
///   * Broken v16 users — installed the build that bumped
///     `schemaVersion` to 16 without an `onUpgrade` branch, so they
///     are at `user_version=16` with the column still missing.
///
/// Both must end up at v17 with the column present. The migration
/// drops and recreates `rip_albums` (and the `rip_tracks` table that
/// references it) instead of an `addColumn` patch, matching the
/// "agreed fix is drop-and-recreate" decision recorded in
/// migration_v16_test.dart.
void main() {
  test('fresh v17 schema exposes rip_albums.gnudb_disc_id', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final cols = await _ripAlbumsColumns(db);
    expect(cols, contains('gnudb_disc_id'));
  });

  test('v15 → v17 upgrade backfills rip_albums.gnudb_disc_id', () async {
    final dbFile = await _writeStubV15Schema(userVersion: 15);
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final cols = await _ripAlbumsColumns(db);
    expect(cols, contains('gnudb_disc_id'));
    // rip_tracks must be recreated too because of its FK to rip_albums.
    expect(await _tableExists(db, 'rip_tracks'), isTrue);
  });

  test('broken v16 → v17 upgrade adds rip_albums.gnudb_disc_id', () async {
    // Same physical schema as v15 (no gnudb_disc_id), but user_version
    // is bumped to 16 to mimic the install that took the broken build.
    final dbFile = await _writeStubV15Schema(userVersion: 16);
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final cols = await _ripAlbumsColumns(db);
    expect(cols, contains('gnudb_disc_id'));
  });
}

Future<Set<String>> _ripAlbumsColumns(AppDatabase db) async {
  final rows = await db
      .customSelect("SELECT name FROM pragma_table_info('rip_albums')")
      .get();
  return rows.map((r) => r.data['name'] as String).toSet();
}

Future<bool> _tableExists(AppDatabase db, String name) async {
  final rows = await db.customSelect(
    "SELECT name FROM sqlite_master WHERE type='table' AND name = ?1",
    variables: [Variable<String>(name)],
  ).get();
  return rows.isNotEmpty;
}

/// Writes a temp SQLite file containing just the rip tables in their
/// pre-gnudb shape, then sets `user_version` to [userVersion]. The
/// caller is responsible for deleting the temp directory via the
/// returned file's parent — this helper registers the cleanup.
Future<File> _writeStubV15Schema({required int userVersion}) async {
  final tempDir = await Directory.systemTemp.createTemp('mms_mig_v17_');
  final dbFile = File('${tempDir.path}/app.sqlite');
  addTearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  final raw = sqlite3.open(dbFile.path);
  // Minimal v15 shape: rip_albums without gnudb_disc_id, plus the
  // rip_tracks FK target so the drop-and-recreate has something to
  // tear down.
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
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (rip_album_id) REFERENCES rip_albums (id)
    )
  ''');
  raw.execute('PRAGMA user_version = $userVersion');
  raw.close();

  return dbFile;
}
