import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mymediascanner/data/remote/api/tvdb/models/tvdb_series_dto.dart';

part 'tvdb_api.g.dart';

@RestApi()
abstract class TvdbApi {
  factory TvdbApi(Dio dio) = _TvdbApi;

  @GET('/search')
  Future<TvdbSearchResponseDto> search(
    @Query('query') String query, {
    @Query('type') String? type,
    @Query('limit') int limit = 5,
  });

  @GET('/series/{id}')
  Future<TvdbSeriesResponseDto> getSeries(@Path('id') int id);
}
