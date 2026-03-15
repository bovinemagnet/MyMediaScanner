import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_album_detail_dialog.dart';
import 'package:mymediascanner/presentation/widgets/empty_state.dart';
import 'package:mymediascanner/presentation/widgets/error_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

/// Displays all rip albums from the local FLAC library with search and scan.
class RipLibraryView extends ConsumerStatefulWidget {
  const RipLibraryView({super.key});

  @override
  ConsumerState<RipLibraryView> createState() => _RipLibraryViewState();
}

class _RipLibraryViewState extends ConsumerState<RipLibraryView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final albumsAsync = ref.watch(allRipAlbumsProvider);
    final scanState = ref.watch(ripScanNotifierProvider);

    return Column(
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

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  childAspectRatio: 1.3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) =>
                    _RipAlbumCard(album: filtered[index]),
              );
            },
          ),
        ),
      ],
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
  const _RipAlbumCard({required this.album});

  final RipAlbum album;

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
        onTap: () => showDialog<void>(
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
