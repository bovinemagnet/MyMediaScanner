/// Result types for a GnuDB (CDDB) `cddb query` request.
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

/// Sealed result type for a GnuDB query.
sealed class GnudbQueryResult {
  const GnudbQueryResult();
}

/// Response code 200 — a single exact match.
class GnudbQuerySingle extends GnudbQueryResult {
  const GnudbQuerySingle(this.match);
  final GnudbQueryMatch match;
}

/// Response code 210 or 211 — multiple matches to disambiguate between.
class GnudbQueryMulti extends GnudbQueryResult {
  const GnudbQueryMulti(this.matches);
  final List<GnudbQueryMatch> matches;
}

/// Response code 202 — no match for the supplied Disc ID.
class GnudbQueryNoMatch extends GnudbQueryResult {
  const GnudbQueryNoMatch();
}

/// Any other response code (401, 403, 5xx…) or malformed body.
class GnudbQueryError extends GnudbQueryResult {
  const GnudbQueryError({required this.code, required this.message});
  final int code;
  final String message;
}
