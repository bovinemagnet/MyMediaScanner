// Insights data entity for the analytics dashboard.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

part 'insights_data.freezed.dart';

@freezed
sealed class InsightsData with _$InsightsData {
  const factory InsightsData({
    // ── Collection overview ──────────────────────
    required int totalItems,
    required Map<MediaType, int> byMediaType,
    required Map<int, int> byYear,
    required Map<String, int> byGenre,
    required double? averageRating,
    required int ratedCount,

    // ── Growth timeline ──────────────────────────
    /// Items added per calendar month: {2026-01: 5, 2026-02: 12, ...}
    required Map<String, int> monthlyGrowth,

    // ── Lending statistics ───────────────────────
    required int activeLoansCount,
    required int overdueCount,
    required int totalLoansAllTime,

    /// Borrower name → active loan count
    required Map<String, int> topBorrowers,

    /// Media item title → total times lent
    required Map<String, int> mostBorrowedItems,

    // ── Rip coverage ────────────────────────────
    required int totalRipAlbums,
    required int matchedRipAlbums,
    required int unmatchedRipAlbums,
    required int totalRipSizeBytes,

    /// Music items in collection that have a matching rip
    required int musicItemsWithRips,

    /// Total music items in collection
    required int totalMusicItems,
  }) = _InsightsData;
}
