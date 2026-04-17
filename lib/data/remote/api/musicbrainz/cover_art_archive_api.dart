import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/core/utils/rate_limit_aware_client.dart';
import 'package:mymediascanner/data/remote/api/dio_factory.dart';
import 'package:mymediascanner/data/remote/api/musicbrainz/models/cover_art_archive_dto.dart';

/// Queries the Cover Art Archive (coverartarchive.org) for front artwork.
///
/// The archive is a CC0 image host maintained by the MetaBrainz
/// Foundation. It is keyed on MusicBrainz release and release-group
/// MBIDs; when a release has no dedicated artwork we fall back to the
/// release group.
class CoverArtArchiveApi {
  CoverArtArchiveApi([Dio? dio, RateLimitAwareClient? client])
      : _dio = dio ??
            DioFactory.createWithUserAgent(
              baseUrl: ApiConstants.coverArtArchiveBaseUrl,
              userAgent: ApiConstants.musicBrainzUserAgent(),
            ),
        _client = client ??
            RateLimitAwareClient(
              minInterval: const Duration(milliseconds: 500),
            );

  final Dio _dio;
  final RateLimitAwareClient _client;

  /// Returns the best available front-cover URL for the release, falling
  /// back to the release group when the release has no artwork.
  Future<String?> findFrontArtwork({
    required String releaseId,
    String? releaseGroupId,
  }) async {
    final releaseUrl = await _fetchFront('/release/$releaseId');
    if (releaseUrl != null) return releaseUrl;
    if (releaseGroupId == null) return null;
    return _fetchFront('/release-group/$releaseGroupId');
  }

  Future<String?> _fetchFront(String path) async {
    try {
      return await _client.run(() async {
        final response = await _dio.get<Map<String, dynamic>>(path);
        if (response.data == null) return null;
        final dto = CoverArtArchiveResponseDto.fromJson(response.data!);
        for (final image in dto.images ?? const <CoverArtArchiveImageDto>[]) {
          if (image.front == true) {
            return image.thumbnails?.large ??
                image.thumbnails?.size250 ??
                image.image;
          }
        }
        return null;
      });
    } on DioException catch (e) {
      // 404 is the normal "no artwork" response — not an error.
      if (e.response?.statusCode == 404) return null;
      debugPrint('Cover Art Archive fetch failed for $path: $e');
      return null;
    } on Exception catch (e) {
      debugPrint('Cover Art Archive fetch failed for $path: $e');
      return null;
    }
  }
}
