import 'package:flutter/foundation.dart';
import 'package:mymediascanner/core/utils/ocr_text_analysis.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ocr_result.dart';
import 'package:mymediascanner/domain/entities/ocr_search_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';

/// Orchestrates the OCR-to-metadata pipeline: takes an [OcrResult],
/// applies heuristics to extract title/artist, builds search queries,
/// and returns an [OcrSearchResult].
class OcrMetadataUseCase {
  const OcrMetadataUseCase({
    required IMetadataRepository metadataRepository,
  }) : _metadataRepo = metadataRepository;

  final IMetadataRepository _metadataRepo;

  /// Minimum overall confidence to attempt a metadata search.
  static const double minConfidenceThreshold = 0.50;

  /// Executes the OCR-to-metadata search pipeline.
  Future<OcrSearchResult> execute(
    OcrResult ocrResult,
    String barcode,
    String barcodeType, {
    MediaType? typeHint,
  }) async {
    if (ocrResult.isEmpty) {
      return OcrSearchResult(
        scanResult: ScanResult.notFound(
          barcode: barcode,
          barcodeType: barcodeType,
        ),
        ocrResult: ocrResult,
        searchTermUsed: '',
        confidence: 0.0,
      );
    }

    final analysis = analyseText(ocrResult);

    if (analysis.confidence < minConfidenceThreshold) {
      return OcrSearchResult(
        scanResult: ScanResult.notFound(
          barcode: barcode,
          barcodeType: barcodeType,
        ),
        ocrResult: ocrResult,
        searchTermUsed: analysis.cleanedTitle ?? '',
        inferredArtist: analysis.cleanedArtist,
        inferredYear: analysis.year,
        confidence: analysis.confidence,
      );
    }

    final searchTitle = analysis.cleanedTitle;
    if (searchTitle == null || searchTitle.isEmpty) {
      return OcrSearchResult(
        scanResult: ScanResult.notFound(
          barcode: barcode,
          barcodeType: barcodeType,
        ),
        ocrResult: ocrResult,
        searchTermUsed: '',
        confidence: analysis.confidence,
      );
    }

    // Build search query — optionally append artist for better results
    var searchQuery = searchTitle;
    if (analysis.cleanedArtist != null &&
        analysis.cleanedArtist!.isNotEmpty) {
      searchQuery = '$searchTitle ${analysis.cleanedArtist}';
    }

    final effectiveTypeHint = typeHint ?? analysis.inferredMediaType;

    try {
      final scanResult = await _metadataRepo.searchByTitle(
        searchQuery,
        barcode,
        barcodeType,
        typeHint: effectiveTypeHint,
      );

      return OcrSearchResult(
        scanResult: scanResult,
        ocrResult: ocrResult,
        searchTermUsed: searchQuery,
        inferredArtist: analysis.cleanedArtist,
        inferredYear: analysis.year,
        confidence: analysis.confidence,
      );
    } catch (e) {
      debugPrint('OCR metadata search failed: $e');
      return OcrSearchResult(
        scanResult: ScanResult.notFound(
          barcode: barcode,
          barcodeType: barcodeType,
        ),
        ocrResult: ocrResult,
        searchTermUsed: searchQuery,
        inferredArtist: analysis.cleanedArtist,
        inferredYear: analysis.year,
        confidence: analysis.confidence,
      );
    }
  }

  /// Strips noise words and extracts year if present.
  @visibleForTesting
  static OcrTextAnalysis analyseText(OcrResult result) {
    return OcrTextAnalysisUtils.analyse(result);
  }
}
