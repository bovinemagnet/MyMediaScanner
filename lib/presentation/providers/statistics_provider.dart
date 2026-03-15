// Collection statistics provider.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

/// Plain Dart class holding collection statistics.
class CollectionStatistics {
  const CollectionStatistics({
    required this.totalItems,
    required this.byMediaType,
    required this.byYear,
    required this.byGenre,
    required this.averageRating,
    required this.ratedCount,
  });

  /// Computes statistics from a list of media items.
  factory CollectionStatistics.fromItems(List<MediaItem> items) {
    final activeItems = items.where((item) => !item.deleted).toList();

    // Count by media type
    final byMediaType = <MediaType, int>{};
    for (final item in activeItems) {
      byMediaType[item.mediaType] = (byMediaType[item.mediaType] ?? 0) + 1;
    }

    // Count by year (top 10)
    final yearCounts = <int, int>{};
    for (final item in activeItems) {
      if (item.year != null) {
        yearCounts[item.year!] = (yearCounts[item.year!] ?? 0) + 1;
      }
    }
    final sortedYears = yearCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final byYear = Map.fromEntries(sortedYears.take(10));

    // Count by genre (top 10)
    final genreCounts = <String, int>{};
    for (final item in activeItems) {
      for (final genre in item.genres) {
        genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
      }
    }
    final sortedGenres = genreCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final byGenre = Map.fromEntries(sortedGenres.take(10));

    // Average rating
    final ratedItems =
        activeItems.where((item) => item.userRating != null).toList();
    final ratedCount = ratedItems.length;
    final averageRating = ratedCount > 0
        ? ratedItems.fold<double>(0, (sum, item) => sum + item.userRating!) /
            ratedCount
        : null;

    return CollectionStatistics(
      totalItems: activeItems.length,
      byMediaType: byMediaType,
      byYear: byYear,
      byGenre: byGenre,
      averageRating: averageRating,
      ratedCount: ratedCount,
    );
  }

  final int totalItems;
  final Map<MediaType, int> byMediaType;
  final Map<int, int> byYear;
  final Map<String, int> byGenre;
  final double? averageRating;
  final int ratedCount;
}

/// Provides collection statistics derived from the media item stream.
final statisticsProvider = StreamProvider<CollectionStatistics>((ref) {
  final repository = ref.watch(mediaItemRepositoryProvider);
  return repository.watchAll().map(CollectionStatistics.fromItems);
});
