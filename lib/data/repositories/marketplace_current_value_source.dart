import 'package:mymediascanner/data/mappers/discogs_marketplace_mapper.dart';
import 'package:mymediascanner/data/mappers/pricecharting_mapper.dart';
import 'package:mymediascanner/data/remote/api/discogs/discogs_api.dart';
import 'package:mymediascanner/data/remote/api/pricecharting/pricecharting_api.dart';
import 'package:mymediascanner/domain/entities/marketplace_price.dart';
import 'package:mymediascanner/domain/repositories/i_current_value_source.dart';

/// [ICurrentValueSource] backed by the Discogs marketplace and
/// PriceCharting APIs. Either client may be `null` when the user has not
/// configured the corresponding credentials.
///
/// Author: Paul Snow
/// @since 0.0.0
class MarketplaceCurrentValueSource implements ICurrentValueSource {
  const MarketplaceCurrentValueSource({
    required DiscogsApi? discogsApi,
    PriceChartingApi? priceChartingApi,
    String? priceChartingToken,
  })  : _discogs = discogsApi,
        _priceCharting = priceChartingApi,
        _priceChartingToken = priceChartingToken;

  final DiscogsApi? _discogs;
  final PriceChartingApi? _priceCharting;
  final String? _priceChartingToken;

  @override
  bool get supportsDiscogs => _discogs != null;

  @override
  bool get supportsPriceCharting =>
      _priceCharting != null &&
      _priceChartingToken != null &&
      _priceChartingToken.isNotEmpty;

  @override
  Future<MarketplacePrice?> lookupDiscogsPrice({
    required int releaseId,
    required int fetchedAt,
  }) async {
    final api = _discogs;
    if (api == null) return null;
    final dto = await api.getMarketplaceStats(releaseId);
    return DiscogsMarketplaceMapper.fromDto(dto, fetchedAt: fetchedAt);
  }

  @override
  Future<MarketplacePrice?> lookupGamePrice({
    String? productId,
    required String barcode,
    required int fetchedAt,
  }) async {
    final api = _priceCharting;
    final token = _priceChartingToken;
    if (api == null || token == null || token.isEmpty) return null;

    final dto = productId != null && productId.isNotEmpty
        ? await api.lookupById(token, productId)
        : await api.lookupByUpc(token, barcode);
    return PriceChartingMapper.fromDto(dto, fetchedAt: fetchedAt);
  }
}
