import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/data/repositories/sync_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSyncClient extends Mock implements PostgresSyncClient {}

/// Pull-side of join-table sync: remote `media_item_tags` and
/// `shelf_items` rows must round-trip to other devices. Last-write-wins
/// on `updated_at`; `deleted = 1` rows are tombstones that soft-delete
/// the local assignment.
void main() {
  late AppDatabase db;
  late _MockSyncClient client;
  late SyncRepositoryImpl repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    client = _MockSyncClient();
    repo = SyncRepositoryImpl(
      mediaItemsDao: db.mediaItemsDao,
      syncLogDao: db.syncLogDao,
      syncClient: client,
    );

    when(() => client.pullRecords(any(),
            afterTimestamp: any(named: 'afterTimestamp')))
        .thenAnswer((_) async => <Map<String, dynamic>>[]);

    // Parent rows so the joins have something to reference.
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
    await repo.dispose();
    await db.close();
  });

  void stubTable(String table, List<Map<String, dynamic>> rows) {
    when(() => client.pullRecords(table,
        afterTimestamp: any(named: 'afterTimestamp'))).thenAnswer(
      (_) async => rows,
    );
  }

  test('pullChanges applies remote tag assignments locally', () async {
    stubTable('media_item_tags', [
      {
        'media_item_id': 'm1',
        'tag_id': 't1',
        'updated_at': 5000,
        'deleted': 0,
      },
    ]);

    await repo.pullChanges();

    expect(await db.tagsDao.getTagIdsForMediaItem('m1'), ['t1']);
  });

  test('pullChanges applies remote shelf memberships with position',
      () async {
    stubTable('shelf_items', [
      {
        'shelf_id': 's1',
        'media_item_id': 'm2',
        'position': 1,
        'updated_at': 5000,
        'deleted': 0,
      },
      {
        'shelf_id': 's1',
        'media_item_id': 'm1',
        'position': 0,
        'updated_at': 5000,
        'deleted': 0,
      },
    ]);

    await repo.pullChanges();

    expect(
        await db.shelvesDao.getMediaItemIdsForShelf('s1'), ['m1', 'm2']);
  });

  test('a remote tombstone soft-deletes the local assignment', () async {
    await db.tagsDao.assignToMediaItem('t1', 'm1', updatedAt: 1000);
    stubTable('media_item_tags', [
      {
        'media_item_id': 'm1',
        'tag_id': 't1',
        'updated_at': 5000,
        'deleted': 1,
      },
    ]);

    await repo.pullChanges();

    expect(await db.tagsDao.getTagIdsForMediaItem('m1'), isEmpty);
  });

  test('an older remote row does not clobber a newer local one', () async {
    await db.tagsDao.assignToMediaItem('t1', 'm1', updatedAt: 9000);
    stubTable('media_item_tags', [
      {
        'media_item_id': 'm1',
        'tag_id': 't1',
        'updated_at': 5000,
        'deleted': 1, // stale removal from a device that synced late
      },
    ]);

    await repo.pullChanges();

    expect(await db.tagsDao.getTagIdsForMediaItem('m1'), ['t1'],
        reason: 'LWW: local updated_at 9000 beats remote 5000');
  });
}
