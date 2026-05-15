import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mymediascanner/data/remote/api/pricecharting/models/pricecharting_product_dto.dart';

part 'pricecharting_api.g.dart';

/// PriceCharting product lookup. The API token is passed as the `t` query
/// param and the product is identified by either the PriceCharting product
/// id (`id`) or by UPC (`upc`); we accept both forms via two endpoints to
/// match the upstream API surface.
@RestApi()
abstract class PriceChartingApi {
  factory PriceChartingApi(Dio dio) = _PriceChartingApi;

  @GET('/product')
  Future<PriceChartingProductDto> lookupById(
    @Query('t') String token,
    @Query('id') String productId,
  );

  @GET('/product')
  Future<PriceChartingProductDto> lookupByUpc(
    @Query('t') String token,
    @Query('upc') String upc,
  );
}
