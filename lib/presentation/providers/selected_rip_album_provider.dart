import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the currently selected rip album ID for master-detail layout.
class SelectedRipAlbumNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String id) => state = id;
  void clear() => state = null;

  /// Move selection to the next album in [albumIds].
  /// Returns the newly selected ID, or null if already at end.
  String? moveNext(List<String> albumIds) {
    if (albumIds.isEmpty) return null;
    final current = state;
    if (current == null) {
      state = albumIds.first;
      return state;
    }
    final index = albumIds.indexOf(current);
    if (index < 0 || index >= albumIds.length - 1) return state;
    state = albumIds[index + 1];
    return state;
  }

  /// Move selection to the previous album in [albumIds].
  /// Returns the newly selected ID, or null if already at start.
  String? movePrevious(List<String> albumIds) {
    if (albumIds.isEmpty) return null;
    final current = state;
    if (current == null) {
      state = albumIds.last;
      return state;
    }
    final index = albumIds.indexOf(current);
    if (index <= 0) return state;
    state = albumIds[index - 1];
    return state;
  }
}

final selectedRipAlbumProvider =
    NotifierProvider<SelectedRipAlbumNotifier, String?>(
        () => SelectedRipAlbumNotifier());
