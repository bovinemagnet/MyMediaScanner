# Insights & Analytics Dashboard — Full Build-Out

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Expand the existing Statistics screen (`/insights`) into a comprehensive analytics dashboard with interactive charts (fl_chart), collection growth timeline, lending statistics, rip library coverage metrics, and CSV/JSON export — all following the established Obsidian Lens / Precision Editorial design system.

**Architecture:** New providers compute derived analytics from existing streams (`collectionProvider`, `activeLoansProvider`, `allRipAlbumsProvider`). Chart widgets use fl_chart for line, bar, and pie visualisations. Export reuses `ExportCollectionUseCase`. No new database tables required — all analytics are computed from existing schema.

**Tech Stack:** Flutter, Riverpod 3.x (hand-written), fl_chart, Drift (existing), file_picker (existing)

**Author:** Paul Snow

**Version:** 0.0.0

---

## Current State

The `/insights` route already renders `StatisticsScreen` with:
- Hero bento grid (total items, average rating, rated count, genre count)
- Genre distribution bar chart (hand-painted vertical bars)
- Collection health card (media type progress bars)
- Items by year horizontal bar chart
- Top rated items gallery (horizontal scroll)

**What is missing:**
- No interactive charts (fl_chart) — all visuals are hand-painted or basic widgets
- No collection growth over time (items added per week/month)
- No lending statistics (active loans, overdue, most borrowed items, top borrowers)
- No rip library coverage stats (matched vs unmatched, total size, quality summary)
- No export action from the insights screen itself
- No date-range filtering or time-period selector
- Statistics provider loads everything in memory — no dedicated aggregation queries

---

## File Structure (New & Modified)

```
lib/
  presentation/
    providers/
      statistics_provider.dart          (MODIFY — add lending/rip stats, growth data)
      insights_export_provider.dart     (CREATE — export trigger from insights screen)
    screens/
      collection/
        statistics_screen.dart          (MODIFY — add new sections, fl_chart widgets)
      collection/widgets/
        growth_chart.dart               (CREATE — fl_chart line chart for growth over time)
        media_type_pie_chart.dart       (CREATE — fl_chart pie/donut for media type split)
        lending_stats_card.dart         (CREATE — lending analytics card)
        rip_coverage_card.dart          (CREATE — rip library coverage card)
        export_action_bar.dart          (CREATE — export buttons row)
        time_period_selector.dart       (CREATE — week/month/year/all-time toggle)
  domain/
    entities/
      insights_data.dart                (CREATE — freezed model for full insights payload)
test/
  unit/
    presentation/
      providers/
        statistics_provider_test.dart   (CREATE — unit tests for new stats computation)
  presentation/
    screens/
      collection/
        statistics_screen_test.dart     (CREATE — widget tests for insights screen)
```

---

## Task 1: Add fl_chart Dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add fl_chart to pubspec.yaml**

Add after the existing `file_picker` dependency line:

```yaml
  fl_chart: ^0.70.2
```

- [ ] **Step 2: Run flutter pub get**

Run: `flutter pub get`
Expected: Dependencies resolved successfully.

- [ ] **Step 3: Commit**

---

## Task 2: Create Insights Data Entity

**Files:**
- Create: `lib/domain/entities/insights_data.dart`

- [ ] **Step 1: Create the InsightsData freezed model**

This model aggregates all analytics data into a single immutable payload consumed by the screen. It extends the existing `CollectionStatistics` concept with lending, rip coverage, and growth timeline data.

```dart
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
```

- [ ] **Step 2: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `insights_data.freezed.dart` without errors.

- [ ] **Step 3: Commit**

---

## Task 3: Expand Statistics Provider

**Files:**
- Modify: `lib/presentation/providers/statistics_provider.dart`

- [ ] **Step 1: Add insightsProvider that combines collection, loan, and rip data**

The new `insightsProvider` watches `collectionProvider`, `activeLoansProvider`, `allBorrowersProvider`, and `allRipAlbumsProvider` to compute the full `InsightsData`. The existing `statisticsProvider` is kept for backwards compatibility (dashboard screen uses it).

Key computation logic:
- **Monthly growth:** Group items by `DateTime.fromMillisecondsSinceEpoch(dateAdded)` formatted as `yyyy-MM`.
- **Overdue loans:** Active loans where `lentAt` is > 30 days ago (configurable threshold, default 30 days).
- **Top borrowers:** Count active loans per borrower, join with borrower names.
- **Most borrowed items:** Count all loans (active + returned) per media item, join with item titles.
- **Rip coverage:** Count rip albums with non-null `mediaItemId` (matched) vs null (unmatched). Count music items from collection that appear in rippedItemIds.

- [ ] **Step 2: Write unit tests for InsightsData computation**

Create `test/unit/presentation/providers/statistics_provider_test.dart`:
- Test monthly growth grouping with items spread across months
- Test overdue loan detection (mock loans with old `lentAt`)
- Test top borrowers ranking
- Test most borrowed items ranking
- Test rip coverage counts (matched, unmatched, music items with rips)
- Test empty collection edge case

