/// Widget tests for [BatchTagEditorDialog] — batch FLAC tag editing UI.
///
/// Covers: title rendering, empty-field validation snackbars, and that the
/// batch metadata edit provider receives the correct tag changes when the
/// Apply button is tapped.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/batch_metadata_edit_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/batch_tag_editor_dialog.dart';

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

const _albumA = RipAlbum(
  id: 'album-a',
  libraryPath: '/music/a',
  artist: 'Artist A',
  albumTitle: 'Album A',
  trackCount: 2,
  totalSizeBytes: 0,
  lastScannedAt: 0,
  updatedAt: 0,
);

const _albumB = RipAlbum(
  id: 'album-b',
  libraryPath: '/music/b',
  artist: 'Artist B',
  albumTitle: 'Album B',
  trackCount: 3,
  totalSizeBytes: 0,
  lastScannedAt: 0,
  updatedAt: 0,
);

const _tracksA = [
  RipTrack(
    id: 'track-a1',
    ripAlbumId: 'album-a',
    trackNumber: 1,
    filePath: '/music/a/01.flac',
    fileSizeBytes: 0,
    updatedAt: 0,
  ),
  RipTrack(
    id: 'track-a2',
    ripAlbumId: 'album-a',
    trackNumber: 2,
    filePath: '/music/a/02.flac',
    fileSizeBytes: 0,
    updatedAt: 0,
  ),
];

const _tracksB = [
  RipTrack(
    id: 'track-b1',
    ripAlbumId: 'album-b',
    trackNumber: 1,
    filePath: '/music/b/01.flac',
    fileSizeBytes: 0,
    updatedAt: 0,
  ),
  RipTrack(
    id: 'track-b2',
    ripAlbumId: 'album-b',
    trackNumber: 2,
    filePath: '/music/b/02.flac',
    fileSizeBytes: 0,
    updatedAt: 0,
  ),
  RipTrack(
    id: 'track-b3',
    ripAlbumId: 'album-b',
    trackNumber: 3,
    filePath: '/music/b/03.flac',
    fileSizeBytes: 0,
    updatedAt: 0,
  ),
];

// ---------------------------------------------------------------------------
// Fake BatchMetadataEditNotifier
//
// Captures calls to prepareBatchEdit so tests can inspect the arguments
// without executing real FLAC file I/O. applyChanges is overridden to
// immediately mark the state as applied.
// ---------------------------------------------------------------------------

class _FakeBatchNotifier extends BatchMetadataEditNotifier {
  Map<String, Map<String, String>> capturedPendingChanges = {};
  int capturedAffectedTrackCount = 0;
  int capturedAffectedAlbumCount = 0;
  bool applyChangesCalled = false;

  @override
  void prepareBatchEdit({
    required Map<String, Map<String, String>> pendingChanges,
    required Map<String, Map<String, String>> originalValues,
    required int affectedTrackCount,
    required int affectedAlbumCount,
  }) {
    capturedPendingChanges = pendingChanges;
    capturedAffectedTrackCount = affectedTrackCount;
    capturedAffectedAlbumCount = affectedAlbumCount;

    // Transition state to previewing so callers can read it.
    super.prepareBatchEdit(
      pendingChanges: pendingChanges,
      originalValues: originalValues,
      affectedTrackCount: affectedTrackCount,
      affectedAlbumCount: affectedAlbumCount,
    );
  }

  @override
  Future<void> applyChanges() async {
    applyChangesCalled = true;
    // Mark as applied immediately — no file I/O in widget tests.
    markApplied();
  }
}

// ---------------------------------------------------------------------------
// Helper: builds the dialog under test inside a MaterialApp+ProviderScope.
//
// [fakeNotifier] is the _FakeBatchNotifier whose state will be exposed via
// [batchMetadataEditProvider].
// ---------------------------------------------------------------------------

