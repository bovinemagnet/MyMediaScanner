import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/importers/letterboxd_csv_parser.dart';
import 'package:mymediascanner/domain/entities/import_source.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

void main() {
  group('LetterboxdCsvParser', () {
    late String fixture;

    setUpAll(() {
      fixture = File('test/fixtures/imports/letterboxd_sample.csv')
          .readAsStringSync();
    });

    test('parses three rows', () {
      expect(const LetterboxdCsvParser().parse(fixture), hasLength(3));
    });

    test('extracts name and year', () {
      final rows = const LetterboxdCsvParser().parse(fixture);
      expect(rows[0].rawTitle, 'Dune');
      expect(rows[0].rawYear, 2021);
      expect(rows[1].rawTitle, 'Blade Runner 2049');
      expect(rows[2].rawTitle, 'Parasite');
    });

    test('stores Letterboxd URI in rawFields', () {
      final rows = const LetterboxdCsvParser().parse(fixture);
      expect(rows[0].rawFields['letterboxd_uri'],
          'https://letterboxd.com/film/dune-2021/');
    });

    test('all rows are film media type from letterboxd', () {
      final rows = const LetterboxdCsvParser().parse(fixture);
      for (final row in rows) {
        expect(row.source, ImportSource.letterboxd);
        expect(row.mediaType, MediaType.film);
      }
    });

    test('empty content returns empty list', () {
      expect(const LetterboxdCsvParser().parse(''), isEmpty);
    });
  });
}
