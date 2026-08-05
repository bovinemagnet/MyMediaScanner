import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/text_scale.dart';

/// A non-linear scaler in the spirit of Android 14+: small text scales fully,
/// large text is compressed so headings do not run away. Kept gentle enough
/// that it stays clear of [kMaxEffectiveTextScale].
class _CompressingScaler extends TextScaler {
  const _CompressingScaler();

  @override
  double scale(double fontSize) => fontSize < 20 ? fontSize * 1.3 : fontSize + 6;

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => 1.3;
}

void main() {
  group('stackTextScale', () {
    test('applies the in-app factor when the platform does not scale', () {
      final scaler = stackTextScale(TextScaler.noScaling, 1.5);

      expect(scaler.scale(14), 21);
    });

    test('keeps the platform scale when the in-app factor is 1.0', () {
      final scaler = stackTextScale(const TextScaler.linear(1.3), 1.0);

      expect(scaler.scale(14), closeTo(18.2, 0.0001));
    });

    test('stacks the in-app factor on top of the platform scale', () {
      final scaler = stackTextScale(const TextScaler.linear(1.3), 1.5);

      // 1.3 × 1.5 = 1.95
      expect(scaler.scale(14), closeTo(27.3, 0.0001));
    });

    test('preserves a non-linear platform curve rather than flattening it', () {
      const platform = _CompressingScaler();
      final scaler = stackTextScale(platform, 1.5);

      // Body text: 14 × 1.5 = 21 unscaled, which the platform compresses.
      expect(scaler.scale(14), platform.scale(14 * 1.5));
      // Hero text stays compressed too — flattening the curve to a single
      // factor is what makes large text overflow.
      expect(scaler.scale(45), platform.scale(45 * 1.5));
    });

    test('caps the effective scale so layouts stay usable', () {
      // Platform at its Android maximum plus the app's own 150% would reach
      // 3.0, which pushes the dashboard hero off the side of the screen.
      final scaler = stackTextScale(const TextScaler.linear(2.0), 1.5);

      expect(scaler.scale(14), 14 * kMaxEffectiveTextScale);
    });

    test('leaves scales below the cap untouched', () {
      final scaler = stackTextScale(const TextScaler.linear(1.2), 1.15);

      // 1.38 is comfortably under the cap, so nothing is clamped.
      expect(scaler.scale(14), closeTo(19.32, 0.0001));
    });

    test('caps the platform scale even without an in-app factor', () {
      final scaler = stackTextScale(const TextScaler.linear(2.5), 1.0);

      expect(scaler.scale(14), 14 * kMaxEffectiveTextScale);
    });

    test('is equal for the same platform scaler and factor', () {
      // MediaQuery compares its data on every rebuild; an unequal scaler each
      // build would notify every dependent needlessly.
      expect(
        stackTextScale(const TextScaler.linear(1.3), 1.5),
        stackTextScale(const TextScaler.linear(1.3), 1.5),
      );
    });
  });
}
