import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/providers/selected_rip_album_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_view_mode_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_album_detail_dialog.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_table_view.dart';
import 'package:mymediascanner/presentation/widgets/empty_state.dart';
import 'package:mymediascanner/presentation/widgets/error_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';
import 'package:mymediascanner/presentation/widgets/master_detail_layout.dart';

/// Displays all rip albums from the local FLAC library with search and scan.
class RipLibraryView extends ConsumerStatefulWidget {
  const RipLibraryView({super.key});

  @override
  ConsumerState<RipLibraryView> createState() => _RipLibraryViewState();
}

class _RipLibraryViewState extends ConsumerState<RipLibraryView> {
  String _searchQuery = '';

  void _onAlbumTap(BuildContext context, RipAlbum album) {
    final width = MediaQuery.sizeOf(context).width;
    final useDetailPanel = PlatformCapability.isDesktop &&
        width >= AppConstants.mediumBreakpoint;
    if (useDetailPanel) {
      ref.read(selectedRipAlbumProvider.notifier).select(album.id);
    } else {
      showDialog<void>(
        context: context,
        builder: (_) => RipAlbumDetailDialog(album: album),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final albumsAsync = ref.watch(allRipAlbumsProvider);
    final scanState = ref.watch(ripScanNotifierProvider);
    final selectedAlbumId = ref.watch(selectedRipAlbumProvider);
    final viewMode = ref.watch(ripViewModeProvider);

    final masterContent = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: SearchBar(
                  hintText: 'Search by artist or album...',
                  leading: const Icon(Icons.search),
                  onChanged: (query) {
                    setState(() {
                      _searchQuery = query.toLowerCase();
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: scanState.status == RipScanStatus.scanning
                    ? null
                    : () => _startScan(ref),
                icon: scanState.status == RipScanStatus.scanning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(scanState.status == RipScanStatus.scanning
                    ? 'Scanning...'
                    : 'Scan Library'),
              ),
              const SizedBox(width: 8),
              SegmentedButton<RipViewMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: RipViewMode.grid,
                    icon: Icon(Icons.grid_view, size: 18),
                  ),
                  ButtonSegment(
                    value: RipViewMode.table,
                    icon: Icon(Icons.table_rows, size: 18),
                  ),
                ],
                selected: {viewMode},
                onSelectionChanged: (selection) {
                  ref
                      .read(ripViewModeProvider.notifier)
                      .setMode(selection.first);
                },
              ),
            ],
          ),
        ),
        if (scanState.status == RipScanStatus.scanning)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: LinearProgressIndicator(
              value: scanState.totalDirectories > 0
                  ? scanState.albumsScanned / scanState.totalDirectories
                  : null,
            ),
          ),
        Expanded(
          child: albumsAsync.when(
            loading: () => const LoadingIndicator(),
            error: (e, _) => ErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(allRipAlbumsProvider),
            ),
            data: (albums) {
              final filtered = _searchQuery.isEmpty
                  ? albums
                  : albums.where((a) {
                      final artist = (a.artist ?? '').toLowerCase();
                      final title = (a.albumTitle ?? '').toLowerCase();
                      return artist.contains(_searchQuery) ||
                          title.contains(_searchQuery);
                    }).toList();

              if (filtered.isEmpty) {
                return const EmptyState(
                  message:
                      'No rip albums found. Use "Scan Library" to discover FLAC rips.',
                  icon: Icons.album_outlined,
                );
              }

              if (viewMode == RipViewMode.table) {
                return RipTableView(
                  albums: filtered,
                  onAlbumTap: (album) => _onAlbumTap(context, album),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  childAspectRatio: 1.3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) => _RipAlbumCard(
                  album: filtered[index],
                  onTap: () => _onAlbumTap(context, filtered[index]),
                ),
              );
            },
          ),
        ),
      ],
    );

    // Build detail panel from selected album
    Widget? detailPanel;
    if (selectedAlbumId != null) {
      final allAlbums = albumsAsync.whenOrNull(data: (a) => a) ?? [];
      final selectedAlbum =
          allAlbums.where((a) => a.id == selectedAlbumId).firstOrNull;
      if (selectedAlbum != null) {
        detailPanel = _RipAlbumDetailPanel(album: selectedAlbum);
      }
    }

    return MasterDetailLayout(
      master: masterContent,
      detail: detailPanel,
    );
  }

  Future<void> _startScan(WidgetRef ref) async {
    final path = ref.read(ripLibraryPathProvider).value;
    if (path == null || path.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Set the FLAC library path in Settings before scanning.'),
        ),
      );
      return;
    }
    unawaited(ref.read(ripScanNotifierProvider.notifier).startScan(path));
  }
}

class _RipAlbumCard extends ConsumerWidget {
  const _RipAlbumCard({required this.album, this.onTap});

  final RipAlbum album;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(ripTracksProvider(album.id));
    final theme = Theme.of(context);

    // Quality summary from tracks
    final tracks = tracksAsync.whenOrNull(data: (t) => t) ?? [];
    final arVerified =
        tracks.where((t) => t.accurateRipStatus == 'verified').length;
    final withClicks = tracks.where((t) => (t.clickCount ?? 0) > 0).length;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ??
            () => showDialog<void>(
                  context: context,
                  builder: (_) => RipAlbumDetailDialog(album: album),
                ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                album.artist ?? 'Unknown Artist',
                style: theme.textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                album.albumTitle ?? 'Unknown Album',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.music_note, size: 14, color: theme.hintColor),
                  const SizedBox(width: 4),
                  Text('${album.trackCount} tracks',
                      style: theme.textTheme.bodySmall),
                  const SizedBox(width: 12),
                  Icon(Icons.storage, size: 14, color: theme.hintColor),
                  const SizedBox(width: 4),
                  Text(_formatSize(album.totalSizeBytes),
                      style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (tracks.isNotEmpty) ...[
                    Icon(
                      Icons.verified,
                      size: 14,
                      color: arVerified == tracks.length
                          ? Colors.green
                          : arVerified > 0
                              ? Colors.amber
                              : theme.hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$arVerified/${tracks.length} AR',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (withClicks > 0) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.warning_amber,
                          size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('$withClicks clicks',
                          style: theme.textTheme.bodySmall),
                    ],
                  ],
                  const Spacer(),
                  if (album.mediaItemId != null)
                    Icon(Icons.link, size: 14, color: theme.colorScheme.primary),
                ],
              ),
            ],
          ),
        ),
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

/// Embedded rip album detail for the master-detail side panel.
class _RipAlbumDetailPanel extends ConsumerWidget {
  const _RipAlbumDetailPanel({required this.album});

  final RipAlbum album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(ripTracksProvider(album.id));
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toolbar
        Material(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.artist ?? 'Unknown Artist',
                        style: theme.textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        album.albumTitle ?? 'Unknown Album',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'Close panel',
                  onPressed: () =>
                      ref.read(selectedRipAlbumProvider.notifier).clear(),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            album.libraryPath,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Divider(),
        // Track listing
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('Tracks', style: theme.textTheme.titleSmall),
        ),
        Expanded(
          child: tracksAsync.when(
            loading: () => const LoadingIndicator(),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (tracks) {
              if (tracks.isEmpty) {
                return const Center(child: Text('No tracks found.'));
              }
              return ListView.builder(
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      track.title ?? 'Track ${track.trackNumber}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    subtitle: track.accurateRipStatus != null
                        ? Text(track.accurateRipStatus!,
                            style: theme.textTheme.bodySmall)
                        : null,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
