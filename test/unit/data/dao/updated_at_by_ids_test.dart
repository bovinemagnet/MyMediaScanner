import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';

/// Bulk `updated_at` lookups added so `SyncRepositoryImpl._pullLastWriteWins`
/// can compare remote rows against local state with one query per entity
/// type instead of one `getById` per remote row (the N+1 it replaced).
/// `markSyncedAll` similarly replaces the per-row `markSynced` loop in
/// `pushChanges`.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('tagsDao.updatedAtByIds returns a map for known ids only', () async {
    await db.tagsDao.insertTag(TagsTableCompanion.insert(
      id: 't1',
      name: 'one',
      updatedAt: 100,
    ));
    await db.tagsDao.insertTag(TagsTableCompanion.insert(
      id: 't2',
      name: 'two',
      updatedAt: 200,
    ));

    final map = await db.tagsDao.updatedAtByIds(['t1', 't2', 'missing']);

    expect(map, {'t1': 100, 't2': 200});
  });

  test('updatedAtByIds returns an empty map for an empty id list', () async {
    expect(await db.tagsDao.updatedAtByIds([]), isEmpty);
    expect(await db.shelvesDao.updatedAtByIds([]), isEmpty);
    expect(await db.borrowersDao.updatedAtByIds([]), isEmpty);
    expect(await db.loansDao.updatedAtByIds([]), isEmpty);
    expect(await db.locationsDao.updatedAtByIds([]), isEmpty);
    expect(await db.seriesDao.updatedAtByIds([]), isEmpty);
  });

  test('each simple-entity DAO resolves updated_at by id', () async {
    await db.shelvesDao.insertShelf(ShelvesTableCompanion.insert(
      id: 's1',
      name: 'shelf',
      updatedAt: 11,
    ));
    await db.borrowersDao.insertBorrower(BorrowersTableCompanion.insert(
      id: 'b1',
      name: 'alice',
      updatedAt: 22,
    ));
    await db.loansDao.insertLoan(LoansTableCompanion.insert(
      id: 'ln1',
      mediaItemId: 'm1',
      borrowerId: 'b1',
      lentAt: 1,
      updatedAt: 33,
    ));
    await db.locationsDao.insertLocation(LocationsTableCompanion.insert(
      id: 'l1',
      name: 'lounge',
      updatedAt: 44,
    ));
    await db.seriesDao.upsert(SeriesTableCompanion.insert(
      id: 'sr1',
      externalId: 'ext-1',
      name: 'series',
      mediaType: 'book',
      source: 'manual',
      updatedAt: 55,
    ));

    expect(await db.shelvesDao.updatedAtByIds(['s1']), {'s1': 11});
    expect(await db.borrowersDao.updatedAtByIds(['b1']), {'b1': 22});
    expect(await db.loansDao.updatedAtByIds(['ln1']), {'ln1': 33});
    expect(await db.locationsDao.updatedAtByIds(['l1']), {'l1': 44});
    expect(await db.seriesDao.updatedAtByIds(['sr1']), {'sr1': 55});
  });

  test('mediaItemsDao.markSyncedAll stamps only the given ids', () async {
    MediaItemsTableCompanion item(String id) => MediaItemsTableCompanion(
          id: Value(id),
          barcode: Value('bc-$id'),
          barcodeType: const Value('ean13'),
          mediaType: const Value('book'),
          title: Value('Title $id'),
          genres: const Value('[]'),
          extraMetadata: const Value('{}'),
          sourceApis: const Value('[]'),
          ownershipStatus: const Value('owned'),
          dateAdded: const Value(1),
          dateScanned: const Value(1),
          updatedAt: const Value(1),
        );
    await db.mediaItemsDao.insertItem(item('a'));
    await db.mediaItemsDao.insertItem(item('b'));
    await db.mediaItemsDao.insertItem(item('c'));

    await db.mediaItemsDao.markSyncedAll(['a', 'b'], 999);

    expect((await db.mediaItemsDao.getById('a'))!.syncedAt, 999);
    expect((await db.mediaItemsDao.getById('b'))!.syncedAt, 999);
    expect((await db.mediaItemsDao.getById('c'))!.syncedAt, isNull);
  });

  test('markSyncedAll with an empty list is a no-op', () async {
    await db.mediaItemsDao.markSyncedAll([], 999);
  });
}
