import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

/// v23 adds `updated_at` and `deleted` to the two join tables
/// (media_item_tags, shelf_items) so tag assignments and shelf
/// memberships can sync: `deleted` provides removal tombstones and
/// `updated_at` the last-write-wins basis. Without them the tables had
/// no sync representation at all and were silently device-local.
void main() {
  test('v23 schema exposes updated_at and deleted on join tables', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    for (final table in ['media_item_tags', 'shelf_items']) {
      final rows = await db.customSelect(
        "SELECT name FROM pragma_table_info('$table')",
      ).get();
      final names = rows.map((r) => r.data['name'] as String).toSet();
      expect(names, containsAll(['updated_at', 'deleted']),
          reason: '$table must carry sync columns');
    }
  });

  test('onUpgrade from v22 adds the sync columns to both join tables',
      () async {
    final tempDir = await Directory.systemTemp.createTemp('mms_mig_v23_');
    final dbFile = File('${tempDir.path}/app.sqlite');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    // Seed the v22 join-table shapes (no updated_at / deleted).
    final raw = sqlite3.open(dbFile.path);
    raw.execute('''
      CREATE TABLE media_item_tags (
        media_item_id TEXT NOT NULL,
        tag_id TEXT NOT NULL,
        PRIMARY KEY (media_item_id, tag_id)
      )
    ''');
    raw.execute('''
      CREATE TABLE shelf_items (
        shelf_id TEXT NOT NULL,
        media_item_id TEXT NOT NULL,
        position INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (shelf_id, media_item_id)
      )
    ''');
    raw.execute("INSERT INTO media_item_tags VALUES ('m1', 't1')");
    raw.execute("INSERT INTO shelf_items VALUES ('s1', 'm1', 0)");
    raw.execute('PRAGMA user_version = 22');
    raw.close();

    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    for (final table in ['media_item_tags', 'shelf_items']) {
      final rows = await db.customSelect(
        "SELECT name FROM pragma_table_info('$table')",
      ).get();
      final names = rows.map((r) => r.data['name'] as String).toSet();
      expect(names, containsAll(['updated_at', 'deleted']),
          reason: '$table must gain sync columns on upgrade');
    }

    // Pre-existing rows survive with live defaults.
    final tagRow = await db.customSelect(
      'SELECT updated_at, deleted FROM media_item_tags',
    ).getSingle();
    expect(tagRow.data['deleted'], 0);
    expect(tagRow.data['updated_at'], 0);
  });
}
