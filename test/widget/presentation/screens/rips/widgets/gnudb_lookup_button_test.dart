import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/gnudb_lookup_button.dart';

RipAlbum _album({String? cue = 'x.cue', int discCount = 1}) => RipAlbum(
      id: 'a',
      libraryPath: '/lib',
      trackCount: 1,
      discCount: discCount,
      totalSizeBytes: 0,
      cueFilePath: cue,
      lastScannedAt: 0,
      updatedAt: 0,
    );

Widget _pumpable(Widget child) => ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('button is disabled when album has no CUE', (tester) async {
    await tester.pumpWidget(
      _pumpable(GnudbLookupButton(album: _album(cue: null))),
    );
    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.onPressed, isNull);
    expect(button.tooltip, contains('CUE sheet'));
  });

  testWidgets('button is disabled for multi-disc albums', (tester) async {
    await tester.pumpWidget(
      _pumpable(GnudbLookupButton(album: _album(discCount: 2))),
    );
    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.onPressed, isNull);
    expect(button.tooltip, contains('multi-disc'));
  });

  testWidgets('button is enabled for valid single-disc rip album',
      (tester) async {
    await tester.pumpWidget(
      _pumpable(GnudbLookupButton(album: _album())),
    );
    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.onPressed, isNotNull);
    expect(button.tooltip, 'Look up on GnuDB');
  });
}
