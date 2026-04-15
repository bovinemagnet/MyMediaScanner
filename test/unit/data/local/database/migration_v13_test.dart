import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('v13 schema includes locations table and media_items.location_id',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final tables = (await db.customSelect(
      "SELECT name FROM sqlite_master "
      "WHERE type='table' AND name='locations'",
    ).get())
        .map((r) => r.data['name'])
        .toSet();
    expect(tables, contains('locations'));

    final cols = (await db.customSelect(
      "SELECT name FROM pragma_table_info('media_items')",
    ).get())
        .map((r) => r.data['name'] as String)
        .toSet();
    expect(cols, contains('location_id'));
  });

  test('onUpgrade from v12 adds locations table and location_id column',
      () async {
    final tempDir = await Directory.systemTemp.createTemp('mms_mig_v13_');
    final dbFile = File('${tempDir.path}/app.sqlite');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    // Hand-craft a v12 media_items schema (everything before location_id).
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
        deleted INTEGER NOT NULL DEFAULT 0,
        ownership_status TEXT NOT NULL DEFAULT 'owned',
        condition TEXT NULL,
        price_paid REAL NULL,
        acquired_at INTEGER NULL,
        retailer TEXT NULL
      )
    ''');
    raw.execute('PRAGMA user_version = 12');
    raw.dispose();

    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final cols = (await db.customSelect(
      "SELECT name FROM pragma_table_info('media_items')",
    ).get())
        .map((r) => r.data['name'] as String)
        .toSet();
    expect(cols, contains('location_id'));

    final tables = (await db.customSelect(
      "SELECT name FROM sqlite_master "
      "WHERE type='table' AND name='locations'",
    ).get())
        .map((r) => r.data['name'])
        .toSet();
    expect(tables, contains('locations'));
  });
}
