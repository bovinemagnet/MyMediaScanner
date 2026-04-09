/// Queue panel widget for the rip library view.
///
/// Displays the current play queue with now-playing highlight, drag-reorder
/// for upcoming tracks, and a scrollable history section.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/queue_item.dart';
import 'package:mymediascanner/presentation/providers/queue_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/playback_widgets.dart';

/// A 320px wide side panel showing the play queue.
///
/// Sections:
/// - **Now Playing** – highlighted row with cover art.
/// - **Up Next** – [ReorderableListView] with drag handles.
/// - **History** – last 50 played items, dimmed.
/// - **Footer** – "Save as Playlist" placeholder button.
class QueuePanel extends ConsumerWidget {
  /// Creates a [QueuePanel].
  const QueuePanel({super.key});

  static const double _panelWidth = 320;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final queue = ref.watch(queueProvider);

    final currentItem = queue.currentIndex >= 0 &&
            queue.currentIndex < queue.items.length
        ? queue.items[queue.currentIndex]
        : null;

    // Items after the current index
    final upNextStart = queue.currentIndex + 1;
    final upNextItems = upNextStart < queue.items.length
        ? queue.items.sublist(upNextStart)
        : <QueueItem>[];

    // History list — most recent at bottom; we show most recent at top
    final history = queue.history.reversed.toList();

    return SizedBox(
      width: _panelWidth,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          border: Border(
            left: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, ref, colors, theme),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  if (currentItem != null) ...[
                    _sectionLabel(context, 'NOW PLAYING', theme, colors),
                    _NowPlayingTile(item: currentItem),
                  ],
                  if (upNextItems.isNotEmpty) ...[
                    _sectionLabel(context, 'UP NEXT', theme, colors),
                    _UpNextList(
                      items: upNextItems,
                      startIndex: upNextStart,
                    ),
                  ],
                  if (history.isNotEmpty) ...[
                    _sectionLabel(context, 'HISTORY', theme, colors),
                    for (final item in history)
                      _HistoryTile(item: item),
                  ],
                  if (currentItem == null &&
                      upNextItems.isEmpty &&
                      history.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'The queue is empty.\nStart playing an album to populate it.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _buildFooter(context, colors, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref,
      ColorScheme colors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Queue',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => ref.read(queueProvider.notifier).clear(),
            icon: const Icon(Icons.clear_all, size: 18),
            label: const Text('Clear'),
            style: TextButton.styleFrom(
              foregroundColor: colors.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
      BuildContext context, ColorScheme colors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: OutlinedButton.icon(
        onPressed: null, // placeholder — playlist save not yet implemented
        icon: const Icon(Icons.playlist_add, size: 18),
        label: const Text('Save as Playlist'),
      ),
    );
  }

  Widget _sectionLabel(
      BuildContext context, String label, ThemeData theme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Now Playing tile
// ---------------------------------------------------------------------------

class _NowPlayingTile extends StatelessWidget {
  const _NowPlayingTile({required this.item});

  final QueueItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final trackTitle = item.track.title ?? 'Track ${item.track.trackNumber}';
    final artist = item.album.artist ?? 'Unknown Artist';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.4),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: AlbumCoverArt(albumId: item.album.id, size: 40),
        title: Text(
          trackTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.primary,
          ),
        ),
        subtitle: Text(
          artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        trailing: Icon(Icons.volume_up, size: 18, color: colors.primary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Up Next reorderable list
// ---------------------------------------------------------------------------

class _UpNextList extends ConsumerWidget {
  const _UpNextList({
    required this.items,
    required this.startIndex,
  });

  /// Slice of [QueueState.items] after the current index.
  final List<QueueItem> items;

  /// The absolute index in [QueueState.items] corresponding to [items][0].
  final int startIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      onReorder: (oldIndex, newIndex) {
        // ReorderableListView passes newIndex *before* removal adjustment
        if (newIndex > oldIndex) newIndex -= 1;
        ref.read(queueProvider.notifier).reorder(
              startIndex + oldIndex,
              startIndex + newIndex,
            );
      },
      itemBuilder: (context, index) {
        final item = items[index];
        final absoluteIndex = startIndex + index;
        return _UpNextTile(
          key: ValueKey(item.track.id),
          item: item,
          absoluteIndex: absoluteIndex,
        );
      },
    );
  }
}

class _UpNextTile extends ConsumerWidget {
  const _UpNextTile({
    super.key,
    required this.item,
    required this.absoluteIndex,
  });

  final QueueItem item;
  final int absoluteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final trackTitle = item.track.title ?? 'Track ${item.track.trackNumber}';
    final artist = item.album.artist ?? 'Unknown Artist';

    return ListTile(
      contentPadding:
          const EdgeInsets.only(left: 12, right: 4, top: 2, bottom: 2),
      leading: AlbumCoverArt(albumId: item.album.id, size: 36),
      title: Text(
        trackTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Text(
        artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            tooltip: 'Remove from queue',
            onPressed: () =>
                ref.read(queueProvider.notifier).removeAt(absoluteIndex),
          ),
          ReorderableDragStartListener(
            index: absoluteIndex - (ref.read(queueProvider).currentIndex + 1),
            child: const Icon(Icons.drag_handle, size: 20),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// History tile
// ---------------------------------------------------------------------------

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final QueueItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final trackTitle = item.track.title ?? 'Track ${item.track.trackNumber}';
    final artist = item.album.artist ?? 'Unknown Artist';

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Opacity(
        opacity: 0.5,
        child: AlbumCoverArt(albumId: item.album.id, size: 32),
      ),
      title: Text(
        trackTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
          fontSize: 11,
        ),
      ),
    );
  }
}
