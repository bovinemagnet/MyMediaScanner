import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_series_repository.dart';

/// Promotes [MetadataResult.seriesExternalId] / `seriesName` into the
/// `series` table and writes the resolved `seriesId` (and optional
/// `seriesPosition`) onto a freshly saved [MediaItem].
///
/// No-op when the metadata carries no series ref. The `source` for upsert
/// is derived from the [externalId] prefix (`tmdb:`, `mb:`, `gbooks:`).
class ResolveSeriesUseCase {
  ResolveSeriesUseCase({
    required ISeriesRepository seriesRepository,
    required IMediaItemRepository mediaItemRepository,
  })  : _series = seriesRepository,
        _items = mediaItemRepository;

  final ISeriesRepository _series;
  final IMediaItemRepository _items;

  /// Resolves the series for [item] from [metadata] and writes back the
  /// updated MediaItem. Returns the (possibly unchanged) item.
  Future<MediaItem> execute(MediaItem item, MetadataResult metadata) async {
    final externalId = metadata.seriesExternalId;
    final name = metadata.seriesName;
    if (externalId == null || name == null || name.isEmpty) {
      return item;
    }

    final source = _sourceFromExternalId(externalId);
    final seriesId = await _series.upsert(
      externalId: externalId,
      name: name,
      mediaType: item.mediaType,
      source: source,
    );

    final updated = item.copyWith(
      seriesId: seriesId,
      seriesPosition: metadata.seriesPosition,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _items.update(updated);
    return updated;
  }

  static String _sourceFromExternalId(String externalId) {
    final colon = externalId.indexOf(':');
    if (colon <= 0) return 'unknown';
    return externalId.substring(0, colon);
  }
}
