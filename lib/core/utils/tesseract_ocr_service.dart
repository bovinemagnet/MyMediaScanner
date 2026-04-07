import 'package:flutter/foundation.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

import 'package:mymediascanner/core/utils/cover_ocr_helper.dart';
import 'package:mymediascanner/domain/entities/ocr_result.dart';

/// OCR service using Tesseract for Windows and Linux.
///
/// Provides text recognition from cover images when ML Kit (Android/iOS)
/// and Vision framework (macOS) are unavailable.
class TesseractOcrService {
  /// Extract structured OCR output from an image file at [path].
  ///
  /// Returns an empty [OcrResult] if no text is recognised.
  Future<OcrResult> extractStructuredFromFile(String path) async {
    try {
      final text = await FlutterTesseractOcr.extractText(
        path,
        language: 'eng',
      );

      if (text.isEmpty) return const OcrResult();

      // Tesseract returns text as a single block; split into lines
      // and treat each non-empty line as a potential title block.
      final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
      if (lines.isEmpty) return const OcrResult();

      final blocks = lines.asMap().entries.map((entry) {
        final cleaned = CoverOcrHelper.cleanTitle(entry.value);
        // Estimate relative area: first/largest lines are more likely the title.
        final area = 1.0 / (entry.key + 1);
        return OcrTextBlock(
          text: cleaned,
          confidence: 0.75, // Tesseract accuracy is generally lower than ML Kit
          area: area,
        );
      }).where((b) => b.text.isNotEmpty).toList();

      return OcrResult(blocks: blocks);
    } on Exception catch (e) {
      debugPrint('Tesseract OCR failed: $e');
      return const OcrResult();
    }
  }
}
