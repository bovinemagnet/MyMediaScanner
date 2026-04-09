// Integration tests for playlist features.
//
// These tests exercise the playlist UI on the Rips screen.
// Note: Tests avoid switching between Library and Playlists segments
// due to a known Flutter SearchBar overlay disposal issue during
// tab transitions.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/rips/rips_screen.dart';

import 'helpers/seed_data.dart';
import 'helpers/test_app.dart';

void main() {
  group('playlists', () {
    Future<void> setUpWideScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('playlists segment appears in rips screen', (tester) async {
      await setUpWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rips').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(RipsScreen), findsOneWidget);
      expect(find.text('Playlists'), findsOneWidget);
    });

    testWidgets('seeded rip albums appear in library view', (tester) async {
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

      await tester.tap(find.text('Rips').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Kind of Blue'), findsOneWidget);
      expect(find.text('Time Out'), findsOneWidget);
    });
  });
}
