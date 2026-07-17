/// Widget tests for the redesigned rip album card.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/app/theme/app_theme.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_album_card.dart';

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

final _album = RipAlbum(
  id: 'a',
  libraryPath: '/library/a',
  artist: 'Test Artist',
  albumTitle: 'Test Album',
  trackCount: 16,
  totalSizeBytes: 100 * 1024 * 1024,
  lastScannedAt: 0,
  updatedAt: 0,
);

List<RipTrack> _verifiedTracks() => List.generate(
      16,
      (i) => RipTrack(
        id: 't$i',
        ripAlbumId: 'a',
        trackNumber: i + 1,
        filePath: '/library/a/track${i + 1}.flac',
        fileSizeBytes: 1024,
        updatedAt: 0,
        accurateRipStatus: 'verified',
        qualityCheckedAt: 1,
      ),
    );

List<RipTrack> _unanalysedTracks() => List.generate(
      16,
      (i) => RipTrack(
        id: 't$i',
        ripAlbumId: 'a',
        trackNumber: i + 1,
        filePath: '/library/a/track${i + 1}.flac',
        fileSizeBytes: 1024,
        updatedAt: 0,
      ),
    );

Widget _wrap(MockRipLibraryRepository repo) => ProviderScope(
      overrides: [ripLibraryRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        home: Scaffold(body: RipAlbumCard(album: _album)),
      ),
    );

void main() {
  testWidgets('shows verified health, AccurateRip progress and format chips',
      (tester) async {
    final repo = MockRipLibraryRepository();
    final tracks = _verifiedTracks();
    when(() => repo.watchAll()).thenAnswer((_) => Stream.value([_album]));
    when(() => repo.watchAllTracksByAlbum())
        .thenAnswer((_) => Stream.value({'a': tracks}));
    when(() => repo.getTracksForAlbum('a'))
        .thenAnswer((_) async => tracks);

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.text('VERIFIED'), findsOneWidget);
    expect(find.textContaining('ACCURATERIP'), findsOneWidget);
    expect(find.text('16 / 16'), findsOneWidget);
    expect(find.text('FLAC'), findsOneWidget);
    expect(find.textContaining('0 defects'), findsOneWidget);
  });

  testWidgets('shows not-analysed health and an Analyse chip', (tester) async {
    final repo = MockRipLibraryRepository();
    final tracks = _unanalysedTracks();
    when(() => repo.watchAll()).thenAnswer((_) => Stream.value([_album]));
    when(() => repo.watchAllTracksByAlbum())
        .thenAnswer((_) => Stream.value({'a': tracks}));
    when(() => repo.getTracksForAlbum('a'))
        .thenAnswer((_) async => tracks);

    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.text('NOT ANALYSED'), findsOneWidget);
    expect(find.text('Analyse'), findsOneWidget);
  });

  testWidgets('does not overflow at the grid cell size', (tester) async {
    final repo = MockRipLibraryRepository();
    final tracks = _verifiedTracks();
    when(() => repo.watchAll()).thenAnswer((_) => Stream.value([_album]));
    when(() => repo.watchAllTracksByAlbum())
        .thenAnswer((_) => Stream.value({'a': tracks}));
    when(() => repo.getTracksForAlbum('a'))
        .thenAnswer((_) async => tracks);

    // The rips grid's master pane can never be narrower than 368px: the
    // enclosing MasterDetailLayout enforces a 400px masterMinWidth, and
    // the GridView adds 16px of padding on each side. Use the app's real
    // (zero-margin) card theme, since the default Material Card margin
    // would understate the space actually available in production.
    await tester.pumpWidget(ProviderScope(
      overrides: [ripLibraryRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 368,
              height: 208,
              child: RipAlbumCard(album: _album),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
