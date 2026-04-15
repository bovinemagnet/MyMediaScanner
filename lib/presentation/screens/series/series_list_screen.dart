// Series list — grid of every detected franchise/collection with a
// completeness bar.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/series.dart';
import 'package:mymediascanner/presentation/providers/series_provider.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';

class SeriesListScreen extends ConsumerWidget {
  const SeriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSeries = ref.watch(allSeriesProvider);
    final isDesktop = PlatformCapability.isDesktop;

    return Scaffold(
      appBar: isDesktop ? null : AppBar(title: const Text('Series')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop)
              const ScreenHeader(
                title: 'Series',
                subtitle:
                    'Franchises and collections detected from your media '
                    'metadata, with completeness percentages.',
              ),
            Expanded(
              child: asyncSeries.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (series) {
                  if (series.isEmpty) return const _EmptyState();
                  return _SeriesGrid(series: series);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.collections_bookmark_outlined,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text('No series yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Series populate automatically as items with collection or '
            'release-group metadata are saved.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesGrid extends StatelessWidget {
  const _SeriesGrid({required this.series});

  final List<SeriesWithCounts> series;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisExtent: 140,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: series.length,
      itemBuilder: (context, index) => _SeriesCard(entry: series[index]),
    );
  }
}

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({required this.entry});

  final SeriesWithCounts entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final completeness = entry.completeness;
    final total = entry.totalCount;

    return InkWell(
      onTap: () => context.go('/series/${entry.series.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.series.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${entry.series.source} · ${entry.series.mediaType.label}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              total != null
                  ? '${entry.ownedCount} of $total owned'
                  : '${entry.ownedCount} owned',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: completeness,
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
