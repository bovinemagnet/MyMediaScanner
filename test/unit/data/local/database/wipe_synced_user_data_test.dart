import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';

/// Cluster-7 HIGH-3 regression: `resetLocalDatabase` previously called
/// `mediaItemsDao.deleteAll() + syncLogDao.deleteAll()` only, leaving
/// every other synced table (shelves, tags, joins, borrowers, loans,
/// locations, series) populated with stale rows. After the fix, the
/// reset routes through `wipeSyncedUserData` which clears all of them
/// in one transaction.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedAll() async {
    // media_items
    await db.mediaItemsDao.insertItem(MediaItemsTableCompanion.insert(
      id: 'm1',
      barcode: 'bc',
      barcodeType: 'ean13',
      mediaType: 'film',
      title: 'Neuromancer',
      ownershipStatus: const Value('owned'),
      consumed: const Value(0),
      dateAdded: 1,
      dateScanned: 1,
      updatedAt: 1,
      deleted: const Value(0),
    ));
    // tags + media_item_tags
    await db.tagsDao.insertTag(TagsTableCompanion.insert(
      id: 't1',
      name: 'Sci-Fi',
      updatedAt: 1,
    ));
    await db.tagsDao.assignToMediaItem('t1', 'm1');
    // shelves + shelf_items
    await db.shelvesDao.insertShelf(ShelvesTableCompanion.insert(
      id: 's1',
      name: 'Wishlist',
      updatedAt: 1,
    ));
    await db.shelvesDao.addItem('s1', 'm1', 0);
    // borrowers + loans
    await db.borrowersDao.insertBorrower(BorrowersTableCompanion.insert(
      id: 'b1',
      name: 'Alice',
      updatedAt: 1,
    ));
    await db.loansDao.insertLoan(LoansTableCompanion.insert(
      id: 'ln1',
      mediaItemId: 'm1',
      borrowerId: 'b1',
      lentAt: 1,
      updatedAt: 1,
    ));
    // locations
    await db.locationsDao.insertLocation(LocationsTableCompanion.insert(
      id: 'l1',
      name: 'Lounge',
      updatedAt: 1,
    ));
    // series
    await db.seriesDao.upsert(SeriesTableCompanion.insert(
      id: 'sr1',
      externalId: 'tmdb:1',
      name: 'Foundation',
      mediaType: 'book',
      source: 'manual',
      updatedAt: 1,
    ));
    // sync_log
    await db.syncLogDao.insertLog(SyncLogTableCompanion.insert(
      id: 'log1',
      entityType: 'media_item',
      entityId: 'm1',
      operation: 'insert',
      payloadJson: '{}',
      createdAt: 1,
    ));
  }

  Future<int> count(String table) async {
    final rows = await db
        .customSelect('SELECT COUNT(*) AS c FROM $table')
        .get();
    return rows.first.data['c'] as int;
  }

  test('seed populates every relevant table', () async {
    await seedAll();
    expect(await count('media_items'), 1);
    expect(await count('tags'), 1);
    expect(await count('media_item_tags'), 1);
    expect(await count('shelves'), 1);
    expect(await count('shelf_items'), 1);
    expect(await count('borrowers'), 1);
    expect(await count('loans'), 1);
    expect(await count('locations'), 1);
    expect(await count('series'), 1);
    expect(await count('sync_log'), 1);
  });

  test('wipeSyncedUserData clears every synced table', () async {
    await seedAll();
    await db.wipeSyncedUserData();
    expect(await count('media_items'), 0);
    expect(await count('tags'), 0);
    expect(await count('media_item_tags'), 0);
    expect(await count('shelves'), 0);
    expect(await count('shelf_items'), 0);
    expect(await count('borrowers'), 0);
    expect(await count('loans'), 0);
    expect(await count('locations'), 0);
    expect(await count('series'), 0);
    expect(await count('sync_log'), 0);
  });

  test('wipeSyncedUserData leaves non-synced tables alone', () async {
    // Seed a barcode_cache row — strictly local, must survive a reset.
    await db.customStatement(
      'INSERT INTO barcode_cache (barcode, response_json, source_api, '
      "cached_at) VALUES ('999', '{}', 'tmdb', 1)",
    );
    await db.wipeSyncedUserData();
    expect(await count('barcode_cache'), 1);
  });
}
