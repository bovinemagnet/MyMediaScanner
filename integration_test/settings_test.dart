// Integration tests for settings screen.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/about/about_screen.dart';

import 'helpers/test_app.dart';

void main() {
  group('settings', () {
    Future<void> setWideScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    Future<void> scrollSettingsUntil(
      WidgetTester tester,
      Finder target,
    ) async {
      for (var i = 0; i < 20; i++) {
        if (tester.any(target)) {
          // `any` matches widgets that ListView has built ahead of
          // the viewport via cacheExtent — they may still be off-
          // screen. `ensureVisible` does the last-mile scroll so the
          // widget is actually inside the viewport and tappable.
          await tester.ensureVisible(target);
          await tester.pumpAndSettle();
          return;
        }
        await tester.drag(
          find.byType(ListView).last,
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();
      }
    }

    testWidgets('renders all sections', (tester) async {
      await setWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings').first);
      await tester.pumpAndSettle();

      // Section headers are uppercased
      expect(find.text('SYNC'), findsOneWidget);
      expect(find.text('API INTEGRATIONS'), findsOneWidget);

      await scrollSettingsUntil(tester, find.text('PREFERENCES'));
      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('theme toggle switches to light mode', (tester) async {
      await setWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings').first);
      await tester.pumpAndSettle();

      // Scroll until the light-mode icon (at the bottom of the Theme
      // tile) is on-screen and tappable.
      await scrollSettingsUntil(tester, find.byIcon(Icons.light_mode));

      // Initially system default
      expect(find.text('System default'), findsOneWidget);

      // Tap the light mode segment (sun icon)
      await tester.tap(find.byIcon(Icons.light_mode));
      await tester.pumpAndSettle();

      // Subtitle should now show "Light"
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('System default'), findsNothing);
    });

    testWidgets('about screen is accessible', (tester) async {
      await setWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings').first);
      await tester.pumpAndSettle();

      final aboutTile = find.text('About MyMediaScanner');
      await scrollSettingsUntil(tester, aboutTile);
      await tester.tap(aboutTile);
      await tester.pumpAndSettle();

      expect(find.byType(AboutScreen), findsOneWidget);
    });
  });
}
