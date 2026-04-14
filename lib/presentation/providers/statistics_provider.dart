// Collection statistics provider.
//
// Author: Paul Snow
// Since: 0.0.0

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/borrower.dart';
import 'package:mymediascanner/domain/entities/insights_data.dart';
import 'package:mymediascanner/domain/entities/loan.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/presentation/providers/loan_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

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

/// Default overdue threshold in days.
const overdueThresholdDays = 30;

/// Computes [InsightsData] from raw collection, loan, borrower, and rip data.
///
/// Extracted as a top-level function for testability.
InsightsData computeInsightsData({
  required List<MediaItem> items,
  required List<Loan> activeLoans,
  required List<Loan> allLoans,
  required List<Borrower> borrowers,
  required List<RipAlbum> ripAlbums,
  required Set<String> rippedItemIds,
  int overdueThreshold = overdueThresholdDays,
}) {
  final activeItems = items.where((item) => !item.deleted).toList();

  // ── Collection overview ──────────────────────────────────────────
  final stats = CollectionStatistics.fromItems(items);

  // ── Monthly growth ───────────────────────────────────────────────
  final monthlyGrowth = <String, int>{};
  for (final item in activeItems) {
    final dt = DateTime.fromMillisecondsSinceEpoch(item.dateAdded);
    final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
    monthlyGrowth[key] = (monthlyGrowth[key] ?? 0) + 1;
  }

  // ── Lending statistics ───────────────────────────────────────────
  final now = DateTime.now();
  final overdueCount = activeLoans.where((loan) {
    final lentDate = DateTime.fromMillisecondsSinceEpoch(loan.lentAt);
    return now.difference(lentDate).inDays > overdueThreshold;
  }).length;

  // Build borrower name lookup
  final borrowerMap = <String, String>{};
  for (final b in borrowers) {
    borrowerMap[b.id] = b.name;
  }

  // Top borrowers: count active loans per borrower
  final borrowerCounts = <String, int>{};
  for (final loan in activeLoans) {
    final name = borrowerMap[loan.borrowerId] ?? 'Unknown';
    borrowerCounts[name] = (borrowerCounts[name] ?? 0) + 1;
  }
  final sortedBorrowers = borrowerCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final topBorrowers = Map.fromEntries(sortedBorrowers.take(5));

  // Build item title lookup
  final itemTitleMap = <String, String>{};
  for (final item in activeItems) {
    itemTitleMap[item.id] = item.title;
  }

  // Most borrowed items: count all loans per media item
  final itemLoanCounts = <String, int>{};
  for (final loan in allLoans) {
    final title = itemTitleMap[loan.mediaItemId] ?? 'Unknown';
    itemLoanCounts[title] = (itemLoanCounts[title] ?? 0) + 1;
  }
  final sortedItems = itemLoanCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final mostBorrowedItems = Map.fromEntries(sortedItems.take(5));

  // ── Rip coverage ─────────────────────────────────────────────────
  final activeRips = ripAlbums.where((r) => !r.deleted).toList();
  final matched = activeRips.where((r) => r.mediaItemId != null).length;
  final unmatched = activeRips.length - matched;
  final totalSizeBytes =
      activeRips.fold<int>(0, (sum, r) => sum + r.totalSizeBytes);

  final musicItems =
      activeItems.where((i) => i.mediaType == MediaType.music).toList();
  final musicItemsWithRips =
      musicItems.where((i) => rippedItemIds.contains(i.id)).length;

  // ── Collection value ──────────────────────────────────────────────
  // Sum of pricePaid over owned items, ignoring nulls. `null` when no
  // owned item has a recorded price, so UI can render "—".
  final ownedPrices = activeItems
      .where((i) => i.ownershipStatus == OwnershipStatus.owned)
      .map((i) => i.pricePaid)
      .whereType<double>()
      .toList();
  final double? totalValue = ownedPrices.isEmpty
      ? null
      : ownedPrices.fold<double>(0, (sum, p) => sum + p);

  return InsightsData(
    totalItems: stats.totalItems,
    byMediaType: stats.byMediaType,
    byYear: stats.byYear,
    byGenre: stats.byGenre,
    averageRating: stats.averageRating,
    ratedCount: stats.ratedCount,
    monthlyGrowth: monthlyGrowth,
    activeLoansCount: activeLoans.length,
    overdueCount: overdueCount,
    totalLoansAllTime: allLoans.length,
    topBorrowers: topBorrowers,
    mostBorrowedItems: mostBorrowedItems,
    totalRipAlbums: activeRips.length,
    matchedRipAlbums: matched,
    unmatchedRipAlbums: unmatched,
    totalRipSizeBytes: totalSizeBytes,
    musicItemsWithRips: musicItemsWithRips,
    totalMusicItems: musicItems.length,
    totalValue: totalValue,
  );
}

/// Debounced insights provider that caches results and only recomputes
/// after 500ms of no upstream changes.
class DebouncedInsightsNotifier extends AsyncNotifier<InsightsData> {
  Timer? _debounce;

  @override
  Future<InsightsData> build() async {
    // Watch all upstream providers
    final itemRepo = ref.watch(mediaItemRepositoryProvider);
    final items = await itemRepo.watchAll().first;
    final activeLoans = ref.watch(activeLoansProvider).value ?? [];
    final allLoans = ref.watch(allLoansProvider).value ?? [];
    final borrowers = ref.watch(allBorrowersProvider).value ?? [];
    final ripAlbums = ref.watch(allRipAlbumsProvider).value ?? [];
    final rippedIds = ref.watch(rippedItemIdsProvider).value ?? {};

    return computeInsightsData(
      items: items,
      activeLoans: activeLoans,
      allLoans: allLoans,
      borrowers: borrowers,
      ripAlbums: ripAlbums,
      rippedItemIds: rippedIds,
    );
  }

  /// Trigger a debounced refresh.
  void scheduleRefresh() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.invalidateSelf();
    });
  }
}

final insightsProvider =
    AsyncNotifierProvider<DebouncedInsightsNotifier, InsightsData>(
        () => DebouncedInsightsNotifier());
