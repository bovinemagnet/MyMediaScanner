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

/// Destination for the scanned item. `collection` saves as
/// [OwnershipStatus.owned]; `wishlist` saves as [OwnershipStatus.wishlist].
/// Chosen on the scan screen so a mistap on the metadata-confirm screen
/// can't quietly divert a scan to the wishlist.
enum SaveTarget { collection, wishlist }

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
    this.saveTarget = SaveTarget.collection,
    this.ocrSearchResult,
  });

  final ScanState state;
  final ScanResult? result;
  final String? error;
  final bool batchMode;
  final int batchCount;
  final ScanMode scanMode;
  final Set<MediaType> enabledMediaTypes;
  final SaveTarget saveTarget;

  /// OCR context from cover scan, if available.
  final OcrSearchResult? ocrSearchResult;

  MediaType? get typeHint {
    if (enabledMediaTypes.length == 1) return enabledMediaTypes.first;
    final withoutGame = enabledMediaTypes.difference({MediaType.game});
    if (withoutGame.length == 1) return withoutGame.first;
    return null;
  }

  /// The nullable fields ([result], [error], [ocrSearchResult]) use
  /// `?? this.field` semantics, so passing `null` preserves the current
  /// value. Use the explicit `clear*` flags to reset them to `null`.
  ScannerState copyWith({
    ScanState? state,
    ScanResult? result,
    String? error,
    bool? batchMode,
    int? batchCount,
    ScanMode? scanMode,
    Set<MediaType>? enabledMediaTypes,
    SaveTarget? saveTarget,
    OcrSearchResult? ocrSearchResult,
    bool clearResult = false,
    bool clearError = false,
    bool clearOcrSearchResult = false,
  }) => ScannerState(
    state: state ?? this.state,
    result: clearResult ? null : result ?? this.result,
    error: clearError ? null : error ?? this.error,
    batchMode: batchMode ?? this.batchMode,
    batchCount: batchCount ?? this.batchCount,
    scanMode: scanMode ?? this.scanMode,
    enabledMediaTypes: enabledMediaTypes ?? this.enabledMediaTypes,
    saveTarget: saveTarget ?? this.saveTarget,
    ocrSearchResult:
        clearOcrSearchResult ? null : ocrSearchResult ?? this.ocrSearchResult,
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

  /// Choose whether the next scan is saved to the main collection or to
  /// the wishlist. Sticky across `reset()` / `cancel()` so a user can
  /// power-scan a stack of wishlist items without re-toggling each time.
  void setSaveTarget(SaveTarget target) {
    state = state.copyWith(saveTarget: target);
  }

  /// Cancel an in-flight lookup and return to idle.
  void cancel() {
    _generation++;
    state = state.copyWith(
      state: ScanState.idle,
      clearResult: true,
      clearError: true,
      clearOcrSearchResult: true,
    );
  }

  Future<void> onBarcodeScanned(String barcode, {MediaType? typeHint}) async {
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
          state = state.copyWith(
            state: isDuplicate ? ScanState.duplicate : ScanState.found,
            result: scanResult,
            clearError: true,
            clearOcrSearchResult: true,
          );
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
              state = state.copyWith(
                state: ScanState.found,
                result: ScanResult.single(metadata: detail, isDuplicate: false),
                clearError: true,
                clearOcrSearchResult: true,
              );
            } else {
              state = state.copyWith(
                state: ScanState.notFound,
                result: ScanResult.notFound(
                  barcode: multi.barcode,
                  barcodeType: multi.barcodeType,
                ),
                clearError: true,
                clearOcrSearchResult: true,
              );
            }
          } else {
            state = state.copyWith(
              state: ScanState.disambiguating,
              result: scanResult,
              clearError: true,
              clearOcrSearchResult: true,
            );
          }
        case NotFoundScanResult():
          state = state.copyWith(
            state: ScanState.notFound,
            result: scanResult,
            clearError: true,
            clearOcrSearchResult: true,
          );
      }
    } catch (e) {
      if (_generation != gen) return;
      state = state.copyWith(
        state: ScanState.error,
        error: e.toString(),
        clearResult: true,
        clearOcrSearchResult: true,
      );
    }
  }

  /// Called after disambiguation screen selects a candidate.
  void onCandidateSelected(MetadataResult metadata) {
    state = state.copyWith(
      state: ScanState.found,
      result: ScanResult.single(metadata: metadata, isDuplicate: false),
      clearError: true,
      clearOcrSearchResult: true,
    );
  }

  /// Called when user taps "None of these" on disambiguation screen.
  void onNoneSelected(String barcode, String barcodeType) {
    state = state.copyWith(
      state: ScanState.found,
      result: ScanResult.single(
        metadata: MetadataResult(barcode: barcode, barcodeType: barcodeType),
        isDuplicate: false,
      ),
      clearError: true,
      clearOcrSearchResult: true,
    );
  }

  /// Search by title when barcode lookup returned notFound.
  Future<void> searchByTitle(
    String title,
    String barcode,
    String barcodeType,
  ) async {
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
          state = state.copyWith(
            state: ScanState.found,
            result: scanResult,
            clearError: true,
            clearOcrSearchResult: true,
          );
        case MultiMatchScanResult():
          state = state.copyWith(
            state: ScanState.disambiguating,
            result: scanResult,
            clearError: true,
            clearOcrSearchResult: true,
          );
        case NotFoundScanResult():
          state = state.copyWith(
            state: ScanState.notFound,
            result: scanResult,
            clearError: true,
            clearOcrSearchResult: true,
          );
      }
    } catch (e) {
      if (_generation != gen) return;
      state = state.copyWith(
        state: ScanState.error,
        error: e.toString(),
        clearResult: true,
        clearOcrSearchResult: true,
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
          state = state.copyWith(
            state: isDuplicate ? ScanState.duplicate : ScanState.found,
            result: ocrSearchResult.scanResult,
            ocrSearchResult: ocrSearchResult,
            clearError: true,
          );
        case MultiMatchScanResult():
          state = state.copyWith(
            state: ScanState.disambiguating,
            result: ocrSearchResult.scanResult,
            ocrSearchResult: ocrSearchResult,
            clearError: true,
          );
        case NotFoundScanResult():
          state = state.copyWith(
            state: ScanState.notFound,
            result: ocrSearchResult.scanResult,
            ocrSearchResult: ocrSearchResult,
            clearError: true,
          );
      }
    } catch (e) {
      if (_generation != gen) return;
      state = state.copyWith(
        state: ScanState.error,
        error: e.toString(),
        clearResult: true,
        clearOcrSearchResult: true,
      );
    }
  }

  /// Called when cover OCR extracts text. Searches by the extracted title.
  @Deprecated('Use onCoverOcrResult() instead')
  Future<void> onCoverTextRecognised(
    String text,
    String barcode,
    String barcodeType,
  ) async {
    // Wrap plain text in an OcrResult for backward compatibility
    final ocrResult = OcrResult(
      blocks: [OcrTextBlock(text: text, confidence: 0.85, area: 1.0)],
    );
    await onCoverOcrResult(ocrResult, barcode, barcodeType);
  }

  void reset() {
    _generation++;
    state = state.copyWith(
      state: ScanState.idle,
      clearResult: true,
      clearError: true,
      clearOcrSearchResult: true,
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

final scannerProvider = NotifierProvider<ScannerNotifier, ScannerState>(
  ScannerNotifier.new,
);
