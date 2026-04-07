import 'dart:typed_data';

import 'package:flutter_zxing/flutter_zxing.dart';

import 'package:mymediascanner/core/services/camera/camera_service.dart';

/// Barcode detector using flutter_zxing (ZXing C++ via FFI).
///
/// Used on Windows and Linux where ML Kit is not available.
/// Supports all major barcode formats: QR, EAN-13, UPC-A, Code 128, etc.
class BarcodeDetector {
  static final _zx = Zxing();

  /// Attempt to detect a barcode from image file bytes (e.g. JPEG/PNG).
  static Future<BarcodeResult?> detectFromBytes(Uint8List imageBytes) async {
    try {
      final result = _zx.readBarcode(imageBytes, DecodeParams());
      if (!result.isValid) return null;
      final text = result.text;
      if (text == null || text.isEmpty) return null;
      return BarcodeResult(
        rawValue: text,
        format: result.format?.toString(),
      );
    } on Exception {
      return null;
    }
  }

  /// Attempt to detect a barcode from an image file path.
  static Future<BarcodeResult?> detectFromFile(String path) async {
    try {
      final result =
          await _zx.readBarcodeImagePathString(path, DecodeParams());
      if (!result.isValid) return null;
      final text = result.text;
      if (text == null || text.isEmpty) return null;
      return BarcodeResult(
        rawValue: text,
        format: result.format?.toString(),
      );
    } on Exception {
      return null;
    }
  }
}
