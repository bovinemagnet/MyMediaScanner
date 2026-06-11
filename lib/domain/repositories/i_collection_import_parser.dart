import 'package:mymediascanner/domain/entities/import_row.dart';
import 'package:mymediascanner/domain/entities/import_source.dart';

/// Parses an export file from an external service into [ImportRow]s,
/// routing to the format-specific parser for [ImportSource].
///
/// Implementations are pure (no I/O, no enrichment) — they only transform
/// the raw file contents into structured rows. Enrichment happens later in
/// the use-case layer.
abstract interface class ICollectionImportParser {
  /// Parse [content] (the full file as a string) into rows using the
  /// parser that matches [source].
  List<ImportRow> parse(ImportSource source, String content);
}
