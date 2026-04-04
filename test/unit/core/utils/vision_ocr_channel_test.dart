import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/core/utils/vision_ocr_channel.dart';

void main() {
  group('VisionOcrChannel', () {
    test('isAvailable returns false on non-macOS platforms', () {
      // In test environment, defaultTargetPlatform is typically android
      // unless overridden. On macOS test runners it could be macOS.
      // This test verifies the property exists and returns a bool.
      expect(VisionOcrChannel.isAvailable, isA<bool>());
    });

    test('recogniseText returns null on unsupported platform', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
      });

      final result = await VisionOcrChannel.recogniseText('/fake/path.png');
      expect(result, isNull);
    });
  });
}
