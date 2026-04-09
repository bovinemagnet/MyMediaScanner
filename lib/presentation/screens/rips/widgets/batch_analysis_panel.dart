import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/batch_analysis_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

/// Panel displayed above the album grid while a batch quality analysis is
/// queued, running, or complete.
class BatchAnalysisPanel extends ConsumerWidget {
  const BatchAnalysisPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batchAnalysisProvider);

    if (state.status == BatchStatus.idle && state.albumStatuses.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colours = theme.colorScheme;

    final total = state.albumStatuses.length;
    final doneCount = state.albumStatuses.values
        .where((s) => s == AlbumAnalysisStatus.done)
        .length;
    final errorCount = state.albumStatuses.values
        .where((s) => s == AlbumAnalysisStatus.error)
        .length;
    final progress = total > 0 ? doneCount / total : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colours.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                state.status == BatchStatus.complete
                    ? Icons.check_circle_outline
                    : state.status == BatchStatus.running
                        ? Icons.analytics_outlined
                        : Icons.queue_music,
                size: 18,
                color: colours.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.status == BatchStatus.complete
                      ? 'Batch analysis complete — $doneCount/$total done'
                          '${errorCount > 0 ? ', $errorCount errors' : ''}'
                      : state.status == BatchStatus.running
                          ? 'Analysing quality — $doneCount/$total complete'
                          : 'Ready to analyse $total album${total == 1 ? '' : 's'}',
                  style: theme.textTheme.labelMedium,
                ),
              ),
              if (state.status == BatchStatus.idle &&
                  state.albumStatuses.isNotEmpty)
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(batchAnalysisProvider.notifier).startAnalysis(),
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Start'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              if (state.status == BatchStatus.running)
                TextButton(
                  onPressed: () =>
                      ref.read(batchAnalysisProvider.notifier).cancel(),
                  child: const Text('Cancel'),
                ),
              if (state.status == BatchStatus.complete)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Dismiss',
                  onPressed: () =>
                      ref.read(batchAnalysisProvider.notifier).cancel(),
                ),
            ],
          ),
          if (state.status != BatchStatus.idle) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: state.status == BatchStatus.complete ? 1.0 : progress,
            ),
          ],
          const SizedBox(height: 8),
          // Per-album status list (scrollable, capped height)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 160),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final entry in state.albumStatuses.entries)
                  _AlbumStatusRow(albumId: entry.key, status: entry.value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumStatusRow extends ConsumerWidget {
  const _AlbumStatusRow({required this.albumId, required this.status});

  final String albumId;
  final AlbumAnalysisStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.colorScheme;

    final albums = ref.watch(allRipAlbumsProvider).value ?? [];
    final albumMap = {for (final a in albums) a.id: a};
    final album = albumMap[albumId];
    final displayName = album != null
        ? '${album.artist ?? "Unknown"} — ${album.albumTitle ?? "Unknown"}'
        : albumId.substring(0, albumId.length.clamp(0, 8));

    Widget icon;
    switch (status) {
      case AlbumAnalysisStatus.queued:
        icon = Icon(Icons.hourglass_empty, size: 14,
            color: colours.onSurfaceVariant);
      case AlbumAnalysisStatus.analysing:
        icon = SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: colours.primary),
        );
      case AlbumAnalysisStatus.done:
        icon = const Icon(Icons.check_circle, size: 14, color: Colors.green);
      case AlbumAnalysisStatus.error:
        icon = Icon(Icons.error_outline, size: 14, color: colours.error);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayName,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
