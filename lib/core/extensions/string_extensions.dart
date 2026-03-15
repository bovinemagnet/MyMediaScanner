extension StringExtensions on String {
  /// Capitalise first letter.
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Convert to title case.
  String get titleCase =>
      split(' ').map((word) => word.capitalised).join(' ');
}
