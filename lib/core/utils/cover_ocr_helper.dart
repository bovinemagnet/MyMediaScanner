import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymediascanner/core/utils/vision_ocr_channel.dart';

/// Extracts text from media cover images using ML Kit text recognition
/// (Android/iOS) or macOS Vision framework (macOS).
///
/// Designed for use when barcode lookup fails — the user photographs the
/// cover and the most prominent text (likely the title) is extracted and
/// used as a search query.
class CoverOcrHelper {
  CoverOcrHelper({TextRecognizer? recognizer, ImagePicker? picker})
      : _recognizer = recognizer ?? TextRecognizer(),
        _picker = picker ?? ImagePicker();

  final TextRecognizer _recognizer;
  final ImagePicker _picker;

  /// Captures a photo using the camera and extracts the most prominent
  /// text from it. Returns `null` if the user cancels or no text is found.
  Future<String?> captureAndExtract() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 85,
    );
    if (photo == null) return null;

    return extractFromFile(photo.path);
  }

  /// Picks an image from the gallery (useful on desktop where the camera
  /// picker may not be available) and extracts text.
  Future<String?> pickAndExtract() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (photo == null) return null;

    return extractFromFile(photo.path);
  }

  /// Extracts the most prominent text from an image file at [path].
  ///
  /// On macOS, uses the Vision framework via a method channel.
  /// On Android/iOS, uses Google ML Kit text recognition.
  /// Returns `null` if no text is recognised.
  Future<String?> extractFromFile(String path) async {
    // macOS: use Vision framework
    if (VisionOcrChannel.isAvailable) {
      return _extractWithVision(path);
    }

    // Android/iOS: use ML Kit
    return _extractWithMlKit(path);
  }

  Future<String?> _extractWithVision(String path) async {
    try {
      final text = await VisionOcrChannel.recogniseText(path);
      if (text == null || text.isEmpty) return null;
      return cleanTitle(text);
    } on Exception catch (e) {
      debugPrint('Vision OCR failed: $e');
      return null;
    }
  }

  Future<String?> _extractWithMlKit(String path) async {
    try {
      final inputImage = InputImage.fromFilePath(path);
      final recognised = await _recognizer.processImage(inputImage);

      if (recognised.text.isEmpty) return null;

      // Find the text block with the largest bounding box — most likely
      // the title or most prominent text on the cover.
      final blocks = recognised.blocks.toList()
        ..sort((a, b) {
          final areaA = a.boundingBox.width * a.boundingBox.height;
          final areaB = b.boundingBox.width * b.boundingBox.height;
          return areaB.compareTo(areaA); // Descending by area
        });

      if (blocks.isEmpty) return null;

      // Take the largest block's text, cleaned up
      final title = cleanTitle(blocks.first.text);
      return title.isEmpty ? null : title;
    } on Exception catch (e) {
      debugPrint('Cover OCR failed: $e');
      return null;
    }
  }

  /// Removes common noise from OCR-extracted text.
  @visibleForTesting
  static String cleanTitle(String raw) {
    return raw
        .replaceAll(RegExp(r'\n+'), ' ') // Collapse newlines
        .replaceAll(RegExp(r'\s+'), ' ') // Collapse whitespace
        .replaceAll(RegExp(r'[™®©]'), '') // Remove trademark symbols
        .trim();
  }

  /// Releases resources held by the text recogniser.
  Future<void> dispose() async {
    await _recognizer.close();
  }
}
