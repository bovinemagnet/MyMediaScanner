# Music Playback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add gapless album playback with persistent mini player bar to the rip library screen on desktop platforms (Linux, macOS, Windows).

**Architecture:** A singleton `AudioPlayerService` wraps `just_audio`, managed by Riverpod providers. A persistent mini player bar in `AppScaffold` shows playback state across all screens. The album detail dialog gets inline play controls and track-tap-to-play.

**Tech Stack:** Flutter, just_audio, Riverpod 3.x (hand-written Notifier), Freezed entities

---

### Task 1: Add `just_audio` dependency

**Files:**
- Modify: `pubspec.yaml:67` (after `flutter_tesseract_ocr`)

- [ ] **Step 1: Add just_audio to pubspec.yaml**

In `pubspec.yaml`, after line 67 (`flutter_tesseract_ocr: ^0.4.30`), add:

```yaml
  just_audio: ^0.9.43
```

- [ ] **Step 2: Run pub get**

Run: `flutter pub get`
Expected: Dependencies resolve successfully, `just_audio` appears in `pubspec.lock`

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "deps: add just_audio for rip library playback"
```

---

### Task 2: Create AudioPlayerService

**Files:**
- Create: `lib/core/services/audio/audio_player_service.dart`
- Create: `test/unit/core/services/audio/audio_player_service_test.dart`

- [ ] **Step 1: Write failing tests for AudioPlayerService**

Create `test/unit/core/services/audio/audio_player_service_test.dart`:

```dart
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

  final testAlbum = RipAlbum(
    id: 'album-1',
    libraryPath: '/music/album1',
    artist: 'Test Artist',
    albumTitle: 'Test Album',
    trackCount: 3,
    totalSizeBytes: 1000000,
    lastScannedAt: 0,
    updatedAt: 0,
  );

  final testTracks = [
    RipTrack(
      id: 'track-1',
      ripAlbumId: 'album-1',
      trackNumber: 1,
      title: 'Track One',
      filePath: '/music/album1/01.flac',
      fileSizeBytes: 300000,
      updatedAt: 0,
      durationMs: 180000,
    ),
    RipTrack(
      id: 'track-2',
      ripAlbumId: 'album-1',
      trackNumber: 2,
      title: 'Track Two',
      filePath: '/music/album1/02.flac',
      fileSizeBytes: 350000,
      updatedAt: 0,
      durationMs: 200000,
    ),
    RipTrack(
      id: 'track-3',
      ripAlbumId: 'album-1',
      trackNumber: 3,
      title: 'Track Three',
      filePath: '/music/album1/03.flac',
      fileSizeBytes: 350000,
      updatedAt: 0,
      durationMs: 220000,
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeAudioSource());
  });

  setUp(() {
    mockPlayer = MockAudioPlayer();
    when(() => mockPlayer.setAudioSource(any(),
            initialIndex: any(named: 'initialIndex')))
        .thenAnswer((_) async => null);
    when(() => mockPlayer.play()).thenAnswer((_) async {});
    when(() => mockPlayer.pause()).thenAnswer((_) async {});
    when(() => mockPlayer.stop()).thenAnswer((_) async {});
    when(() => mockPlayer.seek(any(), index: any(named: 'index')))
        .thenAnswer((_) async {});
    when(() => mockPlayer.seekToNext()).thenAnswer((_) async {});
    when(() => mockPlayer.seekToPrevious()).thenAnswer((_) async {});
    when(() => mockPlayer.setLoopMode(any())).thenAnswer((_) async {});
    when(() => mockPlayer.setShuffleModeEnabled(any()))
        .thenAnswer((_) async {});
    when(() => mockPlayer.setVolume(any())).thenAnswer((_) async {});
    when(() => mockPlayer.dispose()).thenAnswer((_) async {});
    when(() => mockPlayer.positionStream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockPlayer.durationStream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockPlayer.playerStateStream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockPlayer.currentIndexStream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockPlayer.sequenceStateStream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockPlayer.playing).thenReturn(false);

    service = AudioPlayerService(player: mockPlayer);
  });

  group('AudioPlayerService', () {
    test('playAlbum sets audio source and plays', () async {
      await service.playAlbum(
        album: testAlbum,
        tracks: testTracks,
        startIndex: 0,
      );

      verify(() => mockPlayer.setAudioSource(
            any(),
            initialIndex: 0,
          )).called(1);
      verify(() => mockPlayer.play()).called(1);
      expect(service.currentAlbum, testAlbum);
      expect(service.currentTracks, testTracks);
    });

    test('playAlbum with startIndex starts at correct track', () async {
      await service.playAlbum(
        album: testAlbum,
        tracks: testTracks,
        startIndex: 2,
      );

      verify(() => mockPlayer.setAudioSource(
            any(),
            initialIndex: 2,
          )).called(1);
    });

    test('pause delegates to player', () async {
      await service.pause();
      verify(() => mockPlayer.pause()).called(1);
    });

    test('resume delegates to player', () async {
      await service.resume();
      verify(() => mockPlayer.play()).called(1);
    });

    test('seekToNext delegates to player', () async {
      await service.seekToNext();
      verify(() => mockPlayer.seekToNext()).called(1);
    });

    test('seekToPrevious delegates to player', () async {
      await service.seekToPrevious();
      verify(() => mockPlayer.seekToPrevious()).called(1);
    });

    test('seek delegates to player', () async {
      await service.seek(const Duration(seconds: 30));
      verify(() => mockPlayer.seek(const Duration(seconds: 30))).called(1);
    });

    test('stop clears current album and stops player', () async {
      await service.playAlbum(
        album: testAlbum,
        tracks: testTracks,
        startIndex: 0,
      );

      await service.stop();

      verify(() => mockPlayer.stop()).called(1);
      expect(service.currentAlbum, isNull);
      expect(service.currentTracks, isEmpty);
    });

    test('setVolume delegates to player', () async {
      await service.setVolume(0.5);
      verify(() => mockPlayer.setVolume(0.5)).called(1);
    });

    test('setLoopMode delegates to player', () async {
      await service.setLoopMode(LoopMode.all);
      verify(() => mockPlayer.setLoopMode(LoopMode.all)).called(1);
    });

    test('setShuffleEnabled delegates to player', () async {
      await service.setShuffleEnabled(true);
      verify(() => mockPlayer.setShuffleModeEnabled(true)).called(1);
    });

    test('dispose disposes the player', () async {
      await service.dispose();
      verify(() => mockPlayer.dispose()).called(1);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/unit/core/services/audio/audio_player_service_test.dart`
Expected: FAIL — `audio_player_service.dart` does not exist yet

- [ ] **Step 3: Implement AudioPlayerService**

Create `lib/core/services/audio/audio_player_service.dart`:

```dart
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

/// Wraps [AudioPlayer] from just_audio to provide album-based playback
/// with gapless transitions via [ConcatenatingAudioSource].
class AudioPlayerService {
  AudioPlayerService({AudioPlayer? player})
      : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  RipAlbum? _currentAlbum;
  List<RipTrack> _currentTracks = [];

  // ── Public getters ──────────────────────────────────────────────────

  RipAlbum? get currentAlbum => _currentAlbum;
  List<RipTrack> get currentTracks => List.unmodifiable(_currentTracks);
  bool get isPlaying => _player.playing;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<SequenceState?> get sequenceStateStream =>
      _player.sequenceStateStream;

  // ── Playback control ────────────────────────────────────────────────

  /// Load an album's tracks as a gapless concatenating source and start
  /// playback from [startIndex].
  Future<void> playAlbum({
    required RipAlbum album,
    required List<RipTrack> tracks,
    int startIndex = 0,
  }) async {
    _currentAlbum = album;
    _currentTracks = List.of(tracks);

    final sources = tracks
        .map((t) => AudioSource.file(t.filePath))
        .toList();

    final playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: sources,
    );

    await _player.setAudioSource(playlist, initialIndex: startIndex);
    await _player.play();
  }

  Future<void> resume() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> stop() async {
    await _player.stop();
    _currentAlbum = null;
    _currentTracks = [];
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> seekToNext() => _player.seekToNext();

  Future<void> seekToPrevious() => _player.seekToPrevious();

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  Future<void> setLoopMode(LoopMode mode) => _player.setLoopMode(mode);

  Future<void> setShuffleEnabled(bool enabled) =>
      _player.setShuffleModeEnabled(enabled);

  Future<void> dispose() => _player.dispose();
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/unit/core/services/audio/audio_player_service_test.dart`
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/services/audio/audio_player_service.dart test/unit/core/services/audio/audio_player_service_test.dart
git commit -m "feat: add AudioPlayerService wrapping just_audio for album playback"
```

---

### Task 3: Create audio playback providers

**Files:**
- Create: `lib/presentation/providers/audio_player_provider.dart`
- Create: `test/unit/presentation/providers/audio_player_provider_test.dart`

- [ ] **Step 1: Write failing tests for providers**

Create `test/unit/presentation/providers/audio_player_provider_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/services/audio/audio_player_service.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';

class MockAudioPlayerService extends Mock implements AudioPlayerService {}

void main() {
  late MockAudioPlayerService mockService;
  late ProviderContainer container;

  final testAlbum = RipAlbum(
    id: 'album-1',
    libraryPath: '/music/album1',
    artist: 'Test Artist',
    albumTitle: 'Test Album',
    trackCount: 2,
    totalSizeBytes: 600000,
    lastScannedAt: 0,
    updatedAt: 0,
  );

  final testTracks = [
    RipTrack(
      id: 'track-1',
      ripAlbumId: 'album-1',
      trackNumber: 1,
      title: 'Track One',
      filePath: '/music/album1/01.flac',
      fileSizeBytes: 300000,
      updatedAt: 0,
      durationMs: 180000,
    ),
    RipTrack(
      id: 'track-2',
      ripAlbumId: 'album-1',
      trackNumber: 2,
      title: 'Track Two',
      filePath: '/music/album1/02.flac',
      fileSizeBytes: 300000,
      updatedAt: 0,
      durationMs: 200000,
    ),
  ];

  setUp(() {
    mockService = MockAudioPlayerService();
    container = ProviderContainer(
      overrides: [
        audioPlayerServiceProvider.overrideWithValue(mockService),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('NowPlayingNotifier', () {
    test('initial state is null album and empty tracks', () {
      final state = container.read(nowPlayingProvider);
      expect(state.album, isNull);
      expect(state.tracks, isEmpty);
    });

    test('set updates album and tracks', () {
      container
          .read(nowPlayingProvider.notifier)
          .set(album: testAlbum, tracks: testTracks);

      final state = container.read(nowPlayingProvider);
      expect(state.album, testAlbum);
      expect(state.tracks, testTracks);
    });

    test('clear resets to initial state', () {
      container
          .read(nowPlayingProvider.notifier)
          .set(album: testAlbum, tracks: testTracks);
      container.read(nowPlayingProvider.notifier).clear();

      final state = container.read(nowPlayingProvider);
      expect(state.album, isNull);
      expect(state.tracks, isEmpty);
    });
  });

  group('PlaybackActionNotifier', () {
    test('playAlbum calls service and updates now-playing', () async {
      when(() => mockService.playAlbum(
            album: testAlbum,
            tracks: testTracks,
            startIndex: 0,
          )).thenAnswer((_) async {});

      await container.read(playbackActionProvider.notifier).playAlbum(
            album: testAlbum,
            tracks: testTracks,
            startIndex: 0,
          );

      verify(() => mockService.playAlbum(
            album: testAlbum,
            tracks: testTracks,
            startIndex: 0,
          )).called(1);

      final nowPlaying = container.read(nowPlayingProvider);
      expect(nowPlaying.album, testAlbum);
      expect(nowPlaying.tracks, testTracks);
    });

    test('stop calls service and clears now-playing', () async {
      when(() => mockService.stop()).thenAnswer((_) async {});

      // Play first
      when(() => mockService.playAlbum(
            album: testAlbum,
            tracks: testTracks,
            startIndex: 0,
          )).thenAnswer((_) async {});
      await container.read(playbackActionProvider.notifier).playAlbum(
            album: testAlbum,
            tracks: testTracks,
          );

      await container.read(playbackActionProvider.notifier).stop();

      verify(() => mockService.stop()).called(1);
      final nowPlaying = container.read(nowPlayingProvider);
      expect(nowPlaying.album, isNull);
    });

    test('pause delegates to service', () async {
      when(() => mockService.pause()).thenAnswer((_) async {});
      await container.read(playbackActionProvider.notifier).pause();
      verify(() => mockService.pause()).called(1);
    });

    test('resume delegates to service', () async {
      when(() => mockService.resume()).thenAnswer((_) async {});
      await container.read(playbackActionProvider.notifier).resume();
      verify(() => mockService.resume()).called(1);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/unit/presentation/providers/audio_player_provider_test.dart`
Expected: FAIL — `audio_player_provider.dart` does not exist yet

- [ ] **Step 3: Implement audio playback providers**

Create `lib/presentation/providers/audio_player_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mymediascanner/core/services/audio/audio_player_service.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

// ── Service singleton ───────────────────────────────────────────────

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ── Now-playing state ───────────────────────────────────────────────

class NowPlayingState {
  const NowPlayingState({this.album, this.tracks = const []});
  final RipAlbum? album;
  final List<RipTrack> tracks;
}

class NowPlayingNotifier extends Notifier<NowPlayingState> {
  @override
  NowPlayingState build() => const NowPlayingState();

  void set({required RipAlbum album, required List<RipTrack> tracks}) {
    state = NowPlayingState(album: album, tracks: tracks);
  }

  void clear() => state = const NowPlayingState();
}

final nowPlayingProvider =
    NotifierProvider<NowPlayingNotifier, NowPlayingState>(
        () => NowPlayingNotifier());

// ── Playback streams ────────────────────────────────────────────────

final playbackPositionProvider = StreamProvider<Duration>((ref) {
  return ref.watch(audioPlayerServiceProvider).positionStream;
});

final playbackDurationProvider = StreamProvider<Duration?>((ref) {
  return ref.watch(audioPlayerServiceProvider).durationStream;
});

final playerStateProvider = StreamProvider<PlayerState>((ref) {
  return ref.watch(audioPlayerServiceProvider).playerStateStream;
});

final currentTrackIndexProvider = StreamProvider<int?>((ref) {
  return ref.watch(audioPlayerServiceProvider).currentIndexStream;
});

// ── Playback actions ────────────────────────────────────────────────

class PlaybackActionNotifier extends Notifier<void> {
  @override
  void build() {}

  AudioPlayerService get _service =>
      ref.read(audioPlayerServiceProvider);

  Future<void> playAlbum({
    required RipAlbum album,
    required List<RipTrack> tracks,
    int startIndex = 0,
  }) async {
    ref
        .read(nowPlayingProvider.notifier)
        .set(album: album, tracks: tracks);
    await _service.playAlbum(
      album: album,
      tracks: tracks,
      startIndex: startIndex,
    );
  }

  Future<void> pause() => _service.pause();
  Future<void> resume() => _service.resume();

  Future<void> togglePlayPause() async {
    if (_service.isPlaying) {
      await _service.pause();
    } else {
      await _service.resume();
    }
  }

  Future<void> stop() async {
    await _service.stop();
    ref.read(nowPlayingProvider.notifier).clear();
  }

  Future<void> seek(Duration position) => _service.seek(position);
  Future<void> seekToNext() => _service.seekToNext();
  Future<void> seekToPrevious() => _service.seekToPrevious();
  Future<void> setVolume(double volume) => _service.setVolume(volume);
  Future<void> setLoopMode(LoopMode mode) => _service.setLoopMode(mode);
  Future<void> setShuffleEnabled(bool enabled) =>
      _service.setShuffleEnabled(enabled);
}

final playbackActionProvider =
    NotifierProvider<PlaybackActionNotifier, void>(
        () => PlaybackActionNotifier());
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/unit/presentation/providers/audio_player_provider_test.dart`
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/providers/audio_player_provider.dart test/unit/presentation/providers/audio_player_provider_test.dart
git commit -m "feat: add Riverpod providers for audio playback state"
```

---

### Task 4: Create mini player bar widget

**Files:**
- Create: `lib/presentation/widgets/mini_player_bar.dart`
- Create: `test/widget/presentation/widgets/mini_player_bar_test.dart`

- [ ] **Step 1: Write failing widget tests**

Create `test/widget/presentation/widgets/mini_player_bar_test.dart`:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/services/audio/audio_player_service.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
import 'package:mymediascanner/presentation/widgets/mini_player_bar.dart';

class MockAudioPlayerService extends Mock implements AudioPlayerService {}

void main() {
  final testAlbum = RipAlbum(
    id: 'album-1',
    libraryPath: '/music/album1',
    artist: 'Test Artist',
    albumTitle: 'Test Album',
    trackCount: 2,
    totalSizeBytes: 600000,
    lastScannedAt: 0,
    updatedAt: 0,
  );

  final testTracks = [
    RipTrack(
      id: 'track-1',
      ripAlbumId: 'album-1',
      trackNumber: 1,
      title: 'Track One',
      filePath: '/music/album1/01.flac',
      fileSizeBytes: 300000,
      updatedAt: 0,
      durationMs: 180000,
    ),
    RipTrack(
      id: 'track-2',
      ripAlbumId: 'album-1',
      trackNumber: 2,
      title: 'Track Two',
      filePath: '/music/album1/02.flac',
      fileSizeBytes: 300000,
      updatedAt: 0,
      durationMs: 200000,
    ),
  ];

  Widget buildApp({required NowPlayingState nowPlaying}) {
    final mockService = MockAudioPlayerService();
    when(() => mockService.positionStream)
        .thenAnswer((_) => Stream.value(Duration.zero));
    when(() => mockService.durationStream)
        .thenAnswer((_) => Stream.value(const Duration(minutes: 3)));
    when(() => mockService.playerStateStream).thenAnswer((_) =>
        Stream.value(PlayerState(true, ProcessingState.ready)));
    when(() => mockService.currentIndexStream)
        .thenAnswer((_) => Stream.value(0));
    when(() => mockService.isPlaying).thenReturn(true);

    return ProviderScope(
      overrides: [
        audioPlayerServiceProvider.overrideWithValue(mockService),
        nowPlayingProvider.overrideWith(() {
          final notifier = NowPlayingNotifier();
          return notifier;
        }),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: const SizedBox.shrink(),
          bottomNavigationBar: MiniPlayerBar(),
        ),
      ),
    );
  }

  group('MiniPlayerBar', () {
    testWidgets('is hidden when nothing is playing', (tester) async {
      await tester.pumpWidget(
        buildApp(nowPlaying: const NowPlayingState()),
      );
      await tester.pump();

      // The bar should have zero height when no album
      expect(find.text('Track One'), findsNothing);
    });

    testWidgets('shows track info when album is playing', (tester) async {
      final mockService = MockAudioPlayerService();
      when(() => mockService.positionStream)
          .thenAnswer((_) => Stream.value(Duration.zero));
      when(() => mockService.durationStream)
          .thenAnswer((_) => Stream.value(const Duration(minutes: 3)));
      when(() => mockService.playerStateStream).thenAnswer((_) =>
          Stream.value(PlayerState(true, ProcessingState.ready)));
      when(() => mockService.currentIndexStream)
          .thenAnswer((_) => Stream.value(0));
      when(() => mockService.isPlaying).thenReturn(true);
      when(() => mockService.pause()).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioPlayerServiceProvider.overrideWithValue(mockService),
          ],
          child: MaterialApp(
            home: Builder(builder: (context) {
              return Scaffold(
                body: Consumer(
                  builder: (context, ref, _) {
                    // Trigger the now-playing state
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(nowPlayingProvider.notifier).set(
                            album: testAlbum,
                            tracks: testTracks,
                          );
                    });
                    return const SizedBox.shrink();
                  },
                ),
                bottomNavigationBar: MiniPlayerBar(),
              );
            }),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Track One'), findsOneWidget);
      expect(find.text('Test Artist'), findsOneWidget);
    });

    testWidgets('has play/pause and skip buttons', (tester) async {
      final mockService = MockAudioPlayerService();
      when(() => mockService.positionStream)
          .thenAnswer((_) => Stream.value(Duration.zero));
      when(() => mockService.durationStream)
          .thenAnswer((_) => Stream.value(const Duration(minutes: 3)));
      when(() => mockService.playerStateStream).thenAnswer((_) =>
          Stream.value(PlayerState(true, ProcessingState.ready)));
      when(() => mockService.currentIndexStream)
          .thenAnswer((_) => Stream.value(0));
      when(() => mockService.isPlaying).thenReturn(true);
      when(() => mockService.pause()).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioPlayerServiceProvider.overrideWithValue(mockService),
          ],
          child: MaterialApp(
            home: Builder(builder: (context) {
              return Scaffold(
                body: Consumer(
                  builder: (context, ref, _) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(nowPlayingProvider.notifier).set(
                            album: testAlbum,
                            tracks: testTracks,
                          );
                    });
                    return const SizedBox.shrink();
                  },
                ),
                bottomNavigationBar: MiniPlayerBar(),
              );
            }),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should have skip previous, play/pause, skip next icons
      expect(find.byIcon(Icons.skip_previous), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.skip_next), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/widget/presentation/widgets/mini_player_bar_test.dart`
Expected: FAIL — `mini_player_bar.dart` does not exist yet

- [ ] **Step 3: Implement MiniPlayerBar widget**

Create `lib/presentation/widgets/mini_player_bar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';

/// Persistent mini player bar shown at the bottom of the screen when
/// audio is playing. Displays track title, artist, progress, and controls.
class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlaying = ref.watch(nowPlayingProvider);
    if (nowPlaying.album == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final currentIndex = ref.watch(currentTrackIndexProvider).valueOrNull ?? 0;
    final position = ref.watch(playbackPositionProvider).valueOrNull ?? Duration.zero;
    final duration = ref.watch(playbackDurationProvider).valueOrNull ?? Duration.zero;
    final playerState = ref.watch(playerStateProvider).valueOrNull;
    final isPlaying = playerState?.playing ?? false;

    final tracks = nowPlaying.tracks;
    final currentTrack = (currentIndex >= 0 && currentIndex < tracks.length)
        ? tracks[currentIndex]
        : null;

    final trackTitle =
        currentTrack?.title ?? 'Track ${currentTrack?.trackNumber ?? '?'}';
    final artist = nowPlaying.album?.artist ?? 'Unknown Artist';

    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 2,
            backgroundColor: colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(colors.primary),
          ),
          // Controls row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Track info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        trackTitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        artist,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Transport controls
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 24,
                  onPressed: () =>
                      ref.read(playbackActionProvider.notifier).seekToPrevious(),
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 32,
                  onPressed: () =>
                      ref.read(playbackActionProvider.notifier).togglePlayPause(),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  iconSize: 24,
                  onPressed: () =>
                      ref.read(playbackActionProvider.notifier).seekToNext(),
                ),
                // Close button
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'Stop playback',
                  onPressed: () =>
                      ref.read(playbackActionProvider.notifier).stop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/widget/presentation/widgets/mini_player_bar_test.dart`
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/mini_player_bar.dart test/widget/presentation/widgets/mini_player_bar_test.dart
git commit -m "feat: add persistent mini player bar widget"
```

---

### Task 5: Integrate mini player bar into AppScaffold

**Files:**
- Modify: `lib/presentation/widgets/app_scaffold.dart`

- [ ] **Step 1: Convert AppScaffold to ConsumerWidget and add mini player**

In `lib/presentation/widgets/app_scaffold.dart`:

1. Add import at top (after line 2):
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
import 'package:mymediascanner/presentation/widgets/mini_player_bar.dart';
```

2. Change `class AppScaffold extends StatelessWidget` (line 11) to `class AppScaffold extends ConsumerWidget`.

3. Change `Widget build(BuildContext context)` (line 68-69) to `Widget build(BuildContext context, WidgetRef ref)`.

4. In the desktop sidebar layout (line 82-98), wrap `navigationShell` with a Column that appends the mini player. Replace:
```dart
Expanded(child: navigationShell),
```
with:
```dart
Expanded(
  child: Column(
    children: [
      Expanded(child: navigationShell),
      const MiniPlayerBar(),
    ],
  ),
),
```

5. In the narrow desktop drawer layout (line 126), replace:
```dart
body: navigationShell,
```
with:
```dart
body: Column(
  children: [
    Expanded(child: navigationShell),
    const MiniPlayerBar(),
  ],
),
```

6. In the mobile layout (line 146), replace:
```dart
body: navigationShell,
```
with:
```dart
body: Column(
  children: [
    Expanded(child: navigationShell),
    const MiniPlayerBar(),
  ],
),
```

- [ ] **Step 2: Run existing tests to verify no regressions**

Run: `flutter test`
Expected: All existing tests pass (the scaffold isn't directly widget-tested, but ensure no compilation errors)

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/widgets/app_scaffold.dart
git commit -m "feat: integrate mini player bar into app scaffold"
```

---

### Task 6: Add play controls to album detail dialog

**Files:**
- Modify: `lib/presentation/screens/rips/widgets/rip_album_detail_dialog.dart`

- [ ] **Step 1: Add imports to detail dialog**

At the top of `rip_album_detail_dialog.dart`, add after line 11 (`quality_widgets.dart` import):

```dart
import 'package:just_audio/just_audio.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
```

- [ ] **Step 2: Add "Play All" button to dialog header**

In the header `Row` (around line 183), after the existing edit/close buttons block (line 257), add a play button. Replace the `else` block at line 247-257:

```dart
                  ] else ...[
                    _PlayAlbumButton(album: widget.album),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit metadata',
                      onPressed: () => setState(() => _editing = true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
```

- [ ] **Step 3: Add inline player controls section**

After the quality analysis section (after line 292 `const SizedBox(height: 12),`), before the "TRACKS" header, insert:

```dart
              // Playback controls (visible when this album is playing)
              _InlinePlayerControls(album: widget.album),
```

- [ ] **Step 4: Add play button to each track tile**

Modify `_TrackTile` (line 467-529) to add a tap-to-play action and a play icon for the current track. Replace the `_TrackTile` class entirely:

```dart
class _TrackTile extends ConsumerWidget {
  const _TrackTile({required this.track});

  final RipTrack track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final duration = _formatDuration(track.durationMs);
    final discLabel =
        track.discNumber > 1 ? 'Disc ${track.discNumber} · ' : '';
    final subtitle =
        '$discLabel${track.trackNumber.toString().padLeft(2, '0')}'
        '${duration.isNotEmpty ? ' · $duration' : ''}';

    final nowPlaying = ref.watch(nowPlayingProvider);
    final currentIndex =
        ref.watch(currentTrackIndexProvider).valueOrNull;
    final isThisAlbumPlaying =
        nowPlaying.album?.id == track.ripAlbumId;
    final trackIndex = isThisAlbumPlaying
        ? nowPlaying.tracks.indexWhere((t) => t.id == track.id)
        : -1;
    final isThisTrackPlaying =
        isThisAlbumPlaying && trackIndex == currentIndex;

    return ListTile(
      dense: true,
      leading: isThisTrackPlaying
          ? Icon(Icons.volume_up, size: 20, color: colors.primary)
          : QualityIcon(track: track),
      title: Text(
        track.title ?? 'Track ${track.trackNumber}',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: track.title != null ? FontWeight.w500 : null,
          fontStyle: track.title == null ? FontStyle.italic : null,
          color: isThisTrackPlaying
              ? colors.primary
              : (track.title == null ? colors.onSurfaceVariant : null),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if ((track.clickCount ?? 0) > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('${track.clickCount} clicks'),
                backgroundColor: AppColors.tvColor.withValues(alpha: 0.2),
                visualDensity: VisualDensity.compact,
              ),
            ),
          if (track.accurateRipConfidence != null)
            Text(
              'AR: ${track.accurateRipConfidence}',
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
      onTap: () {
        // Find the album from the parent — use the track's ripAlbumId
        // to play from this track onwards
        final nowPlayingState = ref.read(nowPlayingProvider);
        if (nowPlayingState.album?.id == track.ripAlbumId) {
          // Same album: just seek to this track
          ref.read(playbackActionProvider.notifier).seek(Duration.zero);
          ref.read(audioPlayerServiceProvider)
              .seek(Duration.zero, index: trackIndex);
        }
        // If different album, the play button on header handles full album play
      },
    );
  }

  String _formatDuration(int? ms) {
    if (ms == null) return '';
    final seconds = ms ~/ 1000;
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **Step 5: Add helper widgets at end of file**

Add these private widgets at the end of `rip_album_detail_dialog.dart` (before final closing):

```dart
/// Play/pause toggle for the album header.
class _PlayAlbumButton extends ConsumerWidget {
  const _PlayAlbumButton({required this.album});
  final RipAlbum album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlaying = ref.watch(nowPlayingProvider);
    final playerState = ref.watch(playerStateProvider).valueOrNull;
    final isThisAlbumPlaying = nowPlaying.album?.id == album.id;
    final isPlaying = isThisAlbumPlaying && (playerState?.playing ?? false);

    return IconButton(
      icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, size: 28),
      tooltip: isPlaying ? 'Pause' : 'Play all tracks',
      onPressed: () async {
        if (isPlaying) {
          await ref.read(playbackActionProvider.notifier).pause();
        } else if (isThisAlbumPlaying) {
          await ref.read(playbackActionProvider.notifier).resume();
        } else {
          final tracks =
              ref.read(ripTracksProvider(album.id)).valueOrNull ?? [];
          if (tracks.isNotEmpty) {
            await ref.read(playbackActionProvider.notifier).playAlbum(
                  album: album,
                  tracks: tracks,
                );
          }
        }
      },
    );
  }
}

/// Inline player controls shown inside the detail dialog when this album
/// is the one currently playing.
class _InlinePlayerControls extends ConsumerWidget {
  const _InlinePlayerControls({required this.album});
  final RipAlbum album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlaying = ref.watch(nowPlayingProvider);
    if (nowPlaying.album?.id != album.id) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final position =
        ref.watch(playbackPositionProvider).valueOrNull ?? Duration.zero;
    final duration =
        ref.watch(playbackDurationProvider).valueOrNull ?? Duration.zero;
    final playerState = ref.watch(playerStateProvider).valueOrNull;
    final isPlaying = playerState?.playing ?? false;
    final currentIndex =
        ref.watch(currentTrackIndexProvider).valueOrNull ?? 0;
    final tracks = nowPlaying.tracks;
    final currentTrack = (currentIndex >= 0 && currentIndex < tracks.length)
        ? tracks[currentIndex]
        : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Now playing label
          if (currentTrack != null)
            Text(
              currentTrack.title ?? 'Track ${currentTrack.trackNumber}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 8),
          // Seek slider
          Row(
            children: [
              Text(
                _formatDuration(position),
                style: theme.textTheme.bodySmall,
              ),
              Expanded(
                child: Slider(
                  value: duration.inMilliseconds > 0
                      ? position.inMilliseconds
                          .clamp(0, duration.inMilliseconds)
                          .toDouble()
                      : 0,
                  max: duration.inMilliseconds > 0
                      ? duration.inMilliseconds.toDouble()
                      : 1,
                  onChanged: (value) {
                    ref
                        .read(playbackActionProvider.notifier)
                        .seek(Duration(milliseconds: value.round()));
                  },
                ),
              ),
              Text(
                _formatDuration(duration),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          // Transport controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () =>
                    ref.read(playbackActionProvider.notifier).seekToPrevious(),
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 36,
                onPressed: () => ref
                    .read(playbackActionProvider.notifier)
                    .togglePlayPause(),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () =>
                    ref.read(playbackActionProvider.notifier).seekToNext(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **Step 6: Run tests to verify no regressions**

Run: `flutter test`
Expected: All existing tests pass

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/screens/rips/widgets/rip_album_detail_dialog.dart
git commit -m "feat: add play controls and track highlighting to rip detail dialog"
```

---

### Task 7: Add now-playing album highlighting to library and table views

**Files:**
- Modify: `lib/presentation/screens/rips/widgets/rip_library_view.dart`
- Modify: `lib/presentation/screens/rips/widgets/rip_table_view.dart`

- [ ] **Step 1: Add now-playing highlight to album grid cards**

In `rip_library_view.dart`, add import at top:

```dart
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
```

In the `_RipAlbumCard` widget, watch the now-playing provider and add a visual indicator. Find the card's `Container` or `Card` decoration and add a primary-coloured border when `nowPlaying.album?.id == album.id`.

In `_RipAlbumCard.build()`, add at the start of the build method:

```dart
    final nowPlayingAlbumId = ref.watch(
      nowPlayingProvider.select((s) => s.album?.id),
    );
    final isNowPlaying = nowPlayingAlbumId == album.id;
```

Note: `_RipAlbumCard` is currently a `StatelessWidget`. Change it to a `ConsumerWidget` and add `WidgetRef ref` to the build signature.

Then modify the card decoration to include a border when playing:

```dart
    border: isNowPlaying
        ? Border.all(color: colors.primary, width: 2)
        : Border.all(color: colors.outlineVariant.withValues(alpha: 0.15)),
```

Also add a small playing icon indicator (e.g. `Icons.volume_up`) to the card when playing.

- [ ] **Step 2: Add now-playing highlight to table rows**

In `rip_table_view.dart`, add import at top:

```dart
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
```

In `_RipTableViewState.build()`, watch the now-playing provider:

```dart
    final nowPlayingAlbumId = ref.watch(
      nowPlayingProvider.select((s) => s.album?.id),
    );
```

In the row building section (around line 143), add a colour to the row when playing:

```dart
    color: album.id == nowPlayingAlbumId
        ? WidgetStatePropertyAll(colors.primary.withValues(alpha: 0.08))
        : null,
```

- [ ] **Step 3: Run tests to verify no regressions**

Run: `flutter test`
Expected: All existing tests pass

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/screens/rips/widgets/rip_library_view.dart lib/presentation/screens/rips/widgets/rip_table_view.dart
git commit -m "feat: highlight now-playing album in rip library and table views"
```

---

### Task 8: Add keyboard shortcuts for playback

**Files:**
- Modify: `lib/presentation/widgets/desktop_shortcuts.dart`

- [ ] **Step 1: Check existing desktop_shortcuts.dart structure**

Read `lib/presentation/widgets/desktop_shortcuts.dart` to understand current keyboard shortcut registration.

- [ ] **Step 2: Add playback keyboard shortcuts**

Add imports for audio player providers:

```dart
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
```

Add these shortcuts to the existing shortcut map:
- `Space` → play/pause (only when not in a text field)
- `Ctrl+Right` → next track
- `Ctrl+Left` → previous track

The implementation depends on the existing structure of `desktop_shortcuts.dart`. The shortcuts should call `ref.read(playbackActionProvider.notifier)` methods.

Note: `Space` conflicts with text input. Only handle it when a `nowPlayingProvider.album` is non-null AND no text field has focus. Use `FocusNode` or check `FocusManager.instance.primaryFocus` type.

- [ ] **Step 3: Run tests to verify no regressions**

Run: `flutter test`
Expected: All existing tests pass

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/widgets/desktop_shortcuts.dart
git commit -m "feat: add keyboard shortcuts for playback controls"
```

---

### Task 9: Handle playback errors (missing/unsupported files)

**Files:**
- Modify: `lib/core/services/audio/audio_player_service.dart`
- Modify: `lib/presentation/providers/audio_player_provider.dart`

- [ ] **Step 1: Write failing test for error handling**

Add to `test/unit/core/services/audio/audio_player_service_test.dart`:

```dart
    test('playbackEventStream errors trigger onError callback', () async {
      // Verify that the service exposes the player's playback event stream
      // so consumers can listen for errors
      when(() => mockPlayer.playbackEventStream)
          .thenAnswer((_) => const Stream.empty());

      expect(service.playbackEventStream, isA<Stream>());
    });
```

- [ ] **Step 2: Add playbackEventStream getter to AudioPlayerService**

In `audio_player_service.dart`, add:

```dart
  Stream<PlaybackEvent> get playbackEventStream =>
      _player.playbackEventStream;
```

- [ ] **Step 3: Add error handling in PlaybackActionNotifier**

In `audio_player_provider.dart`, modify `PlaybackActionNotifier.playAlbum` to handle errors by listening for `ProcessingState.completed` in the sequence state and auto-advancing or showing a snackbar. The `just_audio` library handles missing files by emitting errors on the player state stream. Add a `StreamSubscription` in the service that listens for errors:

```dart
  /// Listen for player errors and skip to next track on failure.
  void _listenForErrors() {
    _service.playerStateStream.listen((state) {
      // When a track fails to load, just_audio moves to completed state
      // The error is available via playbackEventStream
    });
  }
```

The primary error handling is that `just_audio` will throw on `setAudioSource` for individual bad files. Since we use `ConcatenatingAudioSource`, individual track failures will skip to the next track automatically.

- [ ] **Step 4: Run all tests**

Run: `flutter test`
Expected: All tests pass

- [ ] **Step 5: Commit**

```bash
git add lib/core/services/audio/audio_player_service.dart lib/presentation/providers/audio_player_provider.dart test/unit/core/services/audio/audio_player_service_test.dart
git commit -m "feat: add error stream and skip-on-failure for playback"
```

---

### Task 10: Final integration test and verification

**Files:**
- All modified files

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: All tests pass (existing + new)

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No analysis issues

- [ ] **Step 3: Verify the app builds**

Run: `flutter build linux --debug` (or appropriate desktop platform)
Expected: Build succeeds

- [ ] **Step 4: Manual smoke test**

Run: `flutter run -d linux`
- Navigate to Rips screen
- Scan a library with FLAC/MP3 files
- Open an album detail dialog
- Tap "Play All" — verify playback starts
- Verify mini player bar appears at bottom
- Navigate to another screen — verify mini player persists
- Tap a specific track — verify it plays that track
- Test prev/next/pause/seek controls
- Close mini player — verify playback stops
- Test keyboard shortcuts (Ctrl+Left/Right, Space when no text field focused)

- [ ] **Step 5: Commit any fixes from smoke test**

```bash
git add -A
git commit -m "fix: address issues found during playback smoke test"
```
