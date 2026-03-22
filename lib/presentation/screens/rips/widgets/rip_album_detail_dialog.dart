import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/quality_widgets.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

/// Dialog showing detailed information about a rip album.
class RipAlbumDetailDialog extends ConsumerWidget {
  const RipAlbumDetailDialog({super.key, required this.album});

  final RipAlbum album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(ripTracksProvider(album.id));
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.artist ?? 'Unknown Artist',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          album.albumTitle ?? 'Unknown Album',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                album.libraryPath,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(height: 24),

              // Link section
              _LinkSection(album: album),

              const Divider(height: 24),

              // Quality analysis
              QualityAnalysisSection(albumId: album.id),
              const SizedBox(height: 12),

              // Track listing
              Text('Tracks', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
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
                      itemBuilder: (context, index) =>
                          _TrackTile(track: tracks[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkSection extends ConsumerWidget {
  const _LinkSection({required this.album});

  final RipAlbum album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (album.mediaItemId != null) {
      return Row(
        children: [
          const Icon(Icons.link, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Linked to collection item',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton.icon(
            onPressed: () => context.go('/item/${album.mediaItemId}'),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('View'),
          ),
          TextButton.icon(
            onPressed: () async {
              await ref
                  .read(ripLibraryRepositoryProvider)
                  .unlinkFromMediaItem(album.id);
              ref.invalidate(allRipAlbumsProvider);
              ref.invalidate(rippedItemIdsProvider);
            },
            icon: const Icon(Icons.link_off, size: 16),
            label: const Text('Unlink'),
          ),
        ],
      );
    }

    return FilledButton.icon(
      onPressed: () => _showLinkPicker(context, ref),
      icon: const Icon(Icons.link),
      label: const Text('Link to collection'),
    );
  }

  Future<void> _showLinkPicker(BuildContext context, WidgetRef ref) async {
    final selected = await showDialog<MediaItem>(
      context: context,
      builder: (dialogContext) => _MusicItemPickerDialog(ref: ref),
    );

    if (selected != null) {
      await ref
          .read(ripLibraryRepositoryProvider)
          .linkToMediaItem(album.id, selected.id);
      ref.invalidate(allRipAlbumsProvider);
      ref.invalidate(rippedItemIdsProvider);
    }
  }
}

class _MusicItemPickerDialog extends StatefulWidget {
  const _MusicItemPickerDialog({required this.ref});

  final WidgetRef ref;

  @override
  State<_MusicItemPickerDialog> createState() => _MusicItemPickerDialogState();
}

class _MusicItemPickerDialogState extends State<_MusicItemPickerDialog> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Select a music item to link',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SearchBar(
                hintText: 'Search music items...',
                leading: const Icon(Icons.search),
                onChanged: (q) => setState(() => _search = q),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<List<MediaItem>>(
                  stream: widget.ref
                      .read(mediaItemRepositoryProvider)
                      .watchAll(
                        mediaType: MediaType.music,
                        searchQuery:
                            _search.isNotEmpty ? _search : null,
                      ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingIndicator();
                    }
                    final items = snapshot.data ?? [];
                    if (items.isEmpty) {
                      return const Center(
                          child: Text('No music items found.'));
                    }
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(item.title),
                          subtitle: Text(item.subtitle ?? ''),
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({required this.track});

  final RipTrack track;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      leading: QualityIcon(track: track),
      title: Text(
        track.title ?? 'Track ${track.trackNumber}',
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Text(
        _formatDuration(track.durationMs),
        style: theme.textTheme.bodySmall,
      ),
      trailing: track.qualityCheckedAt != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if ((track.clickCount ?? 0) > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text('${track.clickCount} clicks'),
                      backgroundColor: Colors.amber.withValues(alpha: 0.3),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                if (track.accurateRipConfidence != null)
                  Text(
                    'AR: ${track.accurateRipConfidence}',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            )
          : null,
    );
  }

  String _formatDuration(int? ms) {
    if (ms == null) return '';
    final seconds = ms ~/ 1000;
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
