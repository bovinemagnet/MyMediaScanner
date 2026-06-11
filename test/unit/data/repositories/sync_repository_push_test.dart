import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/data/repositories/media_item_repository_impl.dart';
import 'package:mymediascanner/data/repositories/sync_repository_impl.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSyncClient extends Mock implements PostgresSyncClient {}

/// Regression: `pushChanges` previously collected every pushed
/// `sync_log.entity_id` regardless of entity type and stamped
/// `media_items.synced_at` for each. A tag/shelf/etc. log entry whose id
/// happened to collide with a media item id would stamp an unpushed media
/// item as synced. Only `media_items` carries a `synced_at` column, so
/// only `media_item` log entries may drive the stamping.
void main() {
  late AppDatabase db;
  late _MockSyncClient client;
  late SyncRepositoryImpl repo;
  late MediaItemRepositoryImpl mediaRepo;

  MediaItem baseItem(String id) => MediaItem(
        id: id,
        barcode: 'bc-$id',
        barcodeType: 'ean13',
        mediaType: MediaType.book,
        title: 'Title $id',
        dateAdded: 1000,
        dateScanned: 1000,
        updatedAt: 1000,
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    client = _MockSyncClient();
    repo = SyncRepositoryImpl(
      mediaItemsDao: db.mediaItemsDao,
      syncLogDao: db.syncLogDao,
      syncClient: client,
    );
    mediaRepo = MediaItemRepositoryImpl(
      mediaItemsDao: db.mediaItemsDao,
      syncLogDao: db.syncLogDao,
    );

    when(() => client.upsertRecords(any(), any()))
        .thenAnswer((_) async {});
  });

  tearDown(() async {
    await repo.dispose();
    await db.close();
  });

  test('pushChanges stamps synced_at only on pushed media_item rows',
      () async {
    // Two local media items, neither synced yet. Only m1 has a pending
    // media_item log entry; a tag log entry deliberately reuses the id
    // "m2" to prove the entity-type check.
    await mediaRepo.save(baseItem('m1'));
    await db.mediaItemsDao
        .insertItem(_plainCompanion('m2', title: 'Unpushed'));

    await db.syncLogDao.insertLog(SyncLogTableCompanion.insert(
      id: 'log-tag',
      entityType: 'tag',
      entityId: 'm2', // collides with media item id on purpose
      operation: 'insert',
      payloadJson: jsonEncode({
        'id': 'm2',
        'name': 'fav',
        'colour': null,
        'updated_at': 1,
        'deleted': 0,
      }),
      createdAt: 1,
    ));

    await repo.pushChanges();

    final m1 = await db.mediaItemsDao.getById('m1');
    final m2 = await db.mediaItemsDao.getById('m2');
    expect(m1!.syncedAt, isNotNull,
        reason: 'pushed media_item must be stamped');
    expect(m2!.syncedAt, isNull,
        reason: 'tag log entry must not stamp a media_items row');
  });

  test('pushChanges stamps multiple pushed media_item rows', () async {
    await mediaRepo.save(baseItem('a'));
    await mediaRepo.save(baseItem('b'));

    await repo.pushChanges();

    expect((await db.mediaItemsDao.getById('a'))!.syncedAt, isNotNull);
    expect((await db.mediaItemsDao.getById('b'))!.syncedAt, isNotNull);
  });
}

MediaItemsTableCompanion _plainCompanion(String id, {required String title}) {
  return MediaItemsTableCompanion(
    id: Value(id),
    barcode: Value('bc-$id'),
    barcodeType: const Value('ean13'),
    mediaType: const Value('book'),
    title: Value(title),
    genres: const Value('[]'),
    extraMetadata: const Value('{}'),
    sourceApis: const Value('[]'),
    ownershipStatus: const Value('owned'),
    dateAdded: const Value(1000),
    dateScanned: const Value(1000),
    updatedAt: const Value(1000),
  );
}
