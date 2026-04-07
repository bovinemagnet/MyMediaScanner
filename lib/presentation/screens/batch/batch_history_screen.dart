// Batch history screen — read-only list of past batch sessions.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/app/theme/app_colors.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/presentation/providers/batch_editor_provider.dart';
import 'package:mymediascanner/presentation/providers/batch_history_provider.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';

class BatchHistoryScreen extends ConsumerWidget {
  const BatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHistory = ref.watch(batchHistoryProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDesktop = PlatformCapability.isDesktop;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(title: const Text('Batch History')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            const ScreenHeader(
              title: 'Batch History',
              subtitle: 'Review past batch scanning sessions and their '
                  'outcomes.',
            ),
          Expanded(
            child: asyncHistory.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Error loading history: $error'),
              ),
              data: (sessions) => sessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history, size: 64,
                              color: colors.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text(
                            'No batch history yet',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Completed or discarded batch sessions will '
                            'appear here.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _SessionList(
                      sessions: sessions,
                      theme: theme,
                      colors: colors,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionList extends ConsumerWidget {
  const _SessionList({
    required this.sessions,
    required this.theme,
    required this.colors,
  });

  final List<BatchSessionSummary> sessions;
  final ThemeData theme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length + 1, // +1 for load-more button
      itemBuilder: (context, index) {
        if (index == sessions.length) {
          final notifier = ref.read(batchHistoryProvider.notifier);
          if (!notifier.hasMore) return const SizedBox.shrink();
          return Center(
            child: TextButton(
              onPressed: () => notifier.loadMore(),
              child: const Text('Load More'),
            ),
          );
        }

        final session = sessions[index];
        return _SessionCard(
          session: session,
          theme: theme,
          colors: colors,
        );
      },
    );
  }
}

class _SessionCard extends StatefulWidget {
  const _SessionCard({
    required this.session,
    required this.theme,
    required this.colors,
  });

  final BatchSessionSummary session;
  final ThemeData theme;
  final ColorScheme colors;

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final theme = widget.theme;
    final colors = widget.colors;

    final isCompleted = session.status == 'completed';
    final statusColor = isCompleted ? AppColors.bookColor : colors.error;
    final statusLabel = isCompleted ? 'COMPLETED' : 'DISCARDED';

    final dateStr = _formatDateTime(session.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: session.items.isNotEmpty
                ? () => setState(() => _expanded = !_expanded)
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Status icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle : Icons.cancel,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Session info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateStr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${session.itemCount} items \u2022 '
                          '${session.savedCount} saved',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  if (session.items.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        _expanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_expanded && session.items.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12)),
              ),
              child: Column(
                children: [
                  for (final item in session.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _statusColor(item.status, colors),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.title,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            item.status.name.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _statusColor(item.status, colors),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _statusColor(BatchItemStatus status, ColorScheme colors) {
    return switch (status) {
      BatchItemStatus.confirmed => AppColors.bookColor,
      BatchItemStatus.conflict => colors.error,
      BatchItemStatus.notFound => colors.outline,
      BatchItemStatus.duplicate => colors.tertiary,
      BatchItemStatus.saved => colors.primary,
    };
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today at ${_timeStr(dt)}';
    if (diff.inDays == 1) return 'Yesterday at ${_timeStr(dt)}';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year} at ${_timeStr(dt)}';
  }

  String _timeStr(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
