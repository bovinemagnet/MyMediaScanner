import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/remote/api/gnudb/gnudb_api.dart';
import 'package:mymediascanner/data/remote/api/gnudb/gnudb_response_parser.dart';

class _MockDio extends Mock implements Dio {}

Response<String> _textResponse(String body) => Response<String>(
      requestOptions: RequestOptions(path: '/~cddb/cddb.cgi'),
      data: body,
      statusCode: 200,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  group('GnudbApi.query', () {
    late _MockDio dio;
    late GnudbApi api;

    setUp(() {
      dio = _MockDio();
      api = GnudbApi(
        dio: dio,
        user: 'paul',
        host: 'localhost',
      );
    });

    test('sends hello, proto=6 and correctly-formatted cmd', () async {
      when(() => dio.get<String>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _textResponse('202 No match found\n'));

      await api.query(
        discId: '08025603',
        frameOffsets: const [150, 15000, 30000],
        totalSeconds: 600,
      );

      final captured = verify(() => dio.get<String>(
            captureAny(),
            queryParameters: captureAny(named: 'queryParameters'),
          )).captured;
      final path = captured[0] as String;
      final params = captured[1] as Map<String, dynamic>;

      expect(path, '/~cddb/cddb.cgi');
      expect(params['hello'],
          'paul localhost MyMediaScanner 1.0');
      expect(params['proto'], '6');
      expect(params['cmd'],
          'cddb query 08025603 3 150 15000 30000 600');
    });

    test('returns parsed no-match when server replies 202', () async {
      when(() => dio.get<String>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _textResponse('202 No match found\n'));

      final result = await api.query(
        discId: 'deadbeef',
        frameOffsets: const [150],
        totalSeconds: 60,
      );

      expect(result, isA<GnudbQueryNoMatch>());
    });

    test('returns parsed single-match for 200', () async {
      when(() => dio.get<String>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _textResponse(
          '200 rock 08025603 Example Artist / Example Album\n'));

      final result = await api.query(
        discId: '08025603',
        frameOffsets: const [150],
        totalSeconds: 60,
      );

      expect(result, isA<GnudbQuerySingle>());
      final single = result as GnudbQuerySingle;
      expect(single.match.category, 'rock');
      expect(single.match.discId, '08025603');
    });
  });

  group('GnudbApi.read', () {
    late _MockDio dio;
    late GnudbApi api;

    setUp(() {
      dio = _MockDio();
      api = GnudbApi(dio: dio, user: 'paul', host: 'localhost');
    });

    test('issues a cddb read command with category and discid', () async {
      when(() => dio.get<String>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _textResponse(
          '210 rock 08025603 CD database entry follows (until terminating `.\')\n'
          'DISCID=08025603\n'
          'DTITLE=Artist / Album\n'
          'TTITLE0=One\n'
          'TTITLE1=Two\n'
          '.\n'));

      final dto = await api.read(category: 'rock', discId: '08025603');

      expect(dto, isNotNull);
      expect(dto!.artist, 'Artist');
      expect(dto.albumTitle, 'Album');
      expect(dto.trackTitles, ['One', 'Two']);

      final captured = verify(() => dio.get<String>(
            any(),
            queryParameters: captureAny(named: 'queryParameters'),
          )).captured;
      final params = captured.first as Map<String, dynamic>;
      expect(params['cmd'], 'cddb read rock 08025603');
      expect(params['proto'], '6');
    });

    test('returns null when server returns an error body', () async {
      when(() => dio.get<String>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _textResponse('401 Not authorised\n'));

      final dto = await api.read(category: 'rock', discId: '08025603');
      expect(dto, isNull);
    });
  });
}
