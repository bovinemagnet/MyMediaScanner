import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';

enum DisambiguationState { idle, loading, error }

class DisambiguationData {
  const DisambiguationData({
    this.state = DisambiguationState.idle,
    this.candidates = const [],
    this.barcode = '',
    this.barcodeType = '',
    this.error,
  });

  final DisambiguationState state;
  final List<MetadataCandidate> candidates;
  final String barcode;
  final String barcodeType;
  final String? error;

  DisambiguationData copyWith({
    DisambiguationState? state,
    List<MetadataCandidate>? candidates,
    String? barcode,
    String? barcodeType,
    String? error,
  }) => DisambiguationData(
    state: state ?? this.state,
    candidates: candidates ?? this.candidates,
    barcode: barcode ?? this.barcode,
    barcodeType: barcodeType ?? this.barcodeType,
    error: error ?? this.error,
  );
}

class DisambiguationNotifier extends Notifier<DisambiguationData> {
  @override
  DisambiguationData build() {
    final scanResult = ref.read(scannerProvider).result;
    if (scanResult is MultiMatchScanResult) {
      return DisambiguationData(
        candidates: scanResult.candidates,
        barcode: scanResult.barcode,
        barcodeType: scanResult.barcodeType,
      );
    }
    return const DisambiguationData();
  }

  Future<MetadataResult?> selectCandidate(MetadataCandidate candidate) async {
    state = state.copyWith(state: DisambiguationState.loading);
    try {
      final repo = ref.read(metadataRepositoryProvider);
      final detail = await repo.fetchCandidateDetail(
        candidate,
        state.barcode,
        state.barcodeType,
      );
      if (detail != null) {
        state = state.copyWith(state: DisambiguationState.idle);
        return detail;
      }
      // Detail fetch returned null — remove candidate from list
      state = state.copyWith(
        state: DisambiguationState.idle,
        candidates:
            state.candidates.where((c) => c != candidate).toList(),
      );
      return null;
    } on Exception catch (e) {
      state = state.copyWith(
        state: DisambiguationState.error,
        error: e.toString(),
      );
      return null;
    }
  }
}

final disambiguationProvider =
    NotifierProvider<DisambiguationNotifier, DisambiguationData>(
        DisambiguationNotifier.new);
