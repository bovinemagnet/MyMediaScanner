import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CollectionViewMode { grid, table }

const _prefKey = 'collection_view_mode';

class CollectionViewModeNotifier extends Notifier<CollectionViewMode> {
  @override
  CollectionViewMode build() {
    _loadFromPrefs();
    return CollectionViewMode.grid;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKey);
    if (stored == 'table') {
      state = CollectionViewMode.table;
    }
  }

  void toggle() {
    state = state == CollectionViewMode.grid
        ? CollectionViewMode.table
        : CollectionViewMode.grid;
    _persistToPrefs();
  }

  void setMode(CollectionViewMode mode) {
    state = mode;
    _persistToPrefs();
  }

  Future<void> _persistToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, state.name);
  }
}

final collectionViewModeProvider =
    NotifierProvider<CollectionViewModeNotifier, CollectionViewMode>(
        () => CollectionViewModeNotifier());
