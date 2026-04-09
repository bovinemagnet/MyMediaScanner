import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/services/audio/audio_player_service.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class FakeAudioSource extends Fake implements AudioSource {}

void main() {
  late MockAudioPlayer mockPlayer;
  late AudioPlayerService service;

  const testAlbum = RipAlbum(
    id: 'album-1',
    libraryPath: '/music/artist/album',
    artist: 'Test Artist',
    albumTitle: 'Test Album',
    trackCount: 3,
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
      filePath: '/music/artist/album/01.flac',
      fileSizeBytes: 30000,
      updatedAt: 1000,
      durationMs: 180000,
    ),
    const RipTrack(
      id: 'track-2',
      ripAlbumId: 'album-1',
      trackNumber: 2,
      title: 'Track Two',
      filePath: '/music/artist/album/02.flac',
      fileSizeBytes: 35000,
      updatedAt: 1000,
      durationMs: 200000,
    ),
    const RipTrack(
      id: 'track-3',
      ripAlbumId: 'album-1',
      trackNumber: 3,
      title: 'Track Three',
      filePath: '/music/artist/album/03.flac',
      fileSizeBytes: 35000,
      updatedAt: 1000,
      durationMs: 220000,
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeAudioSource());
    registerFallbackValue(LoopMode.off);
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    mockPlayer = MockAudioPlayer();

    // Default stubs for stream getters
    when(() => mockPlayer.positionStream)
        .thenAnswer((_) => const Stream<Duration>.empty());
    when(() => mockPlayer.durationStream)
        .thenAnswer((_) => const Stream<Duration?>.empty());
    when(() => mockPlayer.playerStateStream)
        .thenAnswer((_) => const Stream<PlayerState>.empty());
    when(() => mockPlayer.currentIndexStream)
        .thenAnswer((_) => const Stream<int?>.empty());
    when(() => mockPlayer.sequenceStateStream)
        .thenAnswer((_) => const Stream<SequenceState?>.empty());
    when(() => mockPlayer.playing).thenReturn(false);

    service = AudioPlayerService(player: mockPlayer);
  });

  group('AudioPlayerService', () {
    group('initial state', () {
      test('currentAlbum is null initially', () {
        expect(service.currentAlbum, isNull);
      });

      test('currentTracks is empty initially', () {
        expect(service.currentTracks, isEmpty);
      });

      test('isPlaying delegates to underlying player', () {
        when(() => mockPlayer.playing).thenReturn(false);
        expect(service.isPlaying, isFalse);

        when(() => mockPlayer.playing).thenReturn(true);
        expect(service.isPlaying, isTrue);
      });
    });

    group('stream delegation', () {
      test('positionStream delegates to player', () {
        final controller = StreamController<Duration>.broadcast();
        when(() => mockPlayer.positionStream)
            .thenAnswer((_) => controller.stream);

        final stream = service.positionStream;
        expect(stream, isA<Stream<Duration>>());

        controller.close();
      });

      test('durationStream delegates to player', () {
        final controller = StreamController<Duration?>.broadcast();
        when(() => mockPlayer.durationStream)
            .thenAnswer((_) => controller.stream);

        final stream = service.durationStream;
        expect(stream, isA<Stream<Duration?>>());

        controller.close();
      });

      test('playerStateStream delegates to player', () {
        final controller = StreamController<PlayerState>.broadcast();
        when(() => mockPlayer.playerStateStream)
            .thenAnswer((_) => controller.stream);

        final stream = service.playerStateStream;
        expect(stream, isA<Stream<PlayerState>>());

        controller.close();
      });

      test('currentIndexStream delegates to player', () {
        final controller = StreamController<int?>.broadcast();
        when(() => mockPlayer.currentIndexStream)
            .thenAnswer((_) => controller.stream);

        final stream = service.currentIndexStream;
        expect(stream, isA<Stream<int?>>());

        controller.close();
      });

      test('sequenceStateStream delegates to player', () {
        final controller = StreamController<SequenceState?>.broadcast();
        when(() => mockPlayer.sequenceStateStream)
            .thenAnswer((_) => controller.stream);

        final stream = service.sequenceStateStream;
        expect(stream, isA<Stream<SequenceState?>>());

        controller.close();
      });
    });

    group('playAlbum', () {
      test('sets currentAlbum and currentTracks', () async {
        when(() => mockPlayer.setAudioSource(any(), initialIndex: any(named: 'initialIndex')))
            .thenAnswer((_) async => const Duration(seconds: 600));
        when(() => mockPlayer.play()).thenAnswer((_) async {});

        await service.playAlbum(
          album: testAlbum,
          tracks: testTracks,
        );

        expect(service.currentAlbum, testAlbum);
        expect(service.currentTracks, testTracks);
        expect(service.currentTracks, isA<List<RipTrack>>());
      });

      test('calls setAudioSource with ConcatenatingAudioSource', () async {
        when(() => mockPlayer.setAudioSource(any(), initialIndex: any(named: 'initialIndex')))
            .thenAnswer((_) async => const Duration(seconds: 600));
        when(() => mockPlayer.play()).thenAnswer((_) async {});

        await service.playAlbum(
          album: testAlbum,
          tracks: testTracks,
        );

        final captured = verify(
          () => mockPlayer.setAudioSource(
            captureAny(),
            initialIndex: any(named: 'initialIndex'),
          ),
        ).captured;

        expect(captured.first, isA<ConcatenatingAudioSource>());
      });

      test('passes startIndex to setAudioSource', () async {
        when(() => mockPlayer.setAudioSource(any(), initialIndex: any(named: 'initialIndex')))
            .thenAnswer((_) async => const Duration(seconds: 600));
        when(() => mockPlayer.play()).thenAnswer((_) async {});

        await service.playAlbum(
          album: testAlbum,
          tracks: testTracks,
          startIndex: 2,
        );

        verify(
          () => mockPlayer.setAudioSource(
            any(),
            initialIndex: 2,
          ),
        ).called(1);
      });

      test('calls play after setting audio source', () async {
        when(() => mockPlayer.setAudioSource(any(), initialIndex: any(named: 'initialIndex')))
            .thenAnswer((_) async => const Duration(seconds: 600));
        when(() => mockPlayer.play()).thenAnswer((_) async {});

        await service.playAlbum(
          album: testAlbum,
          tracks: testTracks,
        );

        verify(() => mockPlayer.play()).called(1);
      });

      test('currentTracks is unmodifiable', () async {
        when(() => mockPlayer.setAudioSource(any(), initialIndex: any(named: 'initialIndex')))
            .thenAnswer((_) async => const Duration(seconds: 600));
        when(() => mockPlayer.play()).thenAnswer((_) async {});

        await service.playAlbum(
          album: testAlbum,
          tracks: testTracks,
        );

        expect(
          () => (service.currentTracks as List).add(testTracks.first),
          throwsUnsupportedError,
        );
      });
    });

    group('resume', () {
      test('calls play on the underlying player', () async {
        when(() => mockPlayer.play()).thenAnswer((_) async {});

        await service.resume();

        verify(() => mockPlayer.play()).called(1);
      });
    });

    group('pause', () {
      test('calls pause on the underlying player', () async {
        when(() => mockPlayer.pause()).thenAnswer((_) async {});

        await service.pause();

        verify(() => mockPlayer.pause()).called(1);
      });
    });

    group('stop', () {
      test('calls stop on the underlying player', () async {
        when(() => mockPlayer.stop()).thenAnswer((_) async {});

        await service.stop();

        verify(() => mockPlayer.stop()).called(1);
      });

      test('clears currentAlbum and currentTracks', () async {
        // First play an album
        when(() => mockPlayer.setAudioSource(any(), initialIndex: any(named: 'initialIndex')))
            .thenAnswer((_) async => const Duration(seconds: 600));
        when(() => mockPlayer.play()).thenAnswer((_) async {});
        when(() => mockPlayer.stop()).thenAnswer((_) async {});

        await service.playAlbum(
          album: testAlbum,
          tracks: testTracks,
        );

        expect(service.currentAlbum, isNotNull);
        expect(service.currentTracks, isNotEmpty);

        await service.stop();

        expect(service.currentAlbum, isNull);
        expect(service.currentTracks, isEmpty);
      });
    });

    group('seek', () {
      test('calls seek on the underlying player', () async {
        when(() => mockPlayer.seek(any())).thenAnswer((_) async {});

        const position = Duration(seconds: 30);
        await service.seek(position);

        verify(() => mockPlayer.seek(position)).called(1);
      });
    });

    group('seekToNext', () {
      test('calls seekToNext on the underlying player', () async {
        when(() => mockPlayer.seekToNext()).thenAnswer((_) async {});

        await service.seekToNext();

        verify(() => mockPlayer.seekToNext()).called(1);
      });
    });

    group('seekToPrevious', () {
      test('calls seekToPrevious on the underlying player', () async {
        when(() => mockPlayer.seekToPrevious()).thenAnswer((_) async {});

        await service.seekToPrevious();

        verify(() => mockPlayer.seekToPrevious()).called(1);
      });
    });

    group('setVolume', () {
      test('calls setVolume on the underlying player', () async {
        when(() => mockPlayer.setVolume(any())).thenAnswer((_) async {});

        await service.setVolume(0.75);

        verify(() => mockPlayer.setVolume(0.75)).called(1);
      });
    });

    group('setLoopMode', () {
      test('calls setLoopMode on the underlying player', () async {
        when(() => mockPlayer.setLoopMode(any())).thenAnswer((_) async {});

        await service.setLoopMode(LoopMode.all);

        verify(() => mockPlayer.setLoopMode(LoopMode.all)).called(1);
      });
    });

    group('setShuffleEnabled', () {
      test('calls setShuffleModeEnabled on the underlying player', () async {
        when(() => mockPlayer.setShuffleModeEnabled(any()))
            .thenAnswer((_) async {});

        await service.setShuffleEnabled(true);

        verify(() => mockPlayer.setShuffleModeEnabled(true)).called(1);
      });
    });

    group('dispose', () {
      test('calls dispose on the underlying player', () async {
        when(() => mockPlayer.dispose()).thenAnswer((_) async {});

        await service.dispose();

        verify(() => mockPlayer.dispose()).called(1);
      });
    });
  });
}
