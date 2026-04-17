/// A single match from a CDDB `cddb query` response.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

/// One candidate returned by a GnuDB query.
class GnudbQueryMatch {
  const GnudbQueryMatch({
    required this.category,
    required this.discId,
    required this.title,
  });

  /// Category (genre bucket) the match lives in — e.g. `rock`, `classical`.
  final String category;

  /// 8-character hex CDDB Disc ID (may differ from the queried ID for 211
  /// inexact matches).
  final String discId;

  /// The concatenated "Artist / Album" title field.
  final String title;

  @override
  String toString() => 'GnudbQueryMatch($category $discId $title)';

  @override
  bool operator ==(Object other) =>
      other is GnudbQueryMatch &&
      other.category == category &&
      other.discId == discId &&
      other.title == title;

  @override
  int get hashCode => Object.hash(category, discId, title);
}
