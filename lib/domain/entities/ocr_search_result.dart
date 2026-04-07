import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mymediascanner/domain/entities/ocr_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';

part 'ocr_search_result.freezed.dart';

/// Wraps a [ScanResult] with additional OCR context: the original
/// [OcrResult], the cleaned search terms used, and the confidence
/// assessment. This allows downstream UI to show the user what text
/// was recognised and how confident the system is.
@freezed
sealed class OcrSearchResult with _$OcrSearchResult {
  const factory OcrSearchResult({
    required ScanResult scanResult,
    required OcrResult ocrResult,
    required String searchTermUsed,
    String? inferredArtist,
    int? inferredYear,
    required double confidence,
  }) = _OcrSearchResult;
}
