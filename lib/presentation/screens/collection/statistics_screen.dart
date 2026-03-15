// Collection statistics dashboard screen.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/app/theme/app_colors.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/providers/statistics_provider.dart';
import 'package:mymediascanner/presentation/widgets/error_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Statistics'),
      ),
      body: statsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(statisticsProvider),
        ),
        data: (stats) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _TotalItemsCard(total: stats.totalItems),
            const SizedBox(height: 16),
            _ByMediaTypeCard(byMediaType: stats.byMediaType),
            const SizedBox(height: 16),
            _ByYearCard(byYear: stats.byYear),
            const SizedBox(height: 16),
            _TopGenresCard(byGenre: stats.byGenre),
            const SizedBox(height: 16),
            _AverageRatingCard(
              averageRating: stats.averageRating,
              ratedCount: stats.ratedCount,
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalItemsCard extends StatelessWidget {
  const _TotalItemsCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Total Items',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '$total',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ByMediaTypeCard extends StatelessWidget {
  const _ByMediaTypeCard({required this.byMediaType});

  final Map<MediaType, int> byMediaType;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By Media Type', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (byMediaType.isEmpty)
              Text('No items yet', style: theme.textTheme.bodyMedium)
            else
              ...byMediaType.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _colourForType(entry.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(entry.key.label)),
                        Text(
                          '${entry.value}',
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _ByYearCard extends StatelessWidget {
  const _ByYearCard({required this.byYear});

  final Map<int, int> byYear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (byYear.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('By Year', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Text('No year data available', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    final sortedEntries = byYear.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final maxCount = sortedEntries.fold<int>(
        0, (max, entry) => entry.value > max ? entry.value : max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By Year (Top 10)', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ...sortedEntries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 48,
                        child: Text('${entry.key}',
                            style: theme.textTheme.bodySmall),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final fraction =
                                maxCount > 0 ? entry.value / maxCount : 0.0;
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 20,
                                width: constraints.maxWidth * fraction,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${entry.value}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _TopGenresCard extends StatelessWidget {
  const _TopGenresCard({required this.byGenre});

  final Map<String, int> byGenre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Genres', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (byGenre.isEmpty)
              Text('No genre data available',
                  style: theme.textTheme.bodyMedium)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: byGenre.entries
                    .map((entry) => Chip(
                          label: Text('${entry.key} (${entry.value})'),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _AverageRatingCard extends StatelessWidget {
  const _AverageRatingCard({
    required this.averageRating,
    required this.ratedCount,
  });

  final double? averageRating;
  final int ratedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Average Rating', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (averageRating == null)
              Text('No rated items yet', style: theme.textTheme.bodyMedium)
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(5, (index) {
                    final starValue = index + 1;
                    if (averageRating! >= starValue) {
                      return const Icon(Icons.star,
                          color: Colors.amber, size: 32);
                    } else if (averageRating! >= starValue - 0.5) {
                      return const Icon(Icons.star_half,
                          color: Colors.amber, size: 32);
                    } else {
                      return const Icon(Icons.star_border,
                          color: Colors.amber, size: 32);
                    }
                  }),
                  const SizedBox(width: 12),
                  Text(
                    averageRating!.toStringAsFixed(1),
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Based on $ratedCount rated item${ratedCount == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
