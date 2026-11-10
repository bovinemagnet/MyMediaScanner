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
            sinceTxid: any(named: 'sinceTxid')))
        .thenAnswer((_) async => <Map<String, dynamic>>[]);
    when(() => client.pullRecordsByIds(any(), any()))
        .thenAnswer((_) async => <Map<String, dynamic>>[]);
    when(() => client.fetchPullHorizon())
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
            sinceTxid: any(named: 'sinceTxid')))
        .thenAnswer((_) async => [remoteRow('m1')]);

    await repo.pullChanges();

    final conflicts = await repo.getConflicts();
    expect(conflicts, isNotEmpty,
        reason: 'precondition: the edit must surface as a conflict');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('sync_pull_cursor_txid'), isNotNull,
        reason: 'a pending conflict must not hold the watermark back');
  });

  test('unresolved conflicts survive a subsequent pull', () async {
    await mediaRepo.save(baseItem('m1'));
    when(() => client.pullRecords('media_items',
            sinceTxid: any(named: 'sinceTxid')))
        .thenAnswer((_) async => [remoteRow('m1')]);

    await repo.pullChanges();
    expect(await repo.getConflicts(), isNotEmpty,
        reason: 'precondition: the edit must surface as a conflict');

    // Next pull returns an empty delta (the watermark advanced past the
    // conflicted row). The still-unresolved conflict must not vanish.
    when(() => client.pullRecords('media_items',
            sinceTxid: any(named: 'sinceTxid')))
        .thenAnswer((_) async => <Map<String, dynamic>>[]);
    await repo.pullChanges();

    expect(await repo.getConflicts(), isNotEmpty,
        reason: 'an unresolved conflict must survive later pulls');
  });

  test('pushChanges holds back entities with pending conflicts', () async {
    await mediaRepo.save(baseItem('m1'));
    await mediaRepo.save(baseItem('m2'));
    when(() => client.pullRecords('media_items',
            sinceTxid: any(named: 'sinceTxid')))
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
            sinceTxid: any(named: 'sinceTxid')))
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
            sinceTxid: any(named: 'sinceTxid')))
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
        sinceTxid: any(named: 'sinceTxid'))).called(1);

    final row = await db.mediaItemsDao.getById('m1');
    expect(row!.title, 'Remote Title');
    expect(await repo.getConflicts(), isEmpty);
  });

  test('resolveConflicts does not advance the global pull cursor (#131)',
      () async {
    await mediaRepo.save(baseItem('m1'));
    when(() => client.pullRecords('media_items',
            sinceTxid: any(named: 'sinceTxid')))
        .thenAnswer((_) async => [remoteRow('m1')]);
    when(() => client.pullRecordsByIds('media_items', any()))
        .thenAnswer((_) async => [remoteRow('m1')]);

    await repo.pullChanges();
    final prefs = await SharedPreferences.getInstance();
    final cursorAfterPull = prefs.getInt('sync_pull_cursor_txid');
    expect(cursorAfterPull, 999999,
        reason: 'precondition: pull stores the server boundary');

    final conflicts = await repo.getConflicts();
    await repo.resolveConflicts(conflicts
        .map((c) => c.copyWith(resolution: ConflictResolution.keepRemote))
        .toList());

    // Resolution only fetched the conflicted ids; unrelated remote
    // changes since the last pull have not been downloaded, so moving
    // the cursor here would skip them permanently.
    expect(prefs.getInt('sync_pull_cursor_txid'), cursorAfterPull);
  });

  test('clearSyncHistory keeps unsent changes queued (#131)', () async {
    await mediaRepo.save(baseItem('m1'));
    expect(await db.syncLogDao.getPending(), isNotEmpty,
        reason: 'precondition: saving queues a pending upload');

    await repo.clearSyncHistory();

    final pending = await db.syncLogDao.getPending();
    expect(pending.map((l) => l.entityId), contains('m1'),
        reason: 'clearing history must not discard operational work');
  });

  test('clearSyncHistory removes completed history (#131)', () async {
    await mediaRepo.save(baseItem('m1'));
    when(() => client.upsertRecords(any(), any())).thenAnswer((_) async {});
    await repo.pushChanges();
    expect(await repo.getSyncHistory(), isNotEmpty,
        reason: 'precondition: the push left a completed history entry');

    await repo.clearSyncHistory();

    expect(await repo.getSyncHistory(), isEmpty);
  });

  // #131 finding 3: conflicts lived only in memory while the pull cursor
  // moved past them, so a restart lost them and unblocked a push that
  // would overwrite the other device's edit.
  group('conflicts survive a restart (#131)', () {
    SyncRepositoryImpl restart() => SyncRepositoryImpl(
          mediaItemsDao: db.mediaItemsDao,
          syncLogDao: db.syncLogDao,
          syncClient: client,
        );

    test('unresolved conflicts are still listed after a restart', () async {
      await mediaRepo.save(baseItem('m1'));
      when(() => client.pullRecords('media_items',
              sinceTxid: any(named: 'sinceTxid')))
          .thenAnswer((_) async => [remoteRow('m1')]);
      await repo.pullChanges();
      final before = await repo.getConflicts();
      expect(before, isNotEmpty);
      await repo.dispose();

      repo = restart();

      final after = await repo.getConflicts();
      expect(after.map((c) => (c.entityId, c.fieldName)),
          before.map((c) => (c.entityId, c.fieldName)));
      final title = after.singleWhere((c) => c.fieldName == 'title');
      expect(title.localValue, 'Local Title');
      expect(title.remoteValue, 'Remote Title');
    });

    test('a conflicted item stays held back from push after a restart',
        () async {
      await mediaRepo.save(baseItem('m1'));
      when(() => client.pullRecords('media_items',
              sinceTxid: any(named: 'sinceTxid')))
          .thenAnswer((_) async => [remoteRow('m1')]);
      when(() => client.upsertRecords(any(), any())).thenAnswer((_) async {});
      await repo.pullChanges();
      await repo.dispose();

      repo = restart();
      await repo.pushChanges();

      verifyNever(() => client.upsertRecords('media_items', any()));
    });

    test('resolving a conflict removes it for good', () async {
      await mediaRepo.save(baseItem('m1'));
      when(() => client.pullRecords('media_items',
              sinceTxid: any(named: 'sinceTxid')))
          .thenAnswer((_) async => [remoteRow('m1')]);
      when(() => client.pullRecordsByIds('media_items', any()))
          .thenAnswer((_) async => [remoteRow('m1')]);
      await repo.pullChanges();
      await repo.resolveConflicts((await repo.getConflicts())
          .map((c) => c.copyWith(resolution: ConflictResolution.keepRemote))
          .toList());
      await repo.dispose();

      repo = restart();

      expect(await repo.getConflicts(), isEmpty);
    });

    test('the status stream reports persisted conflicts after a restart',
        () async {
      await mediaRepo.save(baseItem('m1'));
      when(() => client.pullRecords('media_items',
              sinceTxid: any(named: 'sinceTxid')))
          .thenAnswer((_) async => [remoteRow('m1')]);
      await repo.pullChanges();
      final count = (await repo.getConflicts()).length;
      await repo.dispose();

      repo = restart();

      expect((await repo.watchSyncStatus().first).conflictCount, count);
    });
  });
}

