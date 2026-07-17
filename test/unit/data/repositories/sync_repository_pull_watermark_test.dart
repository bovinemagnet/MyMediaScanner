import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/data/repositories/sync_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSyncClient extends Mock implements PostgresSyncClient {}

/// Issue #102 regression: `pullChanges` reads every remote table
/// sequentially against the previous watermark, then used to store
/// `DateTime.now()` (the puller's own clock) as the NEW watermark once
/// every table had already been read. A remote row updated after its
/// table was read but before that final client-clock snapshot has an
/// `updated_at` older than the stored watermark, so a later pull
/// (`updated_at > watermark`) never fetches it again — permanently
/// skipped.
///
/// The fix captures a server-side boundary (`fetchServerTimestampMillis`)
/// BEFORE any table is read and stores THAT as the next watermark
/// instead. These tests pin the fixed behaviour without a live Postgres.
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

    when(() => client.pullRecords(any(),
            afterTimestamp: any(named: 'afterTimestamp')))
        .thenAnswer((_) async => <Map<String, dynamic>>[]);
  });

  tearDown(() async {
    await repo.dispose();
    await db.close();
  });

  test(
      'stores the pre-read server boundary as the watermark, not the '
      'post-read client clock', () async {
    // The server boundary captured before any table is read. Chosen far
    // below the real wall clock so it can't accidentally match
    // `DateTime.now()` and mask the regression.
    const serverBoundary = 5000;
    when(() => client.fetchServerTimestampMillis())
        .thenAnswer((_) async => serverBoundary);

    // Simulate a remote write landing on `media_items` AFTER that table
    // was already read in this pull cycle, but before the pull as a
    // whole finishes: `updated_at` = 6000, which is after the server
    // boundary (5000) but — under the old buggy behaviour — would be
    // masked by a watermark of `DateTime.now()` (always vastly larger
    // than these fake epoch values in a real run).
    const raceUpdatedAt = 6000;

    await repo.pullChanges();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('sync_last_synced_at'), serverBoundary,
        reason: 'watermark must be the pre-read server boundary, not '
            'DateTime.now() sampled after every table was read');

    // Next pull must use the stored boundary as its `afterTimestamp` and
    // therefore remain eligible to fetch the row that raced in.
    when(() => client.pullRecords('media_items',
        afterTimestamp: serverBoundary)).thenAnswer(
      (_) async => [
        {
          'id': 'm-race',
          'title': 'Raced In',
          'updated_at': raceUpdatedAt,
          'deleted': 0,
        }
      ],
    );
    when(() => client.fetchServerTimestampMillis())
        .thenAnswer((_) async => 7000);

    await repo.pullChanges();

    final row = await db.mediaItemsDao.getById('m-race');
    expect(row, isNotNull,
        reason: 'a write that raced the previous pull must remain '
            'eligible for the next pull, not be permanently skipped');
    expect(row!.title, 'Raced In');
  });

  test('fetchServerTimestampMillis is queried before any table read',
      () async {
    const serverBoundary = 1234;
    final callOrder = <String>[];
    when(() => client.fetchServerTimestampMillis()).thenAnswer((_) async {
      callOrder.add('boundary');
      return serverBoundary;
    });
    when(() => client.pullRecords(any(),
        afterTimestamp: any(named: 'afterTimestamp'))).thenAnswer((_) async {
      callOrder.add('read');
      return <Map<String, dynamic>>[];
    });

    await repo.pullChanges();

    expect(callOrder.first, 'boundary',
        reason: 'the server boundary must be captured before any table '
            'is read, otherwise the race window it is meant to close '
            'stays open');
  });
}
