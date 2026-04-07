import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/sync_provider.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';

/// Screen showing paginated sync history log entries with direction icon,
/// entity type, timestamp, status chip, error expansion, and clear action.
class SyncLogViewer extends ConsumerStatefulWidget {
  const SyncLogViewer({super.key});

  @override
  ConsumerState<SyncLogViewer> createState() => _SyncLogViewerState();
}

class _SyncLogViewerState extends ConsumerState<SyncLogViewer> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDesktop = PlatformCapability.isDesktop;
    final historyAsync = ref.watch(syncHistoryProvider(_currentPage));

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Sync History'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: 'Clear history',
                  onPressed: () => _confirmClear(context, ref),
                ),
              ],
            ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) ...[
              Row(
                children: [
                  Expanded(
                    child: ScreenHeader(
                      title: 'Sync History',
                      subtitle: 'View past sync operations and their results.',
                      padding: const EdgeInsets.only(bottom: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    tooltip: 'Clear history',
                    onPressed: () => _confirmClear(context, ref),
                  ),
                ],
              ),
            ],
            Expanded(
              child: historyAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Error loading history: $e'),
                ),
                data: (entries) {
                  if (entries.isEmpty && _currentPage == 0) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No sync history yet',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return _SyncLogEntryTile(entry: entries[index]);
                    },
                  );
                },
              ),
            ),
            // Pagination controls
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 0
                        ? () => setState(() => _currentPage--)
                        : null,
                  ),
                  Text('Page ${_currentPage + 1}'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => setState(() => _currentPage++),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear sync history?'),
        content: const Text(
          'This will remove all sync log entries. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(syncRepositoryProvider);
              if (repo != null) {
                await repo.purgeSyncHistory(
                  DateTime.now().millisecondsSinceEpoch,
                );
                ref.invalidate(syncHistoryProvider);
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _SyncLogEntryTile extends StatefulWidget {
  const _SyncLogEntryTile({required this.entry});

  final SyncLogEntry entry;

  @override
  State<_SyncLogEntryTile> createState() => _SyncLogEntryTileState();
}

class _SyncLogEntryTileState extends State<_SyncLogEntryTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final entry = widget.entry;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(entry.createdAt);
    final timeStr =
        '${timestamp.day}/${timestamp.month}/${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: entry.errorMessage != null
          ? () => setState(() => _expanded = !_expanded)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Direction icon
                Icon(
                  _directionIcon(entry.direction),
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                // Entity info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.operation} — ${entry.entityType}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status chip
                _StatusChip(
                  synced: entry.synced,
                  hasError: entry.errorMessage != null,
                ),
                // Duration
                if (entry.durationMs != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${entry.durationMs}ms',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            // Error expansion
            if (_expanded && entry.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(left: 28, top: 4),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.errorContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    entry.errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.error,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _directionIcon(String? direction) {
    return switch (direction) {
      'push' => Icons.cloud_upload,
      'pull' => Icons.cloud_download,
      _ => Icons.sync,
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.synced,
    required this.hasError,
  });

  final bool synced;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (hasError) {
      return Chip(
        label: const Text('Error'),
        backgroundColor: colors.errorContainer,
        labelStyle: TextStyle(
          color: colors.onErrorContainer,
          fontSize: 11,
        ),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      );
    }

    if (synced) {
      return Chip(
        label: const Text('Synced'),
        backgroundColor: Colors.green.withValues(alpha: 0.15),
        labelStyle: const TextStyle(
          color: Colors.green,
          fontSize: 11,
        ),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      );
    }

    return Chip(
      label: const Text('Pending'),
      backgroundColor: Colors.amber.withValues(alpha: 0.15),
      labelStyle: const TextStyle(
        color: Colors.amber,
        fontSize: 11,
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
