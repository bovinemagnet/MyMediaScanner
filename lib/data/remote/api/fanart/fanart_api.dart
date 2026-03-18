import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mymediascanner/data/remote/api/fanart/models/fanart_images_dto.dart';

part 'fanart_api.g.dart';

@RestApi()
abstract class FanartApi {
  factory FanartApi(Dio dio) = _FanartApi;

  @GET('/movies/{tmdb_id}')
  Future<FanartMovieImagesDto> getMovieImages(
      @Path('tmdb_id') int tmdbId);

  @GET('/tv/{tvdb_id}')
  Future<FanartTvImagesDto> getTvImages(@Path('tvdb_id') int tvdbId);

  @GET('/music/albums/{mbid}')
  Future<FanartAlbumImagesDto> getAlbumImages(@Path('mbid') String mbid);
}
