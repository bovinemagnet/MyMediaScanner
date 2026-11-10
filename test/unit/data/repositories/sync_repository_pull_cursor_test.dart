import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/data/repositories/sync_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSyncClient extends Mock implements PostgresSyncClient {}

/// #131 finding 1: incremental pulls filtered on `updated_at`, the
/// client's edit time, so an edit made offline and uploaded after
/// another device had pulled kept an old `updated_at` and was never
/// fetched. Pulls now use a server-assigned transaction-id cursor
/// (migration 008); `updated_at` is only the last-write-wins basis.
/// The live behaviour is covered by postgres_change_cursor_live_test.
void main() {
  late AppDatabase db;
  late _MockSyncClient client;
  late SyncRepositoryImpl repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    client = _MockSyncClient();
    repo = SyncRepositoryImpl(
      mediaItemsDao: db.mediaItemsDao,
      syncLogDao: db.syncLogDao,
      syncClient: client,
    );
    when(() => client.pullRecords(any(), sinceTxid: any(named: 'sinceTxid')))
        .thenAnswer((_) async => <Map<String, dynamic>>[]);
  });

  tearDown(() async {
    await repo.dispose();
    await db.close();
  });

  test('the first pull fetches everything and stores the horizon', () async {
    when(() => client.fetchPullHorizon()).thenAnswer((_) async => 700);

    await repo.pullChanges();

    verify(() => client.pullRecords('media_items', sinceTxid: null))
        .called(1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('sync_pull_cursor_txid'), 700);
  });

  test('the next pull reads from the stored horizon, so a late upload '
      'with an old updated_at is still fetched', () async {
    when(() => client.fetchPullHorizon()).thenAnswer((_) async => 700);
    await repo.pullChanges();

    // Another device's offline edit (updated_at long in the past)
    // committed after the previous pull's horizon was taken.
    when(() => client.fetchPullHorizon()).thenAnswer((_) async => 900);
    when(() => client.pullRecords('media_items', sinceTxid: 700)).thenAnswer(
      (_) async => [
        {'id': 'late', 'title': 'Offline edit', 'updated_at': 1, 'deleted': 0},
      ],
    );

    await repo.pullChanges();

    expect((await db.mediaItemsDao.getById('late'))?.title, 'Offline edit');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('sync_pull_cursor_txid'), 900);
  });

  test('the horizon is read before any table', () async {
    final callOrder = <String>[];
    when(() => client.fetchPullHorizon()).thenAnswer((_) async {
      callOrder.add('horizon');
      return 1;
    });
    when(() => client.pullRecords(any(), sinceTxid: any(named: 'sinceTxid')))
        .thenAnswer((_) async {
      callOrder.add('read');
      return <Map<String, dynamic>>[];
    });

    await repo.pullChanges();

    expect(callOrder.first, 'horizon',
        reason: 'a transaction still running when a table is read must '
            'be at or above the stored horizon');
  });

  test('a legacy updated_at watermark is not used as the cursor', () async {
    SharedPreferences.setMockInitialValues({'sync_last_synced_at': 123456});
    when(() => client.fetchPullHorizon()).thenAnswer((_) async => 5);

    await repo.pullChanges();

    verify(() => client.pullRecords('media_items', sinceTxid: null))
        .called(1);
  });

  test('a failed pull leaves the cursor where it was', () async {
    when(() => client.fetchPullHorizon()).thenAnswer((_) async => 700);
    await repo.pullChanges();

    when(() => client.fetchPullHorizon()).thenAnswer((_) async => 900);
    when(() => client.pullRecords('tags', sinceTxid: any(named: 'sinceTxid')))
        .thenThrow(Exception('network'));

    await expectLater(repo.pullChanges(), throwsException);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('sync_pull_cursor_txid'), 700);
  });
}
