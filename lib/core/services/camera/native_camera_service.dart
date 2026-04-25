import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:mymediascanner/core/services/camera/barcode_detector.dart';
import 'package:mymediascanner/core/services/camera/camera_service.dart';

/// Camera service implementation using the camera package + flutter_zxing.
///
/// Supports Windows and Linux where mobile_scanner (ML Kit) is unavailable.
/// Uses [camera_desktop] for native camera access and [flutter_zxing] for
/// barcode detection from captured frames.
///
/// On platforms without image streaming (Windows), falls back to periodic
/// still-frame capture for barcode detection.
class NativeCameraService implements CameraService {
  NativeCameraService({this.captureIntervalMs = 500});

  /// Interval between barcode detection attempts via still capture (ms).
  final int captureIntervalMs;

  CameraController? _controller;
  final _barcodeController = StreamController<BarcodeResult>.broadcast();
  bool _isActive = false;
  bool _captureInFlight = false;
  Timer? _captureTimer;

  /// The underlying camera controller, exposed for the preview widget.
  CameraController? get controller => _controller;

  @override
  Stream<BarcodeResult> get onBarcodeDetected => _barcodeController.stream;

  @override
  Widget buildPreview({Widget Function(String message)? errorBuilder}) {
    final ctrl = _controller;
    if (ctrl != null && ctrl.value.isInitialized) {
      return CameraPreview(ctrl);
    }
    return const Center(child: SizedBox.shrink());
  }

  @override
  Future<void> start() async {
    final cameras = await availableCameras();
    debugPrint('[scan] availableCameras() returned ${cameras.length}: '
        '${cameras.map((c) => '${c.name}(${c.lensDirection.name})').join(', ')}');
    if (cameras.isEmpty) {
      // Throw a CameraException rather than StateError so callers that only
      // `on Exception catch` (StateError extends Error, not Exception) still
      // surface a useful error to the user.
      throw CameraException(
        'no_cameras',
        'No cameras available on this device.',
      );
    }

    // Use the first reported camera. On desktop the OS-default webcam is
    // typically index 0; the previous front-facing preference picked the
    // wrong device on Linux where USB webcams report as `external`.
    final camera = cameras.first;
    debugPrint('[scan] using camera "${camera.name}" '
        '(${camera.lensDirection.name})');

    // Some webcams (and camera_desktop on Linux) reject specific
    // ResolutionPresets with "internal data screen error". Try a chain
    // from high downwards until one initialises successfully.
    const presets = [
      ResolutionPreset.high,
      ResolutionPreset.medium,
      ResolutionPreset.low,
    ];
    CameraException? lastError;
    for (final preset in presets) {
      final ctrl = CameraController(camera, preset, enableAudio: false);
      try {
        await ctrl.initialize();
        _controller = ctrl;
        debugPrint('[scan] camera initialised at $preset, '
            'preview size=${ctrl.value.previewSize}');
        break;
      } on CameraException catch (e) {
        debugPrint('[scan] init failed at $preset: ${e.code} ${e.description}');
        lastError = e;
        // Dispose the failed controller asynchronously so the native V4L2 /
        // WMF device handle is released — otherwise the next preset's
        // `.initialize()` fails with "device busy" on Linux. The tiny delay
        // lets any in-flight listener settle before dispose runs.
        unawaited(Future<void>.delayed(const Duration(milliseconds: 50))
            .then((_) async {
          try {
            await ctrl.dispose();
          } catch (_) {}
        }));
      }
    }
    if (_controller == null) {
      throw lastError ??
          CameraException('init_failed', 'No resolution preset accepted');
    }
    _isActive = true;

    // Use periodic still-frame capture for barcode detection.
    // This works on all desktop platforms including Windows where
    // image streaming may not be available.
    _startPeriodicCapture();
  }

  void _startPeriodicCapture() {
    _captureTimer = Timer.periodic(
      Duration(milliseconds: captureIntervalMs),
      (_) => _captureAndDetect(),
    );
  }

  Future<void> _captureAndDetect() async {
    // Guard against overlapping invocations — Timer.periodic fires every
    // [captureIntervalMs] regardless of whether the previous takePicture()
    // has completed. USB webcams on Linux routinely take longer than
    // 500 ms per frame, so parallel captures corrupt the controller.
    if (_captureInFlight) return;
    final ctrl = _controller;
    if (!_isActive || ctrl == null) return;
    if (!ctrl.value.isInitialized) return;

    _captureInFlight = true;
    try {
      final xFile = await ctrl.takePicture();
      final result = await BarcodeDetector.detectFromFile(xFile.path);
      if (result != null) {
        // Don't log the raw barcode value in release builds — it's user
        // media data and there's no need for it to land in device logs.
        if (kDebugMode) {
          debugPrint(
              '[scan] DECODED ${result.format} (${result.rawValue.length} chars)');
        }
        if (!_barcodeController.isClosed) {
          _barcodeController.add(result);
        }
      }
    } on CameraException catch (e) {
      debugPrint('[scan] camera capture failed: ${e.code} ${e.description}');
    } on Exception catch (e) {
      debugPrint('[scan] capture/decode failed: $e');
    } finally {
      _captureInFlight = false;
    }
  }

  @override
  Future<void> stop() async {
    _isActive = false;
    _captureTimer?.cancel();
    _captureTimer = null;
    await _controller?.dispose();
    _controller = null;
  }

  @override
  bool get isActive => _isActive;

  @override
  Future<String?> captureImage() async {
    final ctrl = _controller;
    if (!_isActive || ctrl == null) return null;
    if (!ctrl.value.isInitialized) return null;

    try {
      // Pause periodic barcode detection during capture.
      _captureTimer?.cancel();
      final xFile = await ctrl.takePicture();
      // The controller may have been stopped while we were awaiting the
      // capture; only restart the periodic timer if we're still active.
      if (_isActive && _controller != null) {
        _startPeriodicCapture();
      }
      return xFile.path;
    } on CameraException catch (e) {
      debugPrint('Still capture failed: ${e.description}');
      if (_isActive && _controller != null) {
        _startPeriodicCapture();
      }
      return null;
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _barcodeController.close();
  }
}
