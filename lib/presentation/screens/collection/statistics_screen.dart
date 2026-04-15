// Insights & Analytics screen.
//
// Author: Paul Snow
// Since: 0.0.0

import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/insights_data.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/providers/statistics_provider.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/export_action_bar.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/growth_chart.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/lending_stats_card.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/media_type_pie_chart.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/rip_coverage_card.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/time_period_selector.dart';
import 'package:mymediascanner/presentation/widgets/error_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider);
    final collectionAsync = ref.watch(collectionProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDesktop = PlatformCapability.isDesktop;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(title: const Text('Insights & Analytics')),
      body: insightsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(insightsProvider),
        ),
        data: (insights) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            // ── Header ───────────────────────────────────────────
            if (isDesktop)
              const ScreenHeader(
                title: 'Analytics',
                subtitle:
                    'Deep dive into your media collection. Precision tracking '
                    'for your physical and digital assets.',
                padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
              ),

            const SizedBox(height: 16),

            // ── Time period selector ─────────────────────────────
            const TimePeriodSelector(),

            const SizedBox(height: 16),

            // ── Hero stat bento grid ─────────────────────────────
            _HeroBentoGrid(insights: insights, theme: theme, colors: colors),

            const SizedBox(height: 16),

            // ── Collection growth chart ──────────────────────────
            GrowthChart(monthlyGrowth: insights.monthlyGrowth),

            const SizedBox(height: 16),

            // ── Collection value tile ────────────────────────────
            _CollectionValueTile(
              totalValue: insights.totalValue,
              theme: theme,
              colors: colors,
            ),

            const SizedBox(height: 16),

            // ── Middle row: Genre bars + Media type pie chart ────
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _GenreBarChart(
                          byGenre: insights.byGenre,
                          theme: theme,
                          colors: colors,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MediaTypePieChart(
                          byMediaType: insights.byMediaType,
                          totalItems: insights.totalItems,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    _GenreBarChart(
                      byGenre: insights.byGenre,
                      theme: theme,
                      colors: colors,
                    ),
                    const SizedBox(height: 16),
                    MediaTypePieChart(
                      byMediaType: insights.byMediaType,
                      totalItems: insights.totalItems,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // ── By year chart ────────────────────────────────────
            _ByYearCard(byYear: insights.byYear),

            const SizedBox(height: 16),

            // ── Lending + Rip coverage cards ─────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final hasLending = insights.activeLoansCount > 0 ||
                    insights.totalLoansAllTime > 0;
                final hasRips = insights.totalRipAlbums > 0 ||
                    insights.totalMusicItems > 0;
                final isWide = constraints.maxWidth > 900;

                if (!hasLending && !hasRips) {
                  return const SizedBox.shrink();
                }

                final lendingCard = hasLending
                    ? LendingStatsCard(
                        activeLoansCount: insights.activeLoansCount,
                        overdueCount: insights.overdueCount,
                        totalLoansAllTime: insights.totalLoansAllTime,
                        topBorrowers: insights.topBorrowers,
                        mostBorrowedItems: insights.mostBorrowedItems,
                      )
                    : null;

                final ripCard = hasRips
                    ? RipCoverageCard(
                        totalRipAlbums: insights.totalRipAlbums,
                        matchedRipAlbums: insights.matchedRipAlbums,
                        unmatchedRipAlbums: insights.unmatchedRipAlbums,
                        totalRipSizeBytes: insights.totalRipSizeBytes,
                        musicItemsWithRips: insights.musicItemsWithRips,
                        totalMusicItems: insights.totalMusicItems,
                      )
                    : null;

                if (isWide && lendingCard != null && ripCard != null) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: lendingCard),
                      const SizedBox(width: 16),
                      Expanded(child: ripCard),
                    ],
                  );
                }

                return Column(
                  children: [
                    ?lendingCard,
                    if (lendingCard != null && ripCard != null)
                      const SizedBox(height: 16),
                    ?ripCard,
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // ── Export action bar ─────────────────────────────────
            const ExportActionBar(),

            const SizedBox(height: 32),

            // ── Top rated items gallery ──────────────────────────
            _TopRatedGallery(collectionAsync: collectionAsync),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Hero bento grid — 3–4 stat cards in a Material Design bento layout
// ═══════════════════════════════════════════════════════════════════════

class _HeroBentoGrid extends StatelessWidget {
  const _HeroBentoGrid({
    required this.insights,
    required this.theme,
    required this.colors,
  });

  final InsightsData insights;
  final ThemeData theme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final mediaTypeCount = insights.byMediaType.length;

        if (isWide) {
          // Bento layout: large card left (2 cols), two stacked right
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Large total items card
                Expanded(
                  flex: 2,
                  child: _LargeStatCard(
                    label: 'Items Catalogued',
                    value: '${insights.totalItems}',
                    subtitle: '$mediaTypeCount media types tracked',
                    icon: Icons.inventory_2,
                    colors: colors,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 12),
                // Right column: rating gauge + rated count
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _RatingGaugeCard(
                          rating: insights.averageRating,
                          colors: colors,
                          theme: theme,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _CompactStatCard(
                          label: 'Rated',
                          value: '${insights.ratedCount}',
                          icon: Icons.star,
                          colors: colors,
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Genre count
                Expanded(
                  child: _CompactStatCard(
                    label: 'Genres',
                    value: '${insights.byGenre.length}',
                    icon: Icons.category,
                    colors: colors,
                    theme: theme,
                  ),
                ),
              ],
            ),
          );
        }

        // Narrow layout: stack vertically
        return Column(
          children: [
            _LargeStatCard(
              label: 'Items Catalogued',
              value: '${insights.totalItems}',
              subtitle: '$mediaTypeCount media types tracked',
              icon: Icons.inventory_2,
              colors: colors,
              theme: theme,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _RatingGaugeCard(
                    rating: insights.averageRating,
                    colors: colors,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CompactStatCard(
                    label: 'Rated',
                    value: '${insights.ratedCount}',
                    icon: Icons.star,
                    colors: colors,
                    theme: theme,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _LargeStatCard extends StatelessWidget {
  const _LargeStatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.theme,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: theme.textTheme.displayLarge?.copyWith(
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.trending_up, size: 16, color: colors.primary),
                  const SizedBox(width: 6),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Background decoration
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              icon,
              size: 120,
              color: colors.primary.withValues(alpha: 0.05),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingGaugeCard extends StatelessWidget {
  const _RatingGaugeCard({
    required this.rating,
    required this.colors,
    required this.theme,
  });

  final double? rating;
  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final percentage = rating != null ? (rating! / 5.0 * 100) : 0.0;
    final displayValue =
        rating != null ? rating!.toStringAsFixed(1) : '—';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(
              painter: _GaugePainter(
                percentage: percentage,
                trackColor: colors.surfaceContainerHighest,
                progressColor: colors.primary,
              ),
              child: Center(
                child: Text(
                  displayValue,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'AVG RATING',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.percentage,
    required this.trackColor,
    required this.progressColor,
  });

  final double percentage;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    const strokeWidth = 6.0;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (percentage > 0) {
      final sweepAngle = (percentage / 100) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      percentage != oldDelegate.percentage;
}

class _CompactStatCard extends StatelessWidget {
  const _CompactStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.colors,
    required this.theme,
  });

  final String label;
  final String value;
  final IconData icon;
  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: colors.primary, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Collection value tile — sum of pricePaid over owned items
// ═══════════════════════════════════════════════════════════════════════

class _CollectionValueTile extends StatelessWidget {
  const _CollectionValueTile({
    required this.totalValue,
    required this.theme,
    required this.colors,
  });

  final double? totalValue;
  final ThemeData theme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.simpleCurrency();
    final display = totalValue != null ? formatter.format(totalValue) : '—';

    return Container(
      key: const Key('collection-value-tile'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_money, color: colors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COLLECTION VALUE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  display,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Genre bar chart — vertical bars like the mockup
// ═══════════════════════════════════════════════════════════════════════

class _GenreBarChart extends StatelessWidget {
  const _GenreBarChart({
    required this.byGenre,
    required this.theme,
    required this.colors,
  });

  final Map<String, int> byGenre;
  final ThemeData theme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(minHeight: 320),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Genre Distribution',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 24),
          if (byGenre.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No genre data available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: _VerticalBarChart(
                entries: byGenre,
                colors: colors,
                theme: theme,
              ),
            ),
        ],
      ),
    );
  }
}

class _VerticalBarChart extends StatelessWidget {
  const _VerticalBarChart({
    required this.entries,
    required this.colors,
    required this.theme,
  });

  final Map<String, int> entries;
  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final sorted = entries.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final display = sorted.take(8).toList();
    final maxValue =
        display.fold<int>(0, (m, e) => e.value > m ? e.value : m);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: display.asMap().entries.map((indexed) {
        final entry = indexed.value;
        final fraction = maxValue > 0 ? entry.value / maxValue : 0.0;
        final isTop = indexed.key == 0;

        // Vary opacity for visual interest
        final opacity = 0.3 + (fraction * 0.7);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Value label on top
                Text(
                  '${entry.value}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isTop
                        ? colors.onSurface
                        : colors.onSurfaceVariant,
                    fontWeight:
                        isTop ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                // Bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  height: 160 * fraction,
                  decoration: BoxDecoration(
                    color: isTop
                        ? colors.primary
                        : colors.primary.withValues(alpha: opacity),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    boxShadow: isTop
                        ? [
                            BoxShadow(
                              color:
                                  colors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                // Genre label
                Text(
                  entry.key,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 9,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// By year horizontal bar chart
// ═══════════════════════════════════════════════════════════════════════

class _ByYearCard extends StatelessWidget {
  const _ByYearCard({required this.byYear});

  final Map<int, int> byYear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (byYear.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BY YEAR',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No year data available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final sortedEntries = byYear.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final maxCount = sortedEntries.fold<int>(
        0, (max, entry) => entry.value > max ? entry.value : max);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ITEMS BY YEAR',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedEntries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Text(
                        '${entry.key}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final fraction =
                              maxCount > 0 ? entry.value / maxCount : 0.0;
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              height: 20,
                              width: constraints.maxWidth * fraction,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colors.primary,
                                    colors.primaryContainer,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${entry.value}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Top rated items gallery — horizontal scroll like "High-Value Assets"
// ═══════════════════════════════════════════════════════════════════════

class _TopRatedGallery extends StatelessWidget {
  const _TopRatedGallery({required this.collectionAsync});

  final AsyncValue collectionAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Rated',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/collection'),
              child: Text(
                'View Full Library',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: collectionAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: Text(
                'Could not load items',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            data: (items) {
              // Sort by rating desc, take top rated with covers
              final allItems = items as List;
              final rated = allItems
                  .where((item) => item.userRating != null)
                  .toList()
                ..sort((a, b) =>
                    (b.userRating ?? 0).compareTo(a.userRating ?? 0));

              final display =
                  rated.isEmpty ? allItems.take(10).toList() : rated.take(10).toList();

              if (display.isEmpty) {
                return Center(
                  child: Text(
                    'No items to display',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                );
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: display.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = display[index];
                  return _GalleryItemCard(
                    title: item.title,
                    subtitle: item.mediaType.label,
                    imageUrl: item.coverUrl,
                    rating: item.userRating,
                    colors: colors,
                    theme: theme,
                    onTap: () =>
                        context.go('/collection/item/${item.id}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GalleryItemCard extends StatelessWidget {
  const _GalleryItemCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.rating,
    required this.colors,
    required this.theme,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final double? rating;
  final ColorScheme colors;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null)
                      CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const SizedBox.shrink(),
                        errorWidget: (_, _, _) => Icon(
                          Icons.image_not_supported,
                          color: colors.onSurfaceVariant,
                        ),
                      )
                    else
                      Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: colors.onSurfaceVariant,
                      ),
                    // Rating badge
                    if (rating != null)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  size: 10, color: Colors.amber),
                              const SizedBox(width: 3),
                              Text(
                                rating!.toStringAsFixed(1),
                                style: theme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            // Subtitle
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
