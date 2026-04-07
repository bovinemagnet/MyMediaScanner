// Collection growth line chart using fl_chart.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/time_period_selector.dart';

/// Line chart showing cumulative collection growth over time.
class GrowthChart extends ConsumerWidget {
  const GrowthChart({
    super.key,
    required this.monthlyGrowth,
  });

  /// Items added per month: {'2026-01': 5, '2026-02': 12, ...}
  final Map<String, int> monthlyGrowth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final timePeriod = ref.watch(timePeriodProvider);

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
            'COLLECTION GROWTH',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (monthlyGrowth.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No growth data available yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: _GrowthLineChart(
                monthlyGrowth: monthlyGrowth,
                timePeriod: timePeriod,
                colors: colors,
                theme: theme,
              ),
            ),
        ],
      ),
    );
  }
}

class _GrowthLineChart extends StatelessWidget {
  const _GrowthLineChart({
    required this.monthlyGrowth,
    required this.timePeriod,
    required this.colors,
    required this.theme,
  });

  final Map<String, int> monthlyGrowth;
  final TimePeriod timePeriod;
  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    // Sort months chronologically
    final sortedKeys = monthlyGrowth.keys.toList()..sort();

    // Filter by time period
    final filteredKeys = _filterByTimePeriod(sortedKeys, timePeriod);
    if (filteredKeys.isEmpty) {
      return Center(
        child: Text(
          'No data for selected period',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      );
    }

    // Build cumulative data points
    final spots = <FlSpot>[];
    var cumulative = 0;

    // Add items before the filtered period to the cumulative count
    for (final key in sortedKeys) {
      if (filteredKeys.contains(key)) break;
      cumulative += monthlyGrowth[key] ?? 0;
    }

    for (var i = 0; i < filteredKeys.length; i++) {
      cumulative += monthlyGrowth[filteredKeys[i]] ?? 0;
      spots.add(FlSpot(i.toDouble(), cumulative.toDouble()));
    }

    final maxY = spots.isEmpty
        ? 10.0
        : (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.1);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 10 ? (maxY / 5).ceilToDouble() : 2,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colors.outlineVariant.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: filteredKeys.length > 6
                  ? (filteredKeys.length / 6).ceilToDouble()
                  : 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= filteredKeys.length) {
                  return const SizedBox.shrink();
                }
                // Show short month label: '2026-01' → 'Jan'
                final parts = filteredKeys[idx].split('-');
                final month = int.tryParse(parts.length > 1 ? parts[1] : '');
                final label = _monthAbbr(month);
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (filteredKeys.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => colors.surfaceContainerHighest,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final idx = spot.x.toInt();
                final monthLabel =
                    idx < filteredKeys.length ? filteredKeys[idx] : '';
                return LineTooltipItem(
                  '$monthLabel\n${spot.y.toInt()} items',
                  TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: colors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: filteredKeys.length <= 12,
              getDotPainter: (spot, percent, bar, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: colors.primary,
                  strokeWidth: 1.5,
                  strokeColor: colors.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.primary.withValues(alpha: 0.3),
                  colors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _filterByTimePeriod(
      List<String> sortedKeys, TimePeriod period) {
    if (period == TimePeriod.allTime || sortedKeys.isEmpty) {
      return sortedKeys;
    }

    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - period.months, 1);

    return sortedKeys.where((key) {
      final parts = key.split('-');
      if (parts.length < 2) return false;
      final year = int.tryParse(parts[0]) ?? 0;
      final month = int.tryParse(parts[1]) ?? 0;
      final date = DateTime(year, month);
      return date.isAfter(cutoff) || date.isAtSameMomentAs(cutoff);
    }).toList();
  }

  String _monthAbbr(int? month) {
    const abbrs = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    if (month == null || month < 1 || month > 12) return '';
    return abbrs[month];
  }
}
