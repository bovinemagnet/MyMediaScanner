/// Rip status enums and providers for collection integration.
///
/// Provides per-item rip status classification, a filter notifier, and
/// aggregate stats across the collection.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Quality classification for a ripped media item.
enum RipStatus {
  /// No linked rip album.
  noRip,

  /// Ripped but no quality analysis performed yet.
  ripped,

  /// All tracks verified via AccurateRip.
  verified,

  /// At least one track has quality issues (click/pop or AccurateRip mismatch).
  qualityIssues,
}

/// Filter options for the collection rip status filter chip.
enum RipStatusFilter {
  /// Show all items regardless of rip status.
  all,

  /// Show only items with a linked rip album.
  hasRip,

  /// Show only items with no linked rip album.
  noRip,

  /// Show only items whose rip is fully AccurateRip-verified.
  verified,

  /// Show only items with at least one quality issue.
  qualityIssues,
}

// ---------------------------------------------------------------------------
// Per-item status provider
// ---------------------------------------------------------------------------

/// Derives the [RipStatus] for a single media item identified by [mediaItemId].
///
/// Resolution order:
///  1. Not in [rippedItemIdsProvider] → [RipStatus.noRip]
///  2. Tracks have quality issues  → [RipStatus.qualityIssues]
///  3. All tracks with quality data verified → [RipStatus.verified]
///  4. Otherwise → [RipStatus.ripped]
final mediaItemRipStatusProvider =
    FutureProvider.family<RipStatus, String>((ref, mediaItemId) async {
  final rippedIds = await ref.watch(rippedItemIdsProvider.future);
  if (!rippedIds.contains(mediaItemId)) return RipStatus.noRip;

  // Watch the rip album to get its id, then check tracks.
  final ripAlbum =
      await ref.watch(ripAlbumForItemProvider(mediaItemId).future);
  if (ripAlbum == null) return RipStatus.noRip;

  final tracks = await ref.watch(ripTracksProvider(ripAlbum.id).future);

  final tracksWithData = tracks.where((t) => t.accurateRipStatus != null);
  if (tracksWithData.isEmpty) return RipStatus.ripped;

  final hasIssues = tracksWithData.any((t) =>
      t.accurateRipStatus != 'verified' ||
      (t.clickCount != null && t.clickCount! > 0));
  if (hasIssues) return RipStatus.qualityIssues;

  return RipStatus.verified;
});

// ---------------------------------------------------------------------------
// Filter notifier
// ---------------------------------------------------------------------------

/// Notifier managing the active [RipStatusFilter] for the collection screen.
class RipStatusFilterNotifier extends Notifier<RipStatusFilter> {
  @override
  RipStatusFilter build() => RipStatusFilter.all;

  /// Updates the active filter.
  void setFilter(RipStatusFilter filter) => state = filter;
}

/// Provider for the active rip status filter.
final ripStatusFilterProvider =
    NotifierProvider<RipStatusFilterNotifier, RipStatusFilter>(
        () => RipStatusFilterNotifier());

// ---------------------------------------------------------------------------
// Aggregate stats provider
// ---------------------------------------------------------------------------

/// Aggregate rip statistics across the whole collection.
class CollectionRipStats {
  const CollectionRipStats({
    this.total = 0,
    this.ripped = 0,
    this.verified = 0,
    this.qualityIssues = 0,
  });

  /// Total number of media items in the collection.
  final int total;

  /// Items with any linked rip album.
  final int ripped;

  /// Items whose rip is fully verified.
  final int verified;

  /// Items with at least one quality issue.
  final int qualityIssues;

  /// Items with no rip.
  int get noRip => total - ripped;
}

// ---------------------------------------------------------------------------
// Quality status cache provider
// ---------------------------------------------------------------------------

/// Pre-computed rip quality status for all ripped media items.
///
/// Maps media item ID → [RipStatus]. Items with no linked album map to
/// [RipStatus.ripped]; items with quality data map to [RipStatus.verified]
/// or [RipStatus.qualityIssues].
final ripQualityStatusCacheProvider =
    FutureProvider<Map<String, RipStatus>>((ref) async {
  final rippedIds = ref.watch(rippedItemIdsProvider).value ?? {};
  final cache = <String, RipStatus>{};

  for (final itemId in rippedIds) {
    final ripAlbum =
        await ref.watch(ripAlbumForItemProvider(itemId).future);
    if (ripAlbum == null) {
      cache[itemId] = RipStatus.ripped;
      continue;
    }
    final tracks =
        await ref.watch(ripTracksProvider(ripAlbum.id).future);
    final tracksWithData =
        tracks.where((t) => t.qualityCheckedAt != null).toList();
    if (tracksWithData.isEmpty) {
      cache[itemId] = RipStatus.ripped;
      continue;
    }
    final hasIssues = tracksWithData.any((t) =>
        (t.accurateRipStatus != null &&
            t.accurateRipStatus != 'verified') ||
        (t.clickCount != null && t.clickCount! > 0));
    cache[itemId] =
        hasIssues ? RipStatus.qualityIssues : RipStatus.verified;
  }
  return cache;
});

/// Computes aggregate [CollectionRipStats] from the collection and rip data.
///
/// Counts total music items in the collection, how many are ripped, and
/// breaks ripped items down into verified vs quality-issues using the
/// [ripQualityStatusCacheProvider].
final collectionRipStatsProvider =
    FutureProvider<CollectionRipStats>((ref) async {
  final rippedIds = ref.watch(rippedItemIdsProvider).value ?? {};

  // Count total music items via the repository (avoids circular import with
  // collection_provider.dart which already imports this file).
  final repo = ref.watch(mediaItemRepositoryProvider);
  final musicItems =
      await repo.watchAll(mediaType: MediaType.music).first;

  final qualityCache =
      await ref.watch(ripQualityStatusCacheProvider.future);

  int verifiedCount = 0;
  int qualityIssuesCount = 0;
  for (final status in qualityCache.values) {
    if (status == RipStatus.verified) verifiedCount++;
    if (status == RipStatus.qualityIssues) qualityIssuesCount++;
  }

  return CollectionRipStats(
    total: musicItems.length,
    ripped: rippedIds.length,
    verified: verifiedCount,
    qualityIssues: qualityIssuesCount,
  );
});
