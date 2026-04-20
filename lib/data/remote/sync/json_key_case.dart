/// Utilities for normalising map key casing between Drift's camelCase JSON
/// output (`barcodeType`, `updatedAt`, …) and PostgreSQL's snake_case column
/// names (`barcode_type`, `updated_at`, …).
///
/// The sync pipeline compares local and remote rows by key, so the two
/// sides must agree on casing before any merge or conflict detection runs.
abstract final class JsonKeyCase {
  /// Convert every key in [map] from camelCase to snake_case.
  ///
  /// Pure key transform — values are passed through unchanged. Keys that
  /// are already snake_case (contain an underscore) are left alone.
  static Map<String, dynamic> toSnakeCase(Map<String, dynamic> map) {
    final out = <String, dynamic>{};
    for (final entry in map.entries) {
      out[_camelToSnake(entry.key)] = entry.value;
    }
    return out;
  }

  /// Convert every key in [map] from snake_case to camelCase.
  static Map<String, dynamic> toCamelCase(Map<String, dynamic> map) {
    final out = <String, dynamic>{};
    for (final entry in map.entries) {
      out[_snakeToCamel(entry.key)] = entry.value;
    }
    return out;
  }

  static String _camelToSnake(String input) {
    if (input.contains('_')) return input;
    final buf = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final ch = input[i];
      final lower = ch.toLowerCase();
      if (ch != lower && i > 0) {
        buf.write('_');
      }
      buf.write(lower);
    }
    return buf.toString();
  }

  static String _snakeToCamel(String input) {
    if (!input.contains('_')) return input;
    final parts = input.split('_');
    final buf = StringBuffer(parts.first);
    for (var i = 1; i < parts.length; i++) {
      final p = parts[i];
      if (p.isEmpty) continue;
      buf
        ..write(p[0].toUpperCase())
        ..write(p.substring(1));
    }
    return buf.toString();
  }
}