Widget _buildDialog({
  required Set<String> selectedAlbumIds,
  required List<RipAlbum> albums,
  required _FakeBatchNotifier fakeNotifier,
}) {
  return ProviderScope(
    overrides: [
      // Swap in the fake notifier so we can inspect calls to prepareBatchEdit.
      batchMetadataEditProvider.overrideWith(() => fakeNotifier),

      // Supply tracks for each album so the provider graph resolves.
      ripTracksProvider('album-a')
          .overrideWith((ref) => Future.value(_tracksA.toList())),
      ripTracksProvider('album-b')
          .overrideWith((ref) => Future.value(_tracksB.toList())),

      // Stub trackRawTagsProvider for every track file path — returns empty
      // tags so originalValues is an empty map (no existing tags to preserve).
      trackRawTagsProvider('/music/a/01.flac')
          .overrideWith((ref) async => <String, String>{}),
      trackRawTagsProvider('/music/a/02.flac')
          .overrideWith((ref) async => <String, String>{}),
      trackRawTagsProvider('/music/b/01.flac')
          .overrideWith((ref) async => <String, String>{}),
      trackRawTagsProvider('/music/b/02.flac')
          .overrideWith((ref) async => <String, String>{}),
      trackRawTagsProvider('/music/b/03.flac')
          .overrideWith((ref) async => <String, String>{}),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => BatchTagEditorDialog(
            selectedAlbumIds: selectedAlbumIds,
            albums: albums,
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // 1. Renders title with album and track counts
  // -------------------------------------------------------------------------

  testWidgets(
    'renders title with album and track counts for 2 albums of 5 tracks total',
    (tester) async {
      final fakeNotifier = _FakeBatchNotifier();

      await tester.pumpWidget(_buildDialog(
        selectedAlbumIds: {'album-a', 'album-b'},
        albums: [_albumA, _albumB],
        fakeNotifier: fakeNotifier,
      ));
      await tester.pump();

      // Title reflects 2 albums, 2+3 = 5 tracks (from trackCount on albums).
      expect(find.text('Edit Tags — 2 Albums (5 tracks)'), findsOneWidget);
    },
  );

  // -------------------------------------------------------------------------
  // 2. Preview with no fields shows snackbar
  // -------------------------------------------------------------------------

  testWidgets(
    'shows snackbar when Preview is tapped with no fields filled',
    (tester) async {
      final fakeNotifier = _FakeBatchNotifier();

      await tester.pumpWidget(_buildDialog(
        selectedAlbumIds: {'album-a'},
        albums: [_albumA],
        fakeNotifier: fakeNotifier,
      ));
      await tester.pump();

      await tester.tap(find.text('Preview Changes'));
      await tester.pump();

      expect(
        find.text('Enter at least one tag value to preview.'),
        findsOneWidget,
      );
    },
  );

  // -------------------------------------------------------------------------
  // 3. Apply with no fields shows snackbar
  // -------------------------------------------------------------------------

  testWidgets(
    'shows snackbar when Apply is tapped with no fields filled',
    (tester) async {
      final fakeNotifier = _FakeBatchNotifier();

      await tester.pumpWidget(_buildDialog(
        selectedAlbumIds: {'album-a'},
        albums: [_albumA],
        fakeNotifier: fakeNotifier,
      ));
      await tester.pump();

      await tester.tap(find.text('Apply'));
      await tester.pump();

      expect(
        find.text('Enter at least one tag value to apply.'),
        findsOneWidget,
      );
    },
  );

  // -------------------------------------------------------------------------
  // 4. Entering a genre and tapping Apply calls provider with GENRE
  // -------------------------------------------------------------------------

  testWidgets(
    'entering a genre and tapping Apply calls prepareBatchEdit with GENRE for every track',
    (tester) async {
      final fakeNotifier = _FakeBatchNotifier();

      await tester.pumpWidget(_buildDialog(
        selectedAlbumIds: {'album-a', 'album-b'},
        albums: [_albumA, _albumB],
        fakeNotifier: fakeNotifier,
      ));
      await tester.pump();

      // Pre-warm the ripTracksProvider cache by reading the future values via
      // the ProviderContainer. This ensures ref.read(...).value is non-null
      // when _applyDirectly calls it synchronously before building
      // pendingChanges.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(BatchTagEditorDialog)),
      );
      await container.read(ripTracksProvider('album-a').future);
      await container.read(ripTracksProvider('album-b').future);
      // Also warm trackRawTagsProvider for each track file path.
      for (final track in [..._tracksA, ..._tracksB]) {
        await container.read(trackRawTagsProvider(track.filePath).future);
      }
      await tester.pump();

      // Find the Genre field by its label text.
      await tester.enterText(find.widgetWithText(TextField, 'Genre'), 'Jazz');
      await tester.pump();

      // Tap Apply and allow the async _applyDirectly body to complete.
      await tester.tap(find.text('Apply'));
      // Give the async method time to finish (it awaits trackRawTagsProvider).
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();

      // prepareBatchEdit should have been called with GENRE for every track.
      final pendingChanges = fakeNotifier.capturedPendingChanges;
      expect(pendingChanges, isNotEmpty,
          reason: 'prepareBatchEdit was not called');

      for (final trackChanges in pendingChanges.values) {
        expect(trackChanges['GENRE'], 'Jazz',
            reason: 'Expected GENRE to be Jazz for every track');
      }

      // Should cover all 5 tracks (2 from album-a + 3 from album-b).
      expect(pendingChanges.keys, hasLength(5));
    },
  );

  // -------------------------------------------------------------------------
  // 5. Multiple fields result in all four tag keys being captured
  // -------------------------------------------------------------------------

  testWidgets(
    'entering multiple fields calls prepareBatchEdit with all four tag keys',
    (tester) async {
      final fakeNotifier = _FakeBatchNotifier();

      await tester.pumpWidget(_buildDialog(
        selectedAlbumIds: {'album-a'},
        albums: [_albumA],
        fakeNotifier: fakeNotifier,
      ));
      await tester.pump();

      // Pre-warm the FutureProvider caches.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(BatchTagEditorDialog)),
      );
      await container.read(ripTracksProvider('album-a').future);
      for (final track in _tracksA) {
        await container.read(trackRawTagsProvider(track.filePath).future);
      }
      await tester.pump();

      await tester.enterText(
          find.widgetWithText(TextField, 'Genre'), 'Classical');
      await tester.enterText(
          find.widgetWithText(TextField, 'Date / Year'), '2024');
      await tester.enterText(
          find.widgetWithText(TextField, 'Album Artist'), 'Various Artists');
      await tester.enterText(
          find.widgetWithText(TextField, 'Comment'), 'Test comment');
      await tester.pump();

      await tester.tap(find.text('Apply'));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();

      final pendingChanges = fakeNotifier.capturedPendingChanges;
      expect(pendingChanges, isNotEmpty,
          reason: 'prepareBatchEdit was not called');

      // Verify all four keys are present in every track's change map.
      for (final trackChanges in pendingChanges.values) {
        expect(trackChanges['GENRE'], 'Classical');
        expect(trackChanges['DATE'], '2024');
        expect(trackChanges['ALBUMARTIST'], 'Various Artists');
        expect(trackChanges['COMMENT'], 'Test comment');
      }
    },
  );
}
