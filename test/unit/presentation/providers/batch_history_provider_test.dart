import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/presentation/providers/batch_history_provider.dart';
import 'package:mymediascanner/presentation/providers/database_provider.dart';

void main() {
  late AppDatabase testDb;

  setUp(() {
    testDb = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await testDb.close();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(testDb),
        batchSessionDaoProvider.overrideWithValue(testDb.batchSessionDao),
      ],
    );
  }

  Future<List<BatchSessionSummary>> readHistory(
      ProviderContainer container) async {
    for (var i = 0; i < 50; i++) {
      final asyncVal = container.read(batchHistoryProvider);
      if (asyncVal.hasValue) return asyncVal.requireValue;
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    fail('Provider did not resolve');
  }

  test('empty history returns empty list', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final history = await readHistory(container);
    expect(history, isEmpty);
  });

  test('completed sessions appear in history', () async {
    // Seed the database with completed sessions.
    final dao = testDb.batchSessionDao;
    await dao.createSession('session-1');
    await dao.completeSession('session-1', status: 'completed');
    await dao.createSession('session-2');
    await dao.completeSession('session-2', status: 'discarded');

    final container = createContainer();
    addTearDown(container.dispose);

    final history = await readHistory(container);
    expect(history.length, 2);
    // Most recent first.
    expect(history[0].id, 'session-2');
    expect(history[0].status, 'discarded');
    expect(history[1].id, 'session-1');
    expect(history[1].status, 'completed');
  });

  test('active sessions do not appear in history', () async {
    final dao = testDb.batchSessionDao;
    await dao.createSession('active-session');
    await dao.createSession('completed-session');
    await dao.completeSession('completed-session', status: 'completed');

    final container = createContainer();
    addTearDown(container.dispose);

    final history = await readHistory(container);
    expect(history.length, 1);
    expect(history[0].id, 'completed-session');
  });
}
