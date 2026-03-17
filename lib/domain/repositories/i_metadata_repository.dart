import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';

abstract interface class IMetadataRepository {
  Future<ScanResult> lookupBarcode(
    String barcode, {
    MediaType? typeHint,
    bool forceIsbn = false,
  });

  /// Fetch full metadata for a previously returned candidate.
  Future<MetadataResult?> fetchCandidateDetail(
    MetadataCandidate candidate,
    String barcode,
    String barcodeType,
  );
}
