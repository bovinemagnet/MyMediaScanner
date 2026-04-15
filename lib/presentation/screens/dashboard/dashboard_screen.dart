// Dashboard / home screen.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/providers/statistics_provider.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/media_item_card.dart';
import 'package:mymediascanner/presentation/screens/dashboard/widgets/random_pick_tile.dart';
import 'package:mymediascanner/presentation/widgets/gradient_button.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final collectionAsync = ref.watch(collectionProvider);
    final statsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Digital\nVault.',
                      style: theme.textTheme.displayMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Catalogue anything in seconds.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      onPressed: () => context.go('/scan'),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code_scanner, size: 20),
                          SizedBox(width: 8),
                          Text('Quick Scan'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Collection insights
              statsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (stats) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _StatCard(
                        label: 'Total Items',
                        value: stats.totalItems.toString(),
                        colors: colors,
                        theme: theme,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Average Rating',
                        value: (stats.averageRating ?? 0) > 0
                            ? stats.averageRating!.toStringAsFixed(1)
                            : '—',
                        colors: colors,
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quick actions
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(child: RandomPickTile()),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Recent additions
              ScreenHeader(
                title: 'Recent Additions',
                actions: [
                  TextButton(
                    onPressed: () => context.go('/collection'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              SizedBox(
                height: 220,
                child: collectionAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Center(
                    child: Text('Could not load collection',
                        style: theme.textTheme.bodyMedium),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          'Scan your first item to get started!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      );
                    }
                    final recent = items.take(10).toList();
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: recent.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = recent[index];
                        return SizedBox(
                          width: 140,
                          child: MediaItemCard(
                            item: item,
                            isLent: false,
                            isRipped: false,
                            onTap: () => context.go('/collection/item/${item.id}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.colors,
    required this.theme,
  });

  final String label;
  final String value;
  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
