import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
import 'package:mymediascanner/presentation/providers/playlist_provider.dart';
import 'package:mymediascanner/presentation/providers/queue_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/providers/selected_rip_album_provider.dart';
import 'package:mymediascanner/presentation/widgets/desktop_context_menu.dart';
import 'package:mymediascanner/presentation/widgets/table_keyboard_navigation.dart';

/// Sortable data table for the rips library, used on desktop.
class RipTableView extends ConsumerStatefulWidget {
  const RipTableView({
    super.key,
    required this.albums,
    required this.onAlbumTap,
  });

  final List<RipAlbum> albums;
  final ValueChanged<RipAlbum> onAlbumTap;

  @override
  ConsumerState<RipTableView> createState() => _RipTableViewState();
}

class _RipTableViewState extends ConsumerState<RipTableView> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late List<RipAlbum> _sorted;

  @override
  void initState() {
    super.initState();
    _sorted = List.of(widget.albums);
  }

  @override
  void didUpdateWidget(covariant RipTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.albums != oldWidget.albums) {
      _sorted = List.of(widget.albums);
      _applySortIfSet();
    }
  }

  void _sort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _applySortIfSet();
    });
  }

  void _applySortIfSet() {
    if (_sortColumnIndex == null) return;
    _sorted.sort((a, b) {
      final cmp = switch (_sortColumnIndex) {
        0 => (a.artist ?? '').compareTo(b.artist ?? ''),
        1 => (a.albumTitle ?? '').compareTo(b.albumTitle ?? ''),
        2 => a.trackCount.compareTo(b.trackCount),
        3 => a.totalSizeBytes.compareTo(b.totalSizeBytes),
        _ => 0,
      };
      return _sortAscending ? cmp : -cmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedRipAlbumProvider);
    final nowPlayingAlbumId = ref.watch(
      nowPlayingProvider.select((s) => s.album?.id),
    );
    final albumIds = _sorted.map((a) => a.id).toList();

    return TableKeyboardNavigation(
      onMoveUp: () =>
          ref.read(selectedRipAlbumProvider.notifier).movePrevious(albumIds),
      onMoveDown: () =>
          ref.read(selectedRipAlbumProvider.notifier).moveNext(albumIds),
      onMoveToFirst: () {
        if (albumIds.isNotEmpty) {
          ref.read(selectedRipAlbumProvider.notifier).select(albumIds.first);
        }
      },
      onMoveToLast: () {
        if (albumIds.isNotEmpty) {
          ref.read(selectedRipAlbumProvider.notifier).select(albumIds.last);
        }
      },
      onSelect: () {
        if (selectedId != null) {
          final album = _sorted.firstWhere(
            (a) => a.id == selectedId,
            orElse: () => _sorted.first,
          );
          widget.onAlbumTap(album);
        }
      },
      onClearSelection: () =>
          ref.read(selectedRipAlbumProvider.notifier).clear(),
      child: DataTable2(
      columnSpacing: 12,
      horizontalMargin: 16,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      headingRowDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      columns: [
        DataColumn2(
          label: const Text('Artist'),
          size: ColumnSize.M,
          onSort: _sort,
        ),
        DataColumn2(
          label: const Text('Album'),
          size: ColumnSize.L,
          onSort: _sort,
        ),
        DataColumn2(
          label: const Text('Tracks'),
          fixedWidth: 70,
          numeric: true,
          onSort: _sort,
        ),
        DataColumn2(
          label: const Text('Size'),
          fixedWidth: 90,
          numeric: true,
          onSort: _sort,
        ),
        const DataColumn2(
          label: Text('AR'),
          fixedWidth: 80,
        ),
        const DataColumn2(
          label: Text('Linked'),
          fixedWidth: 60,
        ),
      ],
      rows: _sorted.map((album) {
        final tracksAsync = ref.watch(ripTracksProvider(album.id));
        final tracks = tracksAsync.whenOrNull(data: (t) => t) ?? [];
        final arVerified =
            tracks.where((t) => t.accurateRipStatus == 'verified').length;

        return DataRow2(
          selected: album.id == selectedId,
          color: album.id == nowPlayingAlbumId
              ? WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.08))
              : null,
          onTap: () => widget.onAlbumTap(album),
          onSecondaryTapDown: (details) => showDesktopContextMenu(
            context,
            details.globalPosition,
            _buildAlbumContextMenu(album, tracks),
          ),
          cells: [
            DataCell(Text(
              album.artist ?? 'Unknown',
              overflow: TextOverflow.ellipsis,
            )),
            DataCell(Text(
              album.albumTitle ?? 'Unknown',
              overflow: TextOverflow.ellipsis,
            )),
            DataCell(Text('${album.trackCount}')),
            DataCell(Text(_formatSize(album.totalSizeBytes))),
            DataCell(Text(
                tracks.isEmpty ? '' : '$arVerified/${tracks.length}')),
            DataCell(Icon(
              album.mediaItemId != null ? Icons.link : Icons.link_off,
              size: 16,
              color: album.mediaItemId != null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            )),
          ],
        );
      }).toList(),
      ),
    );
  }

  List<ContextMenuAction> _buildAlbumContextMenu(
    RipAlbum album,
    List<RipTrack> tracks,
  ) {
    final albumLabel = album.albumTitle ?? 'Album';
    return [
      ContextMenuAction(
        label: 'Play',
        icon: Icons.play_arrow,
        onTap: () => _playAlbum(album, tracks),
      ),
      ContextMenuAction(
        label: 'Add to Queue',
        icon: Icons.playlist_add,
        onTap: () => _addAlbumToQueue(album, tracks, albumLabel),
      ),
      ContextMenuAction(
        label: 'Add to Playlist...',
        icon: Icons.queue_music,
        onTap: () => _showAddAlbumToPlaylistDialog(album, tracks, albumLabel),
      ),
      ContextMenuAction(
        label: 'Open Details',
        icon: Icons.open_in_new,
        onTap: () => widget.onAlbumTap(album),
      ),
    ];
  }

  Future<void> _playAlbum(RipAlbum album, List<RipTrack> tracks) async {
    if (tracks.isEmpty) {
      _showSnack('No tracks loaded for this album yet');
      return;
    }
    await ref
        .read(playbackActionProvider.notifier)
        .playAlbum(album: album, tracks: tracks);
  }

  void _addAlbumToQueue(
    RipAlbum album,
    List<RipTrack> tracks,
    String albumLabel,
  ) {
    if (tracks.isEmpty) {
      _showSnack('No tracks loaded for this album yet');
      return;
    }
    ref.read(queueProvider.notifier).addAlbumToQueue(album, tracks);
    _showSnack('Added "$albumLabel" to queue');
  }

  Future<void> _showAddAlbumToPlaylistDialog(
    RipAlbum album,
    List<RipTrack> tracks,
    String albumLabel,
  ) async {
    if (tracks.isEmpty) {
      _showSnack('No tracks loaded for this album yet');
      return;
    }
    final playlists = ref.read(allPlaylistsProvider).value;
    if (playlists == null || playlists.isEmpty) {
      _showSnack('No playlists found. Create a playlist first.');
      return;
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Add Album to Playlist'),
        children: [
          for (final playlist in playlists)
            SimpleDialogOption(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final trackIds = tracks.map((t) => t.id).toList();
                await ref
                    .read(playlistCrudProvider.notifier)
                    .addTracksToPlaylist(playlist.id, trackIds);
                if (mounted) {
                  _showSnack('Added "$albumLabel" to "${playlist.name}"');
                }
              },
              child: Text(playlist.name),
            ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  }
}
