import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/mappers/discogs_marketplace_mapper.dart';
import 'package:mymediascanner/data/remote/api/discogs/models/discogs_marketplace_stats_dto.dart';

void main() {
  group('DiscogsMarketplaceMapper', () {
    test('maps populated stats DTO to MarketplacePrice', () {
      const dto = DiscogsMarketplaceStatsDto(
        lowestPrice: DiscogsMoneyDto(value: 12.50, currency: 'USD'),
        numForSale: 7,
        blockedFromSale: false,
      );

      final result = DiscogsMarketplaceMapper.fromDto(
        dto,
        fetchedAt: 1700000000,
      );

      expect(result, isNotNull);
      expect(result!.value, 12.50);
      expect(result.currency, 'USD');
      expect(result.numForSale, 7);
      expect(result.source, 'discogs_marketplace');
      expect(result.fetchedAt, 1700000000);
    });

    test('returns null when lowestPrice is missing', () {
      const dto = DiscogsMarketplaceStatsDto(
        lowestPrice: null,
        numForSale: 0,
      );

      final result = DiscogsMarketplaceMapper.fromDto(
        dto,
        fetchedAt: 1700000000,
      );

      expect(result, isNull);
    });

    test('returns null when lowestPrice value is null', () {
      const dto = DiscogsMarketplaceStatsDto(
        lowestPrice: DiscogsMoneyDto(value: null, currency: 'USD'),
        numForSale: 5,
      );

      final result = DiscogsMarketplaceMapper.fromDto(
        dto,
        fetchedAt: 1700000000,
      );

      expect(result, isNull);
    });

    test('returns null when blockedFromSale is true', () {
      const dto = DiscogsMarketplaceStatsDto(
        lowestPrice: DiscogsMoneyDto(value: 5.0, currency: 'GBP'),
        numForSale: 2,
        blockedFromSale: true,
      );

      final result = DiscogsMarketplaceMapper.fromDto(
        dto,
        fetchedAt: 1700000000,
      );

      expect(result, isNull);
    });

    test('defaults numForSale to zero when missing', () {
      const dto = DiscogsMarketplaceStatsDto(
        lowestPrice: DiscogsMoneyDto(value: 8.0, currency: 'EUR'),
      );

      final result = DiscogsMarketplaceMapper.fromDto(
        dto,
        fetchedAt: 1700000000,
      );

      expect(result, isNotNull);
      expect(result!.numForSale, 0);
    });

    test('defaults currency to empty string when missing', () {
      const dto = DiscogsMarketplaceStatsDto(
        lowestPrice: DiscogsMoneyDto(value: 8.0, currency: null),
        numForSale: 3,
      );

      final result = DiscogsMarketplaceMapper.fromDto(
        dto,
        fetchedAt: 1700000000,
      );

      expect(result, isNotNull);
      expect(result!.currency, '');
    });
  });
}
