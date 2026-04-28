import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

/// Push pending changes for a single bridge row.
class PushTmdbChangeUseCase {
  PushTmdbChangeUseCase(this.repo);
  final ITmdbAccountSyncRepository repo;

  Future<TmdbPushResult> call({
    required int tmdbId,
    required String mediaType,
  }) =>
      repo.pushOne(tmdbId: tmdbId, mediaType: mediaType);

  Future<TmdbPushSummary> all() => repo.pushAllDirty();
}
