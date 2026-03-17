import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

part 'scan_result.freezed.dart';

@freezed
sealed class ScanResult with _$ScanResult {
  const factory ScanResult.single({
    required MetadataResult metadata,
    required bool isDuplicate,
  }) = SingleScanResult;

  const factory ScanResult.multiMatch({
    required List<MetadataCandidate> candidates,
    required String barcode,
    required String barcodeType,
  }) = MultiMatchScanResult;

  const factory ScanResult.notFound({
    required String barcode,
    required String barcodeType,
  }) = NotFoundScanResult;
}
