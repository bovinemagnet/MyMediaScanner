import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/conflict_policy_selector.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/remote_first_warning_dialog.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_connect_dialog.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_disconnect_warning_dialog.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_import_dialog.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_pending_changes_dialog.dart';

/// Settings card for TMDB account sync.
class TmdbAccountSyncSection extends ConsumerWidget {
  const TmdbAccountSyncSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            SwitchListTile(
              title: const Text('Push local changes to TMDB'),
              subtitle: const Text('Two-way sync — your edits propagate.'),
              value: settings.twoWaySync,
              onChanged: connectionAsync.value is TmdbConnected
                  ? (v) => ref
                      .read(tmdbAccountSyncSettingsProvider.notifier)
                      .setTwoWaySync(v)
                  : null,
            ),
            SwitchListTile(
              title: const Text('Mirror ownership to TMDB list (movies only)'),
              subtitle: const Text(
                  'Owned movies are added to a private TMDB list called "MyMediaScanner".'),
              value: settings.mirrorOwnership,
              onChanged: connectionAsync.value is TmdbConnected
                  ? (v) => ref
                      .read(tmdbAccountSyncSettingsProvider.notifier)
                      .setMirrorOwnership(v)
                  : null,
            ),
            SwitchListTile(
              title: const Text('Allow remote-first save (film/TV)'),
              subtitle: const Text(
                  'Save scanned or added titles to TMDB only — no local collection record.'),
              value: settings.remoteFirstSaveEnabled,
              onChanged: connectionAsync.value is TmdbConnected
                  ? (v) => _toggleRemoteFirst(
                      context, ref, v, settings.remoteFirstSaveEnabled)
                  : null,
            ),
            const SizedBox(height: 12),
            ConflictPolicySelector(
                enabled: connectionAsync.value is TmdbConnected),
            const SizedBox(height: 12),
            // Pending row — non-conflict dirty changes.
            ref.watch(tmdbPendingChangesProvider).when(
              loading: () => const SizedBox.shrink(),
              error: (err, _) => const SizedBox.shrink(),
              data: (pending) {
                if (pending.isEmpty) return const SizedBox.shrink();
                return Row(children: [
                  Icon(Icons.cloud_upload,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text('${pending.length} pending change'
                          '${pending.length == 1 ? '' : 's'} to push')),
                  TextButton.icon(
                    icon: const Icon(Icons.list, size: 16),
                    label: const Text('View & retry'),
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const TmdbPendingChangesDialog(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    icon: const Icon(Icons.sync, size: 16),
                    label: const Text('Push all now'),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final keys = pending
                          .map((p) => TmdbBridgeKey(
                              tmdbId: p.tmdbId, mediaType: p.mediaType))
                          .toList();
                      final summary =
                          await ref.read(retryPushUseCaseProvider).retry(keys);
                      if (!context.mounted) return;
                      messenger.showSnackBar(SnackBar(
                        content: Text('Pushed ${summary.succeeded} of '
                            '${summary.attempted}; ${summary.failed} failed.'),
                      ));
                    },
                  ),
                ]);
              },
            ),
            // Conflict row — only when at least one conflict exists.
            ref.watch(tmdbConflictCountProvider).when(
              loading: () => const SizedBox.shrink(),
              error: (err, _) => const SizedBox.shrink(),
              data: (count) {
                if (count == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(children: [
                    Icon(Icons.warning_amber,
                        size: 16,
                        color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text('$count conflict'
                            '${count == 1 ? '' : 's'} need resolution')),
                    TextButton.icon(
                      icon: const Icon(Icons.rule, size: 16),
                      label: const Text('Resolve'),
                      onPressed: () => context.go('/tmdb/conflicts'),
                    ),
                  ]),
                );
              },
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
          onPressed: () => _disconnectWithCheck(context, ref),
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

Future<void> _disconnectWithCheck(
    BuildContext context, WidgetRef ref) async {
  final dirty =
      await ref.read(tmdbAccountSyncRepositoryProvider).countDirtyRows();
  if (dirty > 0 && context.mounted) {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TmdbDisconnectWarningDialog(dirtyCount: dirty),
    );
  } else {
    await ref.read(disconnectTmdbAccountUseCaseProvider).call();
    await ref.read(tmdbAccountConnectionProvider.notifier).refresh();
  }
}

Future<void> _toggleRemoteFirst(
  BuildContext context,
  WidgetRef ref,
  bool requested,
  bool currentValue,
) async {
  // First flip-on shows the warning dialog; flip-off is unconditional.
  if (requested && !currentValue) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const RemoteFirstWarningDialog(),
    );
    if (confirmed != true) return;
  }
  await ref
      .read(tmdbAccountSyncSettingsProvider.notifier)
      .setRemoteFirstSaveEnabled(requested);
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
