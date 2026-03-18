import 'package:dio/dio.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/data/remote/api/dio_factory.dart';
import 'package:mymediascanner/data/remote/api/theaudiodb/models/theaudiodb_album_dto.dart';

/// TheAudioDB API client.
///
/// Uses manual Dio calls because the API key is a path segment rather
/// than a query parameter or header. Free tier uses key "2".
class TheAudioDbApi {
  TheAudioDbApi({String apiKey = '2', Dio? dio})
      : _apiKey = apiKey,
        _dio = dio ??
            DioFactory.create(baseUrl: ApiConstants.theAudioDbBaseUrl);

  final String _apiKey;
  final Dio _dio;

  /// Look up an album by MusicBrainz release group ID.
  Future<TheAudioDbAlbumDto?> getByMusicBrainzId(String mbid) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/$_apiKey/album-mb.php',
      queryParameters: {'i': mbid},
    );
    if (response.data == null) return null;
    final parsed = TheAudioDbAlbumResponseDto.fromJson(response.data!);
    return parsed.album?.firstOrNull;
  }

  /// Search for an album by artist and album name.
  Future<TheAudioDbAlbumDto?> searchAlbum(
      String artist, String album) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/$_apiKey/searchalbum.php',
      queryParameters: {'s': artist, 'a': album},
    );
    if (response.data == null) return null;
    final parsed = TheAudioDbAlbumResponseDto.fromJson(response.data!);
    return parsed.album?.firstOrNull;
  }
}
