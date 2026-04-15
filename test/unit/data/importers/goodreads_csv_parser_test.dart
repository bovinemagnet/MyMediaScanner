import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/importers/goodreads_csv_parser.dart';
import 'package:mymediascanner/domain/entities/import_source.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

void main() {
  group('GoodreadsCsvParser', () {
    late String fixture;

    setUpAll(() {
      fixture = File('test/fixtures/imports/goodreads_sample.csv')
          .readAsStringSync();
    });

    test('parses three rows', () {
      final rows = const GoodreadsCsvParser().parse(fixture);
      expect(rows, hasLength(3));
    });

    test('extracts ISBN13 and strips Excel-safe quoting', () {
      final rows = const GoodreadsCsvParser().parse(fixture);
      expect(rows[0].isbn, '9780441172719');
      expect(rows[1].isbn, '9780553293357');
    });

    test('row without ISBN13 falls back to ISBN', () {
      const csv =
          'Book Id,Title,Author,ISBN,ISBN13\n'
          '9,"Old Book","Author A",="0441172717",=""\n';
      final rows = const GoodreadsCsvParser().parse(csv);
      expect(rows, hasLength(1));
      expect(rows.first.isbn, '0441172717');
    });

    test('row with neither ISBN keeps isbn null', () {
      final rows = const GoodreadsCsvParser().parse(fixture);
      expect(rows[2].isbn, isNull);
      expect(rows[2].rawTitle, 'A Book Without ISBN');
    });

    test('every row has book media type and goodreads source', () {
      final rows = const GoodreadsCsvParser().parse(fixture);
      for (final row in rows) {
        expect(row.source, ImportSource.goodreads);
        expect(row.mediaType, MediaType.book);
      }
    });

    test('raw title, author, year populated', () {
      final rows = const GoodreadsCsvParser().parse(fixture);
      expect(rows[0].rawTitle, 'Dune');
      expect(rows[0].rawAuthor, 'Frank Herbert');
      expect(rows[0].rawYear, 1965);
    });

    test('empty content returns empty list', () {
      expect(const GoodreadsCsvParser().parse(''), isEmpty);
    });

    test('header only returns empty list', () {
      const csv = 'Book Id,Title,Author,ISBN,ISBN13\n';
      expect(const GoodreadsCsvParser().parse(csv), isEmpty);
    });

    test('sourceRowId uses Book Id when present', () {
      final rows = const GoodreadsCsvParser().parse(fixture);
      expect(rows[0].sourceRowId, '1');
      expect(rows[1].sourceRowId, '2');
    });
  });
}
