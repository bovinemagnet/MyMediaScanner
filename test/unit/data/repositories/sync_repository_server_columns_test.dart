import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/data/repositories/media_item_repository_impl.dart';
import 'package:mymediascanner/data/repositories/sync_repository_impl.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/sync_conflict.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class _MockSyncClient extends Mock implements PostgresSyncClient {}

/// Regression: remote `media_items` rows arrive via `SELECT *`, so they
/// carry server-managed columns the local schema doesn't have —
/// `created_at` (TIMESTAMPTZ, decoded by `package:postgres` as a Dart
/// `DateTime`) and `device_id`. `SyncStrategy.mergeFields` spread every
/// remote key into the merged map, and `jsonEncode(merged)` then threw
/// `JsonUnsupportedObjectError` — an `Error`, so it bypassed the
/// `on Exception` handlers and crashed the pull uncaught, leaving the
/// status stream stuck in `isSyncing`. Even when encoding succeeded, the
/// refreshed pending payload would push `device_id`/`created_at` back to
/// the server, clobbering attribution.
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
        title: 'Local Title',
        dateAdded: 1000,
        dateScanned: 1000,
        updatedAt: 1000,
      );

  /// Remote row as `pullRecords` actually delivers it: payload columns
  /// plus the server-managed `created_at` (a `DateTime`) and `device_id`.
  Map<String, dynamic> remoteRow(String id, {required int updatedAt}) => {
        'id': id,
        'title': 'Remote Title',
        'updated_at': updatedAt,
        'deleted': 0,
        'created_at': DateTime.utc(2026, 1, 1),
        'device_id': 'other-device',
      };

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

    when(() => client.pullRecords(any(),
            afterTimestamp: any(named: 'afterTimestamp')))
        .thenAnswer((_) async => <Map<String, dynamic>>[]);
    when(() => client.pullRecordsByIds(any(), any()))
        .thenAnswer((_) async => <Map<String, dynamic>>[]);
    when(() => client.fetchServerTimestampMillis())
        .thenAnswer((_) async => 999999);
  });

  tearDown(() async {
    await repo.dispose();
    await db.close();
  });

  test('pullChanges merges a remote update carrying server-managed columns',
      () async {
    await mediaRepo.save(baseItem('m1'));
    // updated_at far outside the 60 s conflict threshold → silent merge path.
    when(() => client.pullRecords('media_items',
            afterTimestamp: any(named: 'afterTimestamp')))
        .thenAnswer((_) async => [remoteRow('m1', updatedAt: 1000 + 61000)]);

    await repo.pullChanges();

    final row = await db.mediaItemsDao.getById('m1');
    expect(row!.title, 'Remote Title');

    // The refreshed pending push payload must stay valid JSON and must
    // not echo server-managed columns back to the server.
    final pending = await db.syncLogDao.getPending();
    final payloads = pending
        .where((e) => e.entityType == 'media_item' && e.entityId == 'm1')
        .map((e) => jsonDecode(e.payloadJson) as Map<String, dynamic>);
    expect(payloads, isNotEmpty,
        reason: 'precondition: save() must leave a pending push entry');
    for (final payload in payloads) {
      expect(payload.containsKey('created_at'), isFalse);
      expect(payload.containsKey('device_id'), isFalse);
    }
  });

  test('resolveConflicts merges a remote row carrying server-managed columns',
      () async {
    await mediaRepo.save(baseItem('m1'));
    // Within the threshold → surfaces as a conflict.
    when(() => client.pullRecords('media_items',
            afterTimestamp: any(named: 'afterTimestamp')))
        .thenAnswer((_) async => [remoteRow('m1', updatedAt: 2000)]);
    when(() => client.pullRecordsByIds('media_items', any()))
        .thenAnswer((_) async => [remoteRow('m1', updatedAt: 2000)]);

    await repo.pullChanges();
    final conflicts = await repo.getConflicts();
    expect(conflicts, isNotEmpty,
        reason: 'precondition: close-in-time edit must surface as conflict');

    final resolutions = conflicts
        .map((c) => c.copyWith(resolution: ConflictResolution.keepRemote))
        .toList();
    await repo.resolveConflicts(resolutions);

    final row = await db.mediaItemsDao.getById('m1');
    expect(row!.title, 'Remote Title');

    final pending = await db.syncLogDao.getPending();
    for (final entry in pending
        .where((e) => e.entityType == 'media_item' && e.entityId == 'm1')) {
      final payload = jsonDecode(entry.payloadJson) as Map<String, dynamic>;
      expect(payload.containsKey('created_at'), isFalse);
      expect(payload.containsKey('device_id'), isFalse);
    }
  });
}
