import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/usecases/scan_barcode_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

enum ScanState {
  idle,
  scanning,
  lookingUp,
  found,
  notFound,
  duplicate,
  disambiguating,
  error,
}

class ScannerState {
  const ScannerState({
    this.state = ScanState.idle,
    this.result,
    this.error,
    this.batchMode = false,
    this.batchCount = 0,
    this.enabledMediaTypes = const {
      MediaType.music,
      MediaType.film,
      MediaType.tv,
      MediaType.book,
      MediaType.game,
    },
  });

  final ScanState state;
  final ScanResult? result;
  final String? error;
  final bool batchMode;
  final int batchCount;
  final Set<MediaType> enabledMediaTypes;

  MediaType? get typeHint {
    if (enabledMediaTypes.length == 1) return enabledMediaTypes.first;
    final withoutGame = enabledMediaTypes.difference({MediaType.game});
    if (withoutGame.length == 1) return withoutGame.first;
    return null;
  }

  ScannerState copyWith({
    ScanState? state,
    ScanResult? result,
    String? error,
    bool? batchMode,
    int? batchCount,
    Set<MediaType>? enabledMediaTypes,
  }) => ScannerState(
    state: state ?? this.state,
    result: result ?? this.result,
    error: error ?? this.error,
    batchMode: batchMode ?? this.batchMode,
    batchCount: batchCount ?? this.batchCount,
    enabledMediaTypes: enabledMediaTypes ?? this.enabledMediaTypes,
  );
}

class ScannerNotifier extends Notifier<ScannerState> {
  @override
  ScannerState build() => const ScannerState();

  void toggleMediaType(MediaType type) {
    final current = Set<MediaType>.from(state.enabledMediaTypes);
    if (current.contains(type)) {
      if (current.length > 1) current.remove(type);
    } else {
      current.add(type);
    }
    state = state.copyWith(enabledMediaTypes: current);
  }

  Future<void> onBarcodeScanned(
    String barcode, {
    MediaType? typeHint,
  }) async {
    final effectiveHint = typeHint ?? state.typeHint;
    state = state.copyWith(state: ScanState.lookingUp);

    try {
      await ref.read(apiKeysProvider.future);

      final useCase = ScanBarcodeUseCase(
        mediaItemRepository: ref.read(mediaItemRepositoryProvider),
        metadataRepository: ref.read(metadataRepositoryProvider),
      );

      final scanResult =
          await useCase.execute(barcode, typeHint: effectiveHint);

      switch (scanResult) {
        case SingleScanResult(:final isDuplicate):
          if (isDuplicate) {
            state = ScannerState(
              state: ScanState.duplicate,
              result: scanResult,
              batchMode: state.batchMode,
              batchCount: state.batchCount,
              enabledMediaTypes: state.enabledMediaTypes,
            );
          } else {
            state = ScannerState(
              state: ScanState.found,
              result: scanResult,
              batchMode: state.batchMode,
              batchCount: state.batchCount,
              enabledMediaTypes: state.enabledMediaTypes,
            );
          }
        case MultiMatchScanResult():
          if (state.batchMode) {
            // In batch mode, auto-select first candidate
            final repo = ref.read(metadataRepositoryProvider);
            final multi = scanResult;
            final detail = await repo.fetchCandidateDetail(
              multi.candidates.first,
              multi.barcode,
              multi.barcodeType,
            );
            if (detail != null) {
              state = ScannerState(
                state: ScanState.found,
                result: ScanResult.single(
                    metadata: detail, isDuplicate: false),
                batchMode: state.batchMode,
                batchCount: state.batchCount,
                enabledMediaTypes: state.enabledMediaTypes,
              );
            } else {
              state = ScannerState(
                state: ScanState.notFound,
                result: ScanResult.notFound(
                  barcode: multi.barcode,
                  barcodeType: multi.barcodeType,
                ),
                batchMode: state.batchMode,
                batchCount: state.batchCount,
                enabledMediaTypes: state.enabledMediaTypes,
              );
            }
          } else {
            state = ScannerState(
              state: ScanState.disambiguating,
              result: scanResult,
              batchMode: state.batchMode,
              batchCount: state.batchCount,
              enabledMediaTypes: state.enabledMediaTypes,
            );
          }
        case NotFoundScanResult():
          state = ScannerState(
            state: ScanState.notFound,
            result: scanResult,
            batchMode: state.batchMode,
            batchCount: state.batchCount,
            enabledMediaTypes: state.enabledMediaTypes,
          );
      }
    } on Exception catch (e) {
      state = ScannerState(
        state: ScanState.error,
        error: e.toString(),
        batchMode: state.batchMode,
        batchCount: state.batchCount,
        enabledMediaTypes: state.enabledMediaTypes,
      );
    }
  }

  /// Called after disambiguation screen selects a candidate.
  void onCandidateSelected(MetadataResult metadata) {
    state = ScannerState(
      state: ScanState.found,
      result: ScanResult.single(metadata: metadata, isDuplicate: false),
      batchMode: state.batchMode,
      batchCount: state.batchCount,
      enabledMediaTypes: state.enabledMediaTypes,
    );
  }

  /// Called when user taps "None of these" on disambiguation screen.
  void onNoneSelected(String barcode, String barcodeType) {
    state = ScannerState(
      state: ScanState.found,
      result: ScanResult.single(
        metadata: MetadataResult(barcode: barcode, barcodeType: barcodeType),
        isDuplicate: false,
      ),
      batchMode: state.batchMode,
      batchCount: state.batchCount,
      enabledMediaTypes: state.enabledMediaTypes,
    );
  }

  void reset() {
    state = const ScannerState();
  }

  void toggleBatchMode() {
    state = state.copyWith(batchMode: !state.batchMode, batchCount: 0);
  }

  void incrementBatchCount() {
    state = state.copyWith(
      state: ScanState.idle,
      batchCount: state.batchCount + 1,
    );
  }
}

final scannerProvider =
    NotifierProvider<ScannerNotifier, ScannerState>(ScannerNotifier.new);
