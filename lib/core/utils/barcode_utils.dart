/// Barcode type detection and classification utilities.
enum BarcodeType { ean13, upcA, isbn13, isbn10, unknown }

abstract final class BarcodeUtils {
  /// Detect the barcode type from the raw string value.
  static BarcodeType detectBarcodeType(String barcode) {
    final cleaned = barcode.trim();

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
}
