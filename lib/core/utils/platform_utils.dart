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
}
