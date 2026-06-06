import 'package:mymediascanner/domain/entities/ocr_result.dart';

/// Desktop (Windows/Linux) cover-OCR service.
///
/// Tesseract is not currently wired on desktop. The former
/// `flutter_tesseract_ocr` dependency only shipped Android/iOS native code
/// (never Windows/Linux), so this path already returned no text at runtime
/// — and on iOS it pulled a `SwiftyTesseract` pod with no arm64-simulator
/// slice, breaking Apple-Silicon simulator builds. Until a desktop-capable
/// Tesseract binding is added, desktop cover OCR returns an empty result,
/// matching the prior behaviour.
class TesseractOcrService {
  /// Returns an empty [OcrResult]; desktop Tesseract OCR is not wired.
  Future<OcrResult> extractStructuredFromFile(String path) async {
    return const OcrResult();
  }
}
