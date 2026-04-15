import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

part 'series.freezed.dart';

/// A franchise / collection grouping multiple media items.
@freezed
sealed class Series with _$Series {
  const factory Series({
    required String id,

    /// Qualified provider id, e.g. `tmdb:131635`, `mb:abc`, `gbooks:HP`.
    required String externalId,
    required String name,
    required MediaType mediaType,

    /// Originating provider, e.g. `tmdb`, `musicbrainz`, `google_books`.
    required String source,

    /// Known number of entries from the upstream provider, or `null` if
    /// the provider did not report a total.
    int? totalCount,
    required int updatedAt,
    @Default(false) bool deleted,
  }) = _Series;
}

/// Series + the count of items the user owns plus an optional [totalCount].
class SeriesWithCounts {
  const SeriesWithCounts({
    required this.series,
    required this.ownedCount,
  });

  final Series series;
  final int ownedCount;

  int? get totalCount => series.totalCount;

  /// Completeness ratio in `[0, 1]`, or `null` when [totalCount] is
  /// unknown or zero.
  double? get completeness {
    final total = totalCount;
    if (total == null || total == 0) return null;
    return (ownedCount / total).clamp(0.0, 1.0);
  }
}
