import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

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
  Timer? _captureTimer;

  /// The underlying camera controller, exposed for the preview widget.
  CameraController? get controller => _controller;

  @override
  Stream<BarcodeResult> get onBarcodeDetected => _barcodeController.stream;

  @override
  Future<void> start() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw StateError('No cameras available');
    }

    // Prefer front-facing for desktop webcam, fall back to first available.
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
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
    if (!_isActive || _controller == null) return;
    if (!(_controller!.value.isInitialized)) return;

    try {
      final xFile = await _controller!.takePicture();
      final result = await BarcodeDetector.detectFromFile(xFile.path);
      if (result != null) {
        _barcodeController.add(result);
      }
    } on CameraException catch (e) {
      debugPrint('Camera capture failed: ${e.description}');
    } on Exception catch (e) {
      debugPrint('Barcode detection failed: $e');
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
  Future<void> dispose() async {
    await stop();
    await _barcodeController.close();
  }
}
