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
