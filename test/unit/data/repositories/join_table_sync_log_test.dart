import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/repositories/shelf_repository_impl.dart';
import 'package:mymediascanner/data/repositories/tag_repository_impl.dart';

/// Tag assignments (`media_item_tags`) and shelf memberships
/// (`shelf_items`) previously never synced: the mutation paths wrote no
/// `sync_log` entries, so the data stayed silently device-local while
/// everything around it replicated. Every mutation must now enqueue a
/// sync_log row (insert or tombstone) and removals must soft-delete so
/// the tombstone has a row to represent.
void main() {
  late AppDatabase db;
  late TagRepositoryImpl tagRepo;
  late ShelfRepositoryImpl shelfRepo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tagRepo = TagRepositoryImpl(
      tagsDao: db.tagsDao,
      syncLogDao: db.syncLogDao,
    );
    shelfRepo = ShelfRepositoryImpl(
      shelvesDao: db.shelvesDao,
      syncLogDao: db.syncLogDao,
    );

    // Parent rows for the joins.
    await db.tagsDao.insertTag(const TagsTableCompanion(
      id: Value('t1'),
      name: Value('Rock'),
      updatedAt: Value(1),
    ));
    await db.shelvesDao.insertShelf(const ShelvesTableCompanion(
      id: Value('s1'),
      name: Value('Favourites'),
      updatedAt: Value(1),
    ));
  });

  tearDown(() async {
    await db.close();
  });

  Future<List<SyncLogTableData>> logsFor(String entityType, String id) async {
    final rows = await db.syncLogDao.getPending();
    return rows
        .where((r) => r.entityType == entityType && r.entityId == id)
        .toList();
  }

  group('tag assignments', () {
    test('assignToMediaItem enqueues a media_item_tag sync_log row',
        () async {
      await tagRepo.assignToMediaItem('t1', 'm1');

      final logs = await logsFor('media_item_tag', 'm1|t1');
      expect(logs, hasLength(1));
      expect(logs.single.operation, 'insert');
      final payload =
          jsonDecode(logs.single.payloadJson) as Map<String, dynamic>;
      expect(payload['media_item_id'], 'm1');
      expect(payload['tag_id'], 't1');
      expect(payload['deleted'], 0);
      expect(payload['updated_at'], greaterThan(0));
    });

    test('removeFromMediaItem tombstones the row and enqueues a delete log',
        () async {
      await tagRepo.assignToMediaItem('t1', 'm1');
      await tagRepo.removeFromMediaItem('t1', 'm1');

      expect(await tagRepo.getTagIdsForMediaItem('m1'), isEmpty,
          reason: 'soft-deleted assignments must be filtered from reads');

      final logs = await logsFor('media_item_tag', 'm1|t1');
      expect(logs, hasLength(2));
      final deleteLog = logs.firstWhere((l) => l.operation == 'delete');
      final payload =
          jsonDecode(deleteLog.payloadJson) as Map<String, dynamic>;
      expect(payload['deleted'], 1);
    });

    test('re-assigning after removal resurrects the assignment', () async {
      await tagRepo.assignToMediaItem('t1', 'm1');
      await tagRepo.removeFromMediaItem('t1', 'm1');
      await tagRepo.assignToMediaItem('t1', 'm1');

      expect(await tagRepo.getTagIdsForMediaItem('m1'), ['t1']);
    });
  });

  group('shelf memberships', () {
    test('addItem enqueues a shelf_item sync_log row with position',
        () async {
      await shelfRepo.addItem('s1', 'm1', 3);

      final logs = await logsFor('shelf_item', 's1|m1');
      expect(logs, hasLength(1));
      expect(logs.single.operation, 'insert');
      final payload =
          jsonDecode(logs.single.payloadJson) as Map<String, dynamic>;
      expect(payload['shelf_id'], 's1');
      expect(payload['media_item_id'], 'm1');
      expect(payload['position'], 3);
      expect(payload['deleted'], 0);
      expect(payload['updated_at'], greaterThan(0));
    });

    test('removeItem tombstones the row and enqueues a delete log',
        () async {
      await shelfRepo.addItem('s1', 'm1', 0);
      await shelfRepo.removeItem('s1', 'm1');

      expect(await shelfRepo.getMediaItemIdsForShelf('s1'), isEmpty,
          reason: 'soft-deleted memberships must be filtered from reads');

      final logs = await logsFor('shelf_item', 's1|m1');
      expect(logs, hasLength(2));
      final deleteLog = logs.firstWhere((l) => l.operation == 'delete');
      final payload =
          jsonDecode(deleteLog.payloadJson) as Map<String, dynamic>;
      expect(payload['deleted'], 1);
    });

    test('reorderItems keeps dense positions, tombstones dropped items, '
        'and logs every change', () async {
      await shelfRepo.addItem('s1', 'm1', 0);
      await shelfRepo.addItem('s1', 'm2', 1);
      await shelfRepo.addItem('s1', 'm3', 2);

      // m2 removed by the reorder; m3 and m1 swap.
      await shelfRepo.reorderItems('s1', ['m3', 'm1']);

      expect(await shelfRepo.getMediaItemIdsForShelf('s1'), ['m3', 'm1']);

      // Surviving items get fresh upsert logs with their new positions.
      final m3Logs = await logsFor('shelf_item', 's1|m3');
      final m3Latest =
          jsonDecode(m3Logs.last.payloadJson) as Map<String, dynamic>;
      expect(m3Latest['position'], 0);
      expect(m3Latest['deleted'], 0);

      // The dropped item gets a tombstone log.
      final m2Logs = await logsFor('shelf_item', 's1|m2');
      final m2Latest =
          jsonDecode(m2Logs.last.payloadJson) as Map<String, dynamic>;
      expect(m2Latest['deleted'], 1);
    });
  });
}
