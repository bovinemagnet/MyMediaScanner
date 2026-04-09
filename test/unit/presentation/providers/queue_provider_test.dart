/// Tests for the play queue Riverpod providers.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/queue_item.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/queue_provider.dart';

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

const _album = RipAlbum(
  id: 'album-1',
  libraryPath: '/music/album1',
  artist: 'Test Artist',
  albumTitle: 'Test Album',
  trackCount: 3,
  totalSizeBytes: 300000,
  lastScannedAt: 1000,
  updatedAt: 1000,
);

const _track1 = RipTrack(
  id: 'track-1',
  ripAlbumId: 'album-1',
  trackNumber: 1,
  title: 'Track One',
  filePath: '/music/album1/01.flac',
  fileSizeBytes: 100000,
  updatedAt: 1000,
);

const _track2 = RipTrack(
  id: 'track-2',
  ripAlbumId: 'album-1',
  trackNumber: 2,
  title: 'Track Two',
  filePath: '/music/album1/02.flac',
  fileSizeBytes: 100000,
  updatedAt: 1000,
);

const _track3 = RipTrack(
  id: 'track-3',
  ripAlbumId: 'album-1',
  trackNumber: 3,
  title: 'Track Three',
  filePath: '/music/album1/03.flac',
  fileSizeBytes: 100000,
  updatedAt: 1000,
);

const _tracks = [_track1, _track2, _track3];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProviderContainer makeContainer() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}

void main() {
  // -------------------------------------------------------------------------
  // QueueNotifier
  // -------------------------------------------------------------------------

  group('QueueNotifier', () {
    test('build_initialState_isEmpty', () {
      final container = makeContainer();

      final state = container.read(queueProvider);

      expect(state.items, isEmpty);
      expect(state.currentIndex, -1);
      expect(state.history, isEmpty);
    });

    test('addAlbumToQueue_appendsAllTracks', () {
      final container = makeContainer();

      container.read(queueProvider.notifier).addAlbumToQueue(_album, _tracks);

      final state = container.read(queueProvider);
      expect(state.items.length, 3);
      expect(state.items[0].track, _track1);
      expect(state.items[1].track, _track2);
      expect(state.items[2].track, _track3);
      expect(state.items.every((i) => i.album == _album), isTrue);
    });

    test('playNext_insertsAfterCurrentIndex', () {
      final container = makeContainer();
      final notifier = container.read(queueProvider.notifier);

      // Set up a queue with two tracks and current at index 0
      notifier.replaceQueue(_album, _tracks, startIndex: 0);
      const insertItem = QueueItem(
        album: _album,
        track: _track3,
        source: QueueItemSource.manual,
      );

      notifier.playNext(insertItem);

      final state = container.read(queueProvider);
      // Item should be at index 1 (after currentIndex 0)
      expect(state.items[1].track, _track3);
    });

    test('removeAt_removesItemAtIndex', () {
      final container = makeContainer();
      final notifier = container.read(queueProvider.notifier);

      notifier.addAlbumToQueue(_album, _tracks);
      notifier.removeAt(1);

      final state = container.read(queueProvider);
      expect(state.items.length, 2);
      expect(state.items[0].track, _track1);
      expect(state.items[1].track, _track3);
    });

    test('reorder_movesItemFromOldToNewIndex', () {
      final container = makeContainer();
      final notifier = container.read(queueProvider.notifier);

      notifier.addAlbumToQueue(_album, _tracks);
      // Move track at index 0 to index 2
      notifier.reorder(0, 2);

      final state = container.read(queueProvider);
      expect(state.items[0].track, _track2);
      expect(state.items[1].track, _track3);
      expect(state.items[2].track, _track1);
    });

    test('advanceToNext_incrementsCurrentIndexAndAddsToHistory', () {
      final container = makeContainer();
      final notifier = container.read(queueProvider.notifier);

      notifier.replaceQueue(_album, _tracks, startIndex: 0);
      notifier.advanceToNext();

      final state = container.read(queueProvider);
      expect(state.currentIndex, 1);
      expect(state.history.length, 1);
      expect(state.history.first.track, _track1);
    });

    test('clear_emptiesQueueButPreservesHistory', () {
      final container = makeContainer();
      final notifier = container.read(queueProvider.notifier);

      notifier.replaceQueue(_album, _tracks, startIndex: 0);
      notifier.advanceToNext(); // add one item to history

      notifier.clear();

      final state = container.read(queueProvider);
      expect(state.items, isEmpty);
      expect(state.history.length, 1);
    });

    test('replaceQueue_clearsExistingAndSetsNewItems', () {
      final container = makeContainer();
      final notifier = container.read(queueProvider.notifier);

      notifier.addAlbumToQueue(_album, [_track1]);
      notifier.replaceQueue(_album, [_track2, _track3], startIndex: 0);

      final state = container.read(queueProvider);
      expect(state.items.length, 2);
      expect(state.items[0].track, _track2);
      expect(state.items[1].track, _track3);
      expect(state.currentIndex, 0);
    });

    test('history_isCappedAt50Items', () {
      final container = makeContainer();
      final notifier = container.read(queueProvider.notifier);

      // Build a queue of 60 tracks (reuse same track with unique ids via
      // building QueueItems directly)
      final manyTracks = List.generate(
        60,
        (i) => RipTrack(
          id: 'track-$i',
          ripAlbumId: 'album-1',
          trackNumber: i + 1,
          filePath: '/music/album1/$i.flac',
          fileSizeBytes: 1000,
          updatedAt: 1000,
        ),
      );

      notifier.replaceQueue(_album, manyTracks, startIndex: 0);
      // Advance through 55 tracks to accumulate 55 history entries
      for (var i = 0; i < 55; i++) {
        notifier.advanceToNext();
      }

      final state = container.read(queueProvider);
      expect(state.history.length, lessThanOrEqualTo(50));
    });
  });

  // -------------------------------------------------------------------------
  // QueueVisibleNotifier
  // -------------------------------------------------------------------------

  group('QueueVisibleNotifier', () {
    test('build_initialState_isFalse', () {
      final container = makeContainer();

      expect(container.read(queueVisibleProvider), isFalse);
    });

    test('toggle_fromFalse_setsStateToTrue', () {
      final container = makeContainer();

      container.read(queueVisibleProvider.notifier).toggle();

      expect(container.read(queueVisibleProvider), isTrue);
    });

    test('toggle_fromTrue_setsStateToFalse', () {
      final container = makeContainer();
      final notifier = container.read(queueVisibleProvider.notifier);

      notifier.toggle(); // false → true
      notifier.toggle(); // true → false

      expect(container.read(queueVisibleProvider), isFalse);
    });
  });
}
