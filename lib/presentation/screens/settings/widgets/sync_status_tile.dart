import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/usecases/sync_collection_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/sync_provider.dart';

class SyncStatusTile extends ConsumerWidget {
  const SyncStatusTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncRepo = ref.watch(syncRepositoryProvider);
    final statusAsync = ref.watch(syncStatusProvider);

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
      data: (status) => ListTile(
        leading: Icon(
          status.isSyncing ? Icons.sync : Icons.cloud_done,
          color: status.error != null ? Colors.red : Colors.green,
        ),
        title: Text(status.isSyncing
            ? 'Syncing...'
            : '${status.pendingCount} pending changes'),
        subtitle: status.lastSyncedAt != null
            ? Text(
                'Last synced: ${DateTime.fromMillisecondsSinceEpoch(status.lastSyncedAt!)}')
            : const Text('Never synced'),
        trailing: IconButton(
          icon: const Icon(Icons.sync),
          onPressed: status.isSyncing
              ? null
              : () {
                  SyncCollectionUseCase(repository: syncRepo).execute();
                },
          tooltip: 'Sync now',
        ),
      ),
    );
  }
}
