// Automated screenshot tour for documentation.
//
// Each test pumps the app with a realistic data set, navigates to a
// specific screen, and writes a PNG into `build/screenshots/`. The
// `tools/capture-screenshots.sh` wrapper runs this file and copies the
// resulting images into `src/docs/modules/ROOT/assets/images/screenshots/`.
//
// Run directly with:
//
//   flutter test integration_test/screenshot_tour_test.dart -d linux
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/screenshot.dart';
import 'helpers/seed_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('screenshot tour', () {
    testWidgets('01-dashboard', (tester) async {
      final res = await pumpScreenshotApp(tester);
      await seedMediaItems(res.db, count: 5);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await takeScreenshot(tester, '01-dashboard');
    });

    testWidgets('02-collection-grid', (tester) async {
      final res = await pumpScreenshotApp(tester);
      await seedMediaItems(res.db, count: 8);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await takeScreenshot(tester, '02-collection-grid');
    });

    testWidgets('03-item-detail', (tester) async {
      final res = await pumpScreenshotApp(tester);
      await seedMediaItems(res.db, count: 5);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Library').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('The Shawshank Redemption').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await takeScreenshot(tester, '03-item-detail');
    });

    testWidgets('04-scan-screen', (tester) async {
      await pumpScreenshotApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Scan').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await takeScreenshot(tester, '04-scan-screen');
    });

    testWidgets('05-insights', (tester) async {
      final res = await pumpScreenshotApp(tester);
      await seedMediaItems(res.db, count: 10);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Insights').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await takeScreenshot(tester, '05-insights');
    });

    testWidgets('06-shelves', (tester) async {
      final res = await pumpScreenshotApp(tester);
      await seedMediaItems(res.db, count: 3);
      await seedShelves(res.db, count: 3);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Shelves').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await takeScreenshot(tester, '06-shelves');
    });

    testWidgets('07-rips', (tester) async {
      final res = await pumpScreenshotApp(tester);
      await seedRipAlbum(
        res.db,
        artist: 'Miles Davis',
        albumTitle: 'Kind of Blue',
        trackCount: 5,
      );
      await seedRipAlbum(
        res.db,
        artist: 'John Coltrane',
        albumTitle: 'A Love Supreme',
        trackCount: 4,
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));
      // "Rips" tab is desktop-only and appears in the sidebar.
      final ripsTab = find.text('Rips');
      if (ripsTab.evaluate().isNotEmpty) {
        await tester.tap(ripsTab.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await takeScreenshot(tester, '07-rips');
      }
    });

    testWidgets('08-settings', (tester) async {
      await pumpScreenshotApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.text('Settings').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await takeScreenshot(tester, '08-settings');
    });

    testWidgets('09-batch', (tester) async {
      await pumpScreenshotApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      final batchTab = find.text('Batch');
      if (batchTab.evaluate().isNotEmpty) {
        await tester.tap(batchTab.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await takeScreenshot(tester, '09-batch');
      }
    });
  });
}
