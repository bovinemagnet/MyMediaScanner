import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/usecases/scan_barcode_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

enum ScanState { idle, scanning, lookingUp, found, notFound, duplicate, error }

class ScannerState {
  const ScannerState({
    this.state = ScanState.idle,
    this.result,
    this.error,
    this.batchMode = false,
    this.batchCount = 0,
  });

  final ScanState state;
  final ScanResult? result;
  final String? error;
  final bool batchMode;
  final int batchCount;

  ScannerState copyWith({
    ScanState? state,
    ScanResult? result,
    String? error,
    bool? batchMode,
    int? batchCount,
  }) => ScannerState(
    state: state ?? this.state,
    result: result ?? this.result,
    error: error ?? this.error,
    batchMode: batchMode ?? this.batchMode,
    batchCount: batchCount ?? this.batchCount,
  );
}

class ScannerNotifier extends Notifier<ScannerState> {
  @override
  ScannerState build() => const ScannerState();

  Future<void> onBarcodeScanned(
    String barcode, {
    MediaType? typeHint,
  }) async {
    state = const ScannerState(state: ScanState.lookingUp);

    try {
      final useCase = ScanBarcodeUseCase(
        mediaItemRepository: ref.read(mediaItemRepositoryProvider),
        metadataRepository: ref.read(metadataRepositoryProvider),
      );

      final scanResult = await useCase.execute(barcode, typeHint: typeHint);

      if (scanResult.isDuplicate) {
        state = ScannerState(state: ScanState.duplicate, result: scanResult);
      } else if (scanResult.metadataResult.title != null) {
        state = ScannerState(state: ScanState.found, result: scanResult);
      } else {
        state = ScannerState(state: ScanState.notFound, result: scanResult);
      }
    } on Exception catch (e) {
      state = ScannerState(state: ScanState.error, error: e.toString());
    }
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
