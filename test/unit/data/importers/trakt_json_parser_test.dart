import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/importers/trakt_json_parser.dart';
import 'package:mymediascanner/domain/entities/import_source.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

void main() {
  group('TraktJsonParser', () {
    late String fixture;

    setUpAll(() {
      fixture =
          File('test/fixtures/imports/trakt_sample.json').readAsStringSync();
    });

    test('parses three rows', () {
      expect(const TraktJsonParser().parse(fixture), hasLength(3));
    });

    test('extracts movie title, year and IMDb ID', () {
      final rows = const TraktJsonParser().parse(fixture);
      expect(rows[0].rawTitle, 'Dune');
      expect(rows[0].rawYear, 2021);
      expect(rows[0].imdbId, 'tt1160419');
      expect(rows[0].mediaType, MediaType.film);
    });

    test('distinguishes show from movie', () {
      final rows = const TraktJsonParser().parse(fixture);
      expect(rows[1].rawTitle, 'Severance');
      expect(rows[1].mediaType, MediaType.tv);
      expect(rows[1].imdbId, 'tt11280740');
    });

    test('rows without imdb id have imdbId null', () {
      final rows = const TraktJsonParser().parse(fixture);
      expect(rows[2].imdbId, isNull);
      expect(rows[2].rawTitle, 'Unknown Film');
    });

    test('sourceRowId uses trakt id', () {
      final rows = const TraktJsonParser().parse(fixture);
      expect(rows[0].sourceRowId, 'trakt-123');
      expect(rows[1].sourceRowId, 'trakt-456');
    });

    test('tmdb id stored in rawFields', () {
      final rows = const TraktJsonParser().parse(fixture);
      expect(rows[0].rawFields['tmdb_id'], '438631');
    });

    test('all rows have trakt source', () {
      final rows = const TraktJsonParser().parse(fixture);
      for (final row in rows) {
        expect(row.source, ImportSource.trakt);
      }
    });

    test('empty content returns empty list', () {
      expect(const TraktJsonParser().parse(''), isEmpty);
      expect(const TraktJsonParser().parse('[]'), isEmpty);
    });

    test('malformed json throws FormatException', () {
      expect(() => const TraktJsonParser().parse('{not json}'),
          throwsA(isA<FormatException>()));
    });
  });
}
