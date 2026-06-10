import 'package:mymediascanner/domain/entities/marketplace_price.dart';

/// Source of current marketplace values for owned items.
///
/// Abstracts the Discogs marketplace (music/film) and PriceCharting
/// (video games) integrations so the lookup use case stays free of
/// data-layer API clients.
///
/// Author: Paul Snow
/// @since 0.0.0
abstract interface class ICurrentValueSource {
  /// Whether Discogs marketplace lookups are configured.
  bool get supportsDiscogs;

  /// Whether PriceCharting lookups are configured (API + token).
  bool get supportsPriceCharting;

  /// Looks up the lowest current Discogs marketplace price for
  /// [releaseId]. Returns `null` when no usable price is available.
  Future<MarketplacePrice?> lookupDiscogsPrice({
    required int releaseId,
    required int fetchedAt,
  });

  /// Looks up the current PriceCharting value for a game, by
  /// [productId] when present, otherwise by [barcode] (UPC). Returns
  /// `null` when unconfigured or no usable price is available.
  Future<MarketplacePrice?> lookupGamePrice({
    String? productId,
    required String barcode,
    required int fetchedAt,
  });
}
