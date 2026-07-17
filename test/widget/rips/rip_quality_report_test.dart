/// Widget tests for [RipQualityReport] and [RipSourceSection].
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_quality_report.dart';

List<RipTrack> _verifiedTracks() => [
  const RipTrack(
    id: 't1',
    ripAlbumId: 'a',
    trackNumber: 1,
    filePath: '/library/a/track1.flac',
    fileSizeBytes: 1024,
    updatedAt: 0,
    accurateRipStatus: 'verified',
    accurateRipConfidence: 156,
    trackQuality: 0.98,
    peakLevel: 0.996,
    ripLogSource: 'XLD',
  ),
  const RipTrack(
    id: 't2',
    ripAlbumId: 'a',
    trackNumber: 2,
    filePath: '/library/a/track2.flac',
    fileSizeBytes: 1024,
    updatedAt: 0,
    accurateRipStatus: 'verified',
    accurateRipConfidence: 142,
    trackQuality: 1.0,
    peakLevel: 0.9,
    ripLogSource: 'XLD',
  ),
];

const _album = RipAlbum(
  id: 'a',
  libraryPath: '/library/a',
  artist: 'Test Artist',
  albumTitle: 'Test Album',
  trackCount: 2,
  totalSizeBytes: 2048,
  lastScannedAt: 0,
  updatedAt: 0,
  cueFilePath: '/library/a/album.cue',
);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('RipQualityReport', () {
    testWidgets(
      'shows quality score, minimum AR confidence, peak and defects',
      (tester) async {
        await tester.pumpWidget(
          _wrap(RipQualityReport(tracks: _verifiedTracks())),
        );

        expect(find.text('QUALITY SCORE'), findsOneWidget);
        expect(find.textContaining('99'), findsWidgets);

        expect(find.text('AR CONFIDENCE'), findsOneWidget);
        expect(find.text('142'), findsOneWidget);

        expect(find.text('PEAK LEVEL'), findsOneWidget);
        expect(find.textContaining('99.6'), findsOneWidget);

        expect(find.text('DEFECTS'), findsOneWidget);
        expect(find.text('0'), findsOneWidget);
      },
    );
  });

  group('RipSourceSection', () {
    testWidgets(
      'shows rip tool, CUE + LOG presence and missing GNUDB disc id',
      (tester) async {
        await tester.pumpWidget(
          _wrap(RipSourceSection(album: _album, tracks: _verifiedTracks())),
        );

        expect(find.text('XLD'), findsOneWidget);
        // The row label itself reads "CUE + LOG" and the computed value for
        // this fixture (both CUE path and LOG source present) is also
        // "CUE + LOG", so two matches are expected.
        expect(find.text('CUE + LOG'), findsNWidgets(2));
        expect(find.text('—'), findsOneWidget);
      },
    );
  });
}
