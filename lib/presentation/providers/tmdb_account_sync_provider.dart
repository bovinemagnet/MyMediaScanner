import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_item.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
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
