import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RipViewMode { grid, table }

const _prefKey = 'rip_view_mode';

class RipViewModeNotifier extends Notifier<RipViewMode> {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  RipViewMode build() {
    _loadFromPrefs();
    return RipViewMode.grid;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await _instance;
    final stored = prefs.getString(_prefKey);
    if (stored == 'table') {
      state = RipViewMode.table;
    }
  }

  void toggle() {
    state = state == RipViewMode.grid ? RipViewMode.table : RipViewMode.grid;
    _persistToPrefs();
  }

  void setMode(RipViewMode mode) {
    state = mode;
    _persistToPrefs();
  }

  Future<void> _persistToPrefs() async {
    final prefs = await _instance;
    await prefs.setString(_prefKey, state.name);
  }
}

final ripViewModeProvider =
    NotifierProvider<RipViewModeNotifier, RipViewMode>(
        () => RipViewModeNotifier());
