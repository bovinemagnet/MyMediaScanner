import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_item.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/domain/entities/tmdb_pending_change.dart';
import 'package:mymediascanner/domain/entities/tmdb_push_progress.dart';
import 'package:mymediascanner/domain/usecases/retry_push_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

class TmdbAccountConnectionNotifier
    extends AsyncNotifier<TmdbConnectionState> {
  @override
  Future<TmdbConnectionState> build() {
    return ref.read(tmdbAccountSyncRepositoryProvider).currentState();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => ref.read(tmdbAccountSyncRepositoryProvider).currentState());
  }

  void setState(TmdbConnectionState newState) {
    state = AsyncValue.data(newState);
  }
}

final tmdbAccountConnectionProvider = AsyncNotifierProvider<
    TmdbAccountConnectionNotifier,
    TmdbConnectionState>(TmdbAccountConnectionNotifier.new);

/// Watch a single bucket of TMDB-only bridge items.
final tmdbBridgeBucketProvider = StreamProvider.family<
    List<TmdbBridgeItem>, TmdbBridgeBucket>((ref, bucket) {
  return ref.watch(tmdbAccountSyncRepositoryProvider).watchBucket(bucket);
});

/// One-shot lookup of bridge state for a specific TMDB ID.
final tmdbBridgeForIdProvider =
    FutureProvider.family<TmdbBridgeItem?, ({int tmdbId, String mediaType})>(
  (ref, key) {
    return ref
        .watch(tmdbAccountSyncRepositoryProvider)
        .getByTmdbId(key.tmdbId, key.mediaType);
  },
);

/// Stream of dirty-row count for the settings card "X pending changes".
final tmdbDirtyCountProvider = StreamProvider<int>((ref) {
  return ref.watch(tmdbAccountSyncRepositoryProvider).watchDirtyCount();
});

/// Stream of conflicted bridge rows for the resolve-conflicts screen.
final tmdbConflictedRowsProvider =
    StreamProvider<List<TmdbBridgeItem>>((ref) {
  return ref.watch(tmdbAccountSyncRepositoryProvider).watchConflicts();
});

/// Tracks whether [TmdbConnectDialog] is currently mounted. The
/// global deep-link SnackBar listener uses this to suppress
/// duplicate notifications when the dialog is up (the dialog will
/// surface its own feedback).
class TmdbConnectDialogVisibleNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;
  void hide() => state = false;
}

final tmdbConnectDialogVisibleProvider =
    NotifierProvider<TmdbConnectDialogVisibleNotifier, bool>(
        TmdbConnectDialogVisibleNotifier.new);

/// Stream of pending changes (dirty bridge rows excluding conflicts)
/// rendered by [TmdbPendingChangesDialog]. Each row is composed in
/// memory from the bridge row itself; titles come from
/// `titleSnapshot` and don't require a media-items join.
final tmdbPendingChangesProvider =
    StreamProvider<List<TmdbPendingChange>>((ref) {
  final dao = ref.watch(tmdbAccountSyncDaoProvider);
  return dao.watchPendingDirty().map((rows) => rows
      .map((r) => TmdbPendingChange(
            tmdbId: r.tmdbId,
            mediaType: r.tmdbMediaType,
            title: r.titleSnapshot,
            actions: derivePendingActions(
              watchlist: r.watchlist,
              favorite: r.favorite,
              localRatingSnapshot: r.localRatingSnapshot,
            ),
            lastPushedAt: r.lastPushedAt,
            lastError: r.lastError,
          ))
      .toList());
});

/// Stream of the conflict count for the section card's second row.
final tmdbConflictCountProvider = StreamProvider<int>((ref) {
  final dao = ref.watch(tmdbAccountSyncDaoProvider);
  return dao.watchConflicts().map((list) => list.length);
});

/// Live progress of any active push-retry. The dialog and any caller
/// observe this for the determinate progress indicator.
class TmdbPushProgressNotifier extends Notifier<TmdbPushProgress> {
  @override
  TmdbPushProgress build() => TmdbPushProgress.idle();

  void start(int total) {
    state = TmdbPushProgress(inFlight: true, current: 0, total: total);
  }

  void advance() {
    state = state.copyWith(current: state.current + 1);
  }

  void finish() {
    state = TmdbPushProgress.idle();
  }
}

final tmdbPushProgressProvider =
    NotifierProvider<TmdbPushProgressNotifier, TmdbPushProgress>(
        TmdbPushProgressNotifier.new);

final retryPushUseCaseProvider = Provider<RetryPushUseCase>((ref) {
  final notifier = ref.watch(tmdbPushProgressProvider.notifier);
  return RetryPushUseCase(
    repo: ref.watch(tmdbAccountSyncRepositoryProvider),
    startProgress: notifier.start,
    advanceProgress: notifier.advance,
    finishProgress: notifier.finish,
  );
});
