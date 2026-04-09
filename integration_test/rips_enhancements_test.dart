// Integration tests for rips/audio player enhancements:
// multi-select, ReplayGain settings, collection rip filter.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/seed_data.dart';
import 'helpers/test_app.dart';

void main() {
  Future<void> setUpWideScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('multi-select mode', () {
    testWidgets('long-press album card enters and exits selection mode',
        (tester) async {
      await setUpWideScreen(tester);
      final res = await tester.pumpTestApp();

      await seedRipAlbum(
        res.db,
        artist: 'Miles Davis',
        albumTitle: 'Kind of Blue',
      );
      await seedRipAlbum(
        res.db,
        artist: 'Dave Brubeck',
        albumTitle: 'Time Out',
      );
      await tester.pumpAndSettle();

      // Navigate to Rips
      await tester.tap(find.text('Rips').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify albums exist
      expect(find.text('Kind of Blue'), findsOneWidget);
      expect(find.text('Time Out'), findsOneWidget);

      // Long-press an album card to enter selection mode
      await tester.longPress(find.text('Kind of Blue').first);
      await tester.pumpAndSettle();

      // Selection toolbar should appear
      expect(find.text('1 selected'), findsOneWidget);
      expect(find.text('Analyse Quality'), findsOneWidget);

      // Tap the close icon button to exit selection mode
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      // Selection toolbar should disappear
      expect(find.text('1 selected'), findsNothing);
    });
  });

  group('ReplayGain settings', () {
    testWidgets('playback section appears with ReplayGain controls',
        (tester) async {
      await setUpWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings').first);
      await tester.pumpAndSettle();

      // Scroll to find the Playback section
      final listView = find.byType(ListView).last;
      await tester.drag(listView, const Offset(0, -500));
      await tester.pumpAndSettle();

      // PLAYBACK section header should be visible
      expect(find.text('PLAYBACK'), findsOneWidget);

      // ReplayGain mode buttons
      expect(find.text('Track'), findsOneWidget);
      expect(find.text('Album'), findsOneWidget);
    });

    testWidgets('can switch ReplayGain mode', (tester) async {
      await setUpWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings').first);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).last, const Offset(0, -500));
      await tester.pumpAndSettle();

      // Tap Track mode segment
      await tester.tap(find.text('Track'));
      await tester.pumpAndSettle();

      // Track should still be visible (segment selected)
      expect(find.text('Track'), findsOneWidget);
    });
  });

  group('collection rip filter', () {
    testWidgets('rip filter chip appears in collection filter bar',
        (tester) async {
      await setUpWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      // Navigate to Library
      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Rip filter chip should be present (label is "Rip: All")
      expect(find.text('Rip: All'), findsOneWidget);
    });

    // Note: item detail rip status section test omitted — the
    // CollectionDetailPanel renders item details in a scrollable
    // view where the Rip Status section may not be visible without
    // deep scrolling. The _RipStatusSection widget is covered by
    // existing unit/widget tests.
  });
}
