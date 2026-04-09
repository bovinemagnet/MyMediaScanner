import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/app/theme/app_colors.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/playback_widgets.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/quality_widgets.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

/// Dialog showing detailed information about a rip album.
class RipAlbumDetailDialog extends ConsumerStatefulWidget {
  const RipAlbumDetailDialog({super.key, required this.album});

  final RipAlbum album;

  @override
  ConsumerState<RipAlbumDetailDialog> createState() =>
      _RipAlbumDetailDialogState();
}

class _RipAlbumDetailDialogState extends ConsumerState<RipAlbumDetailDialog> {
  bool _editing = false;
  late TextEditingController _artistController;
  late TextEditingController _albumTitleController;
  final Map<String, TextEditingController> _trackTitleControllers = {};
  final Map<String, TextEditingController> _tagControllers = {};

  @override
  void initState() {
    super.initState();
    _artistController =
        TextEditingController(text: widget.album.artist ?? '');
    _albumTitleController =
        TextEditingController(text: widget.album.albumTitle ?? '');
  }

  @override
  void dispose() {
    _artistController.dispose();
    _albumTitleController.dispose();
    for (final c in _trackTitleControllers.values) {
      c.dispose();
    }
    for (final c in _tagControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _trackController(RipTrack track) {
    return _trackTitleControllers.putIfAbsent(
      track.id,
      () => TextEditingController(text: track.title ?? ''),
    );
  }

  Future<void> _save(List<RipTrack> tracks) async {
    final notifier = ref.read(ripMetadataEditNotifierProvider.notifier);
    final writer = ref.read(metaflacWriterProvider);

    final newArtist = _artistController.text.trim();
    final newAlbumTitle = _albumTitleController.text.trim();
    final artistChanged = newArtist != (widget.album.artist ?? '');
    final albumTitleChanged = newAlbumTitle != (widget.album.albumTitle ?? '');

    if (artistChanged || albumTitleChanged) {
      await notifier.saveAlbumMetadata(
        album: widget.album,
        tracks: tracks,
        artist: artistChanged ? newArtist : null,
        albumTitle: albumTitleChanged ? newAlbumTitle : null,
      );
    }

    // Save track-level changes (title via notifier, other tags via metaflac)
    for (final track in tracks) {
      // Title change
      final titleCtrl = _trackTitleControllers[track.id];
      if (titleCtrl != null) {
        final newTitle = titleCtrl.text.trim();
        final oldTitle = track.title ?? '';
        if (newTitle != oldTitle) {
          await notifier.saveTrackTitle(
            track: track,
            title: newTitle.isEmpty ? null : newTitle,
          );
        }
      }

      // Other tag changes — write directly via metaflac
      if (track.filePath.toLowerCase().endsWith('.flac')) {
        final rawTags =
            ref.read(trackRawTagsProvider(track.filePath)).value ?? {};
        final changedTags = <String, String>{};
        final removedTags = <String>[];

        for (final entry in _tagControllers.entries) {
          // Keys are "trackId:TAG_KEY"
          if (!entry.key.startsWith('${track.id}:')) continue;
          final tagKey = entry.key.substring(track.id.length + 1);
          if (tagKey == 'TITLE') continue; // handled via notifier above
          final newValue = entry.value.text.trim();
          final oldValue = rawTags[tagKey] ?? '';
          if (newValue != oldValue) {
            if (newValue.isEmpty) {
              removedTags.add(tagKey);
            } else {
              changedTags[tagKey] = newValue;
            }
          }
        }

        try {
          if (changedTags.isNotEmpty) {
            await writer.setTags(track.filePath, changedTags);
          }
          for (final key in removedTags) {
            await writer.removeTag(track.filePath, key);
          }
          if (changedTags.isNotEmpty || removedTags.isNotEmpty) {
            ref.invalidate(trackRawTagsProvider(track.filePath));
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error writing tags to ${track.filePath}: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      }
    }

    final editState = ref.read(ripMetadataEditNotifierProvider);
    if (mounted) {
      if (editState.status == RipMetadataEditStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(editState.error ?? 'Failed to save metadata.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else {
        setState(() => _editing = false);
      }
    }
  }

  void _discard() {
    _artistController.text = widget.album.artist ?? '';
    _albumTitleController.text = widget.album.albumTitle ?? '';
    _trackTitleControllers.clear();
    for (final c in _tagControllers.values) {
      c.dispose();
    }
    _tagControllers.clear();
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final tracksAsync = ref.watch(ripTracksProvider(widget.album.id));
    final editState = ref.watch(ripMetadataEditNotifierProvider);
    final isSaving = editState.status == RipMetadataEditStatus.saving;
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
                    child: _editing
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _artistController,
                                decoration: const InputDecoration(
                                  labelText: 'Artist',
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _albumTitleController,
                                decoration: const InputDecoration(
                                  labelText: 'Album Title',
                                  isDense: true,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.album.artist ?? 'Unknown Artist',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.album.albumTitle ?? 'Unknown Album',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                  if (_editing) ...[
                    isSaving
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : FilledButton(
                            onPressed: () {
                              final tracks =
                                  ref.read(ripTracksProvider(widget.album.id)).value ?? [];
                              _save(tracks);
                            },
                            child: const Text('Save Changes'),
                          ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: isSaving ? null : _discard,
                      child: const Text('Discard'),
                    ),
                  ] else ...[
                    PlayAlbumButton(album: widget.album),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit metadata',
                      onPressed: () => setState(() => _editing = true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.album.libraryPath,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // Link section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _LinkSection(album: widget.album),
              ),

              const SizedBox(height: 12),

              // Quality analysis
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: QualityAnalysisSection(albumId: widget.album.id),
              ),
              const SizedBox(height: 12),

              // Playback controls (visible when this album is playing)
              InlinePlayerControls(album: widget.album),

              // Track listing
              Text('TRACKS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                  )),
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
                      itemBuilder: (context, index) {
                        final track = tracks[index];
                        return _editing
                            ? _EditableTrackTile(
                                track: track,
                                titleController: _trackController(track),
                                tagControllers: _tagControllers,
                              )
                            : _TrackTile(
                                track: track,
                                trackIndex: index,
                                album: widget.album,
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
            onPressed: () => context.go('/collection/item/${album.mediaItemId}'),
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

class _TrackTile extends ConsumerWidget {
  const _TrackTile({
    required this.track,
    required this.trackIndex,
    required this.album,
  });

  final RipTrack track;
  final int trackIndex;
  final RipAlbum album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final duration = _formatTrackDuration(track.durationMs);
    final discLabel =
        track.discNumber > 1 ? 'Disc ${track.discNumber} · ' : '';
    final subtitle =
        '$discLabel${track.trackNumber.toString().padLeft(2, '0')}'
        '${duration.isNotEmpty ? ' · $duration' : ''}';

    final nowPlaying = ref.watch(nowPlayingProvider);
    final currentIndex = ref.watch(currentTrackIndexProvider).value;
    final isThisTrackPlaying = nowPlaying.album?.id == track.ripAlbumId &&
        currentIndex == trackIndex;

    return ListTile(
      dense: true,
      leading: isThisTrackPlaying
          ? Icon(Icons.volume_up, color: colors.primary, size: 20)
          : QualityIcon(track: track),
      title: Text(
        track.title ?? 'Track ${track.trackNumber}',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: track.title != null ? FontWeight.w500 : null,
          fontStyle: track.title == null ? FontStyle.italic : null,
          color: isThisTrackPlaying
              ? colors.primary
              : (track.title == null ? colors.onSurfaceVariant : null),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if ((track.clickCount ?? 0) > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('${track.clickCount} clicks'),
                backgroundColor: AppColors.tvColor.withValues(alpha: 0.2),
                visualDensity: VisualDensity.compact,
              ),
            ),
          if (track.accurateRipConfidence != null)
            Text(
              'AR: ${track.accurateRipConfidence}',
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
      onTap: () {
        final nowPlaying = ref.read(nowPlayingProvider);
        final actions = ref.read(playbackActionProvider.notifier);
        if (nowPlaying.album?.id == album.id) {
          // Already playing this album — seek to track
          actions.seekToIndex(trackIndex);
        } else if (ref.read(playOnSelectProvider)) {
          // Not playing but auto-play is on — start from this track
          final tracks =
              ref.read(ripTracksProvider(album.id)).value ?? [];
          if (tracks.isNotEmpty) {
            actions.playAlbum(
              album: album,
              tracks: tracks,
              startIndex: trackIndex,
            );
          }
        }
      },
    );
  }
}

/// Expandable track tile that shows all Vorbis Comment / ID3 tags for editing.
class _EditableTrackTile extends ConsumerStatefulWidget {
  const _EditableTrackTile({
    required this.track,
    required this.titleController,
    required this.tagControllers,
  });

  final RipTrack track;
  final TextEditingController titleController;

  /// Shared mutable map of tag controllers, keyed by "trackId:TAG_KEY".
  /// Managed by the parent state.
  final Map<String, TextEditingController> tagControllers;

  @override
  ConsumerState<_EditableTrackTile> createState() => _EditableTrackTileState();
}

class _EditableTrackTileState extends ConsumerState<_EditableTrackTile> {
  bool _expanded = false;

  /// Common tags that are always shown as editable fields, even when empty.
  static const _alwaysShowTags = [
    'TITLE',
    'ARTIST',
    'ALBUMARTIST',
    'ALBUM',
    'TRACKNUMBER',
    'DISCNUMBER',
    'GENRE',
    'DATE',
    'BPM',
    'COMPOSER',
    'PERFORMER',
  ];

  /// Full display order including less common tags (shown only if present).
  static const _displayOrder = [
    'TITLE',
    'ARTIST',
    'ALBUMARTIST',
    'ALBUM',
    'TRACKNUMBER',
    'DISCNUMBER',
    'GENRE',
    'DATE',
    'BPM',
    'COMPOSER',
    'PERFORMER',
    'COMMENT',
    'TOTALTRACKS',
    'TOTALDISCS',
    'BARCODE',
    'ISRC',
    'LYRICS',
  ];

  /// Human-readable labels for common tags.
  static const _tagLabels = {
    'TITLE': 'Title',
    'ARTIST': 'Artist',
    'ALBUMARTIST': 'Album Artist',
    'ALBUM': 'Album',
    'TRACKNUMBER': 'Track Number',
    'DISCNUMBER': 'Disc Number',
    'GENRE': 'Genre',
    'DATE': 'Date',
    'BPM': 'BPM',
    'COMPOSER': 'Composer',
    'PERFORMER': 'Performer',
    'COMMENT': 'Comment',
    'TOTALTRACKS': 'Total Tracks',
    'TOTALDISCS': 'Total Discs',
    'BARCODE': 'Barcode',
    'ISRC': 'ISRC',
    'LYRICS': 'Lyrics',
  };

  TextEditingController _controllerForTag(
      String tagKey, Map<String, String> rawTags) {
    final compositeKey = '${widget.track.id}:$tagKey';
    return widget.tagControllers.putIfAbsent(
      compositeKey,
      () => TextEditingController(text: rawTags[tagKey] ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final rawTagsAsync = ref.watch(trackRawTagsProvider(widget.track.filePath));
    final duration = _formatDuration(widget.track.durationMs);

    return Card(
      color: colors.surfaceContainerHigh,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          // Compact header — always visible
          ListTile(
            dense: true,
            leading: QualityIcon(track: widget.track),
            title: TextFormField(
              controller: widget.titleController,
              decoration: InputDecoration(
                labelText: 'Track ${widget.track.trackNumber} — Title',
                isDense: true,
                border: const UnderlineInputBorder(),
              ),
            ),
            subtitle: duration.isNotEmpty
                ? Text(duration, style: theme.textTheme.bodySmall)
                : null,
            trailing: IconButton(
              icon: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
              ),
              tooltip: _expanded ? 'Show less' : 'Show all tags',
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ),
          // Expanded tag list
          if (_expanded)
            rawTagsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(12),
                child: Text('Could not read tags: $e',
                    style: theme.textTheme.bodySmall),
              ),
              data: (rawTags) {
                // Always show common tags (even when empty) + any extras
                final orderedKeys = <String>[];
                // Add all always-shown tags first
                for (final key in _alwaysShowTags) {
                  orderedKeys.add(key);
                }
                // Add remaining display-order tags if they exist in file
                for (final key in _displayOrder) {
                  if (!orderedKeys.contains(key) &&
                      rawTags.containsKey(key)) {
                    orderedKeys.add(key);
                  }
                }
                // Add any custom tags not in the display order
                for (final key in rawTags.keys) {
                  if (!orderedKeys.contains(key)) {
                    orderedKeys.add(key);
                  }
                }
                // Remove TITLE — it's already in the header
                orderedKeys.remove('TITLE');

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      for (final key in orderedKeys)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextFormField(
                            controller: _controllerForTag(key, rawTags),
                            decoration: InputDecoration(
                              labelText: _tagLabels[key] ?? key,
                              isDense: true,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      if (orderedKeys.isEmpty)
                        Text(
                          'No additional tags found in file.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
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

String _formatTrackDuration(int? ms) {
  if (ms == null) return '';
  final seconds = ms ~/ 1000;
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}