Run: `flutter test test/unit/presentation/providers/statistics_provider_test.dart`
Expected: All tests pass.

- [ ] **Step 3: Commit**

---

## Task 4: Create Chart Widgets

**Files:**
- Create: `lib/presentation/screens/collection/widgets/growth_chart.dart`
- Create: `lib/presentation/screens/collection/widgets/media_type_pie_chart.dart`
- Create: `lib/presentation/screens/collection/widgets/time_period_selector.dart`

### Sub-task 4a: Collection Growth Line Chart

- [ ] **Step 1: Create growth_chart.dart**

An fl_chart `LineChart` showing cumulative item count over time. X-axis: months. Y-axis: cumulative count. Uses `monthlyGrowth` from `InsightsData`. Follows design system: primary colour for the line, `surfaceContainerHigh` background, tonal container card wrapper, uppercase label header.

Features:
- Smooth curved line with gradient fill beneath
- Touch tooltips showing month and count
- Respects theme (dark/light)
- Shows last 12 months by default, with `TimePeriodSelector` to change range

### Sub-task 4b: Media Type Pie Chart

- [ ] **Step 2: Create media_type_pie_chart.dart**

An fl_chart `PieChart` (donut style) showing `byMediaType` distribution. Each segment uses the existing `AppColors.filmColor`, `AppColors.tvColor`, etc. from `app_colors.dart`. Centre shows total count. Legend below with colour swatches.

### Sub-task 4c: Time Period Selector

- [ ] **Step 3: Create time_period_selector.dart**

A `SegmentedButton<TimePeriod>` with options: 3 months, 6 months, 12 months, All time. Stored as a Riverpod `StateProvider<TimePeriod>` so chart widgets react to changes.

- [ ] **Step 4: Write widget tests for chart components**

- Test renders without error with sample data
- Test empty data shows placeholder message

Run: `flutter test test/presentation/screens/collection/widgets/`
Expected: All tests pass.

- [ ] **Step 5: Commit**

---

## Task 5: Create Lending Statistics Card

**Files:**
- Create: `lib/presentation/screens/collection/widgets/lending_stats_card.dart`

- [ ] **Step 1: Create lending_stats_card.dart**

A tonal container card showing:
- **Active loans count** — prominent number with icon
- **Overdue count** — highlighted in error colour if > 0
- **Top borrowers** — horizontal bar chart (up to 5) using fl_chart `BarChart`
- **Most borrowed items** — ranked list (up to 5) with loan count badges

Follows design system: `surfaceContainerHigh` background, uppercase `LENDING` label header, no dividers (tonal shifts only), `AppDesignExtension` shadow tokens.

- [ ] **Step 2: Write widget test**

- Test renders active loans count
- Test overdue badge shown when overdue > 0
- Test empty state when no loans exist

Run: `flutter test test/presentation/screens/collection/widgets/lending_stats_card_test.dart`
Expected: All tests pass.

- [ ] **Step 3: Commit**

---

## Task 6: Create Rip Coverage Card

**Files:**
- Create: `lib/presentation/screens/collection/widgets/rip_coverage_card.dart`

- [ ] **Step 1: Create rip_coverage_card.dart**

A tonal container card showing:
- **Total rip albums** — number with disc icon
- **Matched / Unmatched** — stacked progress bar or donut showing ratio
- **Music collection coverage** — `musicItemsWithRips / totalMusicItems` as percentage with circular progress
- **Total library size** — formatted in GB/TB

Follows design system conventions. Uses `AppColors.musicColor` for rip-related accents.

- [ ] **Step 2: Write widget test**

- Test renders total rip albums
- Test coverage percentage calculation
- Test zero rips shows empty state

Run: `flutter test test/presentation/screens/collection/widgets/rip_coverage_card_test.dart`
Expected: All tests pass.

- [ ] **Step 3: Commit**

---

## Task 7: Create Export Action Bar

**Files:**
- Create: `lib/presentation/screens/collection/widgets/export_action_bar.dart`
- Create: `lib/presentation/providers/insights_export_provider.dart`
- Modify: `lib/presentation/screens/collection/collection_screen.dart`

- [ ] **Step 1: Create export_action_bar.dart**

A row of two buttons:
- **Export CSV** — triggers `ExportCollectionUseCase` with `ExportFormat.csv`
- **Export JSON** — triggers `ExportCollectionUseCase` with `ExportFormat.json`

Uses `file_picker` to let user choose output directory. Shows `SnackBar` with file path on success or error message on failure.

- [ ] **Step 2: Create insights_export_provider.dart**

A simple provider that wraps `ExportCollectionUseCase` so both collection screen and insights screen can call it without duplicating logic.

- [ ] **Step 3: Refactor CollectionScreen to use shared export provider**

Update `lib/presentation/screens/collection/collection_screen.dart` to call the shared provider instead of inline `ExportCollectionUseCase` construction.

