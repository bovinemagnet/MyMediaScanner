import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/remote/api/gnudb/gnudb_response_parser.dart';
import 'package:mymediascanner/data/remote/api/gnudb/models/gnudb_disc_dto.dart';

Future<String> _loadFixture(String name) =>
    File('test/fixtures/gnudb/$name').readAsString();

void main() {
  group('GnudbResponseParser.parseQuery', () {
    test('200 returns a single match', () async {
      final body = await _loadFixture('query_200_single.txt');
      final result = GnudbResponseParser.parseQuery(body);

      expect(result, isA<GnudbQuerySingle>());
      final single = result as GnudbQuerySingle;
      expect(single.match.category, 'rock');
      expect(single.match.discId, '08025603');
      expect(single.match.title, 'Example Artist / Example Album');
    });

    test('210 returns multiple matches terminated by dot', () async {
      final body = await _loadFixture('query_210_multi.txt');
      final result = GnudbResponseParser.parseQuery(body);

      expect(result, isA<GnudbQueryMulti>());
      final multi = result as GnudbQueryMulti;
      expect(multi.matches, hasLength(3));
      expect(multi.matches[0].category, 'rock');
      expect(multi.matches[0].discId, '08025603');
      expect(multi.matches[0].title, 'Example Artist / Example Album');
      expect(multi.matches[1].category, 'pop');
      expect(multi.matches[1].discId, 'a0b1c2d3');
      expect(multi.matches[2].category, 'jazz');
      expect(multi.matches[2].discId, 'feedface');
    });

    test('211 is handled as multi (inexact matches)', () {
      const body = '''
211 Close matches, list follows (until terminating `.')
rock 11111111 Foo / Bar
pop  22222222 Baz / Qux
.
''';
      final result = GnudbResponseParser.parseQuery(body);
      expect(result, isA<GnudbQueryMulti>());
      expect((result as GnudbQueryMulti).matches, hasLength(2));
    });

    test('202 returns no-match', () async {
      final body = await _loadFixture('query_202_nomatch.txt');
      final result = GnudbResponseParser.parseQuery(body);
      expect(result, isA<GnudbQueryNoMatch>());
    });

    test('5xx returns error with status code and message', () {
      const body = '500 Internal server error';
      final result = GnudbResponseParser.parseQuery(body);
      expect(result, isA<GnudbQueryError>());
      final err = result as GnudbQueryError;
      expect(err.code, 500);
      expect(err.message, contains('Internal server error'));
    });

    test('empty body produces an error', () {
      final result = GnudbResponseParser.parseQuery('');
      expect(result, isA<GnudbQueryError>());
    });
  });

  group('GnudbResponseParser.parseDisc', () {
    test('parses DTITLE, DYEAR, DGENRE, and numbered TTITLEs', () async {
      final body = await _loadFixture('read_disc_full.txt');
      final dto = GnudbResponseParser.parseDisc(body);

      expect(dto, isA<GnudbDiscDto>());
      expect(dto!.discId, '08025603');
      expect(dto.artist, 'Example Artist');
      expect(dto.albumTitle, 'Example Album');
      expect(dto.year, 2023);
      expect(dto.genre, 'Rock');
      // TTITLE1 appears twice and should be joined, per CDDB spec.
      expect(dto.trackTitles, [
        'First Song',
        'Second Song with a much longer title that wraps  across two lines',
        'Third Song',
      ]);
    });

    test('returns null for non-2xx status', () {
      const body = '401 Not authorised';
      final dto = GnudbResponseParser.parseDisc(body);
      expect(dto, isNull);
    });

    test('handles DTITLE with no slash (artist == album)', () {
      const body = '''
210 rock 12345678 CD database entry follows (until terminating `.')
DISCID=12345678
DTITLE=Various Artists Compilation
DYEAR=
DGENRE=
TTITLE0=One
.
''';
      final dto = GnudbResponseParser.parseDisc(body)!;
      expect(dto.artist, 'Various Artists Compilation');
      expect(dto.albumTitle, 'Various Artists Compilation');
      expect(dto.year, isNull);
      expect(dto.genre, isNull);
      expect(dto.trackTitles, ['One']);
    });

    test('is tolerant to unexpected keys and blank lines', () {
      const body = '''
210 misc abcdef01 CD database entry follows (until terminating `.')
# comment
DISCID=abcdef01
DTITLE=A / B

TTITLE0=Track A
UNKNOWN_KEY=whatever
TTITLE1=Track B
.
''';
      final dto = GnudbResponseParser.parseDisc(body)!;
      expect(dto.trackTitles, ['Track A', 'Track B']);
    });

    test('returns discId from status line when DISCID= absent', () {
      const body = '''
210 rock deadbeef CD database entry follows (until terminating `.')
DTITLE=Foo / Bar
TTITLE0=One
.
''';
      final dto = GnudbResponseParser.parseDisc(body)!;
      expect(dto.discId, 'deadbeef');
    });
  });
}
