import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_search_result_dto.dart';

part 'tmdb_api.g.dart';

@RestApi()
abstract class TmdbApi {
  factory TmdbApi(Dio dio) = _TmdbApi;

  @GET('/search/multi')
  Future<TmdbSearchResponseDto> searchMulti(
    @Query('query') String query, {
    @Query('page') int page = 1,
  });

  @GET('/search/movie')
  Future<TmdbSearchResponseDto> searchMovie(
    @Query('query') String query, {
    @Query('page') int page = 1,
  });

  @GET('/search/tv')
  Future<TmdbSearchResponseDto> searchTv(
    @Query('query') String query, {
    @Query('page') int page = 1,
  });
}
