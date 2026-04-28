import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

class EnrichScanWithTmdbAccountUseCase {
  EnrichScanWithTmdbAccountUseCase(this.repo);
  final ITmdbAccountSyncRepository repo;

  /// Best-effort: swallows network errors so the scan-confirm screen
  /// never gets blocked by an unreachable TMDB.
  Future<void> call({required int tmdbId, required String mediaType}) async {
    try {
      await repo.enrichOne(tmdbId: tmdbId, mediaType: mediaType);
    } catch (_) {
      // Non-fatal — UI shows "TMDB account state unavailable".
    }
  }
}
