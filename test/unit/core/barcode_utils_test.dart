import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/barcode_utils.dart';

void main() {
  group('BarcodeUtils', () {
    group('detectBarcodeType', () {
      test('detects ISBN-13 starting with 978', () {
        expect(
          BarcodeUtils.detectBarcodeType('9780141036144'),
          BarcodeType.isbn13,
        );
      });

      test('detects ISBN-13 starting with 979', () {
        expect(
          BarcodeUtils.detectBarcodeType('9791234567890'),
          BarcodeType.isbn13,
        );
      });

      test('detects ISBN-10', () {
        expect(
          BarcodeUtils.detectBarcodeType('0141036141'),
          BarcodeType.isbn10,
        );
      });

      test('detects EAN-13', () {
        expect(
          BarcodeUtils.detectBarcodeType('5051892002172'),
          BarcodeType.ean13,
        );
      });

      test('detects UPC-A (12 digits)', () {
        expect(
          BarcodeUtils.detectBarcodeType('012345678905'),
          BarcodeType.upcA,
        );
      });

      test('returns unknown for invalid barcode', () {
        expect(
          BarcodeUtils.detectBarcodeType('abc'),
          BarcodeType.unknown,
        );
      });
    });

    group('isIsbn', () {
      test('returns true for ISBN-13', () {
        expect(BarcodeUtils.isIsbn('9780141036144'), isTrue);
      });

      test('returns true for ISBN-10', () {
        expect(BarcodeUtils.isIsbn('0141036141'), isTrue);
      });

      test('returns false for EAN-13', () {
        expect(BarcodeUtils.isIsbn('5051892002172'), isFalse);
      });
    });
  });
}
