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

  /// Returns structured recognition results as a list of maps, each with
  /// 'text', 'confidence', and 'area' keys. Falls back to wrapping the
  /// plain text result if the native side doesn't support structured output.
  static Future<List<Map<String, dynamic>>?> recogniseTextStructured(
      String imagePath) async {
    if (!isAvailable) return null;
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'recogniseTextStructured',
        {'imagePath': imagePath},
      );
      if (result != null) {
        // Defensively coerce — a malformed native implementation returning
        // non-Map entries must not throw an uncaught TypeError.
        final out = <Map<String, dynamic>>[];
        for (final entry in result) {
          if (entry is Map) {
            out.add(Map<String, dynamic>.from(entry));
          }
        }
        return out;
      }
    } on PlatformException catch (_) {
      // Native side doesn't support structured output; fall through
    } on MissingPluginException catch (_) {
      // Method not implemented on native side; fall through
    } on TypeError catch (e) {
      debugPrint('Vision OCR structured: malformed native response: $e');
    }

    // Fallback: wrap plain text result
    final plain = await recogniseText(imagePath);
    if (plain == null || plain.isEmpty) return null;
    return [
      {'text': plain, 'confidence': 1.0, 'area': 1.0},
    ];
  }

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
