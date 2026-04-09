/// Playlist grid view for the Rips Playlists segment.
///
/// Shows all playlists as cards in a grid; selecting one opens [PlaylistDetail]
/// in the detail pane via [MasterDetailLayout].
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/presentation/providers/playlist_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/playlist_detail.dart';
import 'package:mymediascanner/presentation/widgets/master_detail_layout.dart';

/// Top-level playlist grid + detail split for the Rips Playlists segment.
class PlaylistView extends ConsumerWidget {
  /// Creates a [PlaylistView].
  const PlaylistView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(allPlaylistsProvider);
    final selectedId = ref.watch(selectedPlaylistProvider);

    final masterContent = playlistsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading playlists: $e')),
      data: (playlists) => _PlaylistGrid(
        playlists: playlists,
        selectedId: selectedId,
      ),
    );

    return MasterDetailLayout(
      master: masterContent,
      detail: selectedId != null ? PlaylistDetail(playlistId: selectedId) : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Grid with header
// ---------------------------------------------------------------------------

class _PlaylistGrid extends ConsumerWidget {
  const _PlaylistGrid({
    required this.playlists,
    required this.selectedId,
  });

  final List<PlaylistsTableData> playlists;
  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        // Header row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Text(
                  'My Playlists',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _showNewPlaylistDialog(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Playlist'),
                ),
              ],
            ),
          ),
        ),

        // Empty state
        if (playlists.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.playlist_play,
                    size: 64,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No playlists yet',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create one with the button above, or save your queue.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisExtent: 220,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final playlist = playlists[index];
                  return _PlaylistCard(
                    playlist: playlist,
                    isSelected: playlist.id == selectedId,
                    onTap: () => ref
                        .read(selectedPlaylistProvider.notifier)
                        .select(playlist.id),
                  );
                },
                childCount: playlists.length,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showNewPlaylistDialog(
      BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Playlist'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Playlist name',
            hintText: 'e.g. Late Night Chill',
          ),
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed == true && nameController.text.trim().isNotEmpty) {
      final id = await ref
          .read(playlistCrudProvider.notifier)
          .createPlaylist(nameController.text.trim());
      ref.read(selectedPlaylistProvider.notifier).select(id);
    }
    nameController.dispose();
  }
}

// ---------------------------------------------------------------------------
// Playlist card
// ---------------------------------------------------------------------------

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({
    required this.playlist,
    required this.isSelected,
    required this.onTap,
  });

  final PlaylistsTableData playlist;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final created = DateTime.fromMillisecondsSinceEpoch(playlist.createdAt);
    final dateStr =
        '${created.day.toString().padLeft(2, '0')}/'
        '${created.month.toString().padLeft(2, '0')}/'
        '${created.year}';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primaryContainer.withValues(alpha: 0.4)
              : colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.6)
                : colors.outlineVariant.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover art placeholder
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(11),
                  ),
                ),
                child: Icon(
                  Icons.playlist_play,
                  size: 56,
                  color: isSelected
                      ? colors.primary.withValues(alpha: 0.8)
                      : colors.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? colors.primary : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
