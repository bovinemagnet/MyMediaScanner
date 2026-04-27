/// Playlist detail panel for the Rips Playlists segment.
///
/// Shows playlist header (name, description, track count) and the ordered
/// track listing. Provides edit (rename), delete, and per-track remove actions.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/queue_item.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
import 'package:mymediascanner/presentation/providers/playlist_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/playback_widgets.dart';

/// Detail panel for a single playlist identified by [playlistId].
class PlaylistDetail extends ConsumerWidget {
  /// Creates a [PlaylistDetail].
  const PlaylistDetail({super.key, required this.playlistId});

  /// The playlist to display.
  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(allPlaylistsProvider);
    final tracksAsync = ref.watch(playlistTracksProvider(playlistId));
    final ripTracksAsync = ref.watch(playlistRipTracksProvider(playlistId));

    return playlistsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (playlists) {
        final playlist =
            playlists.where((p) => p.id == playlistId).firstOrNull;
        if (playlist == null) {
          return const Center(child: Text('Playlist not found.'));
        }

        return tracksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading tracks: $e')),
          data: (tracks) {
            // Build lookup from the SQL-joined result: ripTrackId -> row.
            // Avoids loading every album's tracks separately in the widget.
            final ripTrackLookup = <String, RipTracksTableData>{
              for (final rt in (ripTracksAsync.value ?? [])) rt.id: rt,
            };
            return _PlaylistDetailContent(
              playlist: playlist,
              tracks: tracks,
              ripTrackLookup: ripTrackLookup,
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Detail content
// ---------------------------------------------------------------------------

class _PlaylistDetailContent extends ConsumerWidget {
  const _PlaylistDetailContent({
    required this.playlist,
    required this.tracks,
    required this.ripTrackLookup,
  });

  final PlaylistsTableData playlist;
  final List<PlaylistTracksTableData> tracks;

  /// Pre-computed map from ripTrackId -> [RipTracksTableData], built by a
  /// SQL join in [PlaylistDao.getRipTracksForPlaylist].
  final Map<String, RipTracksTableData> ripTrackLookup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final trackCount = tracks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        _buildHeader(context, ref, theme, colors, trackCount),

        // Track listing
        Expanded(
          child: tracks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.queue_music,
                        size: 48,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No tracks in this playlist',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add tracks from the Library or save your queue.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              colors.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final pt = tracks[index];
                    final ripRow = ripTrackLookup[pt.ripTrackId];
                    return _PlaylistTrackTile(
                      index: index + 1,
                      playlistTrackId: pt.id,
                      playlistId: playlist.id,
                      ripTrack: ripRow,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colors,
    int trackCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover art placeholder
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.playlist_play,
                  size: 40,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (playlist.description != null &&
                        playlist.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        playlist.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '$trackCount ${trackCount == 1 ? 'track' : 'tracks'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Edit + delete icons
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: 'Rename playlist',
                onPressed: () => _showRenameDialog(context, ref),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: colors.error,
                ),
                tooltip: 'Delete playlist',
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: trackCount == 0
                ? null
                : () async {
                    // Build QueueItems using the pre-resolved ripTrackLookup.
                    // RipTracksTableData is converted to domain RipTrack inline
                    // so QueueItem receives the expected type.
                    //
                    // Await the future rather than reading `.value`; on cold
                    // launch (or right after a refresh) the albums provider
                    // is still loading and `.value` is null, so the prior
                    // `?? []` made the lookup-by-album-id below produce an
                    // empty queue and the Play All button silently no-op'd.
                    final List<RipAlbum> albums;
                    try {
                      albums = await ref.read(allRipAlbumsProvider.future);
                    } on Object {
                      // Provider error path — bail rather than play an empty
                      // queue.
                      return;
                    }
                    final albumById = {for (final a in albums) a.id: a};

                    final items = tracks.map((pt) {
                      final row = ripTrackLookup[pt.ripTrackId];
                      if (row == null) return null;
                      final album = albumById[row.ripAlbumId];
                      if (album == null) return null;
                      final track = RipTrack(
                        id: row.id,
                        ripAlbumId: row.ripAlbumId,
                        discNumber: row.discNumber,
                        trackNumber: row.trackNumber,
                        title: row.title,
                        filePath: row.filePath,
                        durationMs: row.durationMs,
                        fileSizeBytes: row.fileSizeBytes,
                        updatedAt: row.updatedAt,
                        accurateRipStatus: row.accurateripStatus,
                        accurateRipConfidence: row.accurateripConfidence,
                        accurateRipCrcV1: row.accurateripCrcV1,
                        accurateRipCrcV2: row.accurateripCrcV2,
                        peakLevel: row.peakLevel,
                        trackQuality: row.trackQuality,
                        copyCrc: row.copyCrc,
                        clickCount: row.clickCount,
                        ripLogSource: row.ripLogSource,
                        qualityCheckedAt: row.qualityCheckedAt,
                      );
                      return QueueItem(
                        album: album,
                        track: track,
                        source: QueueItemSource.playlist,
                      );
                    }).whereType<QueueItem>().toList();

                    if (items.isEmpty) return;
                    await ref
                        .read(playbackActionProvider.notifier)
                        .playPlaylist(items);
                  },
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Play All'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(120, 36),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: playlist.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Playlist name'),
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    if (confirmed == true && controller.text.trim().isNotEmpty) {
      await ref
          .read(playlistCrudProvider.notifier)
          .renamePlaylist(playlist.id, controller.text.trim());
    }
    controller.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text(
            'Delete "${playlist.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(playlistCrudProvider.notifier)
          .deletePlaylist(playlist.id);
    }
  }
}

// ---------------------------------------------------------------------------
// Track tile
// ---------------------------------------------------------------------------

class _PlaylistTrackTile extends ConsumerWidget {
  const _PlaylistTrackTile({
    required this.index,
    required this.playlistTrackId,
    required this.playlistId,
    this.ripTrack,
  });

  final int index;
  final String playlistTrackId;
  final String playlistId;
  final RipTracksTableData? ripTrack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final title = ripTrack?.title ?? 'Track $index';
    final subtitle = ripTrack != null ? 'Track ${ripTrack!.trackNumber}' : '';
    final albumId = ripTrack?.ripAlbumId;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$index',
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (albumId != null)
            AlbumCoverArt(albumId: albumId, size: 36)
          else
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.music_note,
                size: 18,
                color: colors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
        ],
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            )
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline, size: 18),
        tooltip: 'Remove from playlist',
        onPressed: () => ref
            .read(playlistCrudProvider.notifier)
            .removeTrackFromPlaylist(playlistId, playlistTrackId),
      ),
    );
  }
}
