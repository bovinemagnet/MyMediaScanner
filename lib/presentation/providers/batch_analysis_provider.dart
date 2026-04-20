import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/utils/flac_decoder.dart';
import 'package:mymediascanner/core/utils/native_flac_decoder.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

part 'batch_analysis_provider.freezed.dart';

enum BatchStatus { idle, running, complete }

enum AlbumAnalysisStatus { queued, analysing, done, error }

@freezed
sealed class BatchAnalysisState with _$BatchAnalysisState {
  const factory BatchAnalysisState({
    @Default(BatchStatus.idle) BatchStatus status,
    @Default({}) Map<String, AlbumAnalysisStatus> albumStatuses,
    @Default(false) bool usingNativeDecoder,
  }) = _BatchAnalysisState;
}

/// Probes for a fast bulk-analysis decoder.
///
/// On desktop, returns a [NativeFlacDecoder] when the system `flac` binary
/// is on PATH (~5× faster than the pure-Dart fallback for back-to-back
/// album decodes). Returns `null` when the binary is missing or on mobile,
/// in which case callers should fall back to the standard
/// [flacDecoderProvider].
final bulkFlacDecoderProvider = FutureProvider<FlacDecoder?>((ref) async {
  if (!PlatformCapability.isDesktop) return null;
  final native = NativeFlacDecoder();
  if (await native.isAvailable()) return native;
  return null;
});

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

    // Probe for the native decoder once at the start of the batch so the
    // per-album loop pays no per-iteration cost. Falls back transparently
    // when not on desktop or when the binary isn't on PATH.
    final bulkDecoder = await ref.read(bulkFlacDecoderProvider.future);

    state = state.copyWith(
      status: BatchStatus.running,
      usingNativeDecoder: bulkDecoder != null,
    );

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
        await ref.read(qualityAnalysisNotifierProvider.notifier).analyse(
              albumId,
              decoderOverride: bulkDecoder,
            );

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
