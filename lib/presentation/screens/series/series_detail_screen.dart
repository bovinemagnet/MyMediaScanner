// Series detail — shows owned items in this series and lets the user
// navigate to each.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/series.dart';
import 'package:mymediascanner/presentation/providers/series_provider.dart';

class SeriesDetailScreen extends ConsumerWidget {
  const SeriesDetailScreen({super.key, required this.seriesId});

  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSeries = ref.watch(allSeriesProvider);
    final asyncItems = ref.watch(seriesItemsProvider(seriesId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: asyncSeries.when(
          loading: () => const Text('Series'),
          error: (_, _) => const Text('Series'),
          data: (list) {
            final entry = _findEntry(list, seriesId);
            return Text(entry?.series.name ?? 'Series');
          },
        ),
      ),
      body: asyncSeries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          final entry = _findEntry(list, seriesId);
          if (entry == null) {
            return const Center(child: Text('Series not found.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CompletenessBar(entry: entry),
                const SizedBox(height: 16),
                Text(
                  'OWNED ENTRIES',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: asyncItems.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (items) {
                      if (items.isEmpty) {
                        return const Center(
                          child: Text('No owned entries yet.'),
                        );
                      }
                      return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final item = items[i];
                          return ListTile(
                            leading: item.coverUrl != null
                                ? Image.network(item.coverUrl!,
                                    width: 36,
                                    height: 54,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        const Icon(Icons.image_not_supported))
                                : const Icon(Icons.movie_outlined),
                            title: Text(item.title),
                            subtitle: item.seriesPosition != null
                                ? Text('#${item.seriesPosition}')
                                : (item.year != null
                                    ? Text('${item.year}')
                                    : null),
                            onTap: () =>
                                context.go('/collection/item/${item.id}'),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  SeriesWithCounts? _findEntry(List<SeriesWithCounts> all, String id) {
    for (final s in all) {
      if (s.series.id == id) return s;
    }
    return null;
  }
}

class _CompletenessBar extends StatelessWidget {
  const _CompletenessBar({required this.entry});

  final SeriesWithCounts entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final total = entry.totalCount;
    final completeness = entry.completeness;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            total != null
                ? '${entry.ownedCount} of $total owned'
                : '${entry.ownedCount} owned (total unknown)',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completeness,
              minHeight: 8,
            ),
          ),
          if (completeness != null) ...[
            const SizedBox(height: 6),
            Text(
              '${(completeness * 100).round()}% complete',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
