import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/repositories/borrower_repository_impl.dart';
import 'package:mymediascanner/data/repositories/loan_repository_impl.dart';
import 'package:mymediascanner/data/repositories/location_repository_impl.dart';
import 'package:mymediascanner/data/repositories/series_repository_impl.dart';
import 'package:mymediascanner/data/repositories/shelf_repository_impl.dart';
import 'package:mymediascanner/data/repositories/tag_repository_impl.dart';
import 'package:mymediascanner/domain/entities/borrower.dart';
import 'package:mymediascanner/domain/entities/loan.dart';
import 'package:mymediascanner/domain/entities/location.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/shelf.dart';
import 'package:mymediascanner/domain/entities/tag.dart';

/// Cluster-4 HIGH-2 regression: every save/create/update path on the six
/// non-media-item repositories must enqueue a `sync_log` row so the
/// mutation replicates on the next push. Cluster-3 added delete-logging
/// only; insert/update were silent until this branch.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
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

  test('borrower.save (insert) enqueues an insert sync_log row', () async {
    final repo = BorrowerRepositoryImpl(
      borrowersDao: db.borrowersDao,
      syncLogDao: db.syncLogDao,
    );
    await repo.save(const Borrower(
      id: 'b1',
      name: 'Alice',
      email: null,
      phone: null,
      notes: null,
      updatedAt: 1,
    ));
    final logs = await logsFor('borrower', 'b1');
    expect(logs, hasLength(1));
    expect(logs.single.operation, 'insert');
    final payload =
        jsonDecode(logs.single.payloadJson) as Map<String, dynamic>;
    expect(payload['name'], 'Alice');
  });

  test('borrower.update enqueues an update sync_log row', () async {
    final repo = BorrowerRepositoryImpl(
      borrowersDao: db.borrowersDao,
      syncLogDao: db.syncLogDao,
    );
    await repo.save(const Borrower(
      id: 'b1',
      name: 'Alice',
      email: null,
      phone: null,
      notes: null,
      updatedAt: 1,
    ));
    await repo.update(const Borrower(
      id: 'b1',
      name: 'Alice Smith',
      email: 'a@example.com',
      phone: null,
      notes: null,
      updatedAt: 1,
    ));
    final logs = await logsFor('borrower', 'b1');
    expect(logs, hasLength(2));
    expect(logs.map((l) => l.operation).toList(), ['insert', 'update']);
  });

  test('shelf.save (insert) enqueues an insert sync_log row', () async {
    final repo = ShelfRepositoryImpl(
      shelvesDao: db.shelvesDao,
      syncLogDao: db.syncLogDao,
    );
    await repo.save(const Shelf(
      id: 's1',
      name: 'Wishlist',
      description: null,
      sortOrder: 0,
      updatedAt: 1,
    ));
    final logs = await logsFor('shelf', 's1');
    expect(logs.single.operation, 'insert');
  });

  test('shelf.save (update) enqueues an update sync_log row', () async {
    final repo = ShelfRepositoryImpl(
      shelvesDao: db.shelvesDao,
      syncLogDao: db.syncLogDao,
    );
    const initial = Shelf(
      id: 's1',
      name: 'Wishlist',
      description: null,
      sortOrder: 0,
      updatedAt: 1,
    );
    await repo.save(initial);
    await repo.save(initial.copyWith(name: 'Renamed'));
    final logs = await logsFor('shelf', 's1');
    expect(logs.map((l) => l.operation).toList(), ['insert', 'update']);
  });

  test('tag.save enqueues a sync_log row', () async {
    final repo = TagRepositoryImpl(
      tagsDao: db.tagsDao,
      syncLogDao: db.syncLogDao,
    );
    await repo.save(const Tag(
      id: 't1',
      name: 'fav',
      colour: '#ff0000',
      updatedAt: 1,
    ));
    final logs = await logsFor('tag', 't1');
    expect(logs.single.operation, 'insert');
  });

  test('location.create / update each enqueue a sync_log row', () async {
    final repo = LocationRepositoryImpl(
      dao: db.locationsDao,
      syncLogDao: db.syncLogDao,
    );
    await repo.create(const Location(
      id: 'l1',
      parentId: null,
      name: 'Lounge',
      sortOrder: 0,
      updatedAt: 1,
    ));
    await repo.update(const Location(
      id: 'l1',
      parentId: null,
      name: 'Living Room',
      sortOrder: 0,
      updatedAt: 2,
    ));
    final logs = await logsFor('location', 'l1');
    expect(logs.map((l) => l.operation).toList(), ['insert', 'update']);
  });

  test('series.upsert enqueues a sync_log row', () async {
    final repo = SeriesRepositoryImpl(
      dao: db.seriesDao,
      syncLogDao: db.syncLogDao,
    );
    final id = await repo.upsert(
      externalId: 'ext-1',
      name: 'Foundation',
      mediaType: MediaType.book,
      source: 'manual',
    );
    final logs = await logsFor('series', id);
    expect(logs.single.operation, 'insert');

    // Second upsert with same externalId should record an update.
    await repo.upsert(
      externalId: 'ext-1',
      name: 'Foundation (renamed)',
      mediaType: MediaType.book,
      source: 'manual',
    );
    final logs2 = await logsFor('series', id);
    expect(logs2.map((l) => l.operation).toList(), ['insert', 'update']);
  });

  test('loan.createLoan / updateLoan / returnItem enqueue sync_log rows',
      () async {
    final repo = LoanRepositoryImpl(
      loansDao: db.loansDao,
      syncLogDao: db.syncLogDao,
    );
    const loan = Loan(
      id: 'ln1',
      mediaItemId: 'm1',
      borrowerId: 'b1',
      lentAt: 1,
      updatedAt: 1,
    );
    await repo.createLoan(loan);
    await repo.updateLoan(loan.copyWith(notes: 'update', updatedAt: 2));
    await repo.returnItem('ln1');
    final logs = await logsFor('loan', 'ln1');
    expect(logs.map((l) => l.operation).toList(),
        ['insert', 'update', 'update']);
  });
}
