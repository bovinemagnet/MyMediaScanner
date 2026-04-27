import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefKey = 'master_detail_split_ratio';
const _defaultRatio = 0.45;

/// Drag-debounce window. The master-detail divider can fire `setRatio`
/// at frame rate during a drag; without debouncing each pixel queues a
/// SharedPreferences write and saturates the platform-channel queue.
/// State updates remain immediate so the UI is responsive — only the
/// persistence is throttled.
const _persistDebounce = Duration(milliseconds: 250);

class SplitRatioNotifier extends Notifier<double> {
  Timer? _persistTimer;

  @override
  double build() {
    _loadFromPrefs();
    ref.onDispose(() {
      _persistTimer?.cancel();
      _persistTimer = null;
    });
    return _defaultRatio;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(_prefKey);
    if (stored != null && ref.mounted) {
      state = stored;
    }
  }

  void setRatio(double ratio) {
    state = ratio;
    _schedulePersist();
  }

  /// Schedule a single prefs write [_persistDebounce] after the most
  /// recent `setRatio` call. Repeated drag updates collapse to one
  /// write at rest, instead of one per drag-update.
  void _schedulePersist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(_persistDebounce, _persistToPrefs);
  }

  Future<void> _persistToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefKey, state);
  }
}

final splitRatioProvider =
    NotifierProvider<SplitRatioNotifier, double>(
        () => SplitRatioNotifier());
