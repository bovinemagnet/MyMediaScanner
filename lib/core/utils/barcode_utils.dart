/// Barcode type detection and classification utilities.
enum BarcodeType { ean13, upcA, isbn13, isbn10, imdbId, unknown }

/// Regex matching IMDb title IDs (e.g. tt1234567).
final _imdbIdPattern = RegExp(r'^tt\d{7,}$', caseSensitive: false);

abstract final class BarcodeUtils {
  /// Detect the barcode type from the raw string value.
  static BarcodeType detectBarcodeType(String barcode) {
    final cleaned = barcode.trim();

    // IMDb title ID (tt1234567)
    if (_imdbIdPattern.hasMatch(cleaned)) {
      return BarcodeType.imdbId;
    }

    if (cleaned.length == 13 && RegExp(r'^\d{13}$').hasMatch(cleaned)) {
      if (cleaned.startsWith('978') || cleaned.startsWith('979')) {
        return BarcodeType.isbn13;
      }
      return BarcodeType.ean13;
    }

    if (cleaned.length == 12 && RegExp(r'^\d{12}$').hasMatch(cleaned)) {
      return BarcodeType.upcA;
    }

    if (cleaned.length == 10 && RegExp(r'^\d{9}[\dXx]$').hasMatch(cleaned)) {
      return BarcodeType.isbn10;
    }

    return BarcodeType.unknown;
  }

  /// Returns true if the barcode is an ISBN (10 or 13).
  static bool isIsbn(String barcode) {
    final type = detectBarcodeType(barcode);
    return type == BarcodeType.isbn13 || type == BarcodeType.isbn10;
  }

  /// Returns true if the input is an IMDb title ID.
  static bool isImdbId(String input) =>
      detectBarcodeType(input) == BarcodeType.imdbId;

  /// Canonicalise a barcode for use as a cache key.
  ///
  /// Normalises so the same physical product produces the same key
  /// regardless of how it was captured. Without this, scanning a book as
  /// `0-1234-56789-7` (hyphenated ISBN) and again as `0123456789` (clean)
  /// produces two cache rows and the second scan re-hits the API.
  ///
  /// Rules:
  /// - Trim and uppercase (`tt0133093` and `TT0133093` collide).
  /// - Strip all whitespace and dashes (`978-0-141 03615-9` →
  ///   `9780141036159`).
  /// - If the result is 11 digits and starts with a digit, treat as a
  ///   UPC-A whose leading zero was dropped by the scanner and re-pad
  ///   to 12 digits.
  /// - Otherwise return as-is.
  static String normaliseForCache(String raw) {
    final stripped =
        raw.trim().toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    if (stripped.length == 11 && RegExp(r'^\d{11}$').hasMatch(stripped)) {
      return '0$stripped';
    }
    return stripped;
  }
}
