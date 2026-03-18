import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/remote/api/tvdb/tvdb_token_manager.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late TvdbTokenManager manager;

  setUp(() {
    mockDio = MockDio();
    manager = TvdbTokenManager(apiKey: 'test-key', loginDio: mockDio);
  });

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  Response<Map<String, dynamic>> _loginResponse(String token) {
    return Response(
      requestOptions: RequestOptions(path: '/login'),
      data: {
        'status': 'success',
        'data': {'token': token},
      },
    );
  }

  group('TvdbTokenManager', () {
    test('first getToken call triggers login', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/login',
            data: any(named: 'data'),
          )).thenAnswer((_) async => _loginResponse('jwt-token-1'));

      final token = await manager.getToken();

      expect(token, 'jwt-token-1');
      verify(() => mockDio.post<Map<String, dynamic>>(
            '/login',
            data: any(named: 'data'),
          )).called(1);
    });

    test('subsequent calls return cached token without login', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/login',
            data: any(named: 'data'),
          )).thenAnswer((_) async => _loginResponse('jwt-token-2'));

      await manager.getToken();
      final token2 = await manager.getToken();
      final token3 = await manager.getToken();

      expect(token2, 'jwt-token-2');
      expect(token3, 'jwt-token-2');
      // Login should only be called once
      verify(() => mockDio.post<Map<String, dynamic>>(
            '/login',
            data: any(named: 'data'),
          )).called(1);
    });

    test('throws when login returns null token', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/login',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/login'),
            data: {'status': 'success', 'data': {'token': null}},
          ));

      expect(() => manager.getToken(), throwsException);
    });

    test('throws when login returns empty token', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/login',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/login'),
            data: {'status': 'success', 'data': {'token': ''}},
          ));

      expect(() => manager.getToken(), throwsException);
    });

    test('throws when login response has no data field', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/login',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/login'),
            data: {'status': 'failure'},
          ));

      expect(() => manager.getToken(), throwsException);
    });

    test('invalidate forces re-login on next call', () async {
      var callCount = 0;
      when(() => mockDio.post<Map<String, dynamic>>(
            '/login',
            data: any(named: 'data'),
          )).thenAnswer((_) async {
        callCount++;
        return _loginResponse('token-$callCount');
      });

      final token1 = await manager.getToken();
      expect(token1, 'token-1');

      manager.invalidate();

      final token2 = await manager.getToken();
      expect(token2, 'token-2');
      expect(callCount, 2);
    });

    test('rethrows DioException on login failure', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/login',
            data: any(named: 'data'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/login'),
        type: DioExceptionType.connectionTimeout,
      ));

      expect(() => manager.getToken(), throwsA(isA<DioException>()));
    });
  });
}
