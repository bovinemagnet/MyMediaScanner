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

    // ----------------------------------------------------------------------
    // Cluster-3 MED-2: cache key normalisation
    //
    // Without normalisation, the same physical product captured in two
    // different shapes produces two cache rows and the second scan misses
    // the cache, re-hitting the upstream API.
    // ----------------------------------------------------------------------
    group('normaliseForCache', () {
      test('strips ISBN-10 hyphens', () {
        expect(
          BarcodeUtils.normaliseForCache('0-1234-56789'),
          '0123456789',
        );
      });

      test('strips ISBN-13 hyphens and whitespace', () {
        expect(
          BarcodeUtils.normaliseForCache('978-0-141 03614-4'),
          '9780141036144',
        );
      });

      test(
          'pads UPC-A leading zero when scanner drops it (11 digit input)',
          () {
        expect(
          BarcodeUtils.normaliseForCache('12345678905'),
          '012345678905',
        );
      });

      test('uppercases IMDb id so case variations collide', () {
        expect(
          BarcodeUtils.normaliseForCache('tt0133093'),
          'TT0133093',
        );
        expect(
          BarcodeUtils.normaliseForCache('TT0133093'),
          'TT0133093',
        );
      });

      test('does not pad 12-digit UPC-A or 13-digit EAN-13', () {
        expect(
          BarcodeUtils.normaliseForCache('012345678905'),
          '012345678905',
        );
        expect(
          BarcodeUtils.normaliseForCache('5051892002172'),
          '5051892002172',
        );
      });

      test('idempotent — second normalise is a no-op', () {
        const raw = '978-0-141-03614-4';
        final once = BarcodeUtils.normaliseForCache(raw);
        final twice = BarcodeUtils.normaliseForCache(once);
        expect(twice, once);
      });
    });
  });
}
