/// Provider for batch metadata editing across multiple rip albums.
///
/// Manages pending tag changes, original values (for undo), and the
/// apply/undo lifecycle.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/usecases/edit_rip_metadata_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

/// Lifecycle status for a batch metadata edit operation.
enum BatchEditStatus { idle, previewing, applying, applied, error }

/// Holds state for a batch metadata edit operation.
class BatchMetadataEditState {
  const BatchMetadataEditState({
    this.status = BatchEditStatus.idle,
    this.pendingChanges = const {},
    this.originalValues = const {},
    this.affectedTrackCount = 0,
    this.affectedAlbumCount = 0,
    this.error,
  });

  /// Current lifecycle status.
  final BatchEditStatus status;

  /// Map of trackId → (tagKey → newValue) for changes to be applied.
  final Map<String, Map<String, String>> pendingChanges;

  /// Map of trackId → (tagKey → oldValue) for undo support.
  final Map<String, Map<String, String>> originalValues;

  /// Number of individual tracks affected.
  final int affectedTrackCount;

  /// Number of albums affected.
  final int affectedAlbumCount;

  /// Error message if status is [BatchEditStatus.error].
  final String? error;

  BatchMetadataEditState copyWith({
    BatchEditStatus? status,
    Map<String, Map<String, String>>? pendingChanges,
    Map<String, Map<String, String>>? originalValues,
    int? affectedTrackCount,
    int? affectedAlbumCount,
    String? error,
  }) =>
      BatchMetadataEditState(
        status: status ?? this.status,
        pendingChanges: pendingChanges ?? this.pendingChanges,
        originalValues: originalValues ?? this.originalValues,
        affectedTrackCount: affectedTrackCount ?? this.affectedTrackCount,
        affectedAlbumCount: affectedAlbumCount ?? this.affectedAlbumCount,
        error: error,
      );
}

/// Notifier managing the batch metadata edit lifecycle.
class BatchMetadataEditNotifier extends Notifier<BatchMetadataEditState> {
  @override
  BatchMetadataEditState build() => const BatchMetadataEditState();

  /// Prepares a batch edit with the given pending changes and original values.
  ///
  /// Transitions to [BatchEditStatus.previewing] so the UI can show a preview
  /// before committing.
  void prepareBatchEdit({
    required Map<String, Map<String, String>> pendingChanges,
    required Map<String, Map<String, String>> originalValues,
    required int affectedTrackCount,
    required int affectedAlbumCount,
  }) {
    state = BatchMetadataEditState(
      status: BatchEditStatus.previewing,
      pendingChanges: pendingChanges,
      originalValues: originalValues,
      affectedTrackCount: affectedTrackCount,
      affectedAlbumCount: affectedAlbumCount,
    );
  }

  /// Stores the original tag values for undo support.
  void setOriginalValues(Map<String, Map<String, String>> originals) {
    state = state.copyWith(originalValues: originals);
  }

  /// Marks the operation as in progress.
  void markApplying() {
    state = state.copyWith(status: BatchEditStatus.applying, error: null);
  }

  /// Marks the operation as successfully applied.
  void markApplied() {
    state = state.copyWith(status: BatchEditStatus.applied);
  }

  /// Marks the operation as having encountered an error.
  void markError(String message) {
    state = state.copyWith(status: BatchEditStatus.error, error: message);
  }

  /// Applies the pending changes to all affected FLAC files.
  ///
  /// Uses [EditRipMetadataUseCase] (via [MetaflacWriter]) to write tags.
  /// Transitions to [BatchEditStatus.applied] on success, or
  /// [BatchEditStatus.error] if any writes fail.
  Future<void> applyChanges() async {
    if (state.status == BatchEditStatus.applying) return;
    markApplying();

    try {
      final useCase = EditRipMetadataUseCase(
        repository: ref.read(ripLibraryRepositoryProvider),
        writer: ref.read(metaflacWriterProvider),
      );

      // Group track IDs by their rip album so we can pass the album entity
      // to the use case.  We look up each track via ripTracksProvider cache.
      final errors = <String>[];

      for (final entry in state.pendingChanges.entries) {
        final trackId = entry.key;
        final tags = entry.value;

        // Find the track across all albums.
        // ripTracksProvider is family-keyed by albumId; we stored the full
        // file path as tagKey context, so we write directly via the writer.
        try {
          // We only have a trackId here; iterate albums to find the track.
          final allAlbums =
              ref.read(allRipAlbumsProvider).value ?? [];
          for (final album in allAlbums) {
            final tracks =
                ref.read(ripTracksProvider(album.id)).value ?? [];
            final track =
                tracks.where((t) => t.id == trackId).firstOrNull;
            if (track != null) {
              // Apply TITLE separately if present, others via setTags.
              final titleValue = tags['TITLE'];
              final otherTags = Map<String, String>.from(tags)
                ..remove('TITLE');

              if (titleValue != null) {
                await useCase.editTrackTitle(
                    track: track, title: titleValue);
              }

              if (otherTags.isNotEmpty &&
                  track.filePath.toLowerCase().endsWith('.flac')) {
                await ref
                    .read(metaflacWriterProvider)
                    .setTags(track.filePath, otherTags);
              }
              break;
            }
          }
        } catch (e) {
          errors.add('$trackId: $e');
        }
      }

      if (errors.isNotEmpty) {
        markError(
            'Failed to update ${errors.length} track(s):\n${errors.join('\n')}');
        return;
      }

      markApplied();
      ref.invalidate(allRipAlbumsProvider);
      ref.invalidate(ripTracksProvider);
    } catch (e) {
      markError(e.toString());
    }
  }

  /// Undoes the applied changes by re-writing the original values.
  Future<void> undoChanges() async {
    if (state.originalValues.isEmpty) return;
    markApplying();

    try {
      final errors = <String>[];
      final useCase = EditRipMetadataUseCase(
        repository: ref.read(ripLibraryRepositoryProvider),
        writer: ref.read(metaflacWriterProvider),
      );

      for (final entry in state.originalValues.entries) {
        final trackId = entry.key;
        final origTags = entry.value;

        try {
          final allAlbums = ref.read(allRipAlbumsProvider).value ?? [];
          for (final album in allAlbums) {
            final tracks =
                ref.read(ripTracksProvider(album.id)).value ?? [];
            final track =
                tracks.where((t) => t.id == trackId).firstOrNull;
            if (track != null) {
              final titleValue = origTags['TITLE'];
              final otherTags = Map<String, String>.from(origTags)
                ..remove('TITLE');

              if (titleValue != null) {
                await useCase.editTrackTitle(
                    track: track, title: titleValue);
              }

              if (otherTags.isNotEmpty &&
                  track.filePath.toLowerCase().endsWith('.flac')) {
                await ref
                    .read(metaflacWriterProvider)
                    .setTags(track.filePath, otherTags);
              }
              break;
            }
          }
        } catch (e) {
          errors.add('$trackId: $e');
        }
      }

      if (errors.isNotEmpty) {
        markError(
            'Undo failed for ${errors.length} track(s):\n${errors.join('\n')}');
        return;
      }

      reset();
      ref.invalidate(allRipAlbumsProvider);
      ref.invalidate(ripTracksProvider);
    } catch (e) {
      markError(e.toString());
    }
  }

  /// Resets state back to idle, discarding any pending or applied changes.
  void reset() {
    state = const BatchMetadataEditState();
  }
}

/// Provider for the batch metadata edit state and notifier.
final batchMetadataEditProvider =
    NotifierProvider<BatchMetadataEditNotifier, BatchMetadataEditState>(
        () => BatchMetadataEditNotifier());
