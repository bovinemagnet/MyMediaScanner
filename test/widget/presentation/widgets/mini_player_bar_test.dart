/// Widget tests for [MiniPlayerBar].
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
import 'package:mymediascanner/presentation/widgets/mini_player_bar.dart';

void main() {
  const testAlbum = RipAlbum(
    id: 'album-1',
    libraryPath: '/music/test',
    artist: 'Test Artist',
    albumTitle: 'Test Album',
    trackCount: 3,
    totalSizeBytes: 100000,
    lastScannedAt: 0,
    updatedAt: 0,
  );

  final testTracks = [
    const RipTrack(
      id: 'track-1',
      ripAlbumId: 'album-1',
      trackNumber: 1,
      title: 'First Song',
      filePath: '/music/test/01.flac',
      fileSizeBytes: 30000,
      updatedAt: 0,
    ),
    const RipTrack(
      id: 'track-2',
      ripAlbumId: 'album-1',
      trackNumber: 2,
      title: 'Second Song',
      filePath: '/music/test/02.flac',
      fileSizeBytes: 30000,
      updatedAt: 0,
    ),
    const RipTrack(
      id: 'track-3',
      ripAlbumId: 'album-1',
      trackNumber: 3,
      title: null,
      filePath: '/music/test/03.flac',
      fileSizeBytes: 30000,
      updatedAt: 0,
    ),
  ];

  Widget buildTestWidget({
    NowPlayingState? nowPlayingState,
    Duration position = Duration.zero,
    Duration? duration,
    int? currentIndex,
    bool playing = false,
  }) {
    return ProviderScope(
      overrides: [
        nowPlayingProvider
            .overrideWith(() => _TestNowPlayingNotifier(nowPlayingState)),
        playbackPositionProvider.overrideWith(
          (ref) => Stream.value(position),
        ),
        playbackDurationProvider.overrideWith(
          (ref) => Stream.value(duration ?? const Duration(minutes: 4)),
        ),
        currentTrackIndexProvider.overrideWith(
          (ref) => Stream.value(currentIndex ?? 0),
        ),
        playerStateProvider.overrideWith(
          (ref) => const Stream<Never>.empty(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const Scaffold(
          bottomNavigationBar: MiniPlayerBar(),
        ),
      ),
    );
  }

  group('MiniPlayerBar', () {
    testWidgets('hidden when nothing is playing (no album)', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Should render SizedBox.shrink — no track title visible
      expect(find.text('First Song'), findsNothing);
      expect(find.text('Test Artist'), findsNothing);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });

    testWidgets('shows track info when album is set', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        nowPlayingState: NowPlayingState(
          album: testAlbum,
          tracks: testTracks,
        ),
        currentIndex: 0,
      ));
      await tester.pumpAndSettle();

      expect(find.text('First Song'), findsOneWidget);
      expect(find.text('Test Artist'), findsOneWidget);
    });

    testWidgets('shows fallback title when track title is null',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        nowPlayingState: NowPlayingState(
          album: testAlbum,
          tracks: testTracks,
        ),
        currentIndex: 2,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Track 3'), findsOneWidget);
    });

    testWidgets('has play/pause and skip buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        nowPlayingState: NowPlayingState(
          album: testAlbum,
          tracks: testTracks,
        ),
      ));
      await tester.pumpAndSettle();

      // Default state is not playing, so play_arrow should show
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.skip_previous), findsOneWidget);
      expect(find.byIcon(Icons.skip_next), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows progress indicator', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        nowPlayingState: NowPlayingState(
          album: testAlbum,
          tracks: testTracks,
        ),
        position: const Duration(minutes: 1),
        duration: const Duration(minutes: 4),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}

class _TestNowPlayingNotifier extends NowPlayingNotifier {
  _TestNowPlayingNotifier(this._initial);

  final NowPlayingState? _initial;

  @override
  NowPlayingState build() => _initial ?? const NowPlayingState();
}
