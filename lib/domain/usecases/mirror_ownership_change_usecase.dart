import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

/// Adds or removes a movie from the MyMediaScanner private TMDB list
/// based on a local ownership transition. No-op for TV (v3 list limit).
/// Caller must check the mirror toggle before calling.
class MirrorOwnershipChangeUseCase {
  MirrorOwnershipChangeUseCase(this.repo);
  final ITmdbAccountSyncRepository repo;

  Future<TmdbPushResult> add({required int tmdbId}) =>
      repo.mirrorAddOwnership(tmdbId: tmdbId);

  Future<TmdbPushResult> remove({required int tmdbId}) =>
      repo.mirrorRemoveOwnership(tmdbId: tmdbId);
}
