// Media type pie chart using fl_chart.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mymediascanner/app/theme/app_colors.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

/// Donut-style pie chart showing media type distribution.
class MediaTypePieChart extends StatelessWidget {
  const MediaTypePieChart({
    super.key,
    required this.byMediaType,
    required this.totalItems,
  });

  final Map<MediaType, int> byMediaType;
  final int totalItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
            'MEDIA TYPES',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (byMediaType.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No data yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 45,
                      sections: _buildSections(theme),
                      pieTouchData: PieTouchData(
                        touchCallback: (_, _) {},
                      ),
                    ),
                  ),
                  // Centre total count
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$totalItems',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'TOTAL',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          letterSpacing: 1.0,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: byMediaType.entries.map((entry) {
                final colour = _colourForType(entry.key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colour,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${entry.key.label} (${entry.value})',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(ThemeData theme) {
    final sorted = byMediaType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((entry) {
      final percentage = totalItems > 0 ? entry.value / totalItems * 100 : 0.0;
      return PieChartSectionData(
        color: _colourForType(entry.key),
        value: entry.value.toDouble(),
        title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: 35,
        titleStyle: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      );
    }).toList();
  }

  Color _colourForType(MediaType type) {
    return switch (type) {
      MediaType.film => AppColors.filmColor,
      MediaType.tv => AppColors.tvColor,
      MediaType.music => AppColors.musicColor,
      MediaType.book => AppColors.bookColor,
      MediaType.game => AppColors.gameColor,
      MediaType.unknown => AppColors.unknownColor,
    };
  }
}
