import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

/// Regression tests for two ways the pre-v24 migration chain could
/// brick an install:
///
///   * Half-applied upgrade — drift migrations do not run inside a
///     transaction, so an app killed mid-upgrade leaves the applied
///     DDL committed while `user_version` stays at the old value. A
///     real install was observed at `user_version=6` with the v7–v10
///     branches already applied; every reopen then re-ran
///     `ALTER TABLE loans ADD COLUMN due_at` and failed with
///     `duplicate column name`, permanently blocking the app.
///
///   * Genuine v1 upgrade — the `from < 2` branch creates `loans`
///     from the *current* Dart definition (which includes `due_at`),
///     and `from < 4` creates `rip_albums` (which includes
///     `cue_file_path`), so the later unguarded `addColumn` calls in
///     the v7/v9 branches hit the same `duplicate column` failure.
///     The `from < 8` branch also created indexes on
///     `tmdb_account_sync_items`, a table that does not exist until
///     the v20 branch runs.
void main() {
  test('half-applied v6 upgrade (v7–v10 already committed) recovers',
      () async {
    final dbFile = await _writeHalfAppliedV6Schema();
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    // Migration completed: post-v10 branches applied.
    final mediaCols = await _columns(db, 'media_items');
    expect(mediaCols, contains('ownership_status')); // v12
    expect(mediaCols, contains('series_id')); // v14
    expect(mediaCols, contains('current_value')); // v22
    // The already-present columns were not re-added.
    final loanCols = await _columns(db, 'loans');
    expect(loanCols.where((c) => c == 'due_at').length, 1);
    // v12 backfill still ran for the pre-existing row.
    final row = await db
        .customSelect('SELECT acquired_at, date_added FROM media_items')
        .getSingle();
    expect(row.data['acquired_at'], row.data['date_added']);
  });

  test('genuine v1 → current upgrade succeeds', () async {
    final dbFile = await _writeV1Schema();
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    // Tables created mid-chain from the current Dart definitions must
    // not be broken by later addColumn branches.
    final loanCols = await _columns(db, 'loans');
    expect(loanCols.where((c) => c == 'due_at').length, 1);
    final ripCols = await _columns(db, 'rip_albums');
    expect(ripCols.where((c) => c == 'cue_file_path').length, 1);
    // Columns genuinely missing at v1 were added.
    expect(await _columns(db, 'sync_log'), contains('direction'));
    expect(await _columns(db, 'media_items'), contains('critic_score'));
    expect(await _columns(db, 'media_item_tags'), contains('updated_at'));
  });
}

Future<List<String>> _columns(AppDatabase db, String table) async {
  final rows = await db
      .customSelect("SELECT name FROM pragma_table_info('$table')")
      .get();
  return rows.map((r) => r.data['name'] as String).toList();
}

Future<File> _tempDbFile(String prefix) async {
  final tempDir = await Directory.systemTemp.createTemp(prefix);
  addTearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });
  return File('${tempDir.path}/app.sqlite');
}

/// v6 shape for `media_items` (v1 shape plus the v3 critic columns).
const _mediaItemsV6 = '''
  CREATE TABLE media_items (
    id TEXT NOT NULL PRIMARY KEY,
    barcode TEXT NOT NULL,
    barcode_type TEXT NOT NULL,
    media_type TEXT NOT NULL,
    title TEXT NOT NULL,
    subtitle TEXT NULL,
    description TEXT NULL,
    cover_url TEXT NULL,
    year INTEGER NULL,
    publisher TEXT NULL,
    format TEXT NULL,
    genres TEXT NOT NULL DEFAULT '[]',
    extra_metadata TEXT NOT NULL DEFAULT '{}',
    source_apis TEXT NOT NULL DEFAULT '[]',
    user_rating REAL NULL,
    user_review TEXT NULL,
    critic_score REAL NULL,
    critic_source TEXT NULL,
    date_added INTEGER NOT NULL,
    date_scanned INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    synced_at INTEGER NULL,
    deleted INTEGER NOT NULL DEFAULT 0
  )
''';

const _mediaItemTagsV1 = '''
  CREATE TABLE media_item_tags (
    media_item_id TEXT NOT NULL,
    tag_id TEXT NOT NULL,
    PRIMARY KEY (media_item_id, tag_id)
  )
''';

const _shelfItemsV1 = '''
  CREATE TABLE shelf_items (
    shelf_id TEXT NOT NULL,
    media_item_id TEXT NOT NULL,
    position INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (shelf_id, media_item_id)
  )
''';

/// Mirrors the observed bricked install: `user_version=6`, but the
/// v7 (loans.due_at, sync_log columns), v9 (rip_albums.cue_file_path)
/// and v10 branches were already committed by an upgrade run that was
/// killed before finishing.
Future<File> _writeHalfAppliedV6Schema() async {
  final dbFile = await _tempDbFile('mms_mig_halfv6_');
  final raw = sqlite3.open(dbFile.path);
  raw.execute(_mediaItemsV6);
  raw.execute('''
    CREATE TABLE loans (
      id TEXT NOT NULL PRIMARY KEY,
      media_item_id TEXT NOT NULL,
      borrower_id TEXT NOT NULL,
      lent_at INTEGER NOT NULL,
      returned_at INTEGER NULL,
      notes TEXT NULL,
      updated_at INTEGER NOT NULL,
      deleted INTEGER NOT NULL DEFAULT 0,
      due_at INTEGER NULL
    )
  ''');
  raw.execute('''
    CREATE TABLE sync_log (
      id TEXT NOT NULL PRIMARY KEY,
      entity_type TEXT NOT NULL,
      entity_id TEXT NOT NULL,
      operation TEXT NOT NULL,
      payload_json TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      attempted_at INTEGER NULL,
      synced INTEGER NOT NULL DEFAULT 0,
      error_message TEXT NULL,
      duration_ms INTEGER NULL,
      direction TEXT NULL,
      resolved_by TEXT NULL
    )
  ''');
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
      deleted INTEGER NOT NULL DEFAULT 0,
      cue_file_path TEXT NULL
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
  raw.execute(_mediaItemTagsV1);
  raw.execute(_shelfItemsV1);
  raw.execute('''
    INSERT INTO media_items (
      id, barcode, barcode_type, media_type, title,
      date_added, date_scanned, updated_at
    ) VALUES ('m1', '0123456789012', 'ean13', 'film', 'Stub Film',
      1700000000000, 1700000000000, 1700000000000)
  ''');
  raw.execute('PRAGMA user_version = 6');
  raw.close();
  return dbFile;
}

/// Genuine v1 install: base tables only, at their v1 shapes.
Future<File> _writeV1Schema() async {
  final dbFile = await _tempDbFile('mms_mig_v1_');
  final raw = sqlite3.open(dbFile.path);
  // v1 media_items: v6 shape minus the v3 critic columns.
  raw.execute(_mediaItemsV6
      .replaceAll('critic_score REAL NULL,\n', '')
      .replaceAll('critic_source TEXT NULL,\n', ''));
  raw.execute('''
    CREATE TABLE sync_log (
      id TEXT NOT NULL PRIMARY KEY,
      entity_type TEXT NOT NULL,
      entity_id TEXT NOT NULL,
      operation TEXT NOT NULL,
      payload_json TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      attempted_at INTEGER NULL,
      synced INTEGER NOT NULL DEFAULT 0
    )
  ''');
  raw.execute(_mediaItemTagsV1);
  raw.execute(_shelfItemsV1);
  raw.execute('PRAGMA user_version = 1');
  raw.close();
  return dbFile;
}
