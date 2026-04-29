import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/entities/tmdb_pending_change.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';

class TmdbPendingChangesDialog extends ConsumerWidget {
  const TmdbPendingChangesDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(tmdbPendingChangesProvider);
    final progress = ref.watch(tmdbPushProgressProvider);

    return PopScope(
      canPop: !progress.inFlight,
      child: AlertDialog(
        title: const Text('Pending TMDB changes'),
        content: SizedBox(
          width: 480,
          child: pendingAsync.when(
            loading: () => const SizedBox(
                height: 60,
                child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text('Error loading pending changes: $e'),
            data: (pending) {
              final failed = pending.where((p) => p.hasFailed).toList();
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text('${pending.length} pending '
                          '(${failed.length} failed)'),
                    ),
                    if (failed.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry all failed'),
                        onPressed: progress.inFlight
                            ? null
                            : () => _retryAllFailed(ref, failed),
                      ),
                  ]),
                  if (progress.inFlight) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                        value: progress.total == 0
                            ? null
                            : progress.current / progress.total),
                    const SizedBox(height: 4),
                    Text('Pushing ${progress.current} of ${progress.total}…'),
                  ],
                  const SizedBox(height: 12),
                  if (pending.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('All caught up — no pending changes.'),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: pending.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, i) => _PendingChangeTile(
                          change: pending[i],
                          onRetry: progress.inFlight
                              ? null
                              : () => _retryOne(ref, pending[i]),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: progress.inFlight
                  ? null
                  : () => Navigator.of(context).pop(),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _retryAllFailed(
      WidgetRef ref, List<TmdbPendingChange> failed) async {
    final keys = failed
        .map((p) => TmdbBridgeKey(tmdbId: p.tmdbId, mediaType: p.mediaType))
        .toList();
    await ref.read(retryPushUseCaseProvider).retry(keys);
  }

  Future<void> _retryOne(WidgetRef ref, TmdbPendingChange change) async {
    final key = TmdbBridgeKey(
        tmdbId: change.tmdbId, mediaType: change.mediaType);
    await ref.read(retryPushUseCaseProvider).retryOne(key);
  }
}

class _PendingChangeTile extends StatelessWidget {
  const _PendingChangeTile({required this.change, required this.onRetry});

  final TmdbPendingChange change;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(change.title ?? 'Untitled (TMDB id ${change.tmdbId})'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (change.actions.isEmpty)
            const Text('Pending change',
                style: TextStyle(fontStyle: FontStyle.italic))
          else
            Wrap(spacing: 6, runSpacing: 4, children: [
              for (final a in change.actions) _actionChip(a),
            ]),
          if (change.lastError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                change.lastError!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12),
              ),
            ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.refresh),
        tooltip: 'Retry this change',
        onPressed: onRetry,
      ),
    );
  }

  Widget _actionChip(TmdbPendingAction action) {
    final label = switch (action) {
      TmdbPendingActionRating(:final value) =>
        'Rating ${value.toStringAsFixed(1)}★',
      TmdbPendingActionWatchlist() => 'On watchlist',
      TmdbPendingActionFavourite() => 'Favourited',
    };
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