- [ ] **Step 4: Write widget test**

- Test renders both export buttons
- Test CSV button triggers export

Run: `flutter test test/presentation/screens/collection/widgets/export_action_bar_test.dart`
Expected: All tests pass.

- [ ] **Step 5: Commit**

---

## Task 8: Assemble the Full Insights Screen

**Files:**
- Modify: `lib/presentation/screens/collection/statistics_screen.dart`

- [ ] **Step 1: Update StatisticsScreen to use insightsProvider and new widgets**

Replace the existing `statisticsProvider` watch with `insightsProvider`. Restructure the `ListView` sections in this order:

1. **Header** (existing — keep as-is for desktop)
2. **Time period selector** (new)
3. **Hero bento grid** (existing — update to use `InsightsData`)
4. **Collection growth chart** (new — `GrowthChart`)
5. **Middle row: Genre bars + Media type pie chart** (replace `_CollectionHealthCard` with `MediaTypePieChart`)
6. **Items by year chart** (existing — keep as-is)
7. **Lending statistics card** (new — `LendingStatsCard`)
8. **Rip coverage card** (new — `RipCoverageCard`, only shown on desktop or when rip data exists)
9. **Export action bar** (new — `ExportActionBar`)
10. **Top rated items gallery** (existing — keep as-is)

Layout notes:
- On wide screens (>900px), lending and rip cards sit side-by-side in a `Row`
- On narrow screens, they stack vertically
- Growth chart spans full width
- Export bar sits above the top rated gallery

- [ ] **Step 2: Update imports and remove unused code**

Remove inline `_CollectionHealthCard` if fully replaced by the pie chart, or keep it as a secondary view.

- [ ] **Step 3: Run flutter analyse**

Run: `flutter analyze`
Expected: No issues found.

- [ ] **Step 4: Write/update widget tests for the full screen**

- Test screen renders with mock `InsightsData`
- Test lending section visible when loans exist
- Test rip section hidden when no rip data
- Test export buttons present
- Test time period selector changes state

Run: `flutter test test/presentation/screens/collection/statistics_screen_test.dart`
Expected: All tests pass.

- [ ] **Step 5: Commit**

---

## Task 9: Full Test Suite & Polish

- [ ] **Step 1: Run the full test suite**

Run: `flutter test`
Expected: All tests pass, no regressions.

- [ ] **Step 2: Run flutter analyse**

Run: `flutter analyze`
Expected: No issues found.

- [ ] **Step 3: Manual smoke test**

Run: `flutter run -d macos` (or preferred platform)
- Navigate to `/insights`
- Verify hero stats display correctly
- Verify growth chart renders (may be empty with no data)
- Verify lending section shows or hides based on loan data
- Verify rip coverage shows or hides based on rip data
- Verify export buttons trigger file picker and produce output
- Verify responsive layout (resize window on desktop)
- Test both dark and light themes

- [ ] **Step 4: Final commit if any polish needed**

---

## Architecture Notes

### Provider Dependency Graph

```
collectionProvider ─────┐
activeLoansProvider ─────┤
allBorrowersProvider ────┼──▶ insightsProvider (StreamProvider<InsightsData>)
allRipAlbumsProvider ────┤
rippedItemIdsProvider ───┘
```

### Design System Compliance

All new cards follow the established pattern:
- `surfaceContainerHigh` background with 12px border radius
- Uppercase `labelSmall` section headers with 1.2 letter spacing
- No dividers — tonal shifts only
- Ambient shadows via `AppDesignExtension`
- Primary colour for accent elements, `onSurfaceVariant` for secondary text
- Responsive `LayoutBuilder` breakpoints (700px for two-column, 900px for three-column)

### fl_chart Theming

All fl_chart widgets must read colours from `Theme.of(context).colorScheme` rather than hardcoding, ensuring correct rendering in both Obsidian Lens (dark) and Precision Editorial (light) modes. Touch tooltip backgrounds use `surfaceContainerHighest` with `onSurface` text.

### Performance Considerations

- `insightsProvider` is a `StreamProvider` that recomputes when any upstream changes — this is acceptable for the expected collection sizes (hundreds to low thousands of items)
- If performance becomes an issue with very large collections, consider adding dedicated Drift queries for aggregation rather than computing in Dart
- fl_chart widgets should use `const` constructors where possible and avoid rebuilding on every frame

### Export Strategy

The existing `ExportCollectionUseCase` already handles CSV and JSON generation. The insights screen reuses this via a shared provider rather than duplicating the logic. The export includes all collection items — a future enhancement could add filtered export (e.g., only music items, or only items added in the selected time period).

### Backwards Compatibility

The existing `statisticsProvider` and `CollectionStatistics` class are kept unchanged. The dashboard screen (`/`) continues to use `statisticsProvider`. Only the insights screen (`/insights`) migrates to the new `insightsProvider`. This avoids breaking any existing functionality.
