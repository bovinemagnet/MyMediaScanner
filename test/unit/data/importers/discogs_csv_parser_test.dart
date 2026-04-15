import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/importers/discogs_csv_parser.dart';
import 'package:mymediascanner/domain/entities/import_source.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

void main() {
  group('DiscogsCsvParser', () {
    late String fixture;

    setUpAll(() {
      fixture =
          File('test/fixtures/imports/discogs_sample.csv').readAsStringSync();
    });

    test('parses three rows', () {
      final rows = const DiscogsCsvParser().parse(fixture);
      expect(rows, hasLength(3));
    });

    test('extracts catalog number, artist, title, year', () {
      final rows = const DiscogsCsvParser().parse(fixture);
      expect(rows[0].discogsCatalog, 'ABC123');
      expect(rows[0].rawAuthor, 'Pink Floyd');
      expect(rows[0].rawTitle, 'The Dark Side of the Moon');
      expect(rows[0].rawYear, 1973);
    });

    test('empty catalog number stored as null', () {
      final rows = const DiscogsCsvParser().parse(fixture);
      expect(rows[2].discogsCatalog, isNull);
    });

    test('sourceRowId uses release_id when present', () {
      final rows = const DiscogsCsvParser().parse(fixture);
      expect(rows[0].sourceRowId, '12345');
      expect(rows[1].sourceRowId, '67890');
    });

    test('release_id stored in rawFields for direct lookup', () {
      final rows = const DiscogsCsvParser().parse(fixture);
      expect(rows[0].rawFields['discogs_release_id'], '12345');
    });

    test('all rows are music media type from discogs source', () {
      final rows = const DiscogsCsvParser().parse(fixture);
      for (final row in rows) {
        expect(row.source, ImportSource.discogs);
        expect(row.mediaType, MediaType.music);
      }
    });

    test('empty content returns empty list', () {
      expect(const DiscogsCsvParser().parse(''), isEmpty);
    });
  });
}
