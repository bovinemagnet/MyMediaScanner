import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';
import 'package:mymediascanner/presentation/providers/connection_health_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/sync_provider.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/sync_conflict_dialog.dart';

class SyncStatusTile extends ConsumerWidget {
  const SyncStatusTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncRepo = ref.watch(syncRepositoryProvider);
    final statusAsync = ref.watch(syncStatusProvider);
    final progressAsync = ref.watch(syncProgressProvider);
    final health = ref.watch(connectionHealthProvider);

    if (syncRepo == null) {
      return const ListTile(
        leading: Icon(Icons.sync_disabled),
        title: Text('Sync not configured'),
        subtitle: Text('Set up PostgreSQL connection first'),
      );
    }

    return statusAsync.when(
      loading: () => const ListTile(
        leading: CircularProgressIndicator(),
        title: Text('Checking sync status...'),
      ),
      error: (e, _) => ListTile(
        leading: const Icon(Icons.error, color: Colors.red),
        title: const Text('Sync error'),
        subtitle: Text(e.toString()),
      ),
      data: (status) {
        final progress = progressAsync.when(
          data: (p) => p,
          loading: () => SyncProgress.idle,
          error: (_, _) => SyncProgress.idle,
        );

        return Column(
          children: [
            ListTile(
              leading: _buildLeadingIcon(status, health),
              title: _buildTitle(status, progress),
              subtitle: _buildSubtitle(status),
              trailing: _buildTrailingAction(context, ref, status),
            ),
            if (status.isSyncing && progress.total > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: progress.fraction,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _progressLabel(progress),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLeadingIcon(SyncStatus status, ConnectionHealth health) {
    final healthColour = _healthColour(health);
    final icon = status.isSyncing
        ? Icons.sync
        : (status.error != null ? Icons.error : Icons.cloud_done);
    final iconColour = status.error != null ? Colors.red : Colors.green;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: iconColour),
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: healthColour,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(SyncStatus status, SyncProgress progress) {
    if (status.isSyncing) {
      return const Text('Syncing...');
    }
    if (status.conflictCount > 0) {
      return Text('${status.conflictCount} conflict(s) need resolution');
    }
    return Text('${status.pendingCount} pending changes');
  }

  Widget _buildSubtitle(SyncStatus status) {
    if (status.error != null) {
      return Text(
        status.error!,
        style: const TextStyle(color: Colors.red),
      );
    }
    if (status.lastSyncedAt != null) {
      return Text(_formatRelativeTime(status.lastSyncedAt!));
    }
    return const Text('Never synced');
  }

  Widget _buildTrailingAction(
    BuildContext context,
    WidgetRef ref,
    SyncStatus status,
  ) {
    return IconButton(
      icon: const Icon(Icons.sync),
      onPressed: status.isSyncing
          ? null
          : () => _triggerSync(context, ref),
      tooltip: 'Sync now',
    );
  }

  Future<void> _triggerSync(BuildContext context, WidgetRef ref) async {
    final summary =
        await ref.read(syncTriggerProvider.notifier).triggerSync();

    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (summary.hasError) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Sync failed: ${summary.error}'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (summary.conflicts > 0) {
      // Show conflict resolution dialog
      final conflicts = await ref.read(syncConflictsProvider.future);
      if (context.mounted && conflicts.isNotEmpty) {
        await SyncConflictDialog.show(context, conflicts);
      }
      messenger.showSnackBar(
        SnackBar(
          content:
              Text('Sync complete — ${summary.conflicts} conflict(s) detected'),
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Sync complete')),
      );
    }
  }

  String _progressLabel(SyncProgress progress) {
    final phase = progress.phase == SyncPhase.push ? 'Pushing' : 'Pulling';
    final entity = progress.currentEntityType ?? 'items';
    return '$phase ${progress.current}/${progress.total} $entity...';
  }

  Color _healthColour(ConnectionHealth health) {
    return switch (health) {
      ConnectionHealth.connected => Colors.green,
      ConnectionHealth.timeout => Colors.amber,
      ConnectionHealth.disconnected => Colors.red,
      ConnectionHealth.unconfigured => Colors.grey,
    };
  }

  /// Format an epoch millisecond timestamp as a relative time string.
  String _formatRelativeTime(int epochMs) {
    final now = DateTime.now();
    final then = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final diff = now.difference(then);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      final mins = diff.inMinutes;
      return '$mins minute${mins == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      final hours = diff.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays == 1) {
      return 'Yesterday at ${then.hour.toString().padLeft(2, '0')}:${then.minute.toString().padLeft(2, '0')}';
    }
    return '${diff.inDays} days ago';
  }
}
