/// Regression test for the rip album card's info rows overflowing at
/// narrow widths.
///
/// [RipLibraryView]'s grid uses `SliverGridDelegateWithMaxCrossAxisExtent`,
/// so narrowing the available width (e.g. when the rip detail side panel
/// opens) shrinks each card. The "N tracks / size" and "AR / defects" info
/// rows inside the card previously used unconstrained `Text` widgets, which
/// overflow horizontally once the card gets narrower than their natural
/// width — surfaced by `flutter_test` as an uncaught RenderFlex exception.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_library_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

const _album = RipAlbum(
  id: 'album-1',
  libraryPath: '/music/test',
  artist: 'A Very Long Artist Name That Keeps Going',
  albumTitle: 'An Extremely Long Album Title For Testing Overflow',
  trackCount: 42,
  totalSizeBytes: 1234567890,
  lastScannedAt: 0,
  updatedAt: 0,
);

final _tracks = [
  const RipTrack(
    id: 'track-1',
    ripAlbumId: 'album-1',
    trackNumber: 1,
    filePath: '/music/test/01.flac',
    fileSizeBytes: 1000,
    updatedAt: 0,
    accurateRipStatus: 'verified',
  ),
  const RipTrack(
    id: 'track-2',
    ripAlbumId: 'album-1',
    trackNumber: 2,
    filePath: '/music/test/02.flac',
    fileSizeBytes: 1000,
    updatedAt: 0,
    clickCount: 3,
  ),
];

// ---------------------------------------------------------------------------
// Helper: builds the widget under test, constrained to a width narrow
// enough that the grid's cards are narrower than the info rows' natural
// content width (reproducing the side-panel-open scenario), while staying
// wide enough that the unrelated top toolbar row does not itself overflow.
// ---------------------------------------------------------------------------

Widget _buildNarrowLibraryView(MockRipLibraryRepository repo) {
  return ProviderScope(
    overrides: [
      ripLibraryRepositoryProvider.overrideWithValue(repo),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 900, child: RipLibraryView()),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    // RipLibraryView watches ripViewModeProvider, whose Notifier reads
    // SharedPreferences during build() — back it with an in-memory store
    // so it never touches the platform channel.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'album card info rows do not overflow at narrow grid widths',
    (tester) async {
      final repo = MockRipLibraryRepository();
      when(() => repo.watchAll())
          .thenAnswer((_) => Stream.value([_album]));
      when(() => repo.getTracksForAlbum('album-1'))
          .thenAnswer((_) async => _tracks);

      await tester.pumpWidget(_buildNarrowLibraryView(repo));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );
}
