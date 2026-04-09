/// Provider for batch metadata editing across multiple rip albums.
///
/// Manages pending tag changes, original values (for undo), and the
/// apply/undo lifecycle.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/usecases/edit_rip_metadata_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

part 'batch_metadata_edit_provider.freezed.dart';

/// Lifecycle status for a batch metadata edit operation.
enum BatchEditStatus { idle, previewing, applying, applied, error }

/// Holds state for a batch metadata edit operation.
@freezed
sealed class BatchMetadataEditState with _$BatchMetadataEditState {
  const factory BatchMetadataEditState({
    /// Current lifecycle status.
    @Default(BatchEditStatus.idle) BatchEditStatus status,

    /// Map of trackId → (tagKey → newValue) for changes to be applied.
    @Default({}) Map<String, Map<String, String>> pendingChanges,

    /// Map of trackId → (tagKey → oldValue) for undo support.
    @Default({}) Map<String, Map<String, String>> originalValues,

    /// Number of individual tracks affected.
    @Default(0) int affectedTrackCount,

    /// Number of albums affected.
    @Default(0) int affectedAlbumCount,

    /// Error message if status is [BatchEditStatus.error].
    String? error,
  }) = _BatchMetadataEditState;
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

      // Build a pre-computed lookup: trackId → RipTrack.
      // Iterates albums once up front so the per-change loop is O(1).
      final allAlbums = ref.read(allRipAlbumsProvider).value ?? [];
      final trackLookup = <String, RipTrack>{};
      for (final album in allAlbums) {
        final tracks = ref.read(ripTracksProvider(album.id)).value ?? [];
        for (final track in tracks) {
          trackLookup[track.id] = track;
        }
      }

      final errors = <String>[];

      for (final entry in state.pendingChanges.entries) {
        final trackId = entry.key;
        final tags = entry.value;

        try {
          final track = trackLookup[trackId];
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

      // Build a pre-computed lookup: trackId → RipTrack.
      final allAlbums = ref.read(allRipAlbumsProvider).value ?? [];
      final trackLookup = <String, RipTrack>{};
      for (final album in allAlbums) {
        final tracks = ref.read(ripTracksProvider(album.id)).value ?? [];
        for (final track in tracks) {
          trackLookup[track.id] = track;
        }
      }

      for (final entry in state.originalValues.entries) {
        final trackId = entry.key;
        final origTags = entry.value;

        try {
          final track = trackLookup[trackId];
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
