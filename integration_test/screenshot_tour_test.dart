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

/// Taps a sidebar destination by label if present. Screens that only
/// appear on desktop (or only when a feature flag is on) are skipped
/// silently — the caller decides whether to treat that as an error.
Future<bool> _tapSidebar(WidgetTester tester, String label) async {
  final finder = find.text(label);
  if (finder.evaluate().isEmpty) return false;
  await tester.tap(finder.first);
  await tester.pumpAndSettle(const Duration(seconds: 1));
  return true;
}

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
      await _tapSidebar(tester, 'Library');
      await takeScreenshot(tester, '02-collection-grid');
    });

    testWidgets('03-item-detail', (tester) async {
      final res = await pumpScreenshotApp(tester);
      await seedMediaItems(res.db, count: 5);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await _tapSidebar(tester, 'Library');
      await tester.tap(find.text('The Shawshank Redemption').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await takeScreenshot(tester, '03-item-detail');
    });

    testWidgets('04-scan-screen', (tester) async {
      await pumpScreenshotApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      // Sidebar label is "Scanner", not "Scan". Use pump instead of
      // pumpAndSettle after the tap because the scanner screen may start
      // a camera / scanner stream that never settles in a test harness.
      final tapped = await _tapSidebar(tester, 'Scanner');
      if (!tapped) {
        // Fall back to tapping the Quick Scan CTA on the dashboard.
        final quickScan = find.text('Quick Scan');
        if (quickScan.evaluate().isNotEmpty) {
          await tester.tap(quickScan.first);
        }
      }
      // Let the scanner screen paint its chrome without waiting for
      // camera init to settle.
      await tester.pump(const Duration(seconds: 2));
      await takeScreenshot(tester, '04-scanner');
    });

    testWidgets('05-insights', (tester) async {
      final res = await pumpScreenshotApp(tester);
      await seedMediaItems(res.db, count: 10);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await _tapSidebar(tester, 'Insights');
      await takeScreenshot(tester, '05-insights');
    });

    testWidgets('06-shelves', (tester) async {
      final res = await pumpScreenshotApp(tester);
      await seedMediaItems(res.db, count: 3);
      await seedShelves(res.db, count: 3);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await _tapSidebar(tester, 'Shelves');
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
      if (await _tapSidebar(tester, 'Rips')) {
        await takeScreenshot(tester, '07-rips');
      }
    });

    testWidgets('08-settings', (tester) async {
      await pumpScreenshotApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await _tapSidebar(tester, 'Settings');
      await takeScreenshot(tester, '08-settings');
    });

    testWidgets('09-batch-editor', (tester) async {
      await pumpScreenshotApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      // Sidebar label is "Batch Editor", not "Batch".
      if (await _tapSidebar(tester, 'Batch Editor')) {
        await takeScreenshot(tester, '09-batch-editor');
      }
    });

    testWidgets('10-wishlist', (tester) async {
      final res = await pumpScreenshotApp(tester);
      // Seed a handful of wishlist entries so the screen has content.
      await seedSingleItem(
        res.db,
        title: 'The Dark Forest',
        mediaType: 'book',
        barcode: '9780765377081',
      );
      await seedSingleItem(
        res.db,
        title: 'Death\u2019s End',
        mediaType: 'book',
        barcode: '9780765377104',
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));
      if (await _tapSidebar(tester, 'Wishlist')) {
        await takeScreenshot(tester, '10-wishlist');
      }
    });

    testWidgets('11-series', (tester) async {
      final res = await pumpScreenshotApp(tester);
      await seedMediaItems(res.db, count: 5);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      if (await _tapSidebar(tester, 'Series')) {
        await takeScreenshot(tester, '11-series');
      }
    });

    testWidgets('12-locations', (tester) async {
      final res = await pumpScreenshotApp(tester);
      await seedMediaItems(res.db, count: 3);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      if (await _tapSidebar(tester, 'Locations')) {
        await takeScreenshot(tester, '12-locations');
      }
    });

    testWidgets('13-suggestions', (tester) async {
      final res = await pumpScreenshotApp(tester);
      await seedMediaItems(res.db, count: 10);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      if (await _tapSidebar(tester, 'Suggestions')) {
        await takeScreenshot(tester, '13-suggestions');
      }
    });
  });
}
