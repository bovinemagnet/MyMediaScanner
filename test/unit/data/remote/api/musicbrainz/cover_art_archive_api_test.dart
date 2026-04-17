import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/core/utils/rate_limit_aware_client.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/cover_art_archive_api.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _jsonResponse(
  String path,
  Map<String, dynamic> body,
) =>
    Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: path),
      data: body,
      statusCode: 200,
    );

DioException _notFound(String path) => DioException(
      requestOptions: RequestOptions(path: path),
      response: Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 404,
      ),
      type: DioExceptionType.badResponse,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  late _MockDio dio;
  late CoverArtArchiveApi api;

  setUp(() {
    dio = _MockDio();
    api = CoverArtArchiveApi(
      dio,
      RateLimitAwareClient(minInterval: const Duration(milliseconds: 1)),
    );
  });

  test('returns large thumbnail when the release has a front image',
      () async {
    when(() => dio.get<Map<String, dynamic>>('/release/rel-1'))
        .thenAnswer((_) async => _jsonResponse('/release/rel-1', {
              'images': [
                {
                  'front': true,
                  'image': 'https://example.com/full.jpg',
                  'thumbnails': {
                    'large': 'https://example.com/large.jpg',
                  },
                }
              ],
            }));

    final url = await api.findFrontArtwork(
      releaseId: 'rel-1',
      releaseGroupId: 'rg-1',
    );

    expect(url, 'https://example.com/large.jpg');
  });

  test('falls back to release group when release returns 404', () async {
    when(() => dio.get<Map<String, dynamic>>('/release/rel-1'))
        .thenThrow(_notFound('/release/rel-1'));
    when(() => dio.get<Map<String, dynamic>>('/release-group/rg-1'))
        .thenAnswer(
            (_) async => _jsonResponse('/release-group/rg-1', {
                  'images': [
                    {
                      'front': true,
                      'image': 'https://example.com/rg-full.jpg',
                      'thumbnails': {
                        'large': 'https://example.com/rg-large.jpg',
                      },
                    }
                  ],
                }));

    final url = await api.findFrontArtwork(
      releaseId: 'rel-1',
      releaseGroupId: 'rg-1',
    );

    expect(url, 'https://example.com/rg-large.jpg');
  });

  test('returns null when both release and release group return 404',
      () async {
    when(() => dio.get<Map<String, dynamic>>('/release/rel-1'))
        .thenThrow(_notFound('/release/rel-1'));
    when(() => dio.get<Map<String, dynamic>>('/release-group/rg-1'))
        .thenThrow(_notFound('/release-group/rg-1'));

    final url = await api.findFrontArtwork(
      releaseId: 'rel-1',
      releaseGroupId: 'rg-1',
    );

    expect(url, isNull);
  });

  test('uses size250 thumbnail when large is missing', () async {
    when(() => dio.get<Map<String, dynamic>>('/release/rel-1'))
        .thenAnswer((_) async => _jsonResponse('/release/rel-1', {
              'images': [
                {
                  'front': true,
                  'image': 'https://example.com/full.jpg',
                  'thumbnails': {
                    '250': 'https://example.com/250.jpg',
                  },
                }
              ],
            }));

    final url = await api.findFrontArtwork(
      releaseId: 'rel-1',
      releaseGroupId: 'rg-1',
    );

    expect(url, 'https://example.com/250.jpg');
  });

  test('falls back to full-size image when no thumbnails are present',
      () async {
    when(() => dio.get<Map<String, dynamic>>('/release/rel-1'))
        .thenAnswer((_) async => _jsonResponse('/release/rel-1', {
              'images': [
                {
                  'front': true,
                  'image': 'https://example.com/full.jpg',
                }
              ],
            }));

    final url = await api.findFrontArtwork(
      releaseId: 'rel-1',
      releaseGroupId: 'rg-1',
    );

    expect(url, 'https://example.com/full.jpg');
  });

  test('skips non-front images and falls back to release group', () async {
    when(() => dio.get<Map<String, dynamic>>('/release/rel-1'))
        .thenAnswer((_) async => _jsonResponse('/release/rel-1', {
              'images': [
                {
                  'front': false,
                  'types': ['Back'],
                  'image': 'https://example.com/back.jpg',
                  'thumbnails': {
                    'large': 'https://example.com/back-large.jpg',
                  },
                }
              ],
            }));
    when(() => dio.get<Map<String, dynamic>>('/release-group/rg-1'))
        .thenAnswer((_) async => _jsonResponse('/release-group/rg-1', {
              'images': [
                {
                  'front': true,
                  'image': 'https://example.com/rg.jpg',
                  'thumbnails': {
                    'large': 'https://example.com/rg-large.jpg',
                  },
                }
              ],
            }));

    final url = await api.findFrontArtwork(
      releaseId: 'rel-1',
      releaseGroupId: 'rg-1',
    );

    expect(url, 'https://example.com/rg-large.jpg');
  });

  test('returns null when releaseGroupId is missing and release has no '
      'front image', () async {
    when(() => dio.get<Map<String, dynamic>>('/release/rel-1'))
        .thenAnswer((_) async => _jsonResponse('/release/rel-1', {
              'images': [
                {
                  'front': false,
                  'image': 'https://example.com/back.jpg',
                }
              ],
            }));

    final url = await api.findFrontArtwork(releaseId: 'rel-1');

    expect(url, isNull);
    verifyNever(
        () => dio.get<Map<String, dynamic>>(any(that: contains('release-group'))));
  });
}
