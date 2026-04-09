/// Tests for playback speed Riverpod provider.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/playback_speed_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('playbackSpeedProvider', () {
    test('build_initialState_isOne', () {
      final container = makeContainer();

      expect(container.read(playbackSpeedProvider), 1.0);
    });

    test('setSpeed_updatesState', () {
      final container = makeContainer();

      container.read(playbackSpeedProvider.notifier).setSpeed(1.5);

      expect(container.read(playbackSpeedProvider), 1.5);
    });

    test('setSpeed_clampsToRange', () {
      final container = makeContainer();

      container.read(playbackSpeedProvider.notifier).setSpeed(0.1);
      expect(container.read(playbackSpeedProvider), 0.5);

      container.read(playbackSpeedProvider.notifier).setSpeed(5.0);
      expect(container.read(playbackSpeedProvider), 2.0);
    });

    test('reset_setsSpeedToOne', () {
      final container = makeContainer();

      container.read(playbackSpeedProvider.notifier).setSpeed(1.75);
      container.read(playbackSpeedProvider.notifier).reset();

      expect(container.read(playbackSpeedProvider), 1.0);
    });
  });
}
