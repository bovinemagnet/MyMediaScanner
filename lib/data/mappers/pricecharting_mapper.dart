import 'package:mymediascanner/data/remote/api/pricecharting/models/pricecharting_product_dto.dart';
import 'package:mymediascanner/domain/entities/marketplace_price.dart';

/// Maps PriceCharting product responses to a [MarketplacePrice].
///
/// Prefers the CIB ("complete in box") price for the canonical "current
/// value", falling back to loose. Returns `null` when neither is set.
/// PriceCharting prices are USD cents, so we divide by 100.
///
/// Author: Paul Snow
/// @since 0.0.0
class PriceChartingMapper {
  const PriceChartingMapper._();

  static const String source = 'pricecharting';

  static MarketplacePrice? fromDto(
    PriceChartingProductDto dto, {
    required int fetchedAt,
  }) {
    final cents = dto.cibPrice ?? dto.loosePrice;
    if (cents == null || cents <= 0) return null;

    return MarketplacePrice(
      value: cents / 100.0,
      currency: 'USD',
      numForSale: 0,
      source: source,
      fetchedAt: fetchedAt,
    );
  }
}
