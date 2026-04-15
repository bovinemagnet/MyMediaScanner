import 'package:csv/csv.dart';
import 'package:mymediascanner/data/importers/import_parser.dart';
import 'package:mymediascanner/domain/entities/import_row.dart';
import 'package:mymediascanner/domain/entities/import_source.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

/// Parser for the Goodreads library export CSV.
///
/// Goodreads exports ISBN / ISBN13 fields as Excel-safe formulas
/// (`="9780441172719"`) to stop spreadsheets interpreting them as numbers.
/// This parser strips the `="..."` wrapper.
class GoodreadsCsvParser implements ImportParser {
  const GoodreadsCsvParser();

  static const _converter = CsvToListConverter(
    shouldParseNumbers: false,
    eol: '\n',
  );

  @override
  List<ImportRow> parse(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return const [];

    final table = _converter.convert(trimmed);
    if (table.length < 2) return const [];

    final header = table.first.map((c) => c.toString()).toList();
    final idx = <String, int>{
      for (var i = 0; i < header.length; i++) header[i]: i,
    };

    final bookIdCol = idx['Book Id'];
    final titleCol = idx['Title'];
    final authorCol = idx['Author'];
    final isbnCol = idx['ISBN'];
    final isbn13Col = idx['ISBN13'];
    final origYearCol = idx['Original Publication Year'];
    final yearCol = idx['Year Published'];
    final publisherCol = idx['Publisher'];

    final rows = <ImportRow>[];
    for (var i = 1; i < table.length; i++) {
      final record = table[i];
      String? cell(int? col) {
        if (col == null || col >= record.length) return null;
        final v = record[col].toString().trim();
        return v.isEmpty ? null : v;
      }

      final rawIsbn13 = _stripExcelSafe(cell(isbn13Col));
      final rawIsbn = _stripExcelSafe(cell(isbnCol));
      final isbn = rawIsbn13 ?? rawIsbn;
      final title = cell(titleCol);
      if (title == null) continue;

      rows.add(ImportRow(
        sourceRowId: cell(bookIdCol) ?? 'goodreads-$i',
        source: ImportSource.goodreads,
        mediaType: MediaType.book,
        rawTitle: title,
        rawAuthor: cell(authorCol),
        rawYear: _parseYear(cell(origYearCol) ?? cell(yearCol)),
        isbn: isbn,
        rawFields: {
          if (cell(publisherCol) case final p?) 'publisher': p,
        },
      ));
    }
    return rows;
  }

  static String? _stripExcelSafe(String? value) {
    if (value == null) return null;
    // Matches ="..." (Excel-safe text literal).
    final match = RegExp(r'^="?(.*?)"?$').firstMatch(value);
    final stripped = match != null ? match.group(1)! : value;
    return stripped.isEmpty ? null : stripped;
  }

  static int? _parseYear(String? value) {
    if (value == null) return null;
    final n = int.tryParse(value);
    return (n != null && n > 0) ? n : null;
  }
}
