/// Riverpod providers for the play queue and queue-visible state.
///
/// Provides a [QueueNotifier] that manages the ordered list of [QueueItem]s,
/// current playback index, and playback history (capped at 50 items).
/// Also provides [QueueVisibleNotifier] to control whether the queue panel
/// is shown in the UI.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/queue_item.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

part 'queue_provider.freezed.dart';

// ---------------------------------------------------------------------------
// QueueState
// ---------------------------------------------------------------------------

/// Immutable state for the play queue.
@freezed
sealed class QueueState with _$QueueState {
  /// Creates a [QueueState].
  const factory QueueState({
    /// The ordered list of items in the queue.
    @Default([]) List<QueueItem> items,

    /// Index of the currently playing item, or -1 if nothing is playing.
    @Default(-1) int currentIndex,

    /// Previously played items (most recent last), capped at 50.
    @Default([]) List<QueueItem> history,
  }) = _QueueState;
}

// ---------------------------------------------------------------------------
// QueueNotifier
// ---------------------------------------------------------------------------

/// Notifier that manages the play queue.
class QueueNotifier extends Notifier<QueueState> {
  static const int _historyLimit = 50;

  @override
  QueueState build() => const QueueState();

  /// Replaces the entire queue with tracks from [album], starting playback at
  /// [startIndex].
  void replaceQueue(RipAlbum album, List<RipTrack> tracks,
      {int startIndex = 0}) {
    final items = tracks
        .map((t) => QueueItem(
              album: album,
              track: t,
              source: QueueItemSource.album,
            ))
        .toList();
    state = state.copyWith(
      items: items,
      currentIndex: items.isEmpty ? -1 : startIndex.clamp(0, items.length - 1),
    );
  }

  /// Appends all [tracks] from [album] to the end of the queue.
  void addAlbumToQueue(RipAlbum album, List<RipTrack> tracks) {
    final newItems = tracks
        .map((t) => QueueItem(
              album: album,
              track: t,
              source: QueueItemSource.album,
            ))
        .toList();
    state = state.copyWith(items: [...state.items, ...newItems]);
  }

  /// Inserts [item] immediately after the current index.
  ///
  /// If the queue is empty the item is appended at position 0.
  void playNext(QueueItem item) {
    final insertAt = state.currentIndex < 0 ? 0 : state.currentIndex + 1;
    final updated = [...state.items];
    updated.insert(insertAt, item);
    state = state.copyWith(items: updated);
  }

  /// Removes the item at [index].
  ///
  /// Adjusts [currentIndex] if the removed item was before the current
  /// position.
  void removeAt(int index) {
    if (index < 0 || index >= state.items.length) return;
    final updated = [...state.items]..removeAt(index);
    var newIndex = state.currentIndex;
    if (index < newIndex) {
      newIndex -= 1;
    } else if (index == newIndex) {
      // Current item removed — clamp to valid range or -1
      newIndex = updated.isEmpty ? -1 : newIndex.clamp(0, updated.length - 1);
    }
    state = state.copyWith(items: updated, currentIndex: newIndex);
  }

  /// Moves the item at [oldIndex] to [newIndex].
  ///
  /// [newIndex] is the desired final position in the resulting list.
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= state.items.length ||
        newIndex < 0 ||
        newIndex >= state.items.length) {
      return;
    }
    final updated = [...state.items];
    final item = updated.removeAt(oldIndex);
    // Insert at the desired final index (clamped to new list length).
    final insertAt = newIndex.clamp(0, updated.length);
    updated.insert(insertAt, item);

    // Update currentIndex to follow the moved item if it was current
    var newCurrentIndex = state.currentIndex;
    if (state.currentIndex == oldIndex) {
      newCurrentIndex = insertAt;
    } else if (oldIndex < state.currentIndex && insertAt >= state.currentIndex) {
      newCurrentIndex -= 1;
    } else if (oldIndex > state.currentIndex && insertAt <= state.currentIndex) {
      newCurrentIndex += 1;
    }

    state = state.copyWith(items: updated, currentIndex: newCurrentIndex);
  }

  /// Sets the current index to [index].
  void setCurrentIndex(int index) {
    if (index < -1 || index >= state.items.length) return;
    state = state.copyWith(currentIndex: index);
  }

  /// Advances to the next track.
  ///
  /// The current item is added to history (capped at [_historyLimit]) and
  /// [currentIndex] is incremented.
  void advanceToNext() {
    if (state.currentIndex < 0 || state.items.isEmpty) return;
    final current = state.items[state.currentIndex];
    final updatedHistory = [...state.history, current];
    final capped = updatedHistory.length > _historyLimit
        ? updatedHistory.sublist(updatedHistory.length - _historyLimit)
        : updatedHistory;
    final nextIndex = state.currentIndex + 1;
    state = state.copyWith(
      currentIndex: nextIndex < state.items.length ? nextIndex : state.currentIndex,
      history: capped,
    );
  }

  /// Clears the queue but preserves history.
  void clear() {
    state = state.copyWith(items: [], currentIndex: -1);
  }

  /// Clears the queue and history.
  void clearAll() {
    state = const QueueState();
  }
}

/// Provider for the play queue state.
final queueProvider =
    NotifierProvider<QueueNotifier, QueueState>(() => QueueNotifier());

// ---------------------------------------------------------------------------
// QueueVisibleNotifier
// ---------------------------------------------------------------------------

/// Notifier controlling whether the queue panel is visible.
class QueueVisibleNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Toggles the visibility.
  void toggle() => state = !state;

  /// Shows the queue panel.
  void show() => state = true;

  /// Hides the queue panel.
  void hide() => state = false;
}

/// Provider for whether the queue panel is visible.
final queueVisibleProvider =
    NotifierProvider<QueueVisibleNotifier, bool>(() => QueueVisibleNotifier());
