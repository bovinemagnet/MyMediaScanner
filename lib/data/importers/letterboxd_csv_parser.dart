import 'package:csv/csv.dart';
import 'package:mymediascanner/data/importers/import_parser.dart';
import 'package:mymediascanner/domain/entities/import_row.dart';
import 'package:mymediascanner/domain/entities/import_source.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

/// Parser for the Letterboxd watched/diary CSV export.
///
/// Columns: `Date,Name,Year,Letterboxd URI`. The URI does not contain the
/// IMDb ID; enrichment must search TMDB by title+year.
class LetterboxdCsvParser implements ImportParser {
  const LetterboxdCsvParser();

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

    final nameCol = idx['Name'];
    final yearCol = idx['Year'];
    final uriCol = idx['Letterboxd URI'];
    final dateCol = idx['Date'];

    final rows = <ImportRow>[];
    for (var i = 1; i < table.length; i++) {
      final record = table[i];
      String? cell(int? col) {
        if (col == null || col >= record.length) return null;
        final v = record[col].toString().trim();
        return v.isEmpty ? null : v;
      }

      final name = cell(nameCol);
      if (name == null) continue;

      final uri = cell(uriCol);
      final date = cell(dateCol);
      final fields = <String, String>{};
      if (uri != null) fields['letterboxd_uri'] = uri;
      if (date != null) fields['watched_date'] = date;
      rows.add(ImportRow(
        sourceRowId: uri ?? 'letterboxd-$i',
        source: ImportSource.letterboxd,
        mediaType: MediaType.film,
        rawTitle: name,
        rawYear: int.tryParse(cell(yearCol) ?? ''),
        rawFields: fields,
      ));
    }
    return rows;
  }
}
