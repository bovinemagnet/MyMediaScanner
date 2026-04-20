import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/batch_analysis_provider.dart';

void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('BatchAnalysisNotifier', () {
    test('build_initialState_isIdle', () {
      final container = makeContainer();

      final state = container.read(batchAnalysisProvider);

      expect(state.status, BatchStatus.idle);
      expect(state.albumStatuses, isEmpty);
      expect(state.usingNativeDecoder, isFalse);
    });

    test('queueAlbums_setsAlbumStatusesAsQueued', () {
      final container = makeContainer();

      container
          .read(batchAnalysisProvider.notifier)
          .queueAlbums(['album-1', 'album-2', 'album-3']);

      final state = container.read(batchAnalysisProvider);
      expect(state.albumStatuses['album-1'], AlbumAnalysisStatus.queued);
      expect(state.albumStatuses['album-2'], AlbumAnalysisStatus.queued);
      expect(state.albumStatuses['album-3'], AlbumAnalysisStatus.queued);
    });

    test('cancel_resetsStateToIdle', () {
      final container = makeContainer();
      final notifier = container.read(batchAnalysisProvider.notifier);

      notifier.queueAlbums(['album-1', 'album-2']);
      notifier.cancel();

      final state = container.read(batchAnalysisProvider);
      expect(state.status, BatchStatus.idle);
      expect(state.albumStatuses, isEmpty);
    });
  });
}
