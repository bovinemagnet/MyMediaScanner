/// Unit tests for [RipScanNotifier].
///
/// Verifies state transitions for the rip library scan workflow,
/// including idle → scanning → complete, no-op whilst already scanning,
/// and error handling.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProviderContainer _createContainer({
  required MockRipLibraryRepository ripRepo,
  required MockMediaItemRepository mediaItemRepo,
}) {
  return ProviderContainer(
    overrides: [
      ripLibraryRepositoryProvider.overrideWithValue(ripRepo),
      mediaItemRepositoryProvider.overrideWithValue(mediaItemRepo),
    ],
  );
}

/// Configures the mock repositories to support a successful scan of a
/// directory that contains no FLAC files.
///
/// When [ScanRipLibraryUseCase] scans a non-existent (or empty) path it
/// yields a single zero-progress event and returns without touching the
/// repository.  [MatchRipsUseCase] then calls [getAllNonDeleted] and
/// [watchAll]; both return empty collections so matched count is 0.
void _stubForEmptyScan({
  required MockRipLibraryRepository ripRepo,
  required MockMediaItemRepository mediaItemRepo,
}) {
  // MatchRipsUseCase.execute() calls getAllNonDeleted first.
  when(() => ripRepo.getAllNonDeleted()).thenAnswer((_) async => <RipAlbum>[]);

  // MatchRipsUseCase then calls watchAll on the media item repo.
  when(() => mediaItemRepo.watchAll(mediaType: MediaType.music))
      .thenAnswer((_) => Stream.value(<MediaItem>[]));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockRipLibraryRepository mockRipRepo;
  late MockMediaItemRepository mockMediaItemRepo;

  setUp(() {
    mockRipRepo = MockRipLibraryRepository();
    mockMediaItemRepo = MockMediaItemRepository();
  });

  group('RipScanNotifier', () {
    group('initial state', () {
      test('is idle with zero counters and no error', () {
        final container = _createContainer(
          ripRepo: mockRipRepo,
          mediaItemRepo: mockMediaItemRepo,
        );
        addTearDown(container.dispose);

        final state = container.read(ripScanNotifierProvider);

        expect(state.status, RipScanStatus.idle);
        expect(state.albumsScanned, 0);
        expect(state.totalDirectories, 0);
        expect(state.currentDirectory, '');
        expect(state.matchedCount, 0);
        expect(state.error, isNull);
      });
    });

    group('startScan', () {
      test(
          'transitions through scanning then completes when path has no FLAC files',
          () async {
        // Arrange — use a path that does not exist so the isolate-based
        // directory scan returns an empty result set immediately.
        _stubForEmptyScan(
          ripRepo: mockRipRepo,
          mediaItemRepo: mockMediaItemRepo,
        );

        final container = _createContainer(
          ripRepo: mockRipRepo,
          mediaItemRepo: mockMediaItemRepo,
        );
        addTearDown(container.dispose);

        final notifier = container.read(ripScanNotifierProvider.notifier);

        // Act — pass a path guaranteed not to exist on any test machine.
        await notifier.startScan('/non_existent_path_for_unit_test');

        // Assert — final state is complete with no error.
        final state = container.read(ripScanNotifierProvider);
        expect(state.status, RipScanStatus.complete);
        expect(state.error, isNull);
        expect(state.matchedCount, 0);
      });

      test('invalidates rippedItemIdsProvider on successful completion',
          () async {
        // Arrange
        _stubForEmptyScan(
          ripRepo: mockRipRepo,
          mediaItemRepo: mockMediaItemRepo,
        );

        final container = _createContainer(
          ripRepo: mockRipRepo,
          mediaItemRepo: mockMediaItemRepo,
        );
        addTearDown(container.dispose);

        // Prime rippedItemIdsProvider so it is tracked by the container.
        // After startScan() completes the provider is invalidated, which
        // causes its stream subscription to restart (observable as AsyncLoading).
        when(() => mockRipRepo.watchRippedMediaItemIds())
            .thenAnswer((_) => const Stream.empty());
        container.read(rippedItemIdsProvider);

        final notifier = container.read(ripScanNotifierProvider.notifier);

        // Act
        await notifier.startScan('/non_existent_path_for_unit_test');

        // Assert — provider has been invalidated.
        final rippedIds = container.read(rippedItemIdsProvider);
        expect(rippedIds, isA<AsyncLoading>());
      });

      test('is a no-op when already scanning', () async {
        // Arrange — suspend the match phase so the first scan stays active.
        // getAllNonDeleted is called by MatchRipsUseCase after the Isolate-
        // based scan stream completes.  We block it indefinitely until we are
        // ready to let the test finish.
        final completer = Completer<List<RipAlbum>>();
        when(() => mockRipRepo.getAllNonDeleted())
            .thenAnswer((_) => completer.future);

        final container = _createContainer(
          ripRepo: mockRipRepo,
          mediaItemRepo: mockMediaItemRepo,
        );

        final notifier = container.read(ripScanNotifierProvider.notifier);

        // Start the first scan without awaiting.  The state is set to
        // scanning synchronously (before the first `await`).
        final firstCall =
            notifier.startScan('/non_existent_path_for_unit_test');

        // Yield once so the micro-task for setting state runs, then verify.
        await Future<void>.delayed(Duration.zero);
        expect(
          container.read(ripScanNotifierProvider).status,
          RipScanStatus.scanning,
        );

        // Act — second call should return immediately without mutating state.
        await notifier.startScan('/another_path');

        // Assert — state is still scanning.
        expect(
          container.read(ripScanNotifierProvider).status,
          RipScanStatus.scanning,
        );

        // Clean up — unblock the first scan so the container can be disposed
        // without a "ref used after dispose" error.
        completer.complete([]);
        when(() => mockMediaItemRepo.watchAll(mediaType: MediaType.music))
            .thenAnswer((_) => Stream.value(<MediaItem>[]));
        await firstCall;
        container.dispose();
      });

      test('sets error in state when the repository throws', () async {
        // Arrange — make getAllNonDeleted throw to simulate a failure inside
        // MatchRipsUseCase (which runs after the scan phase).
        when(() => mockRipRepo.getAllNonDeleted())
            .thenThrow(Exception('Repository error'));

        final container = _createContainer(
          ripRepo: mockRipRepo,
          mediaItemRepo: mockMediaItemRepo,
        );
        addTearDown(container.dispose);

        final notifier = container.read(ripScanNotifierProvider.notifier);

        // Act
        await notifier.startScan('/non_existent_path_for_unit_test');

        // Assert — status is complete with an error message.
        final state = container.read(ripScanNotifierProvider);
        expect(state.status, RipScanStatus.complete);
        expect(state.error, contains('Repository error'));
      });
    });
  });
}
