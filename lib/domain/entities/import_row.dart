import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mymediascanner/domain/entities/import_source.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

part 'import_row.freezed.dart';

/// Status of enrichment for a single import row.
enum ImportRowStatus {
  /// Parsed but not yet looked up.
  pending,

  /// Metadata successfully fetched.
  enriched,

  /// Enrichment returned nothing; row still has raw fields only.
  notFound,

  /// Barcode/ISBN already exists in the collection.
  duplicate,

  /// Lookup threw an error.
  error,
}

/// A single row parsed from an import source, optionally enriched with
/// metadata and marked for inclusion in the bulk save.
@freezed
sealed class ImportRow with _$ImportRow {
  const factory ImportRow({
    required String sourceRowId,
    required ImportSource source,
    required MediaType mediaType,
    String? rawTitle,
    String? rawAuthor,
    int? rawYear,
    String? isbn,
    String? imdbId,
    String? discogsCatalog,
    @Default({}) Map<String, String> rawFields,
    @Default(ImportRowStatus.pending) ImportRowStatus status,
    MetadataResult? enriched,
    String? errorMessage,
    @Default(true) bool accepted,
  }) = _ImportRow;
}
