import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/api_key_form.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/sync_status_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sync section
          Text('Sync', style: Theme.of(context).textTheme.titleMedium),
          const SyncStatusTile(),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('PostgreSQL Configuration'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/postgres'),
          ),
          const Divider(height: 32),

          // API Keys section
          const ApiKeyForm(),
          const Divider(height: 32),

          // Preferences section
          Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          // Theme — placeholder for full implementation
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('System default'),
            onTap: () {
              // Theme picker — SET-07
            },
          ),

          const Divider(height: 32),

          // Danger zone
          Text('Data', style: Theme.of(context).textTheme.titleMedium),
          ListTile(
            leading: Icon(Icons.warning,
                color: Theme.of(context).colorScheme.error),
            title: const Text('Reset & Re-sync'),
            subtitle: const Text('Replace local data with remote'),
            onTap: () => _confirmReset(context, ref),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset local database?'),
        content: const Text(
            'This will replace all local data with data from your PostgreSQL server. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // Trigger full re-sync SYNC-09
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
