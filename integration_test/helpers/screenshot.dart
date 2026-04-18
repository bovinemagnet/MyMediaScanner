// Screenshot helpers for the integration-test-driven documentation tour.
//
// Each capture writes a PNG to `build/screenshots/<name>.png`. The parent
// `pumpScreenshotApp` helper wraps the real `App` in a `RepaintBoundary`
// attached to a known `GlobalKey` so we can reliably render the tree to
// an image on every platform. The existing `pumpTestApp` is unsuitable
// because it does not guarantee a top-level repaint boundary of a fixed
// size.
//
// Author: Paul Snow
// Since: 0.0.0

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/app/app.dart';
import 'package:mymediascanner/app/router.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/presentation/providers/database_provider.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_secure_storage.dart';

/// Size used for all desktop screenshots. Wide enough for the expanded
/// sidebar, short enough to render in one go without scrolling.
const Size screenshotSurface = Size(1400, 900);

/// Default pixel ratio for captures — high enough to look sharp in docs,
/// low enough to keep files small.
const double screenshotPixelRatio = 2.0;

/// Directory under the repo root where raw PNGs land before the capture
/// script copies them into the Antora asset tree.
const String screenshotOutputDir = 'build/screenshots';

final _screenshotKey = GlobalKey();

typedef ScreenshotResources = ({
  AppDatabase db,
  MockFlutterSecureStorage storage,
});

/// Pumps the real [App] widget with the same provider overrides as the
/// unit integration harness, but wraps the tree in a [RepaintBoundary]
/// keyed to [_screenshotKey] so [takeScreenshot] can capture it.
Future<ScreenshotResources> pumpScreenshotApp(WidgetTester tester) async {
  tester.view.physicalSize = screenshotSurface * screenshotPixelRatio;
  tester.view.devicePixelRatio = screenshotPixelRatio;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  SharedPreferences.setMockInitialValues({});
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final storage = createMockSecureStorage();

  router.go('/');

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        secureStorageProvider.overrideWithValue(storage),
        apiKeysProvider.overrideWith(_ImmediateApiKeysNotifier.new),
        postgresConfigProvider.overrideWith(_NullPostgresConfigNotifier.new),
      ],
      child: RepaintBoundary(
        key: _screenshotKey,
        child: const App(),
      ),
    ),
  );

  addTearDown(() => db.close());
  return (db: db, storage: storage);
}

/// Captures the current screen as a PNG and writes it to
/// `build/screenshots/<name>.png`.
///
/// Call after `pumpAndSettle` to make sure animations are idle. Safe to
/// call multiple times in one test; each call produces an independent file.
Future<void> takeScreenshot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  final renderObject = _screenshotKey.currentContext?.findRenderObject();
  if (renderObject is! RenderRepaintBoundary) {
    throw StateError(
      'No RepaintBoundary found — did you call pumpScreenshotApp?',
    );
  }
  final boundary = renderObject;
  final ui.Image image =
      await boundary.toImage(pixelRatio: screenshotPixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw StateError('Screenshot encoding failed for "$name"');
  }
  final bytes = byteData.buffer.asUint8List();
  await _writeToDisk(name, bytes);
}

Future<void> _writeToDisk(String name, Uint8List bytes) async {
  final dir = Directory(screenshotOutputDir);
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final file = File('${dir.path}/$name.png');
  await file.writeAsBytes(bytes);
  // ignore: avoid_print
  print('  saved $screenshotOutputDir/$name.png '
      '(${(bytes.length / 1024).toStringAsFixed(1)} KB)');
}

class _ImmediateApiKeysNotifier extends ApiKeysNotifier {
  @override
  Future<Map<String, String?>> build() async => {};
}

class _NullPostgresConfigNotifier extends PostgresConfigNotifier {
  @override
  Future<PostgresConfig?> build() async => null;
}
