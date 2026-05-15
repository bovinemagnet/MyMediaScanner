import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/usecases/value_delta.dart';

void main() {
  group('computeValueDelta', () {
    test('returns absolute delta and percent for valid inputs', () {
      final r = computeValueDelta(pricePaid: 20.0, currentValue: 25.0);
      expect(r.delta, 5.0);
      expect(r.deltaPercent, 25.0);
    });

    test('negative delta for value decrease', () {
      final r = computeValueDelta(pricePaid: 50.0, currentValue: 30.0);
      expect(r.delta, -20.0);
      expect(r.deltaPercent, -40.0);
    });

    test('returns null when pricePaid is null', () {
      final r = computeValueDelta(pricePaid: null, currentValue: 30.0);
      expect(r.delta, isNull);
      expect(r.deltaPercent, isNull);
    });

    test('returns null when currentValue is null', () {
      final r = computeValueDelta(pricePaid: 30.0, currentValue: null);
      expect(r.delta, isNull);
      expect(r.deltaPercent, isNull);
    });

    test('returns null when pricePaid is zero to avoid infinite percent', () {
      final r = computeValueDelta(pricePaid: 0.0, currentValue: 30.0);
      expect(r.delta, isNull);
      expect(r.deltaPercent, isNull);
    });
  });
}
