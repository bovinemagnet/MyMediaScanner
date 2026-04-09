/// Riverpod provider for playback speed, persisted to SharedPreferences.
///
/// Maintains a speed value in the range 0.5–2.0, defaulting to 1.0.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _speedPrefKey = 'playback_speed';
const _minSpeed = 0.5;
const _maxSpeed = 2.0;
const _defaultSpeed = 1.0;

/// Notifier for playback speed, persisted to SharedPreferences.
class PlaybackSpeedNotifier extends Notifier<double> {
  @override
  double build() {
    _load();
    return _defaultSpeed;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(_speedPrefKey);
    if (stored != null) state = stored.clamp(_minSpeed, _maxSpeed);
  }

  /// Updates the playback speed (clamped to 0.5–2.0) and persists it.
  void setSpeed(double speed) {
    state = speed.clamp(_minSpeed, _maxSpeed);
    _persist();
  }

  /// Resets the playback speed to 1.0 and persists it.
  void reset() {
    state = _defaultSpeed;
    _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_speedPrefKey, state);
  }
}

/// Provider for the current playback speed (default: 1.0, range: 0.5–2.0).
final playbackSpeedProvider =
    NotifierProvider<PlaybackSpeedNotifier, double>(
        () => PlaybackSpeedNotifier());
