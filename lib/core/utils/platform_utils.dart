import 'package:flutter/foundation.dart';

/// Platform capability detection.
/// Never use dart:io Platform directly in presentation layer.
abstract final class PlatformCapability {
  /// Whether any camera-based barcode scanning is available.
  static bool get canUseCamera => canUseMobileScanner || canUseNativeCamera;

  /// Whether the mobile_scanner plugin (ML Kit) is available.
  /// Supported on Android, iOS, and macOS.
  static bool get canUseMobileScanner =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  /// Whether the native camera package is available (Windows/Linux).
  static bool get canUseNativeCamera =>
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  static bool get isDesktop =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  static bool get isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  static bool get usesKeyboardScanner => isDesktop;

  /// Whether cover OCR text recognition is available.
  /// Android/iOS use ML Kit, macOS uses Vision framework,
  /// Windows/Linux use Tesseract.
  ///
  /// Explicitly exclude Flutter web — `ImagePicker.gallery` is effectively
  /// unusable there and the "scan cover" button would fail on tap.
  static bool get hasCoverOcr => !kIsWeb && (isMobile || isDesktop);
}
