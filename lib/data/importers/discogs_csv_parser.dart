import 'package:csv/csv.dart';
import 'package:mymediascanner/data/importers/import_parser.dart';
import 'package:mymediascanner/domain/entities/import_row.dart';
import 'package:mymediascanner/domain/entities/import_source.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

/// Parser for Discogs collection CSV export.
///
/// The `release_id` column is the authoritative Discogs release identifier
/// and is stored in `rawFields['discogs_release_id']` for direct API lookup.
class DiscogsCsvParser implements ImportParser {
  const DiscogsCsvParser();

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

    final catalogCol = idx['Catalog#'];
    final artistCol = idx['Artist'];
    final titleCol = idx['Title'];
    final labelCol = idx['Label'];
    final formatCol = idx['Format'];
    final yearCol = idx['Released'];
    final releaseIdCol = idx['release_id'];

    final rows = <ImportRow>[];
    for (var i = 1; i < table.length; i++) {
      final record = table[i];
      String? cell(int? col) {
        if (col == null || col >= record.length) return null;
        final v = record[col].toString().trim();
        return v.isEmpty ? null : v;
      }

      final title = cell(titleCol);
      if (title == null) continue;

      final releaseId = cell(releaseIdCol);
      final catalog = cell(catalogCol);

      final label = cell(labelCol);
      final format = cell(formatCol);
      final fields = <String, String>{};
      if (releaseId != null) fields['discogs_release_id'] = releaseId;
      if (label != null) fields['label'] = label;
      if (format != null) fields['format'] = format;
      rows.add(ImportRow(
        sourceRowId: releaseId ?? 'discogs-$i',
        source: ImportSource.discogs,
        mediaType: MediaType.music,
        rawTitle: title,
        rawAuthor: cell(artistCol),
        rawYear: int.tryParse(cell(yearCol) ?? ''),
        discogsCatalog: catalog,
        rawFields: fields,
      ));
    }
    return rows;
  }
}
