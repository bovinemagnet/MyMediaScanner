/// Tests for rip coverage categorisation and aggregate stats.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_coverage.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

MediaItem music(
  String id, {
  List<String>? trackListing,
}) {
  return MediaItem(
    id: id,
    barcode: 'b$id',
    barcodeType: 'EAN13',
    mediaType: MediaType.music,
    title: 'Album $id',
    extraMetadata: trackListing == null ? const {} : {'track_listing': trackListing},
    dateAdded: 0,
    dateScanned: 0,
    updatedAt: 0,
  );
}

RipAlbum album(String id, String mediaItemId, {int trackCount = 10}) => RipAlbum(
      id: id,
      libraryPath: '/lib/$id',
      mediaItemId: mediaItemId,
      trackCount: trackCount,
      totalSizeBytes: 0,
      lastScannedAt: 0,
      updatedAt: 0,
    );

RipTrack track(
  String albumId, {
  String? arStatus,
  int? checkedAt,
  int clicks = 0,
}) =>
    RipTrack(
      id: '$albumId-t',
      ripAlbumId: albumId,
      trackNumber: 1,
      filePath: '/x.flac',
      fileSizeBytes: 0,
      updatedAt: 0,
      accurateRipStatus: arStatus,
      qualityCheckedAt: checkedAt,
      clickCount: clicks,
    );

void main() {
  group('categoriseRipCoverage', () {
    test('unlinked music item is notRipped', () {
      final entries = categoriseRipCoverage(
        items: [music('m1')],
        albums: const [],
        tracksByAlbum: const {},
      );
      expect(entries.single.status, CoverageStatus.notRipped);
      expect(entries.single.album, isNull);
    });

    test('linked with fewer tracks than listing is partiallyRipped', () {
      final entries = categoriseRipCoverage(
        items: [music('m1', trackListing: ['a', 'b', 'c'])],
        albums: [album('a1', 'm1', trackCount: 2)],
        tracksByAlbum: const {},
      );
      expect(entries.single.status, CoverageStatus.partiallyRipped);
    });

    test('linked and complete with no analysis is fullyRipped', () {
      final entries = categoriseRipCoverage(
        items: [music('m1', trackListing: ['a', 'b'])],
        albums: [album('a1', 'm1', trackCount: 2)],
        tracksByAlbum: {
          'a1': [track('a1')], // no qualityCheckedAt
        },
      );
      expect(entries.single.status, CoverageStatus.fullyRipped);
    });

    test('complete but analysed with defects is qualityIssues', () {
      final entries = categoriseRipCoverage(
        items: [music('m1', trackListing: ['a', 'b'])],
        albums: [album('a1', 'm1', trackCount: 2)],
        tracksByAlbum: {
          'a1': [track('a1', arStatus: 'verified', checkedAt: 1, clicks: 3)],
        },
      );
      expect(entries.single.status, CoverageStatus.qualityIssues);
    });

    test('complete but analysed with mismatch is qualityIssues', () {
      final entries = categoriseRipCoverage(
        items: [music('m1', trackListing: ['a'])],
        albums: [album('a1', 'm1', trackCount: 1)],
        tracksByAlbum: {
          'a1': [track('a1', arStatus: 'mismatch', checkedAt: 1)],
        },
      );
      expect(entries.single.status, CoverageStatus.qualityIssues);
    });

    test('empty track listing treats any linked album as fully ripped', () {
      final entries = categoriseRipCoverage(
        items: [music('m1')], // no track_listing
        albums: [album('a1', 'm1', trackCount: 5)],
        tracksByAlbum: const {},
      );
      expect(entries.single.status, CoverageStatus.fullyRipped);
    });

    test('entries are sorted by status index', () {
      final entries = categoriseRipCoverage(
        items: [
          music('m1', trackListing: ['a']), // fully (linked below)
          music('m2'), // not ripped
        ],
        albums: [album('a1', 'm1', trackCount: 1)],
        tracksByAlbum: const {},
      );
      expect(entries.first.status, CoverageStatus.notRipped);
    });
  });

  group('computeRipCoverageStats', () {
    test('counts per status, ripped count and coverage percent', () {
      final entries = categoriseRipCoverage(
        items: [
          music('m1', trackListing: ['a']), // fully
          music('m2', trackListing: ['a', 'b']), // partial (album has 1)
          music('m3'), // not ripped
          music('m4', trackListing: ['a']), // quality issues
        ],
        albums: [
          album('a1', 'm1', trackCount: 1),
          album('a2', 'm2', trackCount: 1),
          album('a4', 'm4', trackCount: 1),
        ],
        tracksByAlbum: {
          'a4': [track('a4', arStatus: 'mismatch', checkedAt: 1)],
        },
      );
      final stats = computeRipCoverageStats(entries);
      expect(stats.total, 4);
      expect(stats.countOf(CoverageStatus.fullyRipped), 1);
      expect(stats.countOf(CoverageStatus.partiallyRipped), 1);
      expect(stats.countOf(CoverageStatus.notRipped), 1);
      expect(stats.countOf(CoverageStatus.qualityIssues), 1);
      // ripped = fully + qualityIssues
      expect(stats.rippedCount, 2);
      expect(stats.coveragePercent, 50);
    });

    test('empty collection is zero coverage, no division by zero', () {
      final stats = computeRipCoverageStats(const []);
      expect(stats.total, 0);
      expect(stats.coveragePercent, 0);
      expect(stats.rippedCount, 0);
    });
  });
}
