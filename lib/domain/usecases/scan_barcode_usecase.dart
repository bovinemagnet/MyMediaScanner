import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ocr_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';

export 'package:mymediascanner/domain/entities/scan_result.dart';

class ScanBarcodeUseCase {
  const ScanBarcodeUseCase({
    required IMediaItemRepository mediaItemRepository,
    required IMetadataRepository metadataRepository,
  })  : _mediaItemRepo = mediaItemRepository,
        _metadataRepo = metadataRepository;

  final IMediaItemRepository _mediaItemRepo;
  final IMetadataRepository _metadataRepo;

  Future<ScanResult> execute(
    String barcode, {
    MediaType? typeHint,
    bool forceIsbn = false,
    OcrResult? ocrResult,
  }) async {
    final isDuplicate = await _mediaItemRepo.barcodeExists(barcode);
    final result = await _metadataRepo.lookupBarcode(
      barcode,
      typeHint: typeHint,
      forceIsbn: forceIsbn,
    );

    // Repository now returns ScanResult directly.
    // Override isDuplicate on single results.
    final scanResult = switch (result) {
      SingleScanResult(:final metadata) => ScanResult.single(
          metadata: metadata,
          isDuplicate: isDuplicate,
        ),
      MultiMatchScanResult() => result,
      NotFoundScanResult() => result,
    };

    // If barcode lookup failed and OCR text is available, try title search
    if (scanResult is NotFoundScanResult &&
        ocrResult != null &&
        !ocrResult.isEmpty) {
      final ocrTitle = ocrResult.inferredTitle;
      if (ocrTitle != null && ocrTitle.isNotEmpty) {
        final notFound = scanResult as NotFoundScanResult;
        return _metadataRepo.searchByTitle(
          ocrTitle,
          notFound.barcode,
          notFound.barcodeType,
          typeHint: typeHint,
        );
      }
    }

    return scanResult;
  }
}
