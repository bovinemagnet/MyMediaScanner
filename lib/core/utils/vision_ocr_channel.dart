import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Method channel wrapper for macOS Vision framework text recognition.
///
/// Only available on macOS. On other platforms, [recogniseText] returns null.
///
/// **Cancellation note:** Flutter's [MethodChannel] does not natively
/// support per-call cancellation, so the platform invocation always
/// runs to completion native-side. Both methods enforce a configurable
/// timeout so a stalled or runaway recognition can't pin the Dart-side
/// future indefinitely. Callers that may navigate away mid-OCR should
/// still check their own `mounted`/disposed state before consuming the
/// result.
abstract final class VisionOcrChannel {
  static const _channel = MethodChannel('com.mymediascanner/vision_ocr');

  /// Default per-call timeout. Vision OCR on a typical cover image
  /// finishes in <1 s; 15 s is generous slack for large scans on
  /// older Macs and bounds the worst case.
  static const defaultTimeout = Duration(seconds: 15);

  /// Returns `true` if the Vision OCR channel is available on this platform.
  static bool get isAvailable =>
      defaultTargetPlatform == TargetPlatform.macOS;

  /// Returns structured recognition results as a list of maps, each with
  /// 'text', 'confidence', and 'area' keys. Falls back to wrapping the
  /// plain text result if the native side doesn't support structured output.
  ///
  /// On [TimeoutException] returns `null` and lets the caller decide whether
  /// to retry or surface a "took too long" message — the prior behaviour
  /// would await the platform channel indefinitely if Vision deadlocked.
  static Future<List<Map<String, dynamic>>?> recogniseTextStructured(
    String imagePath, {
    Duration timeout = defaultTimeout,
  }) async {
    if (!isAvailable) return null;
    try {
      final result = await _channel
          .invokeMethod<List<dynamic>>(
            'recogniseTextStructured',
            {'imagePath': imagePath},
          )
          .timeout(timeout);
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
    } on TimeoutException {
      debugPrint(
          'Vision OCR structured: timed out after ${timeout.inSeconds}s');
      return null;
    }

    // Fallback: wrap plain text result
    final plain = await recogniseText(imagePath, timeout: timeout);
    if (plain == null || plain.isEmpty) return null;
    return [
      {'text': plain, 'confidence': 1.0, 'area': 1.0},
    ];
  }

  /// Recognises text from an image file at [imagePath] using the macOS
  /// Vision framework. Returns the most prominent text block, or `null`
  /// if no text is detected, the platform is unsupported, or the
  /// platform invocation exceeds [timeout].
  static Future<String?> recogniseText(
    String imagePath, {
    Duration timeout = defaultTimeout,
  }) async {
    if (!isAvailable) return null;
    try {
      final result = await _channel
          .invokeMethod<String>(
            'recogniseText',
            {'imagePath': imagePath},
          )
          .timeout(timeout);
      return result;
    } on PlatformException catch (e) {
      debugPrint('Vision OCR channel error: ${e.message}');
      return null;
    } on TimeoutException {
      debugPrint(
          'Vision OCR: timed out after ${timeout.inSeconds}s on $imagePath');
      return null;
    }
  }
}
