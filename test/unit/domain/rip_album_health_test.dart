import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_album_health.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

RipTrack track({
  String id = 't1',
  int? checkedAt = 1,
  String? arStatus,
  int clicks = 0,
  int pops = 0,
}) {
  return RipTrack(
    id: id,
    ripAlbumId: 'a1',
    trackNumber: 1,
    filePath: '/x/$id.flac',
    fileSizeBytes: 1000,
    updatedAt: 0,
    qualityCheckedAt: checkedAt,
    accurateRipStatus: arStatus,
    clickCount: clicks,
    popCount: pops,
  );
}

RipAlbum album(String id, {int size = 100}) => RipAlbum(
      id: id,
      libraryPath: '/lib/$id',
      trackCount: 1,
      totalSizeBytes: size,
      lastScannedAt: 0,
      updatedAt: 0,
    );

void main() {
  group('classifyRipAlbumHealth', () {
    test('empty track list is notAnalysed', () {
      expect(classifyRipAlbumHealth(const []), RipAlbumHealth.notAnalysed);
    });

    test('no track analysed is notAnalysed', () {
      expect(
        classifyRipAlbumHealth([track(checkedAt: null)]),
        RipAlbumHealth.notAnalysed,
      );
    });

    test('any mismatch wins over defects', () {
      expect(
        classifyRipAlbumHealth([
          track(arStatus: 'verified'),
          track(id: 't2', arStatus: 'mismatch', clicks: 3),
        ]),
        RipAlbumHealth.mismatch,
      );
    });

    test('all verified with zero defects is verified', () {
      expect(
        classifyRipAlbumHealth([
          track(arStatus: 'verified'),
          track(id: 't2', arStatus: 'verified'),
        ]),
        RipAlbumHealth.verified,
      );
    });

    test('verified but with defects is attention', () {
      expect(
        classifyRipAlbumHealth([track(arStatus: 'verified', pops: 2)]),
        RipAlbumHealth.attention,
      );
    });

    test('analysed but unverified (AR not found) is attention, not mismatch',
        () {
      expect(
        classifyRipAlbumHealth([track(arStatus: 'notFound')]),
        RipAlbumHealth.attention,
      );
    });

    test('partially analysed album is attention even if analysed ones pass',
        () {
      expect(
        classifyRipAlbumHealth([
          track(arStatus: 'verified'),
          track(id: 't2', checkedAt: null),
        ]),
        RipAlbumHealth.attention,
      );
    });
  });

  group('computeRipLibraryHealthStats', () {
    test('aggregates counts, AR coverage and size', () {
      final stats = computeRipLibraryHealthStats(
        albums: [album('a', size: 100), album('b', size: 200)],
        tracksByAlbum: {
          'a': [track(arStatus: 'verified'), track(id: 't2', arStatus: 'verified')],
          'b': [track(arStatus: 'mismatch')],
        },
      );
      expect(stats.counts[RipAlbumHealth.verified], 1);
      expect(stats.counts[RipAlbumHealth.mismatch], 1);
      expect(stats.counts[RipAlbumHealth.attention], 0);
      expect(stats.counts[RipAlbumHealth.notAnalysed], 0);
      expect(stats.totalAlbums, 2);
      expect(stats.arVerifiedTracks, 2);
      expect(stats.totalTracks, 3);
      expect(stats.arCoverage, closeTo(2 / 3, 0.0001));
      expect(stats.totalSizeBytes, 300);
    });

    test('album with no tracks entry counts as notAnalysed', () {
      final stats = computeRipLibraryHealthStats(
        albums: [album('a')],
        tracksByAlbum: const {},
      );
      expect(stats.counts[RipAlbumHealth.notAnalysed], 1);
    });

    test('empty library has zero coverage, no division by zero', () {
      final stats = computeRipLibraryHealthStats(
        albums: const [],
        tracksByAlbum: const {},
      );
      expect(stats.arCoverage, 0);
      expect(stats.totalAlbums, 0);
    });
  });
}
