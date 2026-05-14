import 'package:mymediascanner/data/remote/api/discogs/models/discogs_marketplace_stats_dto.dart';
import 'package:mymediascanner/domain/entities/marketplace_price.dart';

/// Maps Discogs marketplace stats responses to the domain price object.
///
/// Returns `null` when no usable price is available — the release is
/// blocked from sale or no listings have populated the stats yet.
///
/// Author: Paul Snow
/// @since 0.0.0
class DiscogsMarketplaceMapper {
  const DiscogsMarketplaceMapper._();

  static const String source = 'discogs_marketplace';

  static MarketplacePrice? fromDto(
    DiscogsMarketplaceStatsDto dto, {
    required int fetchedAt,
  }) {
    if (dto.blockedFromSale == true) return null;
    final money = dto.lowestPrice;
    if (money == null) return null;
    final value = money.value;
    if (value == null) return null;

    return MarketplacePrice(
      value: value,
      currency: money.currency ?? '',
      numForSale: dto.numForSale ?? 0,
      source: source,
      fetchedAt: fetchedAt,
    );
  }
}
