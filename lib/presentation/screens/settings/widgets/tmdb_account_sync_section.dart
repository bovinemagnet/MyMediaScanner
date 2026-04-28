import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_connect_dialog.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_import_dialog.dart';

/// Settings card for TMDB account sync. Desktop only.
class TmdbAccountSyncSection extends ConsumerWidget {
  const TmdbAccountSyncSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!PlatformCapability.isDesktop) return const SizedBox.shrink();

    final tmdbKey = (ref.watch(apiKeysProvider).value ?? {})['tmdb'] ?? '';
    if (tmdbKey.trim().isEmpty) return const SizedBox.shrink();

    final connectionAsync = ref.watch(tmdbAccountConnectionProvider);
    final settings = ref.watch(tmdbAccountSyncSettingsProvider);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('TMDB Account Sync',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text(
                'Sign in to TMDB to import your ratings, watchlist, and '
                'favourites.'),
            const SizedBox(height: 12),
            connectionAsync.when(
              loading: () => const _StatusRow(text: 'Loading…'),
              error: (e, _) => _StatusRow(text: 'Error: $e'),
              data: (state) => _ConnectionRow(state: state),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Enable TMDB account sync'),
              value: settings.enabled,
              onChanged: connectionAsync.value is TmdbConnected
                  ? (v) => ref
                      .read(tmdbAccountSyncSettingsProvider.notifier)
                      .setEnabled(v)
                  : null,
            ),
            SwitchListTile(
              title: const Text('Enrich scans with TMDB account state'),
              value: settings.enrichScans,
              onChanged: settings.enabled
                  ? (v) => ref
                      .read(tmdbAccountSyncSettingsProvider.notifier)
                      .setEnrichScans(v)
                  : null,
            ),
            const SwitchListTile(
              title: Text('Two-way sync (coming in next release)'),
              subtitle: Text('Available in slice 2.'),
              value: false,
              onChanged: null,
            ),
            const SwitchListTile(
              title: Text(
                  'Mirror ownership to TMDB list (coming in next release)'),
              subtitle: Text('Available in slice 2.'),
              value: false,
              onChanged: null,
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_download),
                label: const Text('Import account contents'),
                onPressed: connectionAsync.value is TmdbConnected
                    ? () => showDialog(
                          context: context,
                          builder: (_) => const TmdbImportDialog(),
                        )
                    : null,
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.sync),
                label: const Text('Sync TMDB now'),
                onPressed: connectionAsync.value is TmdbConnected
                    ? () => _syncNow(context, ref)
                    : null,
              ),
            ]),
            const SizedBox(height: 8),
            _LastSyncSummary(settings: settings),
          ],
        ),
      ),
    );
  }

  Future<void> _syncNow(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final summary =
        await ref.read(syncTmdbAccountUseCaseProvider).call();
    await ref
        .read(tmdbAccountSyncSettingsProvider.notifier)
        .recordSyncResult(
          pulled: summary.pulled,
          failed: summary.failed,
          error: summary.lastError,
        );
    messenger.showSnackBar(SnackBar(
      content: Text(
          'Synced — pulled ${summary.pulled}, failed ${summary.failed}'),
    ));
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(children: [Text(text)]);
  }
}

class _ConnectionRow extends ConsumerWidget {
  const _ConnectionRow({required this.state});
  final TmdbConnectionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = switch (state) {
      TmdbDisconnected() => 'Disconnected',
      TmdbConnecting() => 'Connecting…',
      TmdbConnected(:final username) => 'Connected as @$username',
      TmdbExpired() =>
        'Reconnect required — your TMDB session expired',
      TmdbConnectionError(:final message) => 'Error: $message',
    };

    final isConnected = state is TmdbConnected;
    return Row(children: [
      Expanded(
        child: Text(label,
            style: state is TmdbExpired
                ? TextStyle(color: Theme.of(context).colorScheme.error)
                : null),
      ),
      if (isConnected)
        TextButton(
          onPressed: () async {
            await ref
                .read(disconnectTmdbAccountUseCaseProvider)
                .call();
            await ref
                .read(tmdbAccountConnectionProvider.notifier)
                .refresh();
          },
          child: const Text('Disconnect'),
        )
      else
        FilledButton(
          onPressed: () async {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const TmdbConnectDialog(),
            );
            await ref
                .read(tmdbAccountConnectionProvider.notifier)
                .refresh();
          },
          child: const Text('Connect'),
        ),
    ]);
  }
}

class _LastSyncSummary extends StatelessWidget {
  const _LastSyncSummary({required this.settings});
  final TmdbAccountSyncSettings settings;

  @override
  Widget build(BuildContext context) {
    final at = settings.lastSyncAt;
    final summary = at == null
        ? 'Never synced'
        : 'Last sync ${at.toLocal()} — pulled '
            '${settings.lastSyncPulled}, failed ${settings.lastSyncFailed}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(summary, style: Theme.of(context).textTheme.bodySmall),
        if (settings.lastError != null)
          Text(settings.lastError!,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error)),
      ],
    );
  }
}
