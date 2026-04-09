/// Tests for audio playback Riverpod providers.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/services/audio/audio_player_service.dart';
import 'package:mymediascanner/core/services/audio/replay_gain_service.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
import 'package:mymediascanner/presentation/providers/replay_gain_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAudioPlayerService extends Mock implements AudioPlayerService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const RipAlbum(
      id: '',
      libraryPath: '',
      trackCount: 0,
      totalSizeBytes: 0,
      lastScannedAt: 0,
      updatedAt: 0,
    ));
    registerFallbackValue(<RipTrack>[]);
    registerFallbackValue(Duration.zero);
    registerFallbackValue(LoopMode.off);
  });

  late MockAudioPlayerService mockService;

  const testAlbum = RipAlbum(
    id: 'album-1',
    libraryPath: '/music/album1',
    trackCount: 2,
    totalSizeBytes: 100000,
    lastScannedAt: 1000,
    updatedAt: 1000,
  );

  final testTracks = [
    const RipTrack(
      id: 'track-1',
      ripAlbumId: 'album-1',
      trackNumber: 1,
      title: 'Track One',
      filePath: '/music/album1/01.flac',
      fileSizeBytes: 50000,
      updatedAt: 1000,
    ),
    const RipTrack(
      id: 'track-2',
      ripAlbumId: 'album-1',
      trackNumber: 2,
      title: 'Track Two',
      filePath: '/music/album1/02.flac',
      fileSizeBytes: 50000,
      updatedAt: 1000,
    ),
  ];

  setUp(() {
    mockService = MockAudioPlayerService();
    // Provide an in-memory SharedPreferences store so ReplayGain providers
    // don't touch the file system during tests.
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        audioPlayerServiceProvider.overrideWithValue(mockService),
        // Override ReplayGain providers with deterministic defaults so that
        // setVolume() tests are not affected by async SharedPreferences loads.
        replayGainModeProvider.overrideWith(() => _FixedReplayGainModeNotifier()),
        replayGainPreampProvider.overrideWith(() => _FixedPreampNotifier()),
        preventClippingProvider.overrideWith(() => _FixedPreventClippingNotifier()),
        replayGainServiceProvider.overrideWithValue(const ReplayGainService()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  // ----------------------------------------------------------------
  // NowPlayingNotifier
  // ----------------------------------------------------------------

  group('NowPlayingNotifier', () {
    test('build_initialState_hasNullAlbumAndEmptyTracks', () {
      final container = makeContainer();

      final state = container.read(nowPlayingProvider);

      expect(state.album, isNull);
      expect(state.tracks, isEmpty);
    });

    test('set_withAlbumAndTracks_updatesState', () {
      final container = makeContainer();
      final notifier = container.read(nowPlayingProvider.notifier);

      notifier.set(album: testAlbum, tracks: testTracks);

      final state = container.read(nowPlayingProvider);
      expect(state.album, testAlbum);
      expect(state.tracks, testTracks);
    });

    test('clear_afterSet_resetsToInitialState', () {
      final container = makeContainer();
      final notifier = container.read(nowPlayingProvider.notifier);
      notifier.set(album: testAlbum, tracks: testTracks);

      notifier.clear();

      final state = container.read(nowPlayingProvider);
      expect(state.album, isNull);
      expect(state.tracks, isEmpty);
    });

    test('clear_whenAlreadyEmpty_remainsEmpty', () {
      final container = makeContainer();
      final notifier = container.read(nowPlayingProvider.notifier);

      notifier.clear();

      final state = container.read(nowPlayingProvider);
      expect(state.album, isNull);
      expect(state.tracks, isEmpty);
    });
  });

  // ----------------------------------------------------------------
  // PlaybackActionNotifier
  // ----------------------------------------------------------------

  group('PlaybackActionNotifier', () {
    test('playAlbum_updatesNowPlayingAndCallsService', () async {
      when(() => mockService.playAlbum(
            album: any(named: 'album'),
            tracks: any(named: 'tracks'),
            startIndex: any(named: 'startIndex'),
          )).thenAnswer((_) async {});

      final container = makeContainer();
      final actions = container.read(playbackActionProvider.notifier);

      await actions.playAlbum(
        album: testAlbum,
        tracks: testTracks,
        startIndex: 0,
      );

      // Verify now-playing state was updated
      final nowPlaying = container.read(nowPlayingProvider);
      expect(nowPlaying.album, testAlbum);
      expect(nowPlaying.tracks, testTracks);

      // Verify service was called
      verify(() => mockService.playAlbum(
            album: testAlbum,
            tracks: testTracks,
            startIndex: 0,
          )).called(1);
    });

    test('pause_delegatesToService', () async {
      when(() => mockService.pause()).thenAnswer((_) async {});

      final container = makeContainer();
      final actions = container.read(playbackActionProvider.notifier);

      await actions.pause();

      verify(() => mockService.pause()).called(1);
    });

    test('resume_delegatesToService', () async {
      when(() => mockService.resume()).thenAnswer((_) async {});

      final container = makeContainer();
      final actions = container.read(playbackActionProvider.notifier);

      await actions.resume();

      verify(() => mockService.resume()).called(1);
    });

    test('togglePlayPause_whenPlaying_pauses', () async {
      when(() => mockService.isPlaying).thenReturn(true);
      when(() => mockService.pause()).thenAnswer((_) async {});

      final container = makeContainer();
      final actions = container.read(playbackActionProvider.notifier);

      await actions.togglePlayPause();

      verify(() => mockService.pause()).called(1);
      verifyNever(() => mockService.resume());
    });

    test('togglePlayPause_whenNotPlaying_resumes', () async {
      when(() => mockService.isPlaying).thenReturn(false);
      when(() => mockService.resume()).thenAnswer((_) async {});

      final container = makeContainer();
      final actions = container.read(playbackActionProvider.notifier);

      await actions.togglePlayPause();

      verify(() => mockService.resume()).called(1);
      verifyNever(() => mockService.pause());
    });

    test('stop_clearsNowPlayingAndCallsService', () async {
      when(() => mockService.playAlbum(
            album: any(named: 'album'),
            tracks: any(named: 'tracks'),
            startIndex: any(named: 'startIndex'),
          )).thenAnswer((_) async {});
      when(() => mockService.stop()).thenAnswer((_) async {});

      final container = makeContainer();
      final actions = container.read(playbackActionProvider.notifier);

      // First play something
      await actions.playAlbum(
        album: testAlbum,
        tracks: testTracks,
      );
      expect(container.read(nowPlayingProvider).album, isNotNull);

      // Now stop
      await actions.stop();

      verify(() => mockService.stop()).called(1);
      final nowPlaying = container.read(nowPlayingProvider);
      expect(nowPlaying.album, isNull);
      expect(nowPlaying.tracks, isEmpty);
    });

    test('seek_delegatesToService', () async {
      when(() => mockService.seek(any())).thenAnswer((_) async {});

      final container = makeContainer();
      final actions = container.read(playbackActionProvider.notifier);

      await actions.seek(const Duration(seconds: 30));

      verify(() => mockService.seek(const Duration(seconds: 30))).called(1);
    });

    test('seekToNext_delegatesToService', () async {
      when(() => mockService.seekToNext()).thenAnswer((_) async {});

      final container = makeContainer();
      final actions = container.read(playbackActionProvider.notifier);

      await actions.seekToNext();

      verify(() => mockService.seekToNext()).called(1);
    });

    test('seekToPrevious_delegatesToService', () async {
      when(() => mockService.seekToPrevious()).thenAnswer((_) async {});

      final container = makeContainer();
      final actions = container.read(playbackActionProvider.notifier);

      await actions.seekToPrevious();

      verify(() => mockService.seekToPrevious()).called(1);
    });

    test('setVolume_delegatesToService', () async {
      when(() => mockService.setVolume(any())).thenAnswer((_) async {});

      final container = makeContainer();
      final actions = container.read(playbackActionProvider.notifier);

      await actions.setVolume(0.75);

      verify(() => mockService.setVolume(0.75)).called(1);
    });

    test('setLoopMode_delegatesToService', () async {
      when(() => mockService.setLoopMode(any())).thenAnswer((_) async {});

      final container = makeContainer();
      final actions = container.read(playbackActionProvider.notifier);

      await actions.setLoopMode(LoopMode.all);

      verify(() => mockService.setLoopMode(LoopMode.all)).called(1);
    });

    test('setShuffleEnabled_delegatesToService', () async {
      when(() => mockService.setShuffleEnabled(any()))
          .thenAnswer((_) async {});

      final container = makeContainer();
      final actions = container.read(playbackActionProvider.notifier);

      await actions.setShuffleEnabled(true);

      verify(() => mockService.setShuffleEnabled(true)).called(1);
    });
  });

  // ----------------------------------------------------------------
  // Stream providers
  // ----------------------------------------------------------------

  group('Stream providers', () {
    test('playbackPositionProvider_emitsFromService', () async {
      final controller = StreamController<Duration>.broadcast();
      when(() => mockService.positionStream).thenAnswer((_) => controller.stream);

      final container = makeContainer();

      Duration? received;
      container.listen(playbackPositionProvider, (_, next) {
        if (next is AsyncData<Duration>) {
          received = next.value;
        }
      });

      controller.add(const Duration(seconds: 5));
      // Allow microtask queue to flush
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(received, const Duration(seconds: 5));

      await controller.close();
    });

    test('playbackDurationProvider_emitsFromService', () async {
      final controller = StreamController<Duration?>.broadcast();
      when(() => mockService.durationStream).thenAnswer((_) => controller.stream);

      final container = makeContainer();

      Duration? received;
      var gotValue = false;
      container.listen(playbackDurationProvider, (_, next) {
        if (next is AsyncData<Duration?>) {
          received = next.value;
          gotValue = true;
        }
      });

      controller.add(const Duration(minutes: 3));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(gotValue, isTrue);
      expect(received, const Duration(minutes: 3));

      await controller.close();
    });

    test('currentTrackIndexProvider_emitsFromService', () async {
      final controller = StreamController<int?>.broadcast();
      when(() => mockService.currentIndexStream).thenAnswer((_) => controller.stream);

      final container = makeContainer();

      int? received;
      var gotValue = false;
      container.listen(currentTrackIndexProvider, (_, next) {
        if (next is AsyncData<int?>) {
          received = next.value;
          gotValue = true;
        }
      });

      controller.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(gotValue, isTrue);
      expect(received, 1);

      await controller.close();
    });
  });
}

// ---------------------------------------------------------------------------
// Stub notifiers that bypass SharedPreferences for use in makeContainer().
// These extend the real notifier classes to satisfy overrideWith type checks.
// ---------------------------------------------------------------------------

class _FixedReplayGainModeNotifier extends ReplayGainModeNotifier {
  @override
  ReplayGainMode build() => ReplayGainMode.off; // skip async prefs load
}

class _FixedPreampNotifier extends ReplayGainPreampNotifier {
  @override
  double build() => 0.0; // skip async prefs load
}

class _FixedPreventClippingNotifier extends PreventClippingNotifier {
  @override
  bool build() => true; // skip async prefs load
}
