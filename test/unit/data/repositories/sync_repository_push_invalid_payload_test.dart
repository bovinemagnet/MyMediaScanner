import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/data/repositories/sync_repository_impl.dart';
import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSyncClient extends Mock implements PostgresSyncClient {}

/// Issue #105 regression: `pushChanges` decodes each pending entry's
/// `payloadJson` and used to silently `continue` when the JSON decoded to
/// something other than a `Map<String, dynamic>` (an array, a scalar, or
/// `null`). That left the entry not marked synced, without an
/// `errorMessage`, not counted in `firstFailure`, and retried forever with
/// no diagnostics — unlike malformed JSON (which throws and IS already
/// recorded by the `on Exception` handler).
///
/// The fix records the same errorMessage/attemptedAt/direction and
/// `firstFailure` bookkeeping as that existing exception handler.
void main() {
  late AppDatabase db;
  late _MockSyncClient client;
  late SyncRepositoryImpl repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    client = _MockSyncClient();
    repo = SyncRepositoryImpl(
      mediaItemsDao: db.mediaItemsDao,
      syncLogDao: db.syncLogDao,
      syncClient: client,
    );

    when(() => client.upsertRecords(any(), any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await repo.dispose();
    await db.close();
  });

  Future<void> insertLog(String id, String payloadJson) {
    return db.syncLogDao.insertLog(SyncLogTableCompanion.insert(
      id: id,
      entityType: 'tag',
      entityId: 'e-$id',
      operation: 'insert',
      payloadJson: payloadJson,
      createdAt: 1,
    ));
  }

  Future<SyncLogEntry> historyEntry(String id) async {
    final history = await repo.getSyncHistory();
    return history.firstWhere((e) => e.id == id);
  }

  void expectRecordedAsFailed(SyncLogEntry entry) {
    expect(entry.synced, isFalse,
        reason: 'an invalid payload must not be marked synced');
    expect(entry.errorMessage, isNotNull,
        reason: 'the failure must carry an actionable errorMessage');
    expect(entry.attemptedAt, isNotNull,
        reason: 'the attempt must be timestamped like other failures');
    expect(entry.direction, 'push',
        reason: 'direction must be recorded like other push failures');
  }

  test('an array payload is marked failed with diagnostics', () async {
    await insertLog('log-arr', jsonEncode([1, 2, 3]));

    await expectLater(repo.pushChanges(), throwsA(anything));

    expectRecordedAsFailed(await historyEntry('log-arr'));
  });

  test('a scalar payload is marked failed with diagnostics', () async {
    await insertLog('log-scalar', jsonEncode(42));

    await expectLater(repo.pushChanges(), throwsA(anything));

    expectRecordedAsFailed(await historyEntry('log-scalar'));
  });

  test('a null payload is marked failed with diagnostics', () async {
    await insertLog('log-null', jsonEncode(null));

    await expectLater(repo.pushChanges(), throwsA(anything));

    expectRecordedAsFailed(await historyEntry('log-null'));
  });

  test('a string-scalar payload is marked failed with diagnostics',
      () async {
    await insertLog('log-string', jsonEncode('just a string'));

    await expectLater(repo.pushChanges(), throwsA(anything));

    expectRecordedAsFailed(await historyEntry('log-string'));
  });

  test('remaining valid entries still push alongside an invalid one',
      () async {
    await insertLog('log-arr', jsonEncode([1, 2, 3]));
    await insertLog(
      'log-valid',
      jsonEncode({
        'id': 'e-log-valid',
        'name': 'fav',
        'colour': null,
        'updated_at': 1,
        'deleted': 0,
      }),
    );

    await expectLater(repo.pushChanges(), throwsA(anything));

    expectRecordedAsFailed(await historyEntry('log-arr'));
    final valid = await historyEntry('log-valid');
    expect(valid.synced, isTrue,
        reason: 'a valid entry must still push despite a sibling failure');
    verify(() => client.upsertRecords('tags', any())).called(1);
  });

  test('an invalid entry stays available for inspection/retry', () async {
    await insertLog('log-arr', jsonEncode([1, 2, 3]));

    await expectLater(repo.pushChanges(), throwsA(anything));

    final failed = await repo.getSyncHistory();
    final entry = failed.firstWhere((e) => e.id == 'log-arr');
    expect(entry.synced, isFalse,
        reason: 'not synced means it remains pending for retry');
  });
}
