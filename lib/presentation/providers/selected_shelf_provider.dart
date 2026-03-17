import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the currently selected shelf ID for master-detail layout.
class SelectedShelfNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String id) => state = id;
  void clear() => state = null;
}

final selectedShelfProvider =
    NotifierProvider<SelectedShelfNotifier, String?>(
        () => SelectedShelfNotifier());
