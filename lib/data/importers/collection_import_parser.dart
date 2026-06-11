import 'package:mymediascanner/data/importers/discogs_csv_parser.dart';
import 'package:mymediascanner/data/importers/goodreads_csv_parser.dart';
import 'package:mymediascanner/data/importers/import_parser.dart';
import 'package:mymediascanner/data/importers/letterboxd_csv_parser.dart';
import 'package:mymediascanner/data/importers/trakt_json_parser.dart';
import 'package:mymediascanner/domain/entities/import_row.dart';
import 'package:mymediascanner/domain/entities/import_source.dart';
import 'package:mymediascanner/domain/repositories/i_collection_import_parser.dart';

/// Routes an [ImportSource] to its format-specific [ImportParser].
class CollectionImportParser implements ICollectionImportParser {
  const CollectionImportParser();

  /// Pick the parser that matches [source]. Exposed for testability.
  static ImportParser parserFor(ImportSource source) => switch (source) {
        ImportSource.goodreads => const GoodreadsCsvParser(),
        ImportSource.discogs => const DiscogsCsvParser(),
        ImportSource.letterboxd => const LetterboxdCsvParser(),
        ImportSource.trakt => const TraktJsonParser(),
      };

  @override
  List<ImportRow> parse(ImportSource source, String content) {
    return parserFor(source).parse(content);
  }
}
