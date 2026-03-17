import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'package:mymediascanner/core/utils/platform_utils.dart';

/// Manages desktop window size, position, and minimum size enforcement.
///
/// Persists geometry to [SharedPreferences] so the window restores its
/// previous bounds on relaunch. Only active on desktop platforms.
class WindowManagerHelper with WindowListener {
  WindowManagerHelper._();

  static const _keyX = 'window_x';
  static const _keyY = 'window_y';
  static const _keyWidth = 'window_width';
  static const _keyHeight = 'window_height';

  static const _minWidth = 800.0;
  static const _minHeight = 600.0;
  static const _defaultWidth = 1200.0;
  static const _defaultHeight = 800.0;

  static final _instance = WindowManagerHelper._();

  SharedPreferences? _prefs;
  Timer? _debounce;

  /// Initialise window management. Safe to call on any platform —
  /// returns immediately on non-desktop.
  static Future<void> initialise() async {
    if (!PlatformCapability.isDesktop) return;

    await windowManager.ensureInitialized();

    final prefs = await SharedPreferences.getInstance();
    _instance._prefs = prefs;

    final x = prefs.getDouble(_keyX);
    final y = prefs.getDouble(_keyY);
    final width = prefs.getDouble(_keyWidth) ?? _defaultWidth;
    final height = prefs.getDouble(_keyHeight) ?? _defaultHeight;

    final options = WindowOptions(
      size: Size(width, height),
      minimumSize: const Size(_minWidth, _minHeight),
      center: x == null || y == null,
    );

    await windowManager.waitUntilReadyToShow(options, () async {
      if (x != null && y != null) {
        await windowManager.setPosition(Offset(x, y));
      }
      await windowManager.show();
      await windowManager.focus();
    });

    windowManager.addListener(_instance);
  }

  void _persistGeometry() async {
    final prefs = _prefs;
    if (prefs == null) return;

    final position = await windowManager.getPosition();
    final size = await windowManager.getSize();

    await prefs.setDouble(_keyX, position.dx);
    await prefs.setDouble(_keyY, position.dy);
    await prefs.setDouble(_keyWidth, size.width);
    await prefs.setDouble(_keyHeight, size.height);
  }

  void _debouncedPersist() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _persistGeometry);
  }

  @override
  void onWindowResized() => _debouncedPersist();

  @override
  void onWindowMoved() => _debouncedPersist();
}
