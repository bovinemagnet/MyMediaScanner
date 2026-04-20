import 'dart:io';

import 'package:flutter/foundation.dart';
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
  ///
  /// Tries the path-based zxing API first, then falls back to reading the
  /// bytes ourselves and using the bytes API — flutter_zxing's path API has
  /// historically been flaky on Linux.
  static Future<BarcodeResult?> detectFromFile(String path) async {
    final file = File(path);
    final size = await file.exists() ? await file.length() : -1;
    debugPrint('[scan] decoding $path (${size}B)');
    if (size <= 0) return null;

    try {
      final pathResult =
          await _zx.readBarcodeImagePathString(path, DecodeParams());
      if (pathResult.isValid && (pathResult.text?.isNotEmpty ?? false)) {
        return BarcodeResult(
          rawValue: pathResult.text!,
          format: pathResult.format?.toString(),
        );
      }
      debugPrint('[scan] path-API miss (error="${pathResult.error}"), '
          'trying bytes-API');
    } on Exception catch (e) {
      debugPrint('[scan] path-API threw: $e, trying bytes-API');
    }

    try {
      final bytes = await file.readAsBytes();
      final byteResult = _zx.readBarcode(bytes, DecodeParams());
      if (!byteResult.isValid) {
        debugPrint('[scan] bytes-API miss (error="${byteResult.error}")');
        return null;
      }
      final text = byteResult.text;
      if (text == null || text.isEmpty) return null;
      return BarcodeResult(
        rawValue: text,
        format: byteResult.format?.toString(),
      );
    } on Exception catch (e) {
      debugPrint('[scan] bytes-API threw: $e');
      return null;
    }
  }
}
