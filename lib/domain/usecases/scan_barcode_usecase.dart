import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';

class ScanResult {
  const ScanResult({
    required this.metadataResult,
    required this.isDuplicate,
  });

  final MetadataResult metadataResult;
  final bool isDuplicate;
}

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
    final metadata = await _metadataRepo.lookupBarcode(
      barcode,
      typeHint: typeHint,
    );
    return ScanResult(
      metadataResult: metadata,
      isDuplicate: isDuplicate,
    );
  }
}
