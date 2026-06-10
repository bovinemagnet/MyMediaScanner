// Persistent override for the global text scale factor (accessibility).
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'text_scale_factor';
const double _defaultFactor = 1.0;
const double _minFactor = 1.0;
const double _maxFactor = 1.6;

/// User-chosen text scale factor. `1.0` means "use the platform setting".
class TextScaleNotifier extends AsyncNotifier<double> {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<double> build() async {
    final prefs = await _instance;
    final stored = prefs.getDouble(_prefsKey);
    return stored ?? _defaultFactor;
  }

  Future<void> setFactor(double value) async {
    final clamped = value.clamp(_minFactor, _maxFactor);
    final prefs = await _instance;
    await prefs.setDouble(_prefsKey, clamped);
    state = AsyncData(clamped);
  }

  Future<void> reset() => setFactor(_defaultFactor);
}

final textScaleProvider =
    AsyncNotifierProvider<TextScaleNotifier, double>(TextScaleNotifier.new);
