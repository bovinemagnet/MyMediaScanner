import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/taste_profile.dart';

/// Builds a [TasteProfile] from the user's owned items. Pure function —
/// no I/O. Caller is responsible for filtering to the right slice (e.g.
/// `ownership_status='owned'` and `deleted=0`).
class TasteProfileBuilder {
  const TasteProfileBuilder({double lovedRatingThreshold = 4.0})
      : _lovedThreshold = lovedRatingThreshold;

  final double _lovedThreshold;

  TasteProfile build(List<MediaItem> items) {
    if (items.isEmpty) return TasteProfile.empty;

    final genreCounts = <String, int>{};
    final tagCounts = <String, int>{};
    final seriesItemCounts = <String, int>{};
    var ratedCount = 0;
    var ratingSum = 0.0;
    var lovedItemCount = 0;

    for (final item in items) {
      final r = item.userRating;
      if (r != null && r > 0) {
        ratedCount++;
        ratingSum += r;
        if (r >= _lovedThreshold) {
          lovedItemCount++;
          for (final g in item.genres) {
            genreCounts.update(g, (v) => v + 1, ifAbsent: () => 1);
          }
          final tags = item.extraMetadata['tags'];
          if (tags is List) {
            for (final t in tags) {
              if (t is String) {
                tagCounts.update(t, (v) => v + 1, ifAbsent: () => 1);
              }
            }
          }
        }
      }

      final sid = item.seriesId;
      if (sid != null) {
        seriesItemCounts.update(sid, (v) => v + 1, ifAbsent: () => 1);
      }
    }

    Map<String, double> normalise(Map<String, int> counts) {
      if (counts.isEmpty || lovedItemCount == 0) return const {};
      return {
        for (final e in counts.entries)
          e.key: e.value / lovedItemCount,
      };
    }

    return TasteProfile(
      lovedGenres: normalise(genreCounts),
      lovedTags: normalise(tagCounts),
      collectedSeriesIds: {
        for (final e in seriesItemCounts.entries)
          if (e.value >= 2) e.key,
      },
      averageRating: ratedCount > 0 ? ratingSum / ratedCount : null,
      totalRatedItems: ratedCount,
    );
  }
}
