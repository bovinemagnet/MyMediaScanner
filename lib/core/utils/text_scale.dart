// Combines the user's in-app text-size factor with the platform's own
// text-scaling setting.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/painting.dart';

/// Ceiling on the combined text scale.
///
/// The in-app factor reaches 1.5 and Android's own setting reaches 2.0, so
/// stacking them unchecked lands at 3.0 — enough to push the dashboard hero
/// off the side of the screen. 2.0 is the largest scale the widget tests
/// cover and the largest the layouts are known to survive.
const double kMaxEffectiveTextScale = 2.0;

/// Returns a [TextScaler] applying the user's in-app [factor] on top of the
/// [platform] scaler, so the app scales with the device text-size setting
/// rather than replacing it.
///
/// Delegating to [platform] rather than collapsing it to a single number
/// keeps the platform's own curve intact. Android 14+ scales large text less
/// aggressively than small text, and flattening that curve is what makes
/// headings overflow at high scale factors.
TextScaler stackTextScale(TextScaler platform, double factor) {
  final stacked =
      factor == 1.0 ? platform : _StackedTextScaler(platform, factor);
  return stacked.clamp(maxScaleFactor: kMaxEffectiveTextScale);
}

class _StackedTextScaler extends TextScaler {
  const _StackedTextScaler(this._platform, this._factor);

  final TextScaler _platform;
  final double _factor;

  @override
  double scale(double fontSize) => _platform.scale(fontSize * _factor);

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => _platform.textScaleFactor * _factor;

  // MediaQuery compares its data on every rebuild, so an instance that never
  // equals its predecessor would notify every dependent needlessly.
  @override
  bool operator ==(Object other) =>
      other is _StackedTextScaler &&
      other._platform == _platform &&
      other._factor == _factor;

  @override
  int get hashCode => Object.hash(_platform, _factor);
}
