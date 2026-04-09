import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/batch_metadata_edit_provider.dart';

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
}
