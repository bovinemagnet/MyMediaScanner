import 'package:dio/dio.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/core/utils/rate_limit_aware_client.dart';
import 'package:mymediascanner/data/remote/api/dio_factory.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/models/musicbrainz_release_dto.dart';

/// MusicBrainz API client.
///
/// Uses manual Dio calls because the MusicBrainz API requires `?fmt=json`
/// on every request and uses hyphenated query syntax. Wraps each request
/// in a [RateLimitAwareClient] so we pre-throttle to ~1 req/s and back
/// off when the server returns HTTP 503.
class MusicBrainzApi {
  MusicBrainzApi([Dio? dio, RateLimitAwareClient? client])
      : _dio = dio ??
            DioFactory.createWithUserAgent(
              baseUrl: ApiConstants.musicBrainzBaseUrl,
              userAgent: ApiConstants.musicBrainzUserAgent(),
            ),
        _client = client ??
            RateLimitAwareClient(
              minInterval: const Duration(milliseconds: 1100),
            );

  final Dio _dio;
  final RateLimitAwareClient _client;

  bool get isRateLimited => _client.isRateLimited;

  /// Search for releases matching the given barcode.
  Future<MusicBrainzSearchResponseDto> searchByBarcode(String barcode) {
    return _client.run(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/release/',
        queryParameters: {
          'query': 'barcode:${_escapeLucene(barcode)}',
          'fmt': 'json',
          'limit': 5,
        },
      );
      if (response.data == null) {
        return const MusicBrainzSearchResponseDto(count: 0, releases: []);
      }
      return MusicBrainzSearchResponseDto.fromJson(response.data!);
    });
  }

  /// Search for releases matching a title query.
  Future<MusicBrainzSearchResponseDto> searchByTitle(String title) {
    return _client.run(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/release/',
        queryParameters: {
          'query': 'release:${_escapeLucene(title)}',
          'fmt': 'json',
          'limit': 5,
        },
      );
      if (response.data == null) {
        return const MusicBrainzSearchResponseDto(count: 0, releases: []);
      }
      return MusicBrainzSearchResponseDto.fromJson(response.data!);
    });
  }

  /// Fetch full release details by MusicBrainz ID.
  Future<MusicBrainzReleaseDto?> getRelease(String mbid) {
    return _client.run(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/release/$mbid',
        queryParameters: {
          'inc': 'recordings+artists+labels+release-groups',
          'fmt': 'json',
        },
      );
      if (response.data == null) return null;
      return MusicBrainzReleaseDto.fromJson(response.data!);
    });
  }

  /// Escapes Lucene reserved characters so user-supplied barcodes or titles
  /// (e.g. `C++`, `S.O.S.`, hyphenated ISBNs) don't break the query parser
  /// with a 400 or silently return no results.
  ///
  /// Lucene reserved: `+ - && || ! ( ) { } [ ] ^ " ~ * ? : \ /`
  static String _escapeLucene(String raw) {
    final buf = StringBuffer();
    for (final rune in raw.runes) {
      final c = String.fromCharCode(rune);
      if ('+-!(){}[]^"~*?:\\/'.contains(c)) {
        buf.write(r'\');
      }
      buf.write(c);
    }
    return buf.toString();
  }
}
