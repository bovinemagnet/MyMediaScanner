// Lending statistics card for the insights dashboard.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Card showing lending analytics: active loans, overdue count,
/// top borrowers bar chart, and most borrowed items list.
class LendingStatsCard extends StatelessWidget {
  const LendingStatsCard({
    super.key,
    required this.activeLoansCount,
    required this.overdueCount,
    required this.totalLoansAllTime,
    required this.topBorrowers,
    required this.mostBorrowedItems,
  });

  final int activeLoansCount;
  final int overdueCount;
  final int totalLoansAllTime;
  final Map<String, int> topBorrowers;
  final Map<String, int> mostBorrowedItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final hasData = activeLoansCount > 0 ||
        totalLoansAllTime > 0 ||
        topBorrowers.isNotEmpty;

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
            'LENDING',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (!hasData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No lending activity yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else ...[
            // ── Summary row ─────────────────────────────────
            Row(
              children: [
                _StatBadge(
                  icon: Icons.swap_horiz,
                  value: '$activeLoansCount',
                  label: 'Active',
                  colour: colors.primary,
                  theme: theme,
                ),
                const SizedBox(width: 16),
                if (overdueCount > 0)
                  _StatBadge(
                    icon: Icons.warning_amber_rounded,
                    value: '$overdueCount',
                    label: 'Overdue',
                    colour: colors.error,
                    theme: theme,
                  ),
                if (overdueCount > 0) const SizedBox(width: 16),
                _StatBadge(
                  icon: Icons.history,
                  value: '$totalLoansAllTime',
                  label: 'All time',
                  colour: colors.onSurfaceVariant,
                  theme: theme,
                ),
              ],
            ),

            // ── Top borrowers bar chart ─────────────────────
            if (topBorrowers.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'TOP BORROWERS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 1.0,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: _BorrowerBarChart(
                  data: topBorrowers,
                  colors: colors,
                  theme: theme,
                ),
              ),
            ],

            // ── Most borrowed items ─────────────────────────
            if (mostBorrowedItems.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'MOST BORROWED',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 1.0,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 8),
              ...mostBorrowedItems.entries.take(5).map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${entry.value}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.colour,
    required this.theme,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color colour;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: colour),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colour,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colour.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BorrowerBarChart extends StatelessWidget {
  const _BorrowerBarChart({
    required this.data,
    required this.colors,
    required this.theme,
  });

  final Map<String, int> data;
  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxVal = entries.fold<int>(0, (m, e) => e.value > m ? e.value : m);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal.toDouble() * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => colors.surfaceContainerHighest,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final name =
                  groupIndex < entries.length ? entries[groupIndex].key : '';
              return BarTooltipItem(
                '$name\n${rod.toY.toInt()} loans',
                TextStyle(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          leftTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= entries.length) {
                  return const SizedBox.shrink();
                }
                final name = entries[idx].key;
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    name.length > 8 ? '${name.substring(0, 7)}…' : name,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((indexed) {
          return BarChartGroupData(
            x: indexed.key,
            barRods: [
              BarChartRodData(
                toY: indexed.value.value.toDouble(),
                color: colors.primary,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
