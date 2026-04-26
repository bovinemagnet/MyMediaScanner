import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/remote/api/igdb/igdb_token_manager.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _tokenResponse({
  String token = 'abc123',
  int? expiresIn = 5000000,
}) =>
    Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/oauth2/token'),
      data: {
        'access_token': token,
        'expires_in': expiresIn,
        'token_type': 'bearer',
      },
      statusCode: 200,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(Options());
  });

  late _MockDio dio;
  late IgdbTokenManager manager;

  setUp(() {
    dio = _MockDio();
    manager = IgdbTokenManager(
      clientId: 'cid',
      clientSecret: 'secret',
      authDio: dio,
    );
  });

  test(
    'exchanges Client ID + Secret for a bearer token (credentials in body, not query string)',
    () async {
      when(() => dio.post<Map<String, dynamic>>(
            '/oauth2/token',
            data: any<Map<String, dynamic>>(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _tokenResponse(token: 'fresh-token'));

      final token = await manager.getToken();

      expect(token, 'fresh-token');
      final invocation = verify(() => dio.post<Map<String, dynamic>>(
            '/oauth2/token',
            data: captureAny<Map<String, dynamic>>(named: 'data'),
            options: captureAny(named: 'options'),
          )).captured;

      final body = invocation[0] as Map<String, dynamic>;
      expect(body['client_id'], 'cid');
      expect(body['client_secret'], 'secret');
      expect(body['grant_type'], 'client_credentials');

      // Secret must travel in the body so it never reaches Twitch's
      // edge proxies as part of the URL line.
      final options = invocation[1] as Options;
      expect(options.contentType, Headers.formUrlEncodedContentType);
    },
  );

  test('caches the token so subsequent calls skip the exchange', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/oauth2/token',
          data: any<Map<String, dynamic>>(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => _tokenResponse(token: 'once-only'));

    await manager.getToken();
    await manager.getToken();

    verify(() => dio.post<Map<String, dynamic>>(
          '/oauth2/token',
          data: any<Map<String, dynamic>>(named: 'data'),
          options: any(named: 'options'),
        )).called(1);
  });

  test('invalidate() forces a new exchange on the next call', () async {
    var call = 0;
    when(() => dio.post<Map<String, dynamic>>(
          '/oauth2/token',
          data: any<Map<String, dynamic>>(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async {
      call += 1;
      return _tokenResponse(token: 'token-$call');
    });

    final first = await manager.getToken();
    manager.invalidate();
    final second = await manager.getToken();

    expect(first, 'token-1');
    expect(second, 'token-2');
  });

  test('throws when Twitch returns no access_token', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/oauth2/token',
          data: any<Map<String, dynamic>>(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/oauth2/token'),
          data: const {},
          statusCode: 200,
        ));

    await expectLater(manager.getToken(), throwsA(isA<Exception>()));
  });

  test('de-duplicates concurrent getToken() calls', () async {
    var calls = 0;
    when(() => dio.post<Map<String, dynamic>>(
          '/oauth2/token',
          data: any<Map<String, dynamic>>(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async {
      calls += 1;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return _tokenResponse(token: 'shared');
    });

    final results = await Future.wait([
      manager.getToken(),
      manager.getToken(),
      manager.getToken(),
    ]);

    expect(results, ['shared', 'shared', 'shared']);
    expect(calls, 1);
  });
}
