import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/data/repositories/shelf_repository_impl.dart';
import 'package:mymediascanner/data/repositories/sync_repository_impl.dart';
import 'package:mymediascanner/data/repositories/tag_repository_impl.dart';
import 'package:mymediascanner/domain/entities/tag.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSyncClient extends Mock implements PostgresSyncClient {}

/// Cluster-7 HIGH-1b regression: `pullChanges` previously only fetched
/// `media_items`. Successfully pushed tag/shelf/borrower/loan/location/
/// series rows on one device never round-tripped to other devices. The
/// fix adds a last-write-wins pull for those tables. These tests pin
/// the upsert + LWW comparison behaviour without needing a live Postgres.
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

    // Default stubs — every table empty unless overridden.
    when(() => client.pullRecords(any(),
            afterTimestamp: any(named: 'afterTimestamp')))
        .thenAnswer((_) async => <Map<String, dynamic>>[]);
    when(() => client.fetchServerTimestampMillis())
        .thenAnswer((_) async => 999999);
  });

  tearDown(() async {
    await repo.dispose();
    await db.close();
  });

  test('pullChanges inserts new tag from remote', () async {
    when(() => client.pullRecords('tags',
        afterTimestamp: any(named: 'afterTimestamp'))).thenAnswer(
      (_) async => [
        {
          'id': 't-remote',
          'name': 'Remote',
          'colour': '#abcdef',
          'updated_at': 100,
          'deleted': 0,
        }
      ],
    );

    await repo.pullChanges();

    final row = await db.tagsDao.getById('t-remote');
    expect(row, isNotNull);
    expect(row!.name, 'Remote');
    expect(row.colour, '#abcdef');
    expect(row.updatedAt, 100);
  });

  test('pullChanges keeps newer local tag when remote is older', () async {
    // Local: updated_at=200
    await db.tagsDao.insertTag(TagsTableCompanion.insert(
      id: 't1',
      name: 'Local',
      colour: const Value('#111111'),
      updatedAt: 200,
    ));
    // Remote: updated_at=100 (older). Should not overwrite.
    when(() => client.pullRecords('tags',
        afterTimestamp: any(named: 'afterTimestamp'))).thenAnswer(
      (_) async => [
        {
          'id': 't1',
          'name': 'Remote',
          'colour': '#222222',
          'updated_at': 100,
          'deleted': 0,
        }
      ],
    );

    await repo.pullChanges();

    final row = await db.tagsDao.getById('t1');
    expect(row!.name, 'Local');
    expect(row.colour, '#111111');
  });

  test('pullChanges overwrites local tag when remote is newer', () async {
    await db.tagsDao.insertTag(TagsTableCompanion.insert(
      id: 't1',
      name: 'Local',
      colour: const Value('#111111'),
      updatedAt: 100,
    ));
    when(() => client.pullRecords('tags',
        afterTimestamp: any(named: 'afterTimestamp'))).thenAnswer(
      (_) async => [
        {
          'id': 't1',
          'name': 'Remote',
          'colour': '#222222',
          'updated_at': 200,
          'deleted': 0,
        }
      ],
    );

    await repo.pullChanges();

    final row = await db.tagsDao.getById('t1');
    expect(row!.name, 'Remote');
    expect(row.colour, '#222222');
  });

  test('pullChanges inserts shelf, borrower, loan, location, series',
      () async {
    when(() => client.pullRecords('shelves',
        afterTimestamp: any(named: 'afterTimestamp'))).thenAnswer(
      (_) async => [
        {
          'id': 's1',
          'name': 'Wishlist',
          'description': null,
          'sort_order': 0,
          'updated_at': 1,
          'deleted': 0,
        }
      ],
    );
    when(() => client.pullRecords('borrowers',
        afterTimestamp: any(named: 'afterTimestamp'))).thenAnswer(
      (_) async => [
        {
          'id': 'b1',
          'name': 'Alice',
          'email': null,
          'phone': null,
          'notes': null,
          'updated_at': 1,
          'deleted': 0,
        }
      ],
    );
    when(() => client.pullRecords('loans',
        afterTimestamp: any(named: 'afterTimestamp'))).thenAnswer(
      (_) async => [
        {
          'id': 'ln1',
          'media_item_id': 'm1',
          'borrower_id': 'b1',
          'lent_at': 1,
          'returned_at': null,
          'due_at': null,
          'notes': null,
          'updated_at': 1,
          'deleted': 0,
        }
      ],
    );
    when(() => client.pullRecords('locations',
        afterTimestamp: any(named: 'afterTimestamp'))).thenAnswer(
      (_) async => [
        {
          'id': 'l1',
          'parent_id': null,
          'name': 'Lounge',
          'sort_order': 0,
          'updated_at': 1,
          'deleted': 0,
        }
      ],
    );
    when(() => client.pullRecords('series',
        afterTimestamp: any(named: 'afterTimestamp'))).thenAnswer(
      (_) async => [
        {
          'id': 'sr1',
          'external_id': 'tmdb:1',
          'name': 'Foundation',
          'media_type': 'book',
          'source': 'manual',
          'total_count': null,
          'updated_at': 1,
          'deleted': 0,
        }
      ],
    );

    await repo.pullChanges();

    expect((await db.shelvesDao.getById('s1'))!.name, 'Wishlist');
    expect((await db.borrowersDao.getById('b1'))!.name, 'Alice');
    expect((await db.loansDao.getById('ln1'))!.borrowerId, 'b1');
    expect((await db.locationsDao.getById('l1'))!.name, 'Lounge');
    expect((await db.seriesDao.getById('sr1'))!.externalId, 'tmdb:1');
  });

  // #131: when pull accepts a newer remote row, any queued upload for
  // that entity carries the older local state. Pushing it afterwards
  // would overwrite the newer remote edit on the server.
  group('pull reconciles queued uploads (#131)', () {
    late TagRepositoryImpl tagRepo;

    setUp(() {
      tagRepo = TagRepositoryImpl(
        tagsDao: db.tagsDao,
        syncLogDao: db.syncLogDao,
      );
      when(() => client.upsertRecords(any(), any())).thenAnswer((_) async {});
    });

    List<Map<String, dynamic>> pushedTo(String table) {
      final calls = verify(() => client.upsertRecords(table, captureAny()));
      return calls.captured
          .cast<List<Map<String, dynamic>>>()
          .expand((batch) => batch)
          .toList();
    }

    test('a stale pending tag rename is not pushed over a newer remote one',
        () async {
      await tagRepo.save(
          const Tag(id: 't1', name: 'Local rename', updatedAt: 5000));
      final localUpdatedAt = (await db.tagsDao.getById('t1'))!.updatedAt;
      when(() => client.pullRecords('tags',
          afterTimestamp: any(named: 'afterTimestamp'))).thenAnswer(
        (_) async => [
          {
            'id': 't1',
            'name': 'Remote rename',
            'updated_at': localUpdatedAt + 1000,
            'deleted': 0,
          }
        ],
      );

      await repo.pullChanges();
      expect((await db.tagsDao.getById('t1'))!.name, 'Remote rename',
          reason: 'precondition: pull applies the newer remote row');

      await repo.pushChanges();

      verifyNever(() => client.upsertRecords('tags', any()));
    });

    test('a newer pending tag edit still pushes', () async {
      await tagRepo.save(
          const Tag(id: 't1', name: 'Local rename', updatedAt: 5000));
      final localUpdatedAt = (await db.tagsDao.getById('t1'))!.updatedAt;
      when(() => client.pullRecords('tags',
          afterTimestamp: any(named: 'afterTimestamp'))).thenAnswer(
        (_) async => [
          {
            'id': 't1',
            'name': 'Older remote',
            'updated_at': localUpdatedAt - 1000,
            'deleted': 0,
          }
        ],
      );

      await repo.pullChanges();
      await repo.pushChanges();

      expect(pushedTo('tags').map((r) => r['name']), ['Local rename']);
    });

    test('a stale pending tag assignment does not undo a newer remote removal',
        () async {
      await tagRepo.assignToMediaItem('t1', 'm1');
      final localUpdatedAt =
          (await db.tagsDao.assignmentUpdatedAt('m1', 't1'))!;
      when(() => client.pullRecords('media_item_tags',
          afterTimestamp: any(named: 'afterTimestamp'))).thenAnswer(
        (_) async => [
          {
            'media_item_id': 'm1',
            'tag_id': 't1',
            'updated_at': localUpdatedAt + 1000,
            'deleted': 1,
          }
        ],
      );

      await repo.pullChanges();
      await repo.pushChanges();

      verifyNever(() => client.upsertRecords('media_item_tags', any()));
    });

    test('a stale pending shelf membership does not undo a newer remote '
        'removal', () async {
      final shelfRepo = ShelfRepositoryImpl(
        shelvesDao: db.shelvesDao,
        syncLogDao: db.syncLogDao,
      );
      await shelfRepo.addItem('s1', 'm1', 0);
      final localUpdatedAt = (await db.shelvesDao.itemUpdatedAt('s1', 'm1'))!;
      when(() => client.pullRecords('shelf_items',
          afterTimestamp: any(named: 'afterTimestamp'))).thenAnswer(
        (_) async => [
          {
            'shelf_id': 's1',
            'media_item_id': 'm1',
            'position': 0,
            'updated_at': localUpdatedAt + 1000,
            'deleted': 1,
          }
        ],
      );

      await repo.pullChanges();
      await repo.pushChanges();

      verifyNever(() => client.upsertRecords('shelf_items', any()));
    });
  });
}
