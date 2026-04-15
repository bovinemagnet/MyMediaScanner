import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/series.dart';

/// Repository for the series / franchise grouping.
abstract interface class ISeriesRepository {
  Stream<List<SeriesWithCounts>> watchAllWithCounts();

  Future<Series?> getById(String id);

  Future<Series?> findByExternalId(String externalId);

  /// Insert or update by externalId. Returns the resolved id (existing or
  /// newly minted UUID).
  Future<String> upsert({
    required String externalId,
    required String name,
    required MediaType mediaType,
    required String source,
    int? totalCount,
  });

  Future<void> softDelete(String id);

  /// IDs of media items currently assigned to [seriesId], sorted by
  /// series_position then title.
  Future<List<String>> getMediaItemIds(String seriesId);
}
