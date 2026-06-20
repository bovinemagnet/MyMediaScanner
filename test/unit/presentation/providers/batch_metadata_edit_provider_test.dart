import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/utils/metaflac_writer.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/presentation/providers/batch_metadata_edit_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

class MockMetaflacWriter extends Mock implements MetaflacWriter {}

void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('BatchMetadataEditNotifier', () {
    test('build_initialState_isIdle', () {
      final container = makeContainer();

      final state = container.read(batchMetadataEditProvider);

      expect(state.status, BatchEditStatus.idle);
      expect(state.pendingChanges, isEmpty);
      expect(state.originalValues, isEmpty);
      expect(state.affectedTrackCount, 0);
      expect(state.affectedAlbumCount, 0);
      expect(state.error, isNull);
    });

    test('prepareBatchEdit_setsPendingChangesAndCounts', () {
      final container = makeContainer();

      final changes = {
        'track-1': {'GENRE': 'Rock', 'DATE': '2024'},
        'track-2': {'GENRE': 'Rock', 'DATE': '2024'},
        'track-3': {'GENRE': 'Rock'},
      };
      final originals = {
        'track-1': {'GENRE': 'Pop', 'DATE': '2020'},
        'track-2': {'GENRE': 'Jazz'},
        'track-3': <String, String>{},
      };

      container.read(batchMetadataEditProvider.notifier).prepareBatchEdit(
            pendingChanges: changes,
            originalValues: originals,
            affectedTrackCount: 3,
            affectedAlbumCount: 2,
          );

      final state = container.read(batchMetadataEditProvider);
      expect(state.status, BatchEditStatus.previewing);
      expect(state.pendingChanges, changes);
      expect(state.originalValues, originals);
      expect(state.affectedTrackCount, 3);
      expect(state.affectedAlbumCount, 2);
    });

    test('reset_clearsState', () {
      final container = makeContainer();
      final notifier = container.read(batchMetadataEditProvider.notifier);

      notifier.prepareBatchEdit(
        pendingChanges: {
          'track-1': {'GENRE': 'Rock'},
        },
        originalValues: {
          'track-1': {'GENRE': 'Pop'},
        },
        affectedTrackCount: 1,
        affectedAlbumCount: 1,
      );

      notifier.reset();

      final state = container.read(batchMetadataEditProvider);
      expect(state.status, BatchEditStatus.idle);
      expect(state.pendingChanges, isEmpty);
      expect(state.originalValues, isEmpty);
      expect(state.affectedTrackCount, 0);
      expect(state.affectedAlbumCount, 0);
      expect(state.error, isNull);
    });
  });

  group('applyChanges / undoChanges track lookup', () {
    // Regression: apply/undo built their track lookup with a synchronous
    // `ref.read(ripTracksProvider(id)).value ?? []`, which is null for
    // any album whose detail view was never opened — so tracks that
    // exist in the DB and on disk were reported as "track no longer
    // exists in the rip library" (apply) or silently skipped (undo).

    late MockRipLibraryRepository mockRepo;
    late MockMetaflacWriter mockWriter;

    const album = RipAlbum(
      id: 'album-1',
      libraryPath: '/music',
      trackCount: 1,
      totalSizeBytes: 0,
      lastScannedAt: 0,
      updatedAt: 0,
    );
    const track = RipTrack(
      id: 'track-1',
      ripAlbumId: 'album-1',
      trackNumber: 1,
      filePath: '/music/a.flac',
      fileSizeBytes: 0,
      updatedAt: 0,
    );

    setUp(() {
      mockRepo = MockRipLibraryRepository();
      mockWriter = MockMetaflacWriter();
      when(() => mockRepo.getAllNonDeleted())
          .thenAnswer((_) async => const [album]);
      when(() => mockRepo.getTracksForAlbum('album-1'))
          .thenAnswer((_) async => const [track]);
      when(() => mockWriter.setTags(any(), any())).thenAnswer((_) async {});
    });

    ProviderContainer makeOverriddenContainer() {
      final container = ProviderContainer(
        overrides: [
          ripLibraryRepositoryProvider.overrideWithValue(mockRepo),
          metaflacWriterProvider.overrideWithValue(mockWriter),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('applyChanges finds tracks whose providers were never resolved',
        () async {
      final container = makeOverriddenContainer();
      final notifier = container.read(batchMetadataEditProvider.notifier);

      notifier.prepareBatchEdit(
        pendingChanges: {
          'track-1': {'GENRE': 'Rock'},
        },
        originalValues: {
          'track-1': {'GENRE': 'Pop'},
        },
        affectedTrackCount: 1,
        affectedAlbumCount: 1,
      );

      // Deliberately no prior read of allRipAlbumsProvider /
      // ripTracksProvider — as when the album detail was never opened.
      await notifier.applyChanges();

      final state = container.read(batchMetadataEditProvider);
      expect(state.error, isNull);
      expect(state.status, BatchEditStatus.applied);
      verify(() => mockWriter.setTags('/music/a.flac', {'GENRE': 'Rock'}))
          .called(1);
    });

    test('undoChanges finds tracks whose providers were never resolved',
        () async {
      final container = makeOverriddenContainer();
      final notifier = container.read(batchMetadataEditProvider.notifier);

      notifier.prepareBatchEdit(
        pendingChanges: {
          'track-1': {'GENRE': 'Rock'},
        },
        originalValues: {
          'track-1': {'GENRE': 'Pop'},
        },
        affectedTrackCount: 1,
        affectedAlbumCount: 1,
      );

      await notifier.undoChanges();

      final state = container.read(batchMetadataEditProvider);
      expect(state.error, isNull);
      expect(state.status, BatchEditStatus.idle,
          reason: 'a successful undo resets the editor');
      verify(() => mockWriter.setTags('/music/a.flac', {'GENRE': 'Pop'}))
          .called(1);
    });
  });
}
