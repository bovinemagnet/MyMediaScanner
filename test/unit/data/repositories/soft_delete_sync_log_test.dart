import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/repositories/borrower_repository_impl.dart';
import 'package:mymediascanner/data/repositories/location_repository_impl.dart';
import 'package:mymediascanner/data/repositories/media_item_repository_impl.dart';
import 'package:mymediascanner/data/repositories/series_repository_impl.dart';
import 'package:mymediascanner/data/repositories/shelf_repository_impl.dart';
import 'package:mymediascanner/data/repositories/tag_repository_impl.dart';
import 'package:mymediascanner/domain/entities/borrower.dart';
import 'package:mymediascanner/domain/entities/location.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/shelf.dart';
import 'package:mymediascanner/domain/entities/tag.dart';

/// Regression suite for cluster-3 HIGH-1: every non-media-item soft-delete
/// must enqueue a `sync_log` row so the deletion replicates on the next push.
/// Prior to the fix only `MediaItemRepositoryImpl` logged deletes; the other
/// five repositories silently retired rows locally and the remote stayed
/// unaware.
///
/// The delete payload must also be a FULL row snapshot, not just
/// {id, deleted, updated_at}: `PostgresSyncClient.buildBatchUpsertSql`
/// derives the INSERT column list from the payload keys, so a partial
/// delete payload that reaches Postgres before (or without) the original
/// insert creates a remote row whose other columns are all NULL.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> expectDeleteLogged({
    required String entityType,
    required String entityId,
    Map<String, dynamic> fields = const {},
  }) async {
    final pending = await db.syncLogDao.getPending();
    // Match the delete log specifically — cluster-4 added save/update
    // logging, so a save-then-softDelete sequence yields multiple entries
    // for the same (entityType, entityId) and the first one is the
    // pre-delete insert.
    final match = pending.firstWhere(
      (r) =>
          r.entityType == entityType &&
          r.entityId == entityId &&
          r.operation == 'delete',
      orElse: () => throw TestFailure(
          'No pending delete sync_log entry for $entityType/$entityId'),
    );
    final payload = jsonDecode(match.payloadJson) as Map<String, dynamic>;
    expect(payload['id'], entityId);
    expect(payload['deleted'], 1);
    expect(payload['updated_at'], isA<int>());
    // Full-snapshot fields: must be present so the remote upsert carries
    // every column rather than NULLing the row.
    fields.forEach((key, value) {
      expect(payload, containsPair(key, value),
          reason: 'delete payload for $entityType must carry "$key"');
    });
  }

  test('borrower softDelete enqueues a sync_log delete row', () async {
    final repo = BorrowerRepositoryImpl(
      borrowersDao: db.borrowersDao,
      syncLogDao: db.syncLogDao,
    );
    await repo.save(const Borrower(
      id: 'b1',
      name: 'Test',
      email: null,
      phone: null,
      notes: null,
      updatedAt: 1,
    ));
    await repo.softDelete('b1');
    await expectDeleteLogged(
      entityType: 'borrower',
      entityId: 'b1',
      fields: {'name': 'Test', 'email': null, 'phone': null, 'notes': null},
    );
  });

  test('shelf softDelete enqueues a sync_log delete row', () async {
    final repo = ShelfRepositoryImpl(
      shelvesDao: db.shelvesDao,
      syncLogDao: db.syncLogDao,
    );
    await repo.save(const Shelf(
      id: 's1',
      name: 'Test',
      description: null,
      sortOrder: 0,
      updatedAt: 1,
    ));
    await repo.softDelete('s1');
    await expectDeleteLogged(
      entityType: 'shelf',
      entityId: 's1',
      fields: {'name': 'Test', 'description': null, 'sort_order': 0},
    );
  });

  test('tag softDelete enqueues a sync_log delete row', () async {
    final repo = TagRepositoryImpl(
      tagsDao: db.tagsDao,
      syncLogDao: db.syncLogDao,
    );
    await repo.save(const Tag(
      id: 't1',
      name: 'Test',
      colour: null,
      updatedAt: 1,
    ));
    await repo.softDelete('t1');
    await expectDeleteLogged(
      entityType: 'tag',
      entityId: 't1',
      fields: {'name': 'Test', 'colour': null},
    );
  });

  test('location softDelete enqueues a sync_log delete row', () async {
    final repo = LocationRepositoryImpl(
      dao: db.locationsDao,
      syncLogDao: db.syncLogDao,
    );
    await repo.create(const Location(
      id: 'l1',
      parentId: null,
      name: 'Test',
      sortOrder: 0,
      updatedAt: 1,
    ));
    await repo.softDelete('l1');
    await expectDeleteLogged(
      entityType: 'location',
      entityId: 'l1',
      fields: {'name': 'Test', 'parent_id': null, 'sort_order': 0},
    );
  });

  test('series softDelete enqueues a sync_log delete row', () async {
    final repo = SeriesRepositoryImpl(
      dao: db.seriesDao,
      syncLogDao: db.syncLogDao,
    );
    final id = await repo.upsert(
      externalId: 'ext-1',
      name: 'Test',
      mediaType: MediaType.book,
      source: 'manual',
    );
    await repo.softDelete(id);
    await expectDeleteLogged(
      entityType: 'series',
      entityId: id,
      fields: {
        'external_id': 'ext-1',
        'name': 'Test',
        'media_type': 'book',
        'source': 'manual',
      },
    );
  });

  test('media item softDelete enqueues a FULL row snapshot delete payload',
      () async {
    final repo = MediaItemRepositoryImpl(
      mediaItemsDao: db.mediaItemsDao,
      syncLogDao: db.syncLogDao,
    );
    await repo.save(const MediaItem(
      id: 'm1',
      barcode: '5012345678900',
      barcodeType: 'ean13',
      mediaType: MediaType.film,
      title: 'Blade Runner',
      year: 1982,
      dateAdded: 1000,
      dateScanned: 1000,
      updatedAt: 1000,
    ));
    await repo.softDelete('m1');
    await expectDeleteLogged(
      entityType: 'media_item',
      entityId: 'm1',
      fields: {
        'barcode': '5012345678900',
        'barcode_type': 'ean13',
        'media_type': 'film',
        'title': 'Blade Runner',
        'year': 1982,
        'ownership_status': 'owned',
        'date_added': 1000,
        'date_scanned': 1000,
      },
    );
  });

  test('media item softDelete of a missing row enqueues no delete payload',
      () async {
    final repo = MediaItemRepositoryImpl(
      mediaItemsDao: db.mediaItemsDao,
      syncLogDao: db.syncLogDao,
    );
    await repo.softDelete('ghost');
    final pending = await db.syncLogDao.getPending();
    expect(pending.where((r) => r.entityId == 'ghost'), isEmpty,
        reason: 'a partial {id, deleted} payload would create a remote '
            'row with every other column NULL');
  });
}
