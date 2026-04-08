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
    Future<void> _setWideScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('renders all sections', (tester) async {
      await _setWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings').first);
      await tester.pumpAndSettle();

      // Section headers are uppercased
      expect(find.text('SYNC'), findsOneWidget);
      expect(find.text('API INTEGRATIONS'), findsOneWidget);

      // Scroll the settings ListView to reveal sections below the fold
      // (FLAC Library section sits between API Integrations and Preferences on desktop)
      await tester.drag(find.byType(ListView).last, const Offset(0, -800));
      await tester.pumpAndSettle();
      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('theme toggle switches to light mode', (tester) async {
      await _setWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings').first);
      await tester.pumpAndSettle();

      // Scroll to the Preferences section (past FLAC Library on desktop)
      await tester.drag(find.byType(ListView).last, const Offset(0, -800));
      await tester.pumpAndSettle();

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
      await _setWideScreen(tester);
      await tester.pumpTestApp();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings').first);
      await tester.pumpAndSettle();

      // Scroll to find the About tile and tap it
      await tester.drag(find.byType(ListView).last, const Offset(0, -1200));
      await tester.pumpAndSettle();
      final aboutTile = find.text('About MyMediaScanner');
      await tester.tap(aboutTile);
      await tester.pumpAndSettle();

      expect(find.byType(AboutScreen), findsOneWidget);
    });
  });
}
