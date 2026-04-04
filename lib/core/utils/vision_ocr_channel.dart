import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Method channel wrapper for macOS Vision framework text recognition.
///
/// Only available on macOS. On other platforms, [recogniseText] returns null.
abstract final class VisionOcrChannel {
  static const _channel = MethodChannel('com.mymediascanner/vision_ocr');

  /// Returns `true` if the Vision OCR channel is available on this platform.
  static bool get isAvailable =>
      defaultTargetPlatform == TargetPlatform.macOS;

  /// Recognises text from an image file at [imagePath] using the macOS
  /// Vision framework. Returns the most prominent text block, or `null`
  /// if no text is detected or the platform is unsupported.
  static Future<String?> recogniseText(String imagePath) async {
    if (!isAvailable) return null;
    try {
      final result = await _channel.invokeMethod<String>(
        'recogniseText',
        {'imagePath': imagePath},
      );
      return result;
    } on PlatformException catch (e) {
      debugPrint('Vision OCR channel error: ${e.message}');
      return null;
    }
  }
}
