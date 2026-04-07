import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/services/camera/camera_service.dart';

void main() {
  group('BarcodeResult', () {
    test('stores rawValue and format', () {
      const result = BarcodeResult(rawValue: '9780141036144', format: 'EAN_13');

      expect(result.rawValue, '9780141036144');
      expect(result.format, 'EAN_13');
    });

    test('format is nullable', () {
      const result = BarcodeResult(rawValue: '123456');

      expect(result.rawValue, '123456');
      expect(result.format, isNull);
    });
  });

  // Note: BarcodeDetector.detectFromBytes and detectFromFile cannot be
  // unit-tested because flutter_zxing requires its native FFI library
  // (libflutter_zxing.so) which is only available at runtime in a full
  // Flutter application. These should be tested via integration tests.
}
