import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mymediascanner/data/remote/api/discogs/models/discogs_release_dto.dart';

part 'discogs_api.g.dart';

@RestApi()
abstract class DiscogsApi {
  factory DiscogsApi(Dio dio) = _DiscogsApi;

  @GET('/database/search')
  Future<DiscogsSearchResponseDto> searchByBarcode(
    @Query('barcode') String barcode, {
    @Query('type') String type = 'release',
  });

  @GET('/database/search')
  Future<DiscogsSearchResponseDto> searchByTitle(
    @Query('q') String query, {
    @Query('type') String type = 'release',
  });

  @GET('/releases/{id}')
  Future<DiscogsReleaseDto> getRelease(@Path('id') int id);
}
