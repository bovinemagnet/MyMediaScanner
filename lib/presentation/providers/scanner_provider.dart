import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/ocr_result.dart';
import 'package:mymediascanner/domain/entities/ocr_search_result.dart';
import 'package:mymediascanner/domain/usecases/ocr_metadata_usecase.dart';
import 'package:mymediascanner/domain/usecases/scan_barcode_usecase.dart';
import 'package:mymediascanner/presentation/providers/batch_editor_provider.dart';
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
  coverScan,
  error,
}

/// Whether the user is scanning a standard barcode or an ISBN.
enum ScanMode { barcode, isbn }

class ScannerState {
  const ScannerState({
    this.state = ScanState.idle,
    this.result,
    this.error,
    this.batchMode = false,
    this.batchCount = 0,
    this.scanMode = ScanMode.barcode,
    this.enabledMediaTypes = const {
      MediaType.music,
      MediaType.film,
      MediaType.tv,
      MediaType.book,
      MediaType.game,
    },
    this.ocrSearchResult,
  });

  final ScanState state;
  final ScanResult? result;
  final String? error;
  final bool batchMode;
  final int batchCount;
  final ScanMode scanMode;
  final Set<MediaType> enabledMediaTypes;

  /// OCR context from cover scan, if available.
  final OcrSearchResult? ocrSearchResult;

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
    ScanMode? scanMode,
    Set<MediaType>? enabledMediaTypes,
    OcrSearchResult? ocrSearchResult,
  }) => ScannerState(
    state: state ?? this.state,
    result: result ?? this.result,
    error: error ?? this.error,
    batchMode: batchMode ?? this.batchMode,
    batchCount: batchCount ?? this.batchCount,
    scanMode: scanMode ?? this.scanMode,
    enabledMediaTypes: enabledMediaTypes ?? this.enabledMediaTypes,
    ocrSearchResult: ocrSearchResult ?? this.ocrSearchResult,
  );
}

class ScannerNotifier extends Notifier<ScannerState> {
  /// Incremented on cancel/reset so in-flight lookups can detect staleness.
  int _generation = 0;

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

  void setScanMode(ScanMode mode) {
    state = state.copyWith(scanMode: mode);
  }

  /// Cancel an in-flight lookup and return to idle.
  void cancel() {
    _generation++;
    state = ScannerState(
      scanMode: state.scanMode,
      batchMode: state.batchMode,
      batchCount: state.batchCount,
      enabledMediaTypes: state.enabledMediaTypes,
    );
  }

  Future<void> onBarcodeScanned(
    String barcode, {
    MediaType? typeHint,
  }) async {
    final effectiveHint = typeHint ?? state.typeHint;
    _generation++;
    final gen = _generation;
    state = state.copyWith(state: ScanState.lookingUp);

    try {
      await ref.read(apiKeysProvider.future);
      if (_generation != gen) return;

      final useCase = ScanBarcodeUseCase(
        mediaItemRepository: ref.read(mediaItemRepositoryProvider),
        metadataRepository: ref.read(metadataRepositoryProvider),
      );

      final scanResult = await useCase.execute(
        barcode,
        typeHint: effectiveHint,
        forceIsbn: state.scanMode == ScanMode.isbn,
      );
      if (_generation != gen) return;

      switch (scanResult) {
        case SingleScanResult(:final isDuplicate):
          if (isDuplicate) {
            state = ScannerState(
              state: ScanState.duplicate,
              result: scanResult,
              batchMode: state.batchMode,
              batchCount: state.batchCount,
              enabledMediaTypes: state.enabledMediaTypes,
              scanMode: state.scanMode,
            );
          } else {
            state = ScannerState(
              state: ScanState.found,
              result: scanResult,
              batchMode: state.batchMode,
              batchCount: state.batchCount,
              enabledMediaTypes: state.enabledMediaTypes,
              scanMode: state.scanMode,
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
            if (_generation != gen) return;
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
                scanMode: state.scanMode,
              );
            }
          } else {
            state = ScannerState(
              state: ScanState.disambiguating,
              result: scanResult,
              batchMode: state.batchMode,
              batchCount: state.batchCount,
              enabledMediaTypes: state.enabledMediaTypes,
              scanMode: state.scanMode,
            );
          }
        case NotFoundScanResult():
          state = ScannerState(
            state: ScanState.notFound,
            result: scanResult,
            batchMode: state.batchMode,
            batchCount: state.batchCount,
            enabledMediaTypes: state.enabledMediaTypes,
            scanMode: state.scanMode,
          );
      }
    } catch (e) {
      if (_generation != gen) return;
      state = ScannerState(
        state: ScanState.error,
        error: e.toString(),
        batchMode: state.batchMode,
        batchCount: state.batchCount,
        enabledMediaTypes: state.enabledMediaTypes,
        scanMode: state.scanMode,
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
      scanMode: state.scanMode,
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
      scanMode: state.scanMode,
    );
  }

