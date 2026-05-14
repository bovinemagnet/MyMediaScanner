import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('v22 schema exposes current_value and current_value_as_of columns',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final rows = await db.customSelect(
      'SELECT name FROM pragma_table_info(\'media_items\')',
    ).get();
    final names = rows.map((r) => r.data['name'] as String).toSet();
    expect(names, containsAll(['current_value', 'current_value_as_of']));
  });

  test('onUpgrade from v21 adds the two new columns', () async {
    final tempDir = await Directory.systemTemp.createTemp('mms_mig_v22_');
    final dbFile = File('${tempDir.path}/app.sqlite');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    // Seed a minimal v21 media_items shape (only the columns we care about).
    final raw = sqlite3.open(dbFile.path);
    raw.execute('''
      CREATE TABLE media_items (
        id TEXT NOT NULL PRIMARY KEY,
        barcode TEXT NOT NULL,
        barcode_type TEXT NOT NULL,
        media_type TEXT NOT NULL,
        title TEXT NOT NULL,
        genres TEXT NOT NULL DEFAULT '[]',
        extra_metadata TEXT NOT NULL DEFAULT '{}',
        source_apis TEXT NOT NULL DEFAULT '[]',
        date_added INTEGER NOT NULL,
        date_scanned INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted INTEGER NOT NULL DEFAULT 0,
        ownership_status TEXT NOT NULL DEFAULT 'owned',
        condition TEXT NULL,
        price_paid REAL NULL,
        acquired_at INTEGER NULL,
        retailer TEXT NULL,
        consumed INTEGER NOT NULL DEFAULT 0
      )
    ''');
    raw.execute('PRAGMA user_version = 21');
    raw.close();

    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final colRows = await db.customSelect(
      'SELECT name FROM pragma_table_info(\'media_items\')',
    ).get();
    final names = colRows.map((r) => r.data['name'] as String).toSet();
    expect(names, containsAll(['current_value', 'current_value_as_of']));
  });
}
