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

class _MockSyncClient extends Mock implements PostgresSyncClient {}

/// Regressions around conflict handling in `SyncRepositoryImpl`:
///
/// 1. `pullChanges` previously only advanced `lastSyncedAt` when no
///    conflicts were pending, so a single unresolved conflict forced
///    every subsequent pull to re-download everything since the last
///    clean sync.
/// 2. `resolveConflicts` previously downloaded the entire remote
///    `media_items` table just to fetch the handful of conflicted rows.
///    It must use the targeted `pullRecordsByIds` instead.
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

  /// Remote row differing on `title`, with `updated_at` within the 60 s
  /// conflict threshold of the local row's, so it surfaces as a conflict.
  Map<String, dynamic> remoteRow(String id) => {
        'id': id,
        'title': 'Remote Title',
        'updated_at': 2000,
        'deleted': 0,
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

    // Default stubs — every table empty unless overridden.
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

  test('pullChanges advances lastSyncedAt even with pending conflicts',
      () async {
    await mediaRepo.save(baseItem('m1'));
    when(() => client.pullRecords('media_items',
            afterTimestamp: any(named: 'afterTimestamp')))
        .thenAnswer((_) async => [remoteRow('m1')]);

    await repo.pullChanges();

    final conflicts = await repo.getConflicts();
    expect(conflicts, isNotEmpty,
        reason: 'precondition: the edit must surface as a conflict');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('sync_last_synced_at'), isNotNull,
        reason: 'a pending conflict must not hold the watermark back');
  });

  test('unresolved conflicts survive a subsequent pull', () async {
    await mediaRepo.save(baseItem('m1'));
    when(() => client.pullRecords('media_items',
            afterTimestamp: any(named: 'afterTimestamp')))
        .thenAnswer((_) async => [remoteRow('m1')]);

    await repo.pullChanges();
    expect(await repo.getConflicts(), isNotEmpty,
        reason: 'precondition: the edit must surface as a conflict');

    // Next pull returns an empty delta (the watermark advanced past the
    // conflicted row). The still-unresolved conflict must not vanish.
    when(() => client.pullRecords('media_items',
            afterTimestamp: any(named: 'afterTimestamp')))
        .thenAnswer((_) async => <Map<String, dynamic>>[]);
    await repo.pullChanges();

    expect(await repo.getConflicts(), isNotEmpty,
        reason: 'an unresolved conflict must survive later pulls');
  });

  test('pushChanges holds back entities with pending conflicts', () async {
    await mediaRepo.save(baseItem('m1'));
    await mediaRepo.save(baseItem('m2'));
    when(() => client.pullRecords('media_items',
            afterTimestamp: any(named: 'afterTimestamp')))
        .thenAnswer((_) async => [remoteRow('m1')]);
    when(() => client.upsertRecords(any(), any())).thenAnswer((_) async {});

    await repo.pullChanges();
    expect(await repo.getConflicts(), isNotEmpty,
        reason: 'precondition: m1 must surface as a conflict');

    await repo.pushChanges();

    final pushed = verify(() => client.upsertRecords('media_items', captureAny()))
        .captured
        .cast<List<Map<String, dynamic>>>()
        .expand((batch) => batch)
        .map((r) => r['id'])
        .toList();
    expect(pushed, contains('m2'),
        reason: 'non-conflicted entities must still push');
    expect(pushed, isNot(contains('m1')),
        reason: 'a conflicted entity must not be pushed until resolved');
  });

  test('pushChanges reports pending conflicts in its status emission',
      () async {
    await mediaRepo.save(baseItem('m1'));
    when(() => client.pullRecords('media_items',
            afterTimestamp: any(named: 'afterTimestamp')))
        .thenAnswer((_) async => [remoteRow('m1')]);
    when(() => client.upsertRecords(any(), any())).thenAnswer((_) async {});

    await repo.pullChanges();
    expect(await repo.getConflicts(), isNotEmpty);

    final statuses = <int>[];
    final sub = repo
        .watchSyncStatus()
        .listen((status) => statuses.add(status.conflictCount));
    await repo.pushChanges();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(statuses.last, greaterThan(0),
        reason: 'push runs after pull in a sync cycle; its final status '
            'emission must not hide still-pending conflicts');
  });

  test('resolveConflicts pulls only the conflicted ids, not the full table',
      () async {
    await mediaRepo.save(baseItem('m1'));
    when(() => client.pullRecords('media_items',
            afterTimestamp: any(named: 'afterTimestamp')))
        .thenAnswer((_) async => [remoteRow('m1')]);
    when(() => client.pullRecordsByIds('media_items', any()))
        .thenAnswer((_) async => [remoteRow('m1')]);

    await repo.pullChanges();
    final conflicts = await repo.getConflicts();
    expect(conflicts, isNotEmpty);

    final resolutions = conflicts
        .map((c) => c.copyWith(resolution: ConflictResolution.keepRemote))
        .toList();
    await repo.resolveConflicts(resolutions);

    verify(() => client.pullRecordsByIds('media_items', ['m1'])).called(1);
    // Exactly one media_items pull overall — the incremental one inside
    // pullChanges. Resolution itself must not pull the whole table.
    verify(() => client.pullRecords('media_items',
        afterTimestamp: any(named: 'afterTimestamp'))).called(1);

    final row = await db.mediaItemsDao.getById('m1');
    expect(row!.title, 'Remote Title');
    expect(await repo.getConflicts(), isEmpty);
  });
}
