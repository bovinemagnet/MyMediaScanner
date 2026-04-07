import 'package:freezed_annotation/freezed_annotation.dart';

part 'ocr_result.freezed.dart';

/// A single block of text recognised by OCR, with its confidence score
/// and bounding-box area (used as a prominence proxy).
@freezed
sealed class OcrTextBlock with _$OcrTextBlock {
  const OcrTextBlock._();

  const factory OcrTextBlock({
    required String text,
    required double confidence,
    required double area,
  }) = _OcrTextBlock;
}

/// Structured OCR output containing multiple recognised text blocks,
/// ordered by prominence (bounding-box area, descending).
@freezed
sealed class OcrResult with _$OcrResult {
  const OcrResult._();

  const factory OcrResult({
    @Default([]) List<OcrTextBlock> blocks,
  }) = _OcrResult;

  /// Blocks sorted by area descending (most prominent first).
  List<OcrTextBlock> get _sorted =>
      [...blocks]..sort((a, b) => b.area.compareTo(a.area));

  bool get isEmpty => blocks.isEmpty;

  /// The most prominent text block (largest bounding box), likely the title.
  String? get primaryText => _sorted.isEmpty ? null : _sorted.first.text;

  /// The second most prominent text block, likely the artist/author.
  String? get secondaryText => _sorted.length < 2 ? null : _sorted[1].text;

  /// Average confidence across all blocks. Returns 0.0 if empty.
  double get overallConfidence {
    if (blocks.isEmpty) return 0.0;
    return blocks.map((b) => b.confidence).reduce((a, b) => a + b) /
        blocks.length;
  }

  /// Alias for primaryText — the inferred title.
  String? get inferredTitle => primaryText;

  /// Alias for secondaryText — the inferred artist/author/subtitle.
  String? get inferredArtist => secondaryText;

  /// Returns only blocks with confidence at or above [threshold].
  List<OcrTextBlock> highConfidenceBlocks({double threshold = 0.70}) =>
      blocks.where((b) => b.confidence >= threshold).toList();
}
