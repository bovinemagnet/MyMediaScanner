import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

/// Saves a movie or TV title as a TMDB-only bridge row, with no
/// `media_items` entry. The bridge row has no flags set and no rating;
/// the user can later toggle watchlist / favourite / rate via the
/// existing slice-2 use cases, or convert to a local item via
/// `ConvertBridgeToLocalItemUseCase`.
///
/// Throws `ArgumentError` for media types other than `'movie'` or `'tv'`.
class SaveTmdbOnlyUseCase {
  SaveTmdbOnlyUseCase(this.repo);

  final ITmdbAccountSyncRepository repo;

  Future<void> call({
    required int tmdbId,
    required String mediaType,
    required String title,
    required String? posterPath,
    required String? barcode,
  }) async {
    if (mediaType != 'movie' && mediaType != 'tv') {
      throw ArgumentError.value(mediaType, 'mediaType',
          'Remote-first save only supports movie or tv');
    }
    await repo.upsertBridge(
      TmdbAccountSyncItemsTableCompanion(
        tmdbId: Value(tmdbId),
        tmdbMediaType: Value(mediaType),
        titleSnapshot: Value(title),
        posterPathSnapshot:
            posterPath == null ? const Value.absent() : Value(posterPath),
        barcode: barcode == null ? const Value.absent() : Value(barcode),
      ),
    );
  }
}
