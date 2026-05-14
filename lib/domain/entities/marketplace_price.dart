import 'package:freezed_annotation/freezed_annotation.dart';

part 'marketplace_price.freezed.dart';

/// Snapshot of a marketplace price quote for an item.
///
/// Author: Paul Snow
/// @since 0.0.0
@freezed
sealed class MarketplacePrice with _$MarketplacePrice {
  const factory MarketplacePrice({
    required double value,
    required String currency,
    required int numForSale,
    required String source,
    required int fetchedAt,
  }) = _MarketplacePrice;
}
