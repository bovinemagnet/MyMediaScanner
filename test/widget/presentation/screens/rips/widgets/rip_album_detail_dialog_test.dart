/// Widget tests for [RipAlbumDetailDialog] — artist/album-title edit-save flow.
///
/// Focused on: read-only header display, entering edit mode, saving changed
/// artist/album-title fields, discarding changes, and the no-op path when
/// nothing has changed.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/utils/metaflac_writer.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_album_detail_dialog.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

class MockMetaflacWriter extends Mock implements MetaflacWriter {}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

const _album = RipAlbum(
  id: 'album-1',
  libraryPath: '/music/test',
  artist: 'The Artist',
  albumTitle: 'The Album',
  trackCount: 0,
  totalSizeBytes: 0,
  lastScannedAt: 0,
  updatedAt: 0,
);

// ---------------------------------------------------------------------------
// Helper: builds the widget under test inside a ProviderScope with the
// minimum set of overrides required to pump without errors.
// ---------------------------------------------------------------------------

Widget _buildDialog({
  required MockRipLibraryRepository repo,
  required MockMetaflacWriter writer,
}) {
  return ProviderScope(
    overrides: [
      // Repository — empty tracks so the per-track loop in _save is a no-op.
      ripLibraryRepositoryProvider.overrideWithValue(repo),

      // ripTracksProvider — return empty list directly.
      ripTracksProvider('album-1').overrideWith(
        (ref) => Future.value(<RipTrack>[]),
      ),

      // metaflacWriter — stub so _save can read it without hitting the FS.
      metaflacWriterProvider.overrideWithValue(writer),

      // Playback stream providers — empty streams avoid just_audio init.
      playerStateProvider.overrideWith((ref) => const Stream.empty()),
      playbackPositionProvider.overrideWith((ref) => const Stream.empty()),
      playbackDurationProvider.overrideWith((ref) => const Stream.empty()),
      currentTrackIndexProvider.overrideWith((ref) => const Stream.empty()),

      // albumCoverArt — no cover art in tests (avoids file-system read).
      albumCoverArtProvider('album-1').overrideWith((ref) async => null),

      // allRipAlbumsProvider — empty stream so the provider graph is happy.
      allRipAlbumsProvider.overrideWith((ref) => Stream.value(<RipAlbum>[])),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => const RipAlbumDetailDialog(album: _album),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    // RipAlbum is a sealed class — register a concrete instance as fallback.
    registerFallbackValue(const RipAlbum(
      id: '_fallback',
      libraryPath: '/fallback',
      trackCount: 0,
      totalSizeBytes: 0,
      lastScannedAt: 0,
      updatedAt: 0,
    ));
  });

  late MockRipLibraryRepository mockRepo;
  late MockMetaflacWriter mockWriter;

  setUp(() {
    mockRepo = MockRipLibraryRepository();
    mockWriter = MockMetaflacWriter();

    // Default stubs required whether or not a particular test exercises them.
    when(() => mockRepo.watchAll()).thenAnswer((_) => Stream.value([]));
    when(() => mockRepo.getTracksForAlbum(any()))
        .thenAnswer((_) => Future.value([]));
    when(() => mockRepo.updateAlbum(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateTrackTitle(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockWriter.setTags(any(), any())).thenAnswer((_) async {});
    when(() => mockWriter.removeTag(any(), any())).thenAnswer((_) async {});
  });

  // -------------------------------------------------------------------------
  // 1. Read-only header displays artist and album title
  // -------------------------------------------------------------------------

  testWidgets(
    'displays artist and album title in read-only header',
    (tester) async {
      await tester.pumpWidget(_buildDialog(repo: mockRepo, writer: mockWriter));
      await tester.pump();

      expect(find.text('The Artist'), findsOneWidget);
      expect(find.text('The Album'), findsOneWidget);
    },
  );

  // -------------------------------------------------------------------------
  // 2. Tapping the edit button shows pre-populated TextFormFields
  // -------------------------------------------------------------------------

  testWidgets(
    'tapping edit shows text fields pre-populated with artist and album title',
    (tester) async {
      await tester.pumpWidget(_buildDialog(repo: mockRepo, writer: mockWriter));
      await tester.pump();

      // Enter edit mode via the edit icon button.
      await tester.tap(find.byTooltip('Edit metadata'));
      await tester.pump();

      // Two TextFormFields should now be visible.
      expect(find.byType(TextFormField), findsWidgets);

      // The first field should contain the artist value.
      final artistField =
          tester.widget<TextFormField>(find.byType(TextFormField).first);
      expect(artistField.controller?.text, 'The Artist');

      // The second field should contain the album title value.
      final albumField =
          tester.widget<TextFormField>(find.byType(TextFormField).at(1));
      expect(albumField.controller?.text, 'The Album');
    },
  );

  // -------------------------------------------------------------------------
  // 3. Saving after changing the artist calls updateAlbum with the new artist
  // -------------------------------------------------------------------------

  testWidgets(
    'saving after changing the artist calls updateAlbum with the new artist',
    (tester) async {
      await tester.pumpWidget(_buildDialog(repo: mockRepo, writer: mockWriter));
      await tester.pump();

      // Enter edit mode.
      await tester.tap(find.byTooltip('Edit metadata'));
      await tester.pump();

      // Clear the artist field and type a new value.
      await tester.enterText(find.byType(TextFormField).first, 'New Artist');
      await tester.pump();

      // Tap Save Changes.
      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      // updateAlbum must have been called exactly once.
      final captured =
          verify(() => mockRepo.updateAlbum(captureAny())).captured;
      expect(captured, hasLength(1));

      final savedAlbum = captured.first as RipAlbum;
      expect(savedAlbum.artist, 'New Artist');
      // Album title must be unchanged.
      expect(savedAlbum.albumTitle, 'The Album');
    },
  );

  // -------------------------------------------------------------------------
  // 4. Saving after changing the album title updates both fields correctly
  // -------------------------------------------------------------------------

  testWidgets(
    'saving after changing the album title calls updateAlbum with the new title',
    (tester) async {
      await tester.pumpWidget(_buildDialog(repo: mockRepo, writer: mockWriter));
      await tester.pump();

      await tester.tap(find.byTooltip('Edit metadata'));
      await tester.pump();

      // Leave artist unchanged, edit album title only.
      await tester.enterText(
          find.byType(TextFormField).at(1), 'New Album Title');
      await tester.pump();

      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      final captured =
          verify(() => mockRepo.updateAlbum(captureAny())).captured;
      expect(captured, hasLength(1));

      final savedAlbum = captured.first as RipAlbum;
      expect(savedAlbum.albumTitle, 'New Album Title');
      // Artist must be unchanged.
      expect(savedAlbum.artist, 'The Artist');
    },
  );

  // -------------------------------------------------------------------------
  // 5. Tapping Discard resets fields and exits edit mode
  // -------------------------------------------------------------------------

  testWidgets(
    'tapping Discard resets fields and exits edit mode',
    (tester) async {
      await tester.pumpWidget(_buildDialog(repo: mockRepo, writer: mockWriter));
      await tester.pump();

      await tester.tap(find.byTooltip('Edit metadata'));
      await tester.pump();

      // Type a change into the artist field.
      await tester.enterText(
          find.byType(TextFormField).first, 'Temporary Value');
      await tester.pump();

      // Tap Discard.
      await tester.tap(find.text('Discard'));
      await tester.pump();

      // Edit mode should be gone — TextFormFields should not be visible.
      expect(find.byType(TextFormField), findsNothing);

      // The read-only header should display the original artist name.
      expect(find.text('The Artist'), findsOneWidget);
    },
  );

  // -------------------------------------------------------------------------
  // 6. Saving without changes does not call updateAlbum
  // -------------------------------------------------------------------------

  testWidgets(
    'saving without changes does not call updateAlbum',
    (tester) async {
      await tester.pumpWidget(_buildDialog(repo: mockRepo, writer: mockWriter));
      await tester.pump();

      await tester.tap(find.byTooltip('Edit metadata'));
      await tester.pump();

      // Tap Save Changes without modifying anything.
      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      verifyNever(() => mockRepo.updateAlbum(any()));
    },
  );
}
