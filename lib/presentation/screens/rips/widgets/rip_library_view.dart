import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/app/theme/app_colors.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/album_selection_provider.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
import 'package:mymediascanner/presentation/providers/batch_analysis_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/providers/selected_rip_album_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_view_mode_provider.dart';
import 'package:mymediascanner/presentation/providers/queue_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/batch_analysis_panel.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/batch_tag_editor_dialog.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/playback_widgets.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/quality_widgets.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/queue_panel.dart';
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
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

    // Auto-play if toggle is on
    if (ref.read(playOnSelectProvider)) {
      final tracks = ref.read(ripTracksProvider(album.id)).value ?? [];
      if (tracks.isNotEmpty) {
        ref.read(playbackActionProvider.notifier).playAlbum(
              album: album,
              tracks: tracks,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final albumsAsync = ref.watch(allRipAlbumsProvider);
    final scanState = ref.watch(ripScanNotifierProvider);
    final selectedAlbumId = ref.watch(selectedRipAlbumProvider);
    final viewMode = ref.watch(ripViewModeProvider);
    final isSelecting = ref.watch(isInSelectionModeProvider);
    final selectedIds = ref.watch(albumSelectionProvider);

    final masterContent = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: SearchBar(
                  controller: _searchController,
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
              const SizedBox(width: 8),
              Tooltip(
                message: 'Auto Play',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_circle_outline, size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    SizedBox(
                      height: 24,
                      child: Switch(
                        value: ref.watch(playOnSelectProvider),
                        onChanged: (_) => ref
                            .read(playOnSelectProvider.notifier)
                            .toggle(),
                      ),
                    ),
                  ],
                ),
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
        // Selection toolbar — appears when at least one album is selected
        if (isSelecting)
          _SelectionToolbar(
            selectedIds: selectedIds,
            onSelectAll: () {
              final albums =
                  albumsAsync.whenOrNull(data: (a) => a) ?? [];
              ref
                  .read(albumSelectionProvider.notifier)
                  .selectAll(albums.map((a) => a.id).toList());
            },
            onAnalyseQuality: () {
              ref
                  .read(batchAnalysisProvider.notifier)
                  .queueAlbums(selectedIds.toList());
              ref.read(batchAnalysisProvider.notifier).startAnalysis();
              ref.read(albumSelectionProvider.notifier).clear();
            },
            onEditTags: () {
              final allAlbums = albumsAsync.whenOrNull(data: (a) => a) ?? [];
              showDialog<void>(
                context: context,
                builder: (_) => BatchTagEditorDialog(
                  selectedAlbumIds: selectedIds,
                  albums: allAlbums,
                ),
              );
            },
            onCancel: () =>
                ref.read(albumSelectionProvider.notifier).clear(),
          ),
        // Batch analysis progress panel
        const BatchAnalysisPanel(),
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
                itemBuilder: (context, index) {
                  final album = filtered[index];
                  return _RipAlbumCard(
                    album: album,
                    onTap: () {
                      if (isSelecting) {
                        ref
                            .read(albumSelectionProvider.notifier)
                            .toggle(album.id);
                      } else {
                        _onAlbumTap(context, album);
                      }
                    },
                    onLongPress: () => ref
                        .read(albumSelectionProvider.notifier)
                        .toggle(album.id),
                    isSelected: selectedIds.contains(album.id),
                    showCheckbox: isSelecting,
                  );
                },
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

    final showQueue = ref.watch(queueVisibleProvider);
    return Row(
      children: [
        Expanded(
          child: MasterDetailLayout(
            master: masterContent,
            detail: detailPanel,
          ),
        ),
        if (showQueue) const QueuePanel(),
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
  const _RipAlbumCard({
    required this.album,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.showCheckbox = false,
  });

  final RipAlbum album;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool showCheckbox;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(ripTracksProvider(album.id));
    final theme = Theme.of(context);
    final nowPlayingAlbumId = ref.watch(
      nowPlayingProvider.select((s) => s.album?.id),
    );
    final isNowPlaying = nowPlayingAlbumId == album.id;

    // Quality summary from tracks
    final tracks = tracksAsync.whenOrNull(data: (t) => t) ?? [];
    final arVerified =
        tracks.where((t) => t.accurateRipStatus == 'verified').length;
    final withClicks = tracks.where((t) => (t.clickCount ?? 0) > 0).length;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: isSelected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.primary, width: 2),
            )
          : isNowPlaying
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.primary, width: 2),
                )
              : null,
      child: InkWell(
        onTap: onTap ??
            () => showDialog<void>(
                  context: context,
                  builder: (_) => RipAlbumDetailDialog(album: album),
                ),
        onLongPress: onLongPress,
        child: Stack(
          children: [
            Padding(
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
                  Icon(Icons.music_note, size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('${album.trackCount} tracks',
                      style: theme.textTheme.bodySmall),
                  const SizedBox(width: 12),
                  Icon(Icons.storage, size: 14, color: theme.colorScheme.onSurfaceVariant),
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
                          ? AppColors.bookColor
                          : arVerified > 0
                              ? AppColors.tvColor
                              : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$arVerified/${tracks.length} AR',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (withClicks > 0) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.warning_amber,
                          size: 14, color: AppColors.tvColor),
                      const SizedBox(width: 4),
                      Text('$withClicks clicks',
                          style: theme.textTheme.bodySmall),
                    ],
                  ],
                  const Spacer(),
                  if (isNowPlaying)
                    Icon(Icons.volume_up, size: 14, color: theme.colorScheme.primary),
                  if (album.mediaItemId != null)
                    Padding(
                      padding: EdgeInsets.only(left: isNowPlaying ? 6 : 0),
                      child: Icon(Icons.link, size: 14, color: theme.colorScheme.primary),
                    ),
                ],
              ),
            ],
          ),
        ),
            // Checkbox overlay when in selection mode
            if (showCheckbox)
              Positioned(
                top: 6,
                right: 6,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 20,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
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

/// Toolbar shown when one or more albums are selected.
class _SelectionToolbar extends StatelessWidget {
  const _SelectionToolbar({
    required this.selectedIds,
    required this.onSelectAll,
    required this.onAnalyseQuality,
    required this.onEditTags,
    required this.onCancel,
  });

  final Set<String> selectedIds;
  final VoidCallback onSelectAll;
  final VoidCallback onAnalyseQuality;
  final VoidCallback onEditTags;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = selectedIds.length;

    return Container(
      color: theme.colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '$count selected',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: count > 0 ? onAnalyseQuality : null,
            icon: const Icon(Icons.analytics_outlined, size: 16),
            label: const Text('Analyse Quality'),
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: count > 0 ? onEditTags : null,
            icon: const Icon(Icons.label_outline, size: 16),
            label: const Text('Edit Tags'),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onSelectAll,
            child: const Text('Select All'),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            tooltip: 'Cancel selection',
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}

/// Embedded rip album detail for the master-detail side panel.
class _RipAlbumDetailPanel extends ConsumerStatefulWidget {
  const _RipAlbumDetailPanel({required this.album});

  final RipAlbum album;

  @override
  ConsumerState<_RipAlbumDetailPanel> createState() =>
      _RipAlbumDetailPanelState();
}

class _RipAlbumDetailPanelState extends ConsumerState<_RipAlbumDetailPanel> {
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

      // Other tag changes via metaflac
      if (track.filePath.toLowerCase().endsWith('.flac')) {
        final rawTags =
            ref.read(trackRawTagsProvider(track.filePath)).value ?? {};
        final changedTags = <String, String>{};
        final removedTags = <String>[];

        for (final entry in _tagControllers.entries) {
          if (!entry.key.startsWith('${track.id}:')) continue;
          final tagKey = entry.key.substring(track.id.length + 1);
          if (tagKey == 'TITLE') continue;
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
                content: Text('Error writing tags: $e'),
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
            content: Text(
                editState.error ?? 'Failed to save metadata.'),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          color: theme.colorScheme.surfaceContainerHigh,
          child: _editing
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isSaving ? null : _discard,
                          child: const Text('Discard'),
                        ),
                        const SizedBox(width: 8),
                        isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : FilledButton(
                                onPressed: () {
                                  final tracks = ref
                                      .read(ripTracksProvider(widget.album.id))
                                      .value ?? [];
                                  _save(tracks);
                                },
                                child: const Text('Save Changes'),
                              ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.album.artist ?? 'Unknown Artist',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.album.albumTitle ?? 'Unknown Album',
                            style: theme.textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    PlayAlbumButton(album: widget.album),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit metadata',
                      onPressed: () => setState(() => _editing = true),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            widget.album.libraryPath,
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),
        // Quality analysis
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
          ),
          child: QualityAnalysisSection(albumId: widget.album.id),
        ),
        const SizedBox(height: 12),
        // Playback controls (visible when this album is playing)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: InlinePlayerControls(album: widget.album),
        ),
        // Track listing
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('TRACKS',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w700,
              )),
        ),
        const SizedBox(height: 4),
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
                  if (_editing) {
                    return _EditableTrackTileInline(
                      track: track,
                      titleController: _trackController(track),
                      tagControllers: _tagControllers,
                    );
                  }
                  final duration = _formatDuration(track.durationMs);
                  final discLabel = track.discNumber > 1
                      ? 'Disc ${track.discNumber} · '
                      : '';
                  final subtitle =
                      '$discLabel${track.trackNumber.toString().padLeft(2, '0')}'
                      '${duration.isNotEmpty ? ' · $duration' : ''}';
                  final nowPlaying = ref.watch(nowPlayingProvider);
                  final currentIdx =
                      ref.watch(currentTrackIndexProvider).value;
                  final isThisTrackPlaying =
                      nowPlaying.album?.id == track.ripAlbumId &&
                          currentIdx == index;
                  return ListTile(
                    dense: true,
                    leading: isThisTrackPlaying
                        ? Icon(Icons.volume_up,
                            color: theme.colorScheme.primary, size: 20)
                        : QualityIcon(track: track),
                    title: Text(
                      track.title ?? 'Track ${track.trackNumber}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            track.title != null ? FontWeight.w500 : null,
                        fontStyle:
                            track.title == null ? FontStyle.italic : null,
                        color: isThisTrackPlaying
                            ? theme.colorScheme.primary
                            : (track.title == null
                                ? theme.colorScheme.onSurfaceVariant
                                : null),
                      ),
                    ),
                    subtitle: Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () {
                      if (!ref.read(playOnSelectProvider)) return;
                      final np = ref.read(nowPlayingProvider);
                      final actions =
                          ref.read(playbackActionProvider.notifier);
                      if (np.album?.id == widget.album.id) {
                        actions.seekToIndex(index);
                      } else {
                        actions.playAlbum(
                          album: widget.album,
                          tracks: tracks,
                          startIndex: index,
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
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

/// Expandable track tile for the inline panel, showing all tags for editing.
class _EditableTrackTileInline extends ConsumerStatefulWidget {
  const _EditableTrackTileInline({
    required this.track,
    required this.titleController,
    required this.tagControllers,
  });

  final RipTrack track;
  final TextEditingController titleController;
  final Map<String, TextEditingController> tagControllers;

  @override
  ConsumerState<_EditableTrackTileInline> createState() =>
      _EditableTrackTileInlineState();
}

class _EditableTrackTileInlineState
    extends ConsumerState<_EditableTrackTileInline> {
  bool _expanded = false;

  static const _alwaysShowTags = [
    'TITLE', 'ARTIST', 'ALBUMARTIST', 'ALBUM', 'TRACKNUMBER', 'DISCNUMBER',
    'GENRE', 'DATE', 'BPM', 'COMPOSER', 'PERFORMER',
  ];

  static const _displayOrder = [
    'TITLE', 'ARTIST', 'ALBUMARTIST', 'ALBUM', 'TRACKNUMBER', 'DISCNUMBER',
    'GENRE', 'DATE', 'BPM', 'COMPOSER', 'PERFORMER', 'COMMENT',
    'TOTALTRACKS', 'TOTALDISCS', 'BARCODE', 'ISRC', 'LYRICS',
  ];

  static const _tagLabels = {
    'TITLE': 'Title', 'ARTIST': 'Artist', 'ALBUMARTIST': 'Album Artist',
    'ALBUM': 'Album', 'TRACKNUMBER': 'Track Number',
    'DISCNUMBER': 'Disc Number', 'GENRE': 'Genre', 'DATE': 'Date',
    'BPM': 'BPM', 'COMPOSER': 'Composer', 'PERFORMER': 'Performer',
    'COMMENT': 'Comment', 'TOTALTRACKS': 'Total Tracks',
    'TOTALDISCS': 'Total Discs', 'BARCODE': 'Barcode', 'ISRC': 'ISRC',
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
    final rawTagsAsync =
        ref.watch(trackRawTagsProvider(widget.track.filePath));

    return Card(
      color: colors.surfaceContainerHigh,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Column(
        children: [
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
            trailing: IconButton(
              icon: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
              ),
              tooltip: _expanded ? 'Show less' : 'Show all tags',
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ),
          if (_expanded)
            rawTagsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 20, height: 20,
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
                final orderedKeys = <String>[];
                // Always show common tags even when empty
                for (final key in _alwaysShowTags) {
                  orderedKeys.add(key);
                }
                // Add remaining display-order tags if present in file
                for (final key in _displayOrder) {
                  if (!orderedKeys.contains(key) &&
                      rawTags.containsKey(key)) {
                    orderedKeys.add(key);
                  }
                }
                for (final key in rawTags.keys) {
                  if (!orderedKeys.contains(key)) orderedKeys.add(key);
                }
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
}
