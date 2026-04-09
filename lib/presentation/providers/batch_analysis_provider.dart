import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

enum BatchStatus { idle, running, complete }

enum AlbumAnalysisStatus { queued, analysing, done, error }

class BatchAnalysisState {
  const BatchAnalysisState({
    this.status = BatchStatus.idle,
    this.albumStatuses = const {},
  });

  final BatchStatus status;
  final Map<String, AlbumAnalysisStatus> albumStatuses;

  BatchAnalysisState copyWith({
    BatchStatus? status,
    Map<String, AlbumAnalysisStatus>? albumStatuses,
  }) =>
      BatchAnalysisState(
        status: status ?? this.status,
        albumStatuses: albumStatuses ?? this.albumStatuses,
      );
}

class BatchAnalysisNotifier extends Notifier<BatchAnalysisState> {
  bool _cancelled = false;

  @override
  BatchAnalysisState build() => const BatchAnalysisState();

  void queueAlbums(List<String> albumIds) {
    final statuses = {
      for (final id in albumIds) id: AlbumAnalysisStatus.queued,
    };
    state = BatchAnalysisState(
      status: BatchStatus.idle,
      albumStatuses: statuses,
    );
  }

  Future<void> startAnalysis() async {
    if (state.status == BatchStatus.running) return;

    _cancelled = false;
    final albumIds = state.albumStatuses.keys.toList();
    state = state.copyWith(status: BatchStatus.running);

    for (final albumId in albumIds) {
      if (_cancelled) break;

      // Mark as analysing
      state = state.copyWith(
        albumStatuses: {
          ...state.albumStatuses,
          albumId: AlbumAnalysisStatus.analysing,
        },
      );

      try {
        await ref.read(qualityAnalysisNotifierProvider.notifier).analyse(albumId);

        if (!_cancelled) {
          state = state.copyWith(
            albumStatuses: {
              ...state.albumStatuses,
              albumId: AlbumAnalysisStatus.done,
            },
          );
        }
      } catch (_) {
        if (!_cancelled) {
          state = state.copyWith(
            albumStatuses: {
              ...state.albumStatuses,
              albumId: AlbumAnalysisStatus.error,
            },
          );
        }
      }
    }

    if (!_cancelled) {
      state = state.copyWith(status: BatchStatus.complete);
    }
  }

  void cancel() {
    _cancelled = true;
    state = const BatchAnalysisState();
  }
}

final batchAnalysisProvider =
    NotifierProvider<BatchAnalysisNotifier, BatchAnalysisState>(
        () => BatchAnalysisNotifier());
