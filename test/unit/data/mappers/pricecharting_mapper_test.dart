import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/mappers/pricecharting_mapper.dart';
import 'package:mymediascanner/data/remote/api/pricecharting/models/pricecharting_product_dto.dart';

void main() {
  group('PriceChartingMapper', () {
    test('prefers cibPrice and converts cents to dollars', () {
      const dto = PriceChartingProductDto(
        cibPrice: 2499,
        loosePrice: 999,
      );
      final price = PriceChartingMapper.fromDto(dto, fetchedAt: 1700000000);

      expect(price, isNotNull);
      expect(price!.value, 24.99);
      expect(price.currency, 'USD');
      expect(price.source, 'pricecharting');
    });

    test('falls back to loosePrice when cibPrice missing', () {
      const dto = PriceChartingProductDto(loosePrice: 1599);
      final price = PriceChartingMapper.fromDto(dto, fetchedAt: 1700000000);

      expect(price, isNotNull);
      expect(price!.value, 15.99);
    });

    test('returns null when both prices missing', () {
      const dto = PriceChartingProductDto();
      final price = PriceChartingMapper.fromDto(dto, fetchedAt: 1700000000);

      expect(price, isNull);
    });

    test('returns null when both prices are zero or negative', () {
      const dto = PriceChartingProductDto(cibPrice: 0, loosePrice: 0);
      final price = PriceChartingMapper.fromDto(dto, fetchedAt: 1700000000);

      expect(price, isNull);
    });
  });
}
