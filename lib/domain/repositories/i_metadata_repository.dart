import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

abstract interface class IMetadataRepository {
  Future<MetadataResult> lookupBarcode(
    String barcode, {
    MediaType? typeHint,
  });
}
