// Tests for the camera detection guard that prevents the live preview from
// silently processing real-world barcodes while a dialog or pushed route
// (manual entry, confirm, disambiguation, not-found) covers the scanner.
//
// Author: Paul Snow
// Since: 0.0.0
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/scanner/mobile_scan_screen.dart';

void main() {
  group('shouldProcessCameraDetection', () {
    test('processes a detection when the idle scanner is the current route', () {
      expect(
        shouldProcessCameraDetection(hasScanned: false, routeIsCurrent: true),
        isTrue,
      );
    });

    test('ignores a detection while a scan is already in flight', () {
      expect(
        shouldProcessCameraDetection(hasScanned: true, routeIsCurrent: true),
        isFalse,
      );
    });

    test(
      'ignores a detection while a dialog or pushed route covers the scanner',
      () {
        expect(
          shouldProcessCameraDetection(
            hasScanned: false,
            routeIsCurrent: false,
          ),
          isFalse,
        );
      },
    );
  });
}