  /// Search by title when barcode lookup returned notFound.
  Future<void> searchByTitle(
      String title, String barcode, String barcodeType) async {
    _generation++;
    final gen = _generation;
    state = state.copyWith(state: ScanState.lookingUp);

    try {
      final repo = ref.read(metadataRepositoryProvider);
      final scanResult = await repo.searchByTitle(
        title,
        barcode,
        barcodeType,
        typeHint: state.typeHint,
      );
      if (_generation != gen) return;

      switch (scanResult) {
        case SingleScanResult():
          state = ScannerState(
            state: ScanState.found,
            result: scanResult,
            batchMode: state.batchMode,
            batchCount: state.batchCount,
            enabledMediaTypes: state.enabledMediaTypes,
            scanMode: state.scanMode,
          );
        case MultiMatchScanResult():
          state = ScannerState(
            state: ScanState.disambiguating,
            result: scanResult,
            batchMode: state.batchMode,
            batchCount: state.batchCount,
            enabledMediaTypes: state.enabledMediaTypes,
            scanMode: state.scanMode,
          );
        case NotFoundScanResult():
          state = ScannerState(
            state: ScanState.notFound,
            result: scanResult,
            batchMode: state.batchMode,
            batchCount: state.batchCount,
            enabledMediaTypes: state.enabledMediaTypes,
            scanMode: state.scanMode,
          );
      }
    } catch (e) {
      if (_generation != gen) return;
      state = ScannerState(
        state: ScanState.error,
        error: e.toString(),
        batchMode: state.batchMode,
        batchCount: state.batchCount,
        enabledMediaTypes: state.enabledMediaTypes,
        scanMode: state.scanMode,
      );
    }
  }

  /// Transition to cover scan mode (mobile only).
  void startCoverScan() {
    state = state.copyWith(state: ScanState.coverScan);
  }

  /// Called when structured OCR results are available from a cover scan.
  /// Uses [OcrMetadataUseCase] to orchestrate search with OCR context.
  Future<void> onCoverOcrResult(
    OcrResult ocrResult,
    String barcode,
    String barcodeType,
  ) async {
    _generation++;
    final gen = _generation;
    state = state.copyWith(state: ScanState.lookingUp);

    try {
      final useCase = OcrMetadataUseCase(
        metadataRepository: ref.read(metadataRepositoryProvider),
      );
      final ocrSearchResult = await useCase.execute(
        ocrResult,
        barcode,
        barcodeType,
        typeHint: state.typeHint,
      );
      if (_generation != gen) return;

      switch (ocrSearchResult.scanResult) {
        case SingleScanResult(:final isDuplicate):
          if (isDuplicate) {
            state = ScannerState(
              state: ScanState.duplicate,
              result: ocrSearchResult.scanResult,
              batchMode: state.batchMode,
              batchCount: state.batchCount,
              enabledMediaTypes: state.enabledMediaTypes,
              scanMode: state.scanMode,
              ocrSearchResult: ocrSearchResult,
            );
          } else {
            state = ScannerState(
              state: ScanState.found,
              result: ocrSearchResult.scanResult,
              batchMode: state.batchMode,
              batchCount: state.batchCount,
              enabledMediaTypes: state.enabledMediaTypes,
              scanMode: state.scanMode,
              ocrSearchResult: ocrSearchResult,
            );
          }
        case MultiMatchScanResult():
          state = ScannerState(
            state: ScanState.disambiguating,
            result: ocrSearchResult.scanResult,
            batchMode: state.batchMode,
            batchCount: state.batchCount,
            enabledMediaTypes: state.enabledMediaTypes,
            scanMode: state.scanMode,
            ocrSearchResult: ocrSearchResult,
          );
        case NotFoundScanResult():
          state = ScannerState(
            state: ScanState.notFound,
            result: ocrSearchResult.scanResult,
            batchMode: state.batchMode,
            batchCount: state.batchCount,
            enabledMediaTypes: state.enabledMediaTypes,
            scanMode: state.scanMode,
            ocrSearchResult: ocrSearchResult,
          );
      }
    } catch (e) {
      if (_generation != gen) return;
      state = ScannerState(
        state: ScanState.error,
        error: e.toString(),
        batchMode: state.batchMode,
        batchCount: state.batchCount,
        enabledMediaTypes: state.enabledMediaTypes,
        scanMode: state.scanMode,
      );
    }
  }

  /// Called when cover OCR extracts text. Searches by the extracted title.
  @Deprecated('Use onCoverOcrResult() instead')
  Future<void> onCoverTextRecognised(
      String text, String barcode, String barcodeType) async {
    // Wrap plain text in an OcrResult for backward compatibility
    final ocrResult = OcrResult(blocks: [
      OcrTextBlock(text: text, confidence: 0.85, area: 1.0),
    ]);
    await onCoverOcrResult(ocrResult, barcode, barcodeType);
  }

  void reset() {
    _generation++;
    state = ScannerState(
      scanMode: state.scanMode,
      batchMode: state.batchMode,
      batchCount: state.batchCount,
      enabledMediaTypes: state.enabledMediaTypes,
    );
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

  /// Queue the current scan result to the batch editor.
  Future<void> queueToBatch(ScanResult result) async {
    await ref.read(batchEditorProvider.notifier).addScanResult(result);
    incrementBatchCount();
  }
}

final scannerProvider =
    NotifierProvider<ScannerNotifier, ScannerState>(ScannerNotifier.new);
