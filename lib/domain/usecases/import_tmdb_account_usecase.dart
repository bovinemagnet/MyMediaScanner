import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

class ImportTmdbAccountUseCase {
  ImportTmdbAccountUseCase(this.repo);
  final ITmdbAccountSyncRepository repo;

  Future<TmdbSyncSummary> call({
    required Set<TmdbBucketSelection> selectedBuckets,
    void Function(int pulled, int failed)? progress,
  }) {
    return repo.importAll(
        selectedBuckets: selectedBuckets, progress: progress);
  }

  /// Convenience: all six buckets selected.
  static Set<TmdbBucketSelection> allBuckets() => {
        const TmdbBucketSelection(
            bucket: TmdbBridgeBucket.watchlist, mediaType: 'movie'),
        const TmdbBucketSelection(
            bucket: TmdbBridgeBucket.watchlist, mediaType: 'tv'),
        const TmdbBucketSelection(
            bucket: TmdbBridgeBucket.rated, mediaType: 'movie'),
        const TmdbBucketSelection(
            bucket: TmdbBridgeBucket.rated, mediaType: 'tv'),
        const TmdbBucketSelection(
            bucket: TmdbBridgeBucket.favourite, mediaType: 'movie'),
        const TmdbBucketSelection(
            bucket: TmdbBridgeBucket.favourite, mediaType: 'tv'),
      };
}
