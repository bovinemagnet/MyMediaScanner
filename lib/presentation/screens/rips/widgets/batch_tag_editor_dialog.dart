/// Dialog for batch editing FLAC tags across multiple selected albums.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/presentation/providers/batch_metadata_edit_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/batch_tag_preview_dialog.dart';

/// Opens the batch tag editor for the given selected album IDs.
///
/// Fetches track counts from the provider cache and presents editable tag
/// fields for GENRE, DATE, ALBUMARTIST, and COMMENT. Only non-empty fields
/// are applied to the affected tracks.
class BatchTagEditorDialog extends ConsumerStatefulWidget {
  const BatchTagEditorDialog({
    super.key,
    required this.selectedAlbumIds,
    required this.albums,
  });

  final Set<String> selectedAlbumIds;
  final List<RipAlbum> albums;

  @override
  ConsumerState<BatchTagEditorDialog> createState() =>
      _BatchTagEditorDialogState();
}

class _BatchTagEditorDialogState extends ConsumerState<BatchTagEditorDialog> {
  final _genreController = TextEditingController();
  final _dateController = TextEditingController();
  final _albumArtistController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _genreController.dispose();
    _dateController.dispose();
    _albumArtistController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  List<RipAlbum> get _selectedAlbums => widget.albums
      .where((a) => widget.selectedAlbumIds.contains(a.id))
      .toList();

  int get _totalTrackCount =>
      _selectedAlbums.fold(0, (sum, a) => sum + a.trackCount);

  /// Builds a Map of tagKey → newValue for only the fields that were filled.
  Map<String, String> _buildTagChanges() {
    final tags = <String, String>{};
    final genre = _genreController.text.trim();
    final date = _dateController.text.trim();
    final albumArtist = _albumArtistController.text.trim();
    final comment = _commentController.text.trim();

    if (genre.isNotEmpty) tags['GENRE'] = genre;
    if (date.isNotEmpty) tags['DATE'] = date;
    if (albumArtist.isNotEmpty) tags['ALBUMARTIST'] = albumArtist;
    if (comment.isNotEmpty) tags['COMMENT'] = comment;
    return tags;
  }

  Future<void> _openPreview() async {
    final tagChanges = _buildTagChanges();
    if (tagChanges.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter at least one tag value to preview.')),
      );
      return;
    }

    // Collect all track IDs and build pending changes map.
    final pendingChanges = <String, Map<String, String>>{};
    final originalValues = <String, Map<String, String>>{};

    for (final album in _selectedAlbums) {
      final tracks = ref.read(ripTracksProvider(album.id)).value ?? [];
      for (final track in tracks) {
        pendingChanges[track.id] = Map<String, String>.from(tagChanges);
        // Read current tag values for undo
        final currentTags =
            await ref.read(trackRawTagsProvider(track.filePath).future);
        originalValues[track.id] = {
          for (final key in tagChanges.keys)
            if (currentTags.containsKey(key)) key: currentTags[key]!,
        };
      }
    }

    ref.read(batchMetadataEditProvider.notifier).prepareBatchEdit(
          pendingChanges: pendingChanges,
          originalValues: originalValues,
          affectedTrackCount: _totalTrackCount,
          affectedAlbumCount: _selectedAlbums.length,
        );

    if (!mounted) return;
    Navigator.of(context).pop();
    await showDialog<void>(
      context: context,
      builder: (_) => const BatchTagPreviewDialog(),
    );
  }

  Future<void> _applyDirectly() async {
    final tagChanges = _buildTagChanges();
    if (tagChanges.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter at least one tag value to apply.')),
      );
      return;
    }

    final pendingChanges = <String, Map<String, String>>{};
    final originalValues = <String, Map<String, String>>{};

    for (final album in _selectedAlbums) {
      final tracks = ref.read(ripTracksProvider(album.id)).value ?? [];
      for (final track in tracks) {
        pendingChanges[track.id] = Map<String, String>.from(tagChanges);
        final currentTags =
            await ref.read(trackRawTagsProvider(track.filePath).future);
        originalValues[track.id] = {
          for (final key in tagChanges.keys)
            if (currentTags.containsKey(key)) key: currentTags[key]!,
        };
      }
    }

    ref.read(batchMetadataEditProvider.notifier).prepareBatchEdit(
          pendingChanges: pendingChanges,
          originalValues: originalValues,
          affectedTrackCount: _totalTrackCount,
          affectedAlbumCount: _selectedAlbums.length,
        );

    if (!mounted) return;
    Navigator.of(context).pop();

    await ref.read(batchMetadataEditProvider.notifier).applyChanges();

    if (!mounted) return;
    final state = ref.read(batchMetadataEditProvider);
    if (state.status == BatchEditStatus.applied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Tags updated on ${state.affectedTrackCount} tracks across '
              '${state.affectedAlbumCount} albums.'),
          duration: const Duration(seconds: 30),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () =>
                ref.read(batchMetadataEditProvider.notifier).undoChanges(),
          ),
        ),
      );
    } else if (state.status == BatchEditStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(state.error ?? 'An error occurred.'),
            backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final albumCount = _selectedAlbums.length;
    final trackCount = _totalTrackCount;

    return AlertDialog(
      title: Text('Edit Tags — $albumCount Album${albumCount == 1 ? '' : 's'} '
          '($trackCount track${trackCount == 1 ? '' : 's'})'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leave blank to keep existing values.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _TagField(
              label: 'Genre',
              tagKey: 'GENRE',
              controller: _genreController,
            ),
            const SizedBox(height: 12),
            _TagField(
              label: 'Date / Year',
              tagKey: 'DATE',
              controller: _dateController,
            ),
            const SizedBox(height: 12),
            _TagField(
              label: 'Album Artist',
              tagKey: 'ALBUMARTIST',
              controller: _albumArtistController,
            ),
            const SizedBox(height: 12),
            _TagField(
              label: 'Comment',
              tagKey: 'COMMENT',
              controller: _commentController,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _openPreview,
          child: const Text('Preview Changes'),
        ),
        FilledButton(
          onPressed: _applyDirectly,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _TagField extends StatelessWidget {
  const _TagField({
    required this.label,
    required this.tagKey,
    required this.controller,
  });

  final String label;
  final String tagKey;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Leave blank to keep existing',
        helperText: tagKey,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
