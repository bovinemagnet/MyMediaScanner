import 'package:mymediascanner/domain/entities/import_row.dart';

/// Parses an export file from an external service into [ImportRow]s.
///
/// Implementations are pure (no I/O, no enrichment) — they only transform
/// the raw file contents into structured rows. Enrichment happens later in
/// the use-case layer.
abstract interface class ImportParser {
  /// Parse [content] (the full file as a string) into rows.
  List<ImportRow> parse(String content);
}
