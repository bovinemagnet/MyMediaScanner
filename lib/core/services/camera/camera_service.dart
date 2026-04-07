import 'dart:async';

/// Result of a barcode detection from a camera frame.
class BarcodeResult {
  const BarcodeResult({required this.rawValue, this.format});

  final String rawValue;
  final String? format;
}

/// Abstract camera service for barcode scanning.
///
/// Platform implementations:
/// - [MobileScannerCameraService] for Android/iOS/macOS (uses mobile_scanner)
/// - [NativeCameraService] for Windows/Linux (uses camera + flutter_zxing)
abstract class CameraService {
  /// Stream of detected barcodes.
  Stream<BarcodeResult> get onBarcodeDetected;

  /// Start the camera and begin detection.
  Future<void> start();

  /// Stop the camera and release resources.
  Future<void> stop();

  /// Whether the camera is currently active.
  bool get isActive;

  /// Dispose of all resources.
  Future<void> dispose();
}
