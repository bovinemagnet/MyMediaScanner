import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

/// Drives a sequence of `pushOne` calls and reports live progress
/// through callbacks (so the use case stays platform/UI agnostic).
///
/// On non-error completion it leaves the progress in idle. On error
/// it re-throws after marking finish, so the caller's stack trace is
/// preserved.
class RetryPushUseCase {
  RetryPushUseCase({
    required this.repo,
    required this.startProgress,
    required this.advanceProgress,
    required this.finishProgress,
  });

  final ITmdbAccountSyncRepository repo;
  final void Function(int total) startProgress;
  final void Function() advanceProgress;
  final void Function() finishProgress;

  /// Attempt every key in [keys]. Returns a summary identical in shape
  /// to [TmdbPushSummary] from `pushAllDirty()`.
  Future<TmdbPushSummary> retry(List<TmdbBridgeKey> keys) async {
    if (keys.isEmpty) {
      return const TmdbPushSummary(
          attempted: 0, succeeded: 0, failed: 0);
    }
    startProgress(keys.length);
    int succeeded = 0;
    int failed = 0;
    String? lastError;
    try {
      for (final k in keys) {
        final result =
            await repo.pushOne(tmdbId: k.tmdbId, mediaType: k.mediaType);
        if (result.success) {
          succeeded++;
        } else {
          failed++;
          if (result.error != null) lastError = result.error;
        }
        advanceProgress();
      }
    } finally {
      finishProgress();
    }
    return TmdbPushSummary(
      attempted: keys.length,
      succeeded: succeeded,
      failed: failed,
      lastError: lastError,
    );
  }

  /// Convenience wrapper around [retry] with a single key.
  Future<TmdbPushResult> retryOne(TmdbBridgeKey key) async {
    final summary = await retry([key]);
    return TmdbPushResult(
      success: summary.failed == 0,
      error: summary.lastError,
    );
  }
}
