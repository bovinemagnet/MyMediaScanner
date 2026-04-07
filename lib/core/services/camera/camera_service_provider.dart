import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mymediascanner/core/services/camera/camera_service.dart';
import 'package:mymediascanner/core/services/camera/mobile_scanner_camera_service.dart';
import 'package:mymediascanner/core/services/camera/native_camera_service.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';

/// Provides the appropriate [CameraService] for the current platform.
///
/// - Android/iOS/macOS: [MobileScannerCameraService] (mobile_scanner + ML Kit)
/// - Windows/Linux: [NativeCameraService] (camera package + zxing2)
final cameraServiceProvider = Provider<CameraService>((ref) {
  if (PlatformCapability.canUseMobileScanner) {
    return MobileScannerCameraService();
  }
  return NativeCameraService();
});
