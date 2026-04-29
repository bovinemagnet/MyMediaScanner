import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/retry_push_usecase.dart';

class _MockRepo extends Mock implements ITmdbAccountSyncRepository {}

void main() {
  late _MockRepo repo;
  late List<int> startedTotals;
  late int advanceCount;
  late int finishCount;
  late RetryPushUseCase uc;

  setUp(() {
    repo = _MockRepo();
    startedTotals = [];
    advanceCount = 0;
    finishCount = 0;
    uc = RetryPushUseCase(
      repo: repo,
      startProgress: (n) => startedTotals.add(n),
      advanceProgress: () => advanceCount++,
      finishProgress: () => finishCount++,
    );
  });

  TmdbBridgeKey key(int id) =>
      TmdbBridgeKey(tmdbId: id, mediaType: 'movie');

  test('retry empty list returns idle summary, no progress', () async {
    final summary = await uc.retry(const []);
    expect(summary.attempted, 0);
    expect(summary.succeeded, 0);
    expect(summary.failed, 0);
    expect(startedTotals, isEmpty);
    expect(advanceCount, 0);
    expect(finishCount, 0);
    verifyNever(() => repo.pushOne(
        tmdbId: any(named: 'tmdbId'),
        mediaType: any(named: 'mediaType')));
  });

  test('retry two keys: both succeed', () async {
    when(() => repo.pushOne(
            tmdbId: any(named: 'tmdbId'),
            mediaType: any(named: 'mediaType')))
        .thenAnswer((_) async => const TmdbPushResult(success: true));

    final summary = await uc.retry([key(1), key(2)]);

    expect(summary.attempted, 2);
    expect(summary.succeeded, 2);
    expect(summary.failed, 0);
    expect(startedTotals, [2]);
    expect(advanceCount, 2);
    expect(finishCount, 1);
  });

  test('retry mixed success/failure reports lastError of last failure',
      () async {
    var calls = 0;
    when(() => repo.pushOne(
            tmdbId: any(named: 'tmdbId'),
            mediaType: any(named: 'mediaType')))
        .thenAnswer((_) async {
      calls++;
      if (calls == 1) return const TmdbPushResult(success: true);
      if (calls == 2) {
        return const TmdbPushResult(
            success: false, error: 'first failure');
      }
      return const TmdbPushResult(
          success: false, error: 'second failure');
    });

    final summary = await uc.retry([key(1), key(2), key(3)]);

    expect(summary.attempted, 3);
    expect(summary.succeeded, 1);
    expect(summary.failed, 2);
    expect(summary.lastError, 'second failure');
    expect(advanceCount, 3);
    expect(finishCount, 1);
  });

  test('finish runs even when pushOne throws', () async {
    when(() => repo.pushOne(
            tmdbId: any(named: 'tmdbId'),
            mediaType: any(named: 'mediaType')))
        .thenThrow(StateError('boom'));

    expect(() => uc.retry([key(1)]), throwsStateError);
    // Allow the microtask queue to drain so finally runs.
    await Future<void>.delayed(Duration.zero);
    expect(finishCount, 1);
  });

  test('retryOne wraps retry([key])', () async {
    when(() => repo.pushOne(
            tmdbId: any(named: 'tmdbId'),
            mediaType: any(named: 'mediaType')))
        .thenAnswer((_) async => const TmdbPushResult(success: true));

    final result = await uc.retryOne(key(7));

    expect(result.success, isTrue);
    expect(result.error, isNull);
    expect(advanceCount, 1);
    expect(finishCount, 1);
  });
}
