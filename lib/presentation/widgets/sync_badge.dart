import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/presentation/providers/connection_health_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/sync_provider.dart';

/// A compact badge showing the current sync state:
///
/// - Green dot: connected and idle
/// - Animated sync icon: active sync in progress
/// - Amber dot: pending changes waiting to sync
/// - Red dot: disconnected or error
///
/// Includes a tooltip with a summary. Only renders when sync is configured.
class SyncBadge extends ConsumerWidget {
  const SyncBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncRepo = ref.watch(syncRepositoryProvider);

    // Only show when sync is configured
    if (syncRepo == null) return const SizedBox.shrink();

    final health = ref.watch(connectionHealthProvider);
    final statusAsync = ref.watch(syncStatusProvider);

    return statusAsync.when(
      loading: () => _buildDot(Colors.grey, 'Checking...'),
      error: (e, _) => _buildDot(Colors.red, 'Error: $e'),
      data: (status) {
        if (status.isSyncing) {
          return _buildSyncingIcon(context);
        }

        if (status.error != null) {
          return _buildDot(Colors.red, 'Error: ${status.error}');
        }

        if (status.conflictCount > 0) {
          return _buildDot(
            Colors.orange,
            '${status.conflictCount} conflict(s)',
          );
        }

        if (status.pendingCount > 0) {
          return _buildDot(
            Colors.amber,
            '${status.pendingCount} pending',
          );
        }

        if (health == ConnectionHealth.disconnected ||
            health == ConnectionHealth.timeout) {
          return _buildDot(Colors.red, 'Disconnected');
        }

        return _buildDot(Colors.green, 'Connected & synced');
      },
    );
  }

  Widget _buildDot(Color colour, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: colour,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildSyncingIcon(BuildContext context) {
    return Tooltip(
      message: 'Syncing...',
      child: SizedBox(
        width: 16,
        height: 16,
        child: Icon(
          Icons.sync,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
