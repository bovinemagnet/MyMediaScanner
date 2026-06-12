import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mymediascanner/core/services/camera/camera_service.dart';
import 'package:mymediascanner/core/services/camera/mobile_scanner_camera_service.dart';
import 'package:mymediascanner/core/services/camera/native_camera_service.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';

/// Provides a factory for the appropriate [CameraService] for the
/// current platform.
///
/// - Android/iOS/macOS: [MobileScannerCameraService] (mobile_scanner + ML Kit)
/// - Windows/Linux: [NativeCameraService] (camera package + zxing2)
///
/// This is deliberately a factory, not a cached instance: the scan
/// screen owns each service's lifecycle and calls `dispose()` when the
/// webcam is toggled off, which permanently closes the service's
/// barcode stream (and the MobileScannerController on macOS). A cached
/// singleton would hand that dead instance back to the next session,
/// silently dropping all detections until app restart.
final cameraServiceFactoryProvider = Provider<CameraService Function()>((ref) {
  return () {
    if (PlatformCapability.canUseMobileScanner) {
      return MobileScannerCameraService();
    }
    return NativeCameraService();
  };
});
