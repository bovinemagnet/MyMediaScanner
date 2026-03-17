import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the currently selected/focused media item ID in the collection.
///
/// Used by keyboard navigation and the master-detail layout.
class SelectedItemNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String id) => state = id;

  void clear() => state = null;

  /// Move selection to the next item in [itemIds].
  /// Returns the newly selected ID, or null if already at end.
  String? moveNext(List<String> itemIds) {
    if (itemIds.isEmpty) return null;
    final current = state;
    if (current == null) {
      state = itemIds.first;
      return state;
    }
    final index = itemIds.indexOf(current);
    if (index < 0 || index >= itemIds.length - 1) return state;
    state = itemIds[index + 1];
    return state;
  }

  /// Move selection to the previous item in [itemIds].
  /// Returns the newly selected ID, or null if already at start.
  String? movePrevious(List<String> itemIds) {
    if (itemIds.isEmpty) return null;
    final current = state;
    if (current == null) {
      state = itemIds.last;
      return state;
    }
    final index = itemIds.indexOf(current);
    if (index <= 0) return state;
    state = itemIds[index - 1];
    return state;
  }
}

final selectedItemProvider =
    NotifierProvider<SelectedItemNotifier, String?>(() => SelectedItemNotifier());
