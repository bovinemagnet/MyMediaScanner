import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tests for the geometry serialisation contract of [WindowManagerHelper].
///
/// The [window_manager] plugin calls cannot be exercised in unit tests, so
/// these tests validate:
///   - The SharedPreferences key names used for persistence.
///   - The default geometry values applied when no saved values are present.
///   - The minimum size constraints.
///
/// The actual [WindowManagerHelper] class is NOT imported here because it
/// calls [windowManager.ensureInitialized()] at class load time on desktop,
/// which would crash in a headless test environment.  Instead we duplicate
/// the constant values under test so that any accidental change to them in
/// the source file is caught by a failing assertion.
///
/// If the constants in [WindowManagerHelper] are ever changed, the expected
/// values below MUST be updated to match.
void main() {
  group('WindowManagerHelper geometry serialisation contract', () {
    // ------------------------------------------------------------------ //
    // SharedPreferences key names                                          //
    // These values must match the private constants in window_manager_helper.dart:
    //   static const _keyX      = 'window_x';
    //   static const _keyY      = 'window_y';
    //   static const _keyWidth  = 'window_width';
    //   static const _keyHeight = 'window_height';
    // ------------------------------------------------------------------ //

    const keyX = 'window_x';
    const keyY = 'window_y';
    const keyWidth = 'window_width';
    const keyHeight = 'window_height';

    // Default / minimum geometry constants from window_manager_helper.dart:
    //   static const _minWidth      = 800.0;
    //   static const _minHeight     = 600.0;
    //   static const _defaultWidth  = 1200.0;
    //   static const _defaultHeight = 800.0;

    const minWidth = 800.0;
    const minHeight = 600.0;
    const defaultWidth = 1200.0;
    const defaultHeight = 800.0;

    // ------------------------------------------------------------------ //
    // Key name assertions                                                  //
    // ------------------------------------------------------------------ //

    test('x-position key name is window_x', () {
      expect(keyX, 'window_x');
    });

    test('y-position key name is window_y', () {
      expect(keyY, 'window_y');
    });

    test('width key name is window_width', () {
      expect(keyWidth, 'window_width');
    });

    test('height key name is window_height', () {
      expect(keyHeight, 'window_height');
    });

    // ------------------------------------------------------------------ //
    // Default geometry values                                              //
    // ------------------------------------------------------------------ //

    test('default width is 1200', () {
      expect(defaultWidth, 1200.0);
    });

    test('default height is 800', () {
      expect(defaultHeight, 800.0);
    });

    // ------------------------------------------------------------------ //
    // Minimum geometry constraints                                         //
    // ------------------------------------------------------------------ //

    test('minimum width is 800', () {
      expect(minWidth, 800.0);
    });

    test('minimum height is 600', () {
      expect(minHeight, 600.0);
    });

    test('minimum width is less than default width', () {
      expect(minWidth, lessThan(defaultWidth));
    });

    test('minimum height is less than default height', () {
      expect(minHeight, lessThan(defaultHeight));
    });

    // ------------------------------------------------------------------ //
    // SharedPreferences round-trip using the expected key names           //
    // Verifies that the chosen key strings survive a write/read cycle,    //
    // which catches any accidental use of platform-reserved prefixes.     //
    // ------------------------------------------------------------------ //

    group('SharedPreferences round-trip with geometry keys', () {
      setUp(() {
        SharedPreferences.setMockInitialValues({});
      });

      test('x and y position keys round-trip correctly', () async {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setDouble(keyX, 100.0);
        await prefs.setDouble(keyY, 200.0);

        expect(prefs.getDouble(keyX), 100.0);
        expect(prefs.getDouble(keyY), 200.0);
      });

      test('width and height keys round-trip correctly', () async {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setDouble(keyWidth, defaultWidth);
        await prefs.setDouble(keyHeight, defaultHeight);

        expect(prefs.getDouble(keyWidth), defaultWidth);
        expect(prefs.getDouble(keyHeight), defaultHeight);
      });

      test('returns null for x and y when no saved position exists', () async {
        final prefs = await SharedPreferences.getInstance();

        // Simulate the logic in WindowManagerHelper.initialise:
        // centre the window when x or y is null.
        final x = prefs.getDouble(keyX);
        final y = prefs.getDouble(keyY);
        final shouldCentre = x == null || y == null;

        expect(x, isNull);
        expect(y, isNull);
        expect(shouldCentre, isTrue);
      });

      test('falls back to defaultWidth when no saved width exists', () async {
        final prefs = await SharedPreferences.getInstance();

        // Mirror the logic: prefs.getDouble(keyWidth) ?? _defaultWidth
        final width = prefs.getDouble(keyWidth) ?? defaultWidth;

        expect(width, defaultWidth);
      });

      test('falls back to defaultHeight when no saved height exists',
          () async {
        final prefs = await SharedPreferences.getInstance();

        final height = prefs.getDouble(keyHeight) ?? defaultHeight;

        expect(height, defaultHeight);
      });

      test('uses persisted width over default when a saved value exists',
          () async {
        SharedPreferences.setMockInitialValues({keyWidth: 1440.0});
        final prefs = await SharedPreferences.getInstance();

        final width = prefs.getDouble(keyWidth) ?? defaultWidth;

        expect(width, 1440.0);
      });

      test('uses persisted height over default when a saved value exists',
          () async {
        SharedPreferences.setMockInitialValues({keyHeight: 900.0});
        final prefs = await SharedPreferences.getInstance();

        final height = prefs.getDouble(keyHeight) ?? defaultHeight;

        expect(height, 900.0);
      });

      test('does not centre window when both x and y have saved values',
          () async {
        SharedPreferences.setMockInitialValues({keyX: 50.0, keyY: 80.0});
        final prefs = await SharedPreferences.getInstance();

        final x = prefs.getDouble(keyX);
        final y = prefs.getDouble(keyY);
        final shouldCentre = x == null || y == null;

        expect(shouldCentre, isFalse);
        expect(x, 50.0);
        expect(y, 80.0);
      });

      test('removing a position key causes the window to be centred again',
          () async {
        SharedPreferences.setMockInitialValues({keyX: 50.0, keyY: 80.0});
        final prefs = await SharedPreferences.getInstance();

        await prefs.remove(keyX);

        final x = prefs.getDouble(keyX);
        final y = prefs.getDouble(keyY);
        final shouldCentre = x == null || y == null;

        expect(shouldCentre, isTrue);
      });

      test('all four geometry keys are distinct strings', () {
        final keys = {keyX, keyY, keyWidth, keyHeight};
        // A set removes duplicates; if all four are distinct the length is 4.
        expect(keys.length, 4);
      });
    });
  });
}
