// Trash-flow tests for MediaItemRepositoryImpl.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/repositories/media_item_repository_impl.dart';

void main() {
  late AppDatabase db;
  late MediaItemRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = MediaItemRepositoryImpl(
      mediaItemsDao: db.mediaItemsDao,
      syncLogDao: db.syncLogDao,
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedItem({
    required String id,
    bool deleted = false,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.mediaItemsDao.insertItem(MediaItemsTableCompanion(
      id: Value(id),
      barcode: Value('b$id'),
      barcodeType: const Value('EAN-13'),
      mediaType: const Value('music'),
      title: Value('Item $id'),
      dateAdded: Value(now),
      dateScanned: Value(now),
      updatedAt: Value(now),
      deleted: Value(deleted ? 1 : 0),
    ));
  }

  test('watchDeleted emits only soft-deleted items', () async {
    await seedItem(id: 'live');
    await seedItem(id: 'gone', deleted: true);

    final items = await repo.watchDeleted().first;

    expect(items, hasLength(1));
    expect(items.single.id, 'gone');
  });

  test('restore flips deleted flag and writes an update sync-log entry',
      () async {
    await seedItem(id: 'a', deleted: true);

    await repo.restore('a');

    final row = await db.mediaItemsDao.getById('a');
    expect(row, isNotNull);
    expect(row!.deleted, 0);

    final logs = await db.syncLogDao.getPending();
    final restored = logs.where((l) => l.entityId == 'a').toList();
    expect(restored, isNotEmpty);
    expect(restored.last.operation, 'update');
  });

  test('hardDelete removes the row entirely', () async {
    await seedItem(id: 'wipe', deleted: true);

    await repo.hardDelete('wipe');

    final row = await db.mediaItemsDao.getById('wipe');
    expect(row, isNull);
  });

  test('watchDeleted reflects restore in real time', () async {
    await seedItem(id: 'restoreable', deleted: true);
    expect((await repo.watchDeleted().first), hasLength(1));

    await repo.restore('restoreable');

    expect((await repo.watchDeleted().first), isEmpty);
  });
}
