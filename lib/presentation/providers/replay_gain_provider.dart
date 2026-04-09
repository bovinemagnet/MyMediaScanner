/// Riverpod providers for ReplayGain normalisation settings.
///
/// Persists mode, pre-amp, and clipping-prevention preferences to
/// SharedPreferences so they survive app restarts.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/services/audio/replay_gain_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ------------------------------------------------------------------
// ReplayGain mode
// ------------------------------------------------------------------

const _modePrefKey = 'replay_gain_mode';

/// Notifier for [ReplayGainMode], persisted to SharedPreferences.
class ReplayGainModeNotifier extends Notifier<ReplayGainMode> {
  @override
  ReplayGainMode build() {
    _load();
    return ReplayGainMode.off;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_modePrefKey);
    final loaded = switch (stored) {
      'track' => ReplayGainMode.track,
      'album' => ReplayGainMode.album,
      _ => null,
    };
    if (loaded != null) state = loaded;
  }

  /// Updates the ReplayGain mode and persists it.
  void setMode(ReplayGainMode mode) {
    state = mode;
    _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modePrefKey, state.name);
  }
}

/// Provider for the current [ReplayGainMode] (default: off).
final replayGainModeProvider =
    NotifierProvider<ReplayGainModeNotifier, ReplayGainMode>(
        () => ReplayGainModeNotifier());

// ------------------------------------------------------------------
// Pre-amp
// ------------------------------------------------------------------

const _preampPrefKey = 'replay_gain_preamp_db';

/// Notifier for the ReplayGain pre-amp value in dB, persisted to
/// SharedPreferences.
class ReplayGainPreampNotifier extends Notifier<double> {
  @override
  double build() {
    _load();
    return 0.0;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(_preampPrefKey);
    if (stored != null) state = stored.clamp(-6.0, 6.0);
  }

  /// Updates the pre-amp value (clamped to −6.0…+6.0 dB) and persists it.
  void setPreamp(double db) {
    state = db.clamp(-6.0, 6.0);
    _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_preampPrefKey, state);
  }
}

/// Provider for the ReplayGain pre-amp in dB (default: 0.0).
final replayGainPreampProvider =
    NotifierProvider<ReplayGainPreampNotifier, double>(
        () => ReplayGainPreampNotifier());

// ------------------------------------------------------------------
// Prevent clipping
// ------------------------------------------------------------------

const _clipPrefKey = 'replay_gain_prevent_clipping';

/// Notifier for the prevent-clipping flag, persisted to SharedPreferences.
class PreventClippingNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    // Only update state if the key actually exists; absence means default (true).
    if (prefs.containsKey(_clipPrefKey)) {
      state = prefs.getBool(_clipPrefKey) ?? true;
    }
  }

  /// Updates the clipping-prevention flag and persists it.
  void setPreventClipping(bool value) {
    state = value;
    _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_clipPrefKey, state);
  }
}

/// Provider for the prevent-clipping setting (default: true).
final preventClippingProvider =
    NotifierProvider<PreventClippingNotifier, bool>(
        () => PreventClippingNotifier());

// ------------------------------------------------------------------
// ReplayGainService singleton
// ------------------------------------------------------------------

/// Provides the stateless [ReplayGainService] instance.
final replayGainServiceProvider = Provider<ReplayGainService>(
  (_) => const ReplayGainService(),
);
