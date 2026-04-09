/// Tests for ReplayGain Riverpod providers.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/services/audio/replay_gain_service.dart';
import 'package:mymediascanner/presentation/providers/replay_gain_provider.dart';
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

  // ------------------------------------------------------------------
  // replayGainModeProvider
  // ------------------------------------------------------------------

  group('replayGainModeProvider', () {
    test('build_initialState_isOff', () {
      final container = makeContainer();

      expect(container.read(replayGainModeProvider), ReplayGainMode.off);
    });

    test('setMode_track_updatesState', () {
      final container = makeContainer();

      container.read(replayGainModeProvider.notifier).setMode(ReplayGainMode.track);

      expect(container.read(replayGainModeProvider), ReplayGainMode.track);
    });

    test('build_withStoredTrackMode_loadsTrackState', () async {
      SharedPreferences.setMockInitialValues({'replay_gain_mode': 'track'});

      final container = ProviderContainer();
      final completer = Completer<ReplayGainMode>();
      final sub = container.listen<ReplayGainMode>(
        replayGainModeProvider,
        (_, next) {
          if (!completer.isCompleted) completer.complete(next);
        },
        fireImmediately: false,
      );

      final result = await completer.future.timeout(
        const Duration(seconds: 1),
        onTimeout: () => container.read(replayGainModeProvider),
      );

      sub.close();
      container.dispose();

      expect(result, ReplayGainMode.track);
    });
  });

  // ------------------------------------------------------------------
  // replayGainPreampProvider
  // ------------------------------------------------------------------

  group('replayGainPreampProvider', () {
    test('build_initialState_isZero', () {
      final container = makeContainer();

      expect(container.read(replayGainPreampProvider), 0.0);
    });

    test('setPreamp_updatesState', () {
      final container = makeContainer();

      container.read(replayGainPreampProvider.notifier).setPreamp(3.0);

      expect(container.read(replayGainPreampProvider), 3.0);
    });
  });

  // ------------------------------------------------------------------
  // preventClippingProvider
  // ------------------------------------------------------------------

  group('preventClippingProvider', () {
    test('build_initialState_isTrue', () {
      final container = makeContainer();

      expect(container.read(preventClippingProvider), isTrue);
    });

    test('setPreventClipping_false_updatesState', () {
      final container = makeContainer();

      container.read(preventClippingProvider.notifier).setPreventClipping(false);

      expect(container.read(preventClippingProvider), isFalse);
    });
  });

  // ------------------------------------------------------------------
  // replayGainServiceProvider
  // ------------------------------------------------------------------

  group('replayGainServiceProvider', () {
    test('provides_ReplayGainService_instance', () {
      final container = makeContainer();

      final svc = container.read(replayGainServiceProvider);

      expect(svc, isA<ReplayGainService>());
    });
  });
}
