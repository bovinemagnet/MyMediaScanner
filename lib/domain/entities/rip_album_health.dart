// Author: Paul Snow

import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

/// Derived health classification for a rip album, computed from its
/// tracks' AccurateRip and defect-analysis results. Never persisted —
/// always recomputed so it stays in sync with analysis runs.
enum RipAlbumHealth { verified, attention, mismatch, notAnalysed }

/// Classify an album from its tracks. Precedence (first match wins):
/// notAnalysed → mismatch → attention → verified.
///
/// Unknown or missing `accurateRipStatus` values on analysed tracks are
/// treated as "analysed but unverified" (attention), never as mismatch.
RipAlbumHealth classifyRipAlbumHealth(List<RipTrack> tracks) {
  final analysed =
      tracks.where((t) => t.qualityCheckedAt != null).toList(growable: false);
  if (analysed.isEmpty) return RipAlbumHealth.notAnalysed;
  if (analysed.any((t) => t.accurateRipStatus == 'mismatch')) {
    return RipAlbumHealth.mismatch;
  }
  final allTracksVerified = analysed.length == tracks.length &&
      analysed.every((t) => t.accurateRipStatus == 'verified');
  final anyDefects = analysed.any((t) => t.totalDefects > 0);
  if (anyDefects || !allTracksVerified) return RipAlbumHealth.attention;
  return RipAlbumHealth.verified;
}

/// Library-wide aggregate for the rips header stat cards.
class RipLibraryHealthStats {
  const RipLibraryHealthStats({
    required this.counts,
    required this.arVerifiedTracks,
    required this.totalTracks,
    required this.totalSizeBytes,
  });

  final Map<RipAlbumHealth, int> counts;
  final int arVerifiedTracks;
  final int totalTracks;
  final int totalSizeBytes;

  int get totalAlbums => counts.values.fold(0, (a, b) => a + b);

  /// AR-verified tracks as a fraction of all tracks (0 when empty).
  double get arCoverage =>
      totalTracks == 0 ? 0 : arVerifiedTracks / totalTracks;
}

RipLibraryHealthStats computeRipLibraryHealthStats({
  required List<RipAlbum> albums,
  required Map<String, List<RipTrack>> tracksByAlbum,
}) {
  final counts = {for (final h in RipAlbumHealth.values) h: 0};
  var arVerified = 0;
  var totalTracks = 0;
  var totalSize = 0;
  for (final album in albums) {
    final tracks = tracksByAlbum[album.id] ?? const <RipTrack>[];
    final health = classifyRipAlbumHealth(tracks);
    counts[health] = counts[health]! + 1;
    arVerified +=
        tracks.where((t) => t.accurateRipStatus == 'verified').length;
    totalTracks += tracks.length;
    totalSize += album.totalSizeBytes;
  }
  return RipLibraryHealthStats(
    counts: counts,
    arVerifiedTracks: arVerified,
    totalTracks: totalTracks,
    totalSizeBytes: totalSize,
  );
}
