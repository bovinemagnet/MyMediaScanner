import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:mymediascanner/core/utils/debug_log.dart';

/// Persists access to user-picked folders across app launches on
/// sandboxed macOS builds.
///
/// The App Sandbox only lets this app read paths the user granted via
/// the native open panel, and that grant dies with the process. A
/// security-scoped bookmark captures the grant so it can be restored
/// on the next launch — resolve the bookmark, then start accessing the
/// resource before touching the folder.
///
/// On non-macOS platforms [isAvailable] is false and callers should
/// skip bookmarking entirely (plain paths work there).
abstract class SecureBookmarkService {
  /// Whether security-scoped bookmarks apply on this platform.
  bool get isAvailable;

  /// Creates a security-scoped bookmark for [path].
  ///
  /// Only succeeds while the app still holds live access to the path
  /// (i.e. immediately after the user picked it in the open panel).
  /// Returns the base64 bookmark blob, or null when creation failed.
  Future<String?> createBookmark(String path);

  /// Resolves [bookmark] and begins security-scoped access.
  ///
  /// Returns the bookmark that should be stored going forward — the
  /// same blob normally, or a renewed one when macOS flagged the
  /// stored blob as stale. Returns null when access could not be
  /// restored (the caller should ask the user to re-pick the folder).
  Future<String?> startAccess(String bookmark);
}

/// macOS implementation backed by the
/// `com.mymediascanner/secure_bookmarks` method channel registered in
/// `MainFlutterWindow.swift`.
class MacosSecureBookmarkService implements SecureBookmarkService {
  static const _channel = MethodChannel('com.mymediascanner/secure_bookmarks');

  @override
  bool get isAvailable => defaultTargetPlatform == TargetPlatform.macOS;

  @override
  Future<String?> createBookmark(String path) async {
    if (!isAvailable) return null;
    try {
      return await _channel
          .invokeMethod<String>('createBookmark', {'path': path});
    } on PlatformException catch (e) {
      debugLog('SecureBookmarkService: createBookmark failed: ${e.message}');
      return null;
    }
  }

  @override
  Future<String?> startAccess(String bookmark) async {
    if (!isAvailable) return null;
    try {
      return await _channel
          .invokeMethod<String>('startAccess', {'bookmark': bookmark});
    } on PlatformException catch (e) {
      debugLog('SecureBookmarkService: startAccess failed: ${e.message}');
      return null;
    }
  }
}
