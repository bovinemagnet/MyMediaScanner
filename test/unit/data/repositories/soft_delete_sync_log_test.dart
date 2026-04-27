import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/repositories/borrower_repository_impl.dart';
import 'package:mymediascanner/data/repositories/location_repository_impl.dart';
import 'package:mymediascanner/data/repositories/series_repository_impl.dart';
import 'package:mymediascanner/data/repositories/shelf_repository_impl.dart';
import 'package:mymediascanner/data/repositories/tag_repository_impl.dart';
import 'package:mymediascanner/domain/entities/borrower.dart';
import 'package:mymediascanner/domain/entities/location.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/shelf.dart';
import 'package:mymediascanner/domain/entities/tag.dart';

/// Regression suite for cluster-3 HIGH-1: every non-media-item soft-delete
/// must enqueue a `sync_log` row so the deletion replicates on the next push.
/// Prior to the fix only `MediaItemRepositoryImpl` logged deletes; the other
/// five repositories silently retired rows locally and the remote stayed
/// unaware.
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
  }) async {
    final pending = await db.syncLogDao.getPending();
    final match = pending.firstWhere(
      (r) => r.entityType == entityType && r.entityId == entityId,
      orElse: () => throw TestFailure(
          'No pending sync_log entry for $entityType/$entityId'),
    );
    expect(match.operation, 'delete');
    final payload = jsonDecode(match.payloadJson) as Map<String, dynamic>;
    expect(payload['id'], entityId);
    expect(payload['deleted'], 1);
    expect(payload['updated_at'], isA<int>());
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
    await expectDeleteLogged(entityType: 'borrower', entityId: 'b1');
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
    await expectDeleteLogged(entityType: 'shelf', entityId: 's1');
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
    await expectDeleteLogged(entityType: 'tag', entityId: 't1');
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
    await expectDeleteLogged(entityType: 'location', entityId: 'l1');
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
    await expectDeleteLogged(entityType: 'series', entityId: id);
  });
}
