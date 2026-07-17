// Author: Paul Snow

import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

/// Rip coverage status for a physical music item, comparing the collection
/// against the linked FLAC rip album.
enum CoverageStatus { notRipped, partiallyRipped, fullyRipped, qualityIssues }

/// One music item paired with its linked rip album (if any) and derived
/// coverage status.
class RipCoverageEntry {
  const RipCoverageEntry({
    required this.item,
    required this.album,
    required this.status,
  });

  final MediaItem item;
  final RipAlbum? album;
  final CoverageStatus status;
}

/// Categorise each music item's rip coverage.
///
/// `tracksByAlbum` supplies analysed tracks (keyed by rip album ID) used to
/// escalate a fully-ripped album to [CoverageStatus.qualityIssues] when a
/// track has an AccurateRip mismatch or recorded defects. Quality is only
/// considered once analysis has run (`qualityCheckedAt` set). Entries are
/// returned sorted by status index (notRipped first).
List<RipCoverageEntry> categoriseRipCoverage({
  required List<MediaItem> items,
  required List<RipAlbum> albums,
  required Map<String, List<RipTrack>> tracksByAlbum,
}) {
  final albumByMediaId = <String, RipAlbum>{};
  for (final album in albums) {
    if (album.mediaItemId != null) {
      albumByMediaId[album.mediaItemId!] = album;
    }
  }

  return items.map((item) {
    final linked = albumByMediaId[item.id];
    if (linked == null) {
      return RipCoverageEntry(
        item: item,
        album: null,
        status: CoverageStatus.notRipped,
      );
    }

    final trackListing = item.extraMetadata['track_listing'];
    final expectedTracks = trackListing is List ? trackListing.length : 0;
    final fullyRipped =
        expectedTracks == 0 || linked.trackCount >= expectedTracks;
    if (!fullyRipped) {
      return RipCoverageEntry(
        item: item,
        album: linked,
        status: CoverageStatus.partiallyRipped,
      );
    }

    final tracks = tracksByAlbum[linked.id] ?? const <RipTrack>[];
    final anyChecked = tracks.any((t) => t.qualityCheckedAt != null);
    final hasQualityIssues = anyChecked &&
        tracks.any((t) =>
            t.accurateRipStatus == 'mismatch' || t.totalDefects > 0);
    return RipCoverageEntry(
      item: item,
      album: linked,
      status: hasQualityIssues
          ? CoverageStatus.qualityIssues
          : CoverageStatus.fullyRipped,
    );
  }).toList()
    ..sort((a, b) => a.status.index.compareTo(b.status.index));
}

/// Library-wide aggregate of rip coverage for the header stat cards.
class RipCoverageStats {
  const RipCoverageStats({required this.counts, required this.total});

  final Map<CoverageStatus, int> counts;
  final int total;

  int countOf(CoverageStatus status) => counts[status] ?? 0;

  /// Items with a complete rip (fully ripped, with or without quality issues).
  int get rippedCount =>
      countOf(CoverageStatus.fullyRipped) +
      countOf(CoverageStatus.qualityIssues);

  int get coveragePercent =>
      total == 0 ? 0 : (rippedCount * 100 / total).round();
}

RipCoverageStats computeRipCoverageStats(List<RipCoverageEntry> entries) {
  final counts = {for (final s in CoverageStatus.values) s: 0};
  for (final entry in entries) {
    counts[entry.status] = counts[entry.status]! + 1;
  }
  return RipCoverageStats(counts: counts, total: entries.length);
}
