import 'package:mymediascanner/domain/usecases/convert_bridge_to_local_item_usecase.dart';
import 'package:mymediascanner/domain/usecases/toggle_tmdb_watchlist_usecase.dart';
import 'package:mymediascanner/domain/usecases/mirror_ownership_change_usecase.dart';

/// "Mark as owned" on the TMDB watchlist bucket view.
///
/// Three steps:
///  1. Convert the bridge row to a local `media_items` row (owned).
///  2. Remove the title from the TMDB watchlist (push).
///  3. If the mirror toggle is enabled AND the title is a movie,
///     add the title to the MyMediaScanner private TMDB list.
///
/// Returns a per-step result so the caller can show partial-success messages.
class MarkTmdbWatchlistOwnedUseCase {
  MarkTmdbWatchlistOwnedUseCase({
    required this.convert,
    required this.toggleWatchlist,
    required this.mirror,
  });

  final ConvertBridgeToLocalItemUseCase convert;
  final ToggleTmdbWatchlistUseCase toggleWatchlist;
  final MirrorOwnershipChangeUseCase mirror;

  Future<MarkOwnedResult> call({
    required String bridgeId,
    required int tmdbId,
    required String mediaType,
    required bool mirrorEnabled,
  }) async {
    String? convertError;
    String? watchlistError;
    String? mirrorError;
    String mediaItemId = '';
    try {
      mediaItemId = await convert(bridgeId);
    } catch (e) {
      convertError = e.toString();
    }
    final wl = await toggleWatchlist(
        tmdbId: tmdbId, mediaType: mediaType, value: false);
    if (!wl.success) watchlistError = wl.error;
    if (mirrorEnabled && mediaType == 'movie') {
      final m = await mirror.add(tmdbId: tmdbId);
      if (!m.success) mirrorError = m.error;
    }
    return MarkOwnedResult(
      mediaItemId: mediaItemId,
      convertError: convertError,
      watchlistError: watchlistError,
      mirrorError: mirrorError,
    );
  }
}

class MarkOwnedResult {
  const MarkOwnedResult({
    required this.mediaItemId,
    this.convertError,
    this.watchlistError,
    this.mirrorError,
  });
  final String mediaItemId;
  final String? convertError;
  final String? watchlistError;
  final String? mirrorError;

  bool get fullSuccess =>
      convertError == null &&
      watchlistError == null &&
      mirrorError == null;
}
