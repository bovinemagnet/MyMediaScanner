import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_item.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';

abstract class ITmdbAccountSyncRepository {
  /// Cached connection state. Reads stored creds and emits one of:
  /// disconnected, connected, expired.
  Future<TmdbConnectionState> currentState();

  // ── Auth ──────────────────────────────────────────────────────

  /// Step 1 — request a TMDB token. Returns the URL the user should
  /// open in their browser for approval.
  Future<({String requestToken, Uri approvalUrl})> startConnect();

  /// Step 2 — exchange an approved [requestToken] for a session.
  /// Stores creds on success and returns the resulting state.
  Future<TmdbConnectionState> finishConnect(String requestToken);

  /// Forget all stored creds. Bridge rows are preserved.
  Future<void> disconnect();

  // ── Bridge data ───────────────────────────────────────────────

  Stream<List<TmdbBridgeItem>> watchBucket(TmdbBridgeBucket bucket);

  Future<TmdbBridgeItem?> getByTmdbId(int tmdbId, String mediaType);

  /// Upsert account-state for a single title (used by scan-confirm).
  Future<void> enrichOne({required int tmdbId, required String mediaType});

  // ── Sync operations ───────────────────────────────────────────

  /// Six-bucket import. [progress] is invoked per page completed.
  /// [selectedBuckets] lets the user opt-out of certain buckets.
  Future<TmdbSyncSummary> importAll({
    required Set<TmdbBucketSelection> selectedBuckets,
    void Function(int pulled, int failed)? progress,
  });

  /// Manual full pull + prune. Equivalent to importing every bucket
  /// followed by `pruneOrphans` for unlinked rows.
  Future<TmdbSyncSummary> syncNow();

  /// Promote a bridge row to a real `media_items` entry. Returns the
  /// new media-item ID. Slice A creates the row with
  /// `OwnershipStatus.owned` and links the bridge row to it.
  Future<String> convertBridgeToLocalItem(String bridgeId);

  // ── Slice 2 — push pipeline ────────────────────────────────────

  /// Push any pending changes for the title `(tmdbId, mediaType)`.
  Future<TmdbPushResult> pushOne({
    required int tmdbId,
    required String mediaType,
  });

  /// Push every dirty row sequentially. Used by "Push pending now".
  Future<TmdbPushSummary> pushAllDirty();

  /// Watch the count of dirty rows for UI badging.
  Stream<int> watchDirtyCount();

  /// Stream conflicted rows (those needing user resolution).
  Stream<List<TmdbBridgeItem>> watchConflicts();

  /// Count dirty rows — used by the disconnect dialog precondition.
  Future<int> countDirtyRows();

  // ── Slice 2 — toggle helpers ───────────────────────────────────

  /// Toggle the watchlist flag locally + push (regardless of two-way setting;
  /// the use-case layer enforces the gate).
  Future<TmdbPushResult> toggleWatchlist({
    required int tmdbId,
    required String mediaType,
    required bool value,
  });

  /// Toggle the favourite flag locally + push.
  Future<TmdbPushResult> toggleFavorite({
    required int tmdbId,
    required String mediaType,
    required bool value,
  });

  /// Set local rating + push. Pass `null` to clear the rating on TMDB.
  Future<TmdbPushResult> updateRating({
    required int tmdbId,
    required String mediaType,
    required double? localRating, // 0–5 scale; null clears.
  });
}

/// Single bucket selection for the import wizard.
class TmdbBucketSelection {
  const TmdbBucketSelection({required this.bucket, required this.mediaType});
  final TmdbBridgeBucket bucket;
  final String mediaType; // 'movie' or 'tv'

  @override
  bool operator ==(Object other) =>
      other is TmdbBucketSelection &&
      other.bucket == bucket &&
      other.mediaType == mediaType;

  @override
  int get hashCode => Object.hash(bucket, mediaType);
}

class TmdbSyncSummary {
  const TmdbSyncSummary({
    required this.pulled,
    required this.failed,
    this.lastError,
  });

  final int pulled;
  final int failed;
  final String? lastError;
}

class TmdbPushResult {
  const TmdbPushResult({required this.success, this.error});
  final bool success;
  final String? error;
}

class TmdbPushSummary {
  const TmdbPushSummary({
    required this.attempted,
    required this.succeeded,
    required this.failed,
    this.lastError,
  });
  final int attempted;
  final int succeeded;
  final int failed;
  final String? lastError;
}
