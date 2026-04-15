import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('v12 schema exposes ownership and purchase columns', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    // Trigger creation via a no-op query
    await db.customSelect('SELECT 1').get();

    final rows = await db.customSelect(
      'SELECT name FROM pragma_table_info(\'media_items\')',
    ).get();
    final names = rows.map((r) => r.data['name'] as String).toSet();
    expect(
        names,
        containsAll([
          'ownership_status',
          'condition',
          'price_paid',
          'acquired_at',
          'retailer',
        ]));
  });

  test('onUpgrade from v11 adds new columns and backfills acquired_at',
      () async {
    // Create a temporary file-backed sqlite DB seeded with the v11 schema.
    final tempDir = await Directory.systemTemp.createTemp('mms_mig_v12_');
    final dbFile = File('${tempDir.path}/app.sqlite');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    // Hand-craft the v11 media_items schema: identical to current but
    // without the five columns introduced in v12.
    final raw = sqlite3.open(dbFile.path);
    raw.execute('''
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
    ''');

    const seededDateAdded = 1700000000000;
    raw.execute(
      'INSERT INTO media_items (id, barcode, barcode_type, media_type, '
      'title, date_added, date_scanned, updated_at) VALUES '
      "('seed-1', '123', 'ean13', 'cd', 'Seed Title', $seededDateAdded, "
      '$seededDateAdded, $seededDateAdded)',
    );
    raw.execute('PRAGMA user_version = 11');
    raw.close();

    // Reopen via AppDatabase, which triggers onUpgrade from v11 -> v12.
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    // Assert the five new columns exist after migration.
    final colRows = await db.customSelect(
      'SELECT name FROM pragma_table_info(\'media_items\')',
    ).get();
    final names = colRows.map((r) => r.data['name'] as String).toSet();
    expect(
        names,
        containsAll([
          'ownership_status',
          'condition',
          'price_paid',
          'acquired_at',
          'retailer',
        ]));

    // Assert the seeded row was backfilled correctly.
    final seeded = await db.customSelect(
      'SELECT acquired_at, ownership_status FROM media_items '
      "WHERE id = 'seed-1'",
    ).getSingle();
    expect(seeded.data['acquired_at'], seededDateAdded);
    expect(seeded.data['ownership_status'], 'owned');
  });
}
