import 'package:mymediascanner/domain/entities/media_type.dart';
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
  }) async {
    final isDuplicate = await _mediaItemRepo.barcodeExists(barcode);
    final result = await _metadataRepo.lookupBarcode(
      barcode,
      typeHint: typeHint,
    );

    // Repository now returns ScanResult directly.
    // Override isDuplicate on single results.
    return switch (result) {
      SingleScanResult(:final metadata) => ScanResult.single(
          metadata: metadata,
          isDuplicate: isDuplicate,
        ),
      MultiMatchScanResult() => result,
      NotFoundScanResult() => result,
    };
  }
}
