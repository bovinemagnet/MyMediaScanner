import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlbumSelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String albumId) {
    final updated = {...state};
    if (updated.contains(albumId)) {
      updated.remove(albumId);
    } else {
      updated.add(albumId);
    }
    state = updated;
  }

  void selectAll(List<String> albumIds) {
    state = {...albumIds};
  }

  void clear() {
    state = {};
  }
}

final albumSelectionProvider =
    NotifierProvider<AlbumSelectionNotifier, Set<String>>(
        () => AlbumSelectionNotifier());

final isInSelectionModeProvider = Provider<bool>((ref) {
  return ref.watch(albumSelectionProvider).isNotEmpty;
});
