import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ocr_result.dart';

/// Holds the result of analysing OCR text blocks.
class OcrTextAnalysis {
  const OcrTextAnalysis({
    this.cleanedTitle,
    this.cleanedArtist,
    this.year,
    this.inferredMediaType,
    required this.confidence,
  });

  final String? cleanedTitle;
  final String? cleanedArtist;
  final int? year;
  final MediaType? inferredMediaType;
  final double confidence;
}

/// Utility functions for interpreting OCR text from media covers.
abstract final class OcrTextAnalysisUtils {
  /// Noise words commonly found on media covers but unhelpful for search.
  static const noiseWords = {
    'blu-ray',
    'bluray',
    'dvd',
    'cd',
    'disc',
    'digital',
    'remastered',
    'special edition',
    'deluxe',
    'limited edition',
    'widescreen',
    'dolby',
    'atmos',
    '4k',
    'uhd',
    'hdr',
  };

  /// Patterns that suggest a specific media type.
  static const _filmIndicators = {
    'blu-ray', 'bluray', 'dvd', 'widescreen', '4k', 'uhd', 'hdr',
  };
  static const _musicIndicators = {'cd', 'vinyl', 'lp', 'album'};
  static const _bookIndicators = {'isbn', 'hardcover', 'paperback'};

  /// Extracts a year (1900-2099) from text. Returns the first match.
  static int? extractYear(String text) {
    final match = RegExp(r'\b(19\d{2}|20\d{2})\b').firstMatch(text);
    if (match == null) return null;
    return int.parse(match.group(1)!);
  }

  /// Removes noise words from text, case-insensitive.
  static String removeNoiseWords(String text) {
    var cleaned = text;
    // Remove multi-word noise phrases first
    for (final phrase in noiseWords.where((w) => w.contains(' '))) {
      cleaned = cleaned.replaceAll(
        RegExp(RegExp.escape(phrase), caseSensitive: false),
        '',
      );
    }
    // Remove single-word noise
    for (final word in noiseWords.where((w) => !w.contains(' '))) {
      cleaned = cleaned.replaceAll(
        RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false),
        '',
      );
    }
    // Clean up parentheses with only whitespace/numbers (leftover years)
    cleaned = cleaned.replaceAll(RegExp(r'\(\s*\)'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\(\s*\d{4}\s*\)'), '');
    // Collapse whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  /// Attempts to split "Artist - Title" or "Title by Artist" patterns.
  /// Returns a record of (title, artist) or null if no pattern matched.
  static ({String title, String artist})? splitTitleArtist(String text) {
    // "Artist - Title" pattern
    final dashMatch = RegExp(r'^(.+?)\s*[-\u2013\u2014]\s*(.+)$').firstMatch(text);
    if (dashMatch != null) {
      final left = dashMatch.group(1)!.trim();
      final right = dashMatch.group(2)!.trim();
      if (left.isNotEmpty && right.isNotEmpty) {
        return (title: right, artist: left);
      }
    }

    // "Title by Artist" pattern
    final byMatch =
        RegExp(r'^(.+?)\s+by\s+(.+)$', caseSensitive: false).firstMatch(text);
    if (byMatch != null) {
      final title = byMatch.group(1)!.trim();
      final artist = byMatch.group(2)!.trim();
      if (title.isNotEmpty && artist.isNotEmpty) {
        return (title: title, artist: artist);
      }
    }

    return null;
  }

  /// Infers media type from OCR text clues.
  static MediaType? inferMediaType(String text) {
    final lower = text.toLowerCase();
    for (final indicator in _bookIndicators) {
      if (lower.contains(indicator)) return MediaType.book;
    }
    for (final indicator in _filmIndicators) {
      if (lower.contains(indicator)) return MediaType.film;
    }
    for (final indicator in _musicIndicators) {
      if (lower.contains(indicator)) return MediaType.music;
    }
    // ISBN pattern
    if (RegExp(r'978[-\s]?\d[-\s]?\d{2}[-\s]?\d{6}[-\s]?\d').hasMatch(lower)) {
      return MediaType.book;
    }
    return null;
  }

  /// Analyses an [OcrResult] to extract title, artist, year, and media type.
  static OcrTextAnalysis analyse(OcrResult result) {
    if (result.isEmpty) {
      return const OcrTextAnalysis(confidence: 0.0);
    }

    final allText = result.blocks.map((b) => b.text).join(' ');
    final year = extractYear(allText);
    final inferredType = inferMediaType(allText);

    final primaryRaw = result.primaryText;
    final secondaryRaw = result.secondaryText;

    String? title;
    String? artist;

    if (primaryRaw != null) {
      final cleaned = removeNoiseWords(primaryRaw);
      // Try to split if it contains artist-title pattern
      final split = splitTitleArtist(cleaned);
      if (split != null) {
        title = split.title;
        artist = split.artist;
      } else {
        title = cleaned.isEmpty ? null : cleaned;
      }
    }

    if (artist == null && secondaryRaw != null) {
      final cleaned = removeNoiseWords(secondaryRaw);
      if (cleaned.isNotEmpty) {
        artist = cleaned;
      }
    }

    return OcrTextAnalysis(
      cleanedTitle: title,
      cleanedArtist: artist,
      year: year,
      inferredMediaType: inferredType,
      confidence: result.overallConfidence,
    );
  }
}
