import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/remote/api/igdb/igdb_api.dart';
import 'package:mymediascanner/data/remote/api/igdb/igdb_token_manager.dart';

class _MockDio extends Mock implements Dio {}

class _MockTokenManager extends Mock implements IgdbTokenManager {}

Response<List<dynamic>> _gamesResponse(List<Map<String, dynamic>> games) =>
    Response<List<dynamic>>(
      requestOptions: RequestOptions(path: '/games'),
      data: games,
      statusCode: 200,
    );

DioException _unauthorized() => DioException(
      requestOptions: RequestOptions(path: '/games'),
      response: Response(
        requestOptions: RequestOptions(path: '/games'),
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(Options());
  });

  late _MockDio dio;
  late _MockTokenManager tokens;
  late IgdbApi api;

  setUp(() {
    dio = _MockDio();
    tokens = _MockTokenManager();
    when(() => tokens.clientId).thenReturn('cid');
    when(() => tokens.getToken()).thenAnswer((_) async => 'tkn');
    api = IgdbApi(tokenManager: tokens, dio: dio);
  });

  test('sends Client-ID and Bearer headers with Apicalypse body', () async {
    when(() => dio.post<List<dynamic>>(
          '/games',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => _gamesResponse([
          {'id': 1, 'name': 'Game'},
        ]));

    final results = await api.searchByTitle('Halo');

    expect(results, hasLength(1));
    expect(results.first.id, 1);
    expect(results.first.name, 'Game');

    final captured = verify(() => dio.post<List<dynamic>>(
          '/games',
          data: captureAny(named: 'data'),
          options: captureAny(named: 'options'),
        )).captured;
    final body = captured[0] as String;
    final options = captured[1] as Options;
    expect(body, contains('search "Halo"'));
    expect(body, contains('limit 10;'));
    expect(body, contains('fields'));
    expect(options.headers?['Client-ID'], 'cid');
    expect(options.headers?['Authorization'], 'Bearer tkn');
  });

  test('escapes embedded double-quotes so the Apicalypse body stays valid',
      () async {
    when(() => dio.post<List<dynamic>>(
          '/games',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => _gamesResponse(const []));

    await api.searchByTitle('say "hi"');

    final body = verify(() => dio.post<List<dynamic>>(
          '/games',
          data: captureAny(named: 'data'),
          options: any(named: 'options'),
        )).captured.single as String;
    expect(body, contains(r'search "say \"hi\""'));
  });

  test('uses where clause for getById', () async {
    when(() => dio.post<List<dynamic>>(
          '/games',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => _gamesResponse([
          {'id': 42, 'name': 'Found'},
        ]));

    final game = await api.getById(42);

    expect(game?.id, 42);
    final body = verify(() => dio.post<List<dynamic>>(
          '/games',
          data: captureAny(named: 'data'),
          options: any(named: 'options'),
        )).captured.single as String;
    expect(body, contains('where id = 42'));
    expect(body, isNot(contains('search')));
  });

  test('returns null from getById when the result list is empty', () async {
    when(() => dio.post<List<dynamic>>(
          '/games',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => _gamesResponse(const []));

    final game = await api.getById(1);

    expect(game, isNull);
  });

  test('retries once after a 401, invalidating the cached token', () async {
    var calls = 0;
    when(() => dio.post<List<dynamic>>(
          '/games',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async {
      calls += 1;
      if (calls == 1) throw _unauthorized();
      return _gamesResponse([
        {'id': 5, 'name': 'Retry'},
      ]);
    });

    final results = await api.searchByTitle('anything');

    expect(results.single.name, 'Retry');
    expect(calls, 2);
    verify(() => tokens.invalidate()).called(1);
  });

  test('bubbles up non-401 errors without retrying', () async {
    final boom = DioException(
      requestOptions: RequestOptions(path: '/games'),
      response: Response(
        requestOptions: RequestOptions(path: '/games'),
        statusCode: 500,
      ),
      type: DioExceptionType.badResponse,
    );
    when(() => dio.post<List<dynamic>>(
          '/games',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenThrow(boom);

    await expectLater(
      api.searchByTitle('x'),
      throwsA(isA<DioException>()),
    );
    verifyNever(() => tokens.invalidate());
  });
}
