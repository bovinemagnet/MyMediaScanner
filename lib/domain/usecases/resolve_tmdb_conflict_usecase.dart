import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

class ResolveTmdbConflictUseCase {
  ResolveTmdbConflictUseCase(this.repo);
  final ITmdbAccountSyncRepository repo;

  Future<void> keepMine({
    required int tmdbId,
    required String mediaType,
  }) =>
      repo.applyConflictResolution(
          tmdbId: tmdbId, mediaType: mediaType, keepLocal: true);

  Future<void> useTmdb({
    required int tmdbId,
    required String mediaType,
  }) =>
      repo.applyConflictResolution(
          tmdbId: tmdbId, mediaType: mediaType, keepLocal: false);
}
