import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the currently selected rip album ID for master-detail layout.
class SelectedRipAlbumNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String id) => state = id;
  void clear() => state = null;
}

final selectedRipAlbumProvider =
    NotifierProvider<SelectedRipAlbumNotifier, String?>(
        () => SelectedRipAlbumNotifier());
