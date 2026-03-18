import 'package:dio/dio.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/core/utils/rate_limiter.dart';
import 'package:mymediascanner/data/remote/api/dio_factory.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/models/musicbrainz_release_dto.dart';

/// MusicBrainz API client.
///
/// Uses manual Dio calls rather than Retrofit because the MusicBrainz API
/// requires `?fmt=json` on every request and uses hyphenated query syntax.
/// Includes built-in rate limiting (1 request per second) as required by
/// the MusicBrainz API terms of service.
class MusicBrainzApi {
  MusicBrainzApi([Dio? dio])
      : _dio = dio ??
            DioFactory.createWithUserAgent(
              baseUrl: ApiConstants.musicBrainzBaseUrl,
              userAgent: ApiConstants.musicBrainzUserAgent,
            ),
        _rateLimiter =
            RateLimiter(minInterval: const Duration(milliseconds: 1100));

  final Dio _dio;
  final RateLimiter _rateLimiter;

  /// Search for releases matching the given barcode.
  Future<MusicBrainzSearchResponseDto> searchByBarcode(
      String barcode) async {
    await _rateLimiter.throttle();
    final response = await _dio.get<Map<String, dynamic>>(
      '/release/',
      queryParameters: {
        'query': 'barcode:$barcode',
        'fmt': 'json',
        'limit': 5,
      },
    );
    if (response.data == null) {
      return const MusicBrainzSearchResponseDto(count: 0, releases: []);
    }
    return MusicBrainzSearchResponseDto.fromJson(response.data!);
  }

  /// Search for releases matching a title query.
  Future<MusicBrainzSearchResponseDto> searchByTitle(String title) async {
    await _rateLimiter.throttle();
    final response = await _dio.get<Map<String, dynamic>>(
      '/release/',
      queryParameters: {
        'query': 'release:$title',
        'fmt': 'json',
        'limit': 5,
      },
    );
    if (response.data == null) {
      return const MusicBrainzSearchResponseDto(count: 0, releases: []);
    }
    return MusicBrainzSearchResponseDto.fromJson(response.data!);
  }

  /// Fetch full release details by MusicBrainz ID.
  Future<MusicBrainzReleaseDto?> getRelease(String mbid) async {
    await _rateLimiter.throttle();
    final response = await _dio.get<Map<String, dynamic>>(
      '/release/$mbid',
      queryParameters: {
        'inc': 'recordings+artists+labels+release-groups',
        'fmt': 'json',
      },
    );
    if (response.data == null) return null;
    return MusicBrainzReleaseDto.fromJson(response.data!);
  }
}
