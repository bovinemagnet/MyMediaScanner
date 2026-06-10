/// Disc-level metadata returned by a GnuDB (CDDB) `cddb read` request.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

/// Parsed disc-level metadata from a GnuDB read response.
class GnudbDisc {
  const GnudbDisc({
    required this.discId,
    required this.artist,
    required this.albumTitle,
    required this.trackTitles,
    this.year,
    this.genre,
    this.extendedAlbum,
    this.extendedTracks = const [],
  });

  /// Disc identifier this metadata is for (8-char hex).
  final String discId;

  /// Artist portion of `DTITLE` (before the `/`). Falls back to the whole
  /// DTITLE when no slash is present.
  final String artist;

  /// Album portion of `DTITLE` (after the `/`). Falls back to the whole
  /// DTITLE when no slash is present.
  final String albumTitle;

  /// Parsed `DYEAR` value. `null` when absent or unparseable.
  final int? year;

  /// Parsed `DGENRE` value. `null` when absent or empty.
  final String? genre;

  /// Per-track titles from `TTITLE0..TTITLEn`, in index order. Continuation
  /// lines (a repeated key) are joined per the CDDB protocol.
  final List<String> trackTitles;

  /// Parsed `EXTD` album-level notes.
  final String? extendedAlbum;

  /// Parsed `EXTT0..EXTTn` per-track notes, in index order. Empty strings
  /// are preserved to keep alignment with [trackTitles].
  final List<String> extendedTracks;
}

/// Pairs a `MetadataResult`-ready payload with its GnuDB disc id.
class GnudbCandidate {
  const GnudbCandidate({
    required this.discId,
    required this.category,
    required this.disc,
  });
  final String discId;
  final String category;
  final GnudbDisc disc;
}
