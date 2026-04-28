import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

/// Toggle the TMDB watchlist flag for a single title.
///
/// The caller is responsible for gating this behind the two-way sync
/// setting if required.
class ToggleTmdbWatchlistUseCase {
  ToggleTmdbWatchlistUseCase(this.repo);
  final ITmdbAccountSyncRepository repo;

  Future<TmdbPushResult> call({
    required int tmdbId,
    required String mediaType,
    required bool value,
  }) =>
      repo.toggleWatchlist(
          tmdbId: tmdbId, mediaType: mediaType, value: value);
}
