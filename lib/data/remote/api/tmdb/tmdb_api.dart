import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_find_result_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_movie_detail_dto.dart';
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

  @GET('/find/{externalId}')
  Future<TmdbFindResponseDto> findByExternalId(
    @Path('externalId') String externalId, {
    @Query('external_source') String externalSource = 'imdb_id',
  });

  /// Movie detail — used to read `belongs_to_collection` for series
  /// resolution. Search/find responses do not include collection refs.
  @GET('/movie/{id}')
  Future<TmdbMovieDetailDto> getMovieDetail(@Path('id') int id);

  /// Trending content for the current week — used as a candidate pool
  /// for wishlist suggestions. `mediaType` accepts `movie`, `tv` or `all`.
  @GET('/trending/{mediaType}/week')
  Future<TmdbSearchResponseDto> trending(
    @Path('mediaType') String mediaType,
  );
}
