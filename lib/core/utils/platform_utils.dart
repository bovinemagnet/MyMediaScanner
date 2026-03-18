import 'package:flutter/foundation.dart';

/// Platform capability detection.
/// Never use dart:io Platform directly in presentation layer.
abstract final class PlatformCapability {
  static bool get canUseCamera =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isDesktop =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  static bool get isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  static bool get usesKeyboardScanner => isDesktop;

  /// Whether cover OCR (ML Kit text recognition) is available.
  /// Only supported on Android and iOS.
  static bool get hasCoverOcr =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}
