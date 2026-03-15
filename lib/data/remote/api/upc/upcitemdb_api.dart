import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mymediascanner/data/remote/api/upc/models/upc_item_dto.dart';

part 'upcitemdb_api.g.dart';

@RestApi()
abstract class UpcitemdbApi {
  factory UpcitemdbApi(Dio dio) = _UpcitemdbApi;

  @GET('/lookup')
  Future<UpcSearchResponseDto> lookup(@Query('upc') String barcode);
}
