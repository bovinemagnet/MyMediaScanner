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

  /// Search for metadata by title when barcode lookup fails.
  ///
  /// Routes to the appropriate API based on [typeHint]:
  /// film/TV → TMDB, music → MusicBrainz/Discogs, book → Google Books.
  Future<ScanResult> searchByTitle(
    String title,
    String barcode,
    String barcodeType, {
    MediaType? typeHint,
  });
}
