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
  /// Which media types to search for. Determines the typeHint passed to lookup.
  final Set<MediaType> enabledMediaTypes;

  /// Derives a typeHint from enabled types. If only one category is enabled,
  /// use it as the hint. If multiple are enabled, return null (no hint).
  MediaType? get typeHint {
    if (enabledMediaTypes.length == 1) return enabledMediaTypes.first;
    // If only music-related types are off, hint is film, etc.
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
      if (current.length > 1) current.remove(type); // Don't allow empty set
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
      final useCase = ScanBarcodeUseCase(
        mediaItemRepository: ref.read(mediaItemRepositoryProvider),
        metadataRepository: ref.read(metadataRepositoryProvider),
      );

      final scanResult = await useCase.execute(barcode, typeHint: effectiveHint);

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
