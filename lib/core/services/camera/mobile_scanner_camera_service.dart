import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:mymediascanner/core/services/camera/camera_service.dart';

/// Camera service implementation using the mobile_scanner package.
///
/// Supports Android, iOS, and macOS where ML Kit barcode detection
/// is available natively.
class MobileScannerCameraService implements CameraService {
  MobileScannerCameraService({MobileScannerController? controller})
      : _controller = controller ??
            MobileScannerController(
              detectionSpeed: DetectionSpeed.normal,
              detectionTimeoutMs: 500,
            );

  final MobileScannerController _controller;
  final _barcodeController = StreamController<BarcodeResult>.broadcast();
  StreamSubscription<BarcodeCapture>? _subscription;

  /// The underlying controller, exposed for the camera preview widget.
  MobileScannerController get controller => _controller;

  @override
  Stream<BarcodeResult> get onBarcodeDetected => _barcodeController.stream;

  @override
  Widget buildPreview({Widget Function(String message)? errorBuilder}) {
    return MobileScanner(
      controller: _controller,
      onDetect: (_) {}, // Detection handled via onBarcodeDetected stream
      errorBuilder: errorBuilder != null
          ? (context, error) =>
              errorBuilder('Camera error: ${error.errorCode.message}')
          : null,
    );
  }

  @override
  Future<void> start() async {
    await _controller.start();
    _subscription = _controller.barcodes.listen((capture) {
      for (final barcode in capture.barcodes) {
        final value = barcode.rawValue ?? barcode.displayValue;
        if (value != null && value.isNotEmpty) {
          _barcodeController.add(BarcodeResult(
            rawValue: value,
            format: barcode.format.name,
          ));
        }
      }
    });
  }

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await _controller.stop();
  }

  @override
  bool get isActive => _controller.value.isRunning;

  @override
  Future<String?> captureImage() async {
    // MobileScanner doesn't expose still capture directly.
    // Fall back to gallery picker for cover OCR on macOS.
    return null;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _barcodeController.close();
    await _controller.dispose();
  }
}
