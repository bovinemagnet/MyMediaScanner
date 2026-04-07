import 'dart:async';

import 'package:flutter/widgets.dart';

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

  /// Build the camera preview widget.
  ///
  /// [errorBuilder] is called when the camera encounters an error.
  Widget buildPreview({Widget Function(String message)? errorBuilder});

  /// Start the camera and begin detection.
  Future<void> start();

  /// Stop the camera and release resources.
  Future<void> stop();

  /// Whether the camera is currently active.
  bool get isActive;

  /// Capture a still image and return the file path.
  ///
  /// Returns `null` if the camera is not active or capture fails.
  Future<String?> captureImage();

  /// Dispose of all resources.
  Future<void> dispose();
}
