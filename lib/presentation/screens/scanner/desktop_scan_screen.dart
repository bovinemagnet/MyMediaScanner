import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/core/services/camera/camera_service.dart';
import 'package:mymediascanner/core/services/camera/camera_service_provider.dart';
import 'package:mymediascanner/core/utils/cover_ocr_helper.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';
import 'package:mymediascanner/presentation/screens/scanner/widgets/batch_scan_counter.dart';
import 'package:mymediascanner/presentation/screens/scanner/widgets/media_type_toggles.dart';
import 'package:mymediascanner/presentation/screens/scanner/widgets/save_target_toggle.dart';
import 'package:mymediascanner/presentation/screens/scanner/widgets/scan_mode_toggle.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

class DesktopScanScreen extends ConsumerStatefulWidget {
  const DesktopScanScreen({super.key});

  @override
  ConsumerState<DesktopScanScreen> createState() => _DesktopScanScreenState();
}

class _DesktopScanScreenState extends ConsumerState<DesktopScanScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _keyboardFocusNode = FocusNode();

  bool _webcamMode = false;
  CameraService? _cameraService;
  StreamSubscription<BarcodeResult>? _barcodeSubscription;
  bool _hasScanned = false;
  String? _cameraError;

  /// Last keyboard-wedge submission timestamp + value. USB barcode
  /// scanners are HID devices that can fire two Enter events in quick
  /// succession; without this guard the same barcode is dispatched
  /// twice before scannerProvider transitions to lookingUp.
  DateTime? _lastKeyboardSubmitAt;
  String? _lastKeyboardSubmitValue;
  static const _keyboardSubmitDebounce = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _keyboardFocusNode.dispose();
    _barcodeSubscription?.cancel();
    // CameraService.dispose() is async (V4L2 / WMF / AVFoundation handle
    // teardown) but State.dispose() must be sync. unawaited(...) marks
    // the fire-and-forget intent; the catchError ensures a teardown
    // failure on Linux/Windows surfaces in debug logs instead of going
    // through the unhandled-async-error path.
    final pendingCamera = _cameraService?.dispose();
    if (pendingCamera != null) {
      unawaited(pendingCamera.catchError((Object error, StackTrace stack) {
        debugPrint('Camera dispose failed: $error');
      }));
    }
    super.dispose();
  }

  Future<void> _toggleWebcam() async {
    if (_webcamMode) {
      // Switching off webcam
      await _barcodeSubscription?.cancel();
      _barcodeSubscription = null;
      await _cameraService?.stop();
      await _cameraService?.dispose();
      _cameraService = null;
      if (!mounted) return;
      setState(() {
        _webcamMode = false;
        _cameraError = null;
      });
      _focusNode.requestFocus();
      return;
    }

    // Switching on webcam — create the appropriate service for the platform.
    setState(() {
      _webcamMode = true;
      _hasScanned = false;
      _cameraError = null;
    });

    final CameraService service = ref.read(cameraServiceProvider);
    _cameraService = service;
    try {
      await service.start();
      if (!mounted) {
        // User navigated away during start(); tear down to avoid leaking
        // the native device handle.
        await service.stop();
        await service.dispose();
        if (_cameraService == service) _cameraService = null;
        return;
      }
      setState(() {}); // Rebuild to show preview

      // Listen for barcode detections from the service.
      _barcodeSubscription = service.onBarcodeDetected.listen(
        (result) => unawaited(_onServiceBarcodeDetected(result.rawValue)),
      );
    } catch (e) {
      // Catch Error as well as Exception — some platforms throw StateError
      // for "no cameras available" which is not an Exception subtype.
      try {
        await service.dispose();
      } catch (_) {}
      if (_cameraService == service) _cameraService = null;
      if (!mounted) return;
      setState(() => _cameraError = e.toString());
    }
  }

  Future<void> _onServiceBarcodeDetected(String barcodeValue) async {
    if (_hasScanned) return;
    if (barcodeValue.trim().isEmpty) return;

    // Flip the guard synchronously so any further stream events are ignored,
    // then await stop() so a late periodic-capture frame can't land on a
    // half-disposed controller.
    _hasScanned = true;
    await _cameraService?.stop();

    // Fire-and-forget: the scannerProvider maintains its own lifecycle and
    // `await`ing here would block subsequent detections on slow lookups.
    unawaited(ref
        .read(scannerProvider.notifier)
        .onBarcodeScanned(barcodeValue.trim()));
  }

  Future<void> _resumeWebcamScanning() async {
    // Clear `_hasScanned` BEFORE reset() — Riverpod fires `ref.listen`
    // callbacks synchronously, so reset() re-enters the idle listener
    // below; leaving `_hasScanned` true would recurse via this method.
    _hasScanned = false;
    ref.read(scannerProvider.notifier).reset();
    // Ensure the prior stop() has fully drained before restarting; callers
    // can fire this during a state transition that runs back-to-back with
    // `_onServiceBarcodeDetected`'s own stop().
    await _cameraService?.stop();
    await _cameraService?.start();
  }

  /// Fire-and-forget wrapper for [_resumeWebcamScanning] suitable for
  /// the synchronous `ref.listen` callback. Surfaces any failure as a
  /// SnackBar instead of letting it silently disappear into a dropped
  /// future — the camera-restart path on Linux/Windows can throw if the
  /// device is still releasing from the prior `stop()`.
  void _resumeWebcamScanningSafely() {
    unawaited(_resumeWebcamScanning().catchError((Object e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not restart webcam: $e')),
      );
    }));
  }

  void _onSubmitted(String barcode) {
    final trimmed = barcode.trim();
    if (trimmed.isEmpty) return;
    // Debounce keyboard-wedge bursts: a fast HID scanner can deliver two
    // Enter events for the same scan before scannerProvider's state has
    // transitioned to lookingUp, so the dedupe in the provider's `if
    // (state.isLookingUp)` branch doesn't catch it. Drop the second
    // submission of the same value within a 300 ms window.
    final now = DateTime.now();
    if (_lastKeyboardSubmitValue == trimmed &&
        _lastKeyboardSubmitAt != null &&
        now.difference(_lastKeyboardSubmitAt!) < _keyboardSubmitDebounce) {
      _controller.clear();
      return;
    }
    _lastKeyboardSubmitAt = now;
    _lastKeyboardSubmitValue = trimmed;
    _controller.clear();
    ref.read(scannerProvider.notifier).onBarcodeScanned(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerProvider);

    ref.listen(scannerProvider, (prev, next) {
      if (next.state == ScanState.found) {
        if (next.batchMode && next.result != null) {
          ref.read(scannerProvider.notifier).queueToBatch(next.result!);
          if (_webcamMode) {
            _resumeWebcamScanningSafely();
          } else {
            ref.read(scannerProvider.notifier).reset();
          }
        } else {
          context.go('/scan/confirm');
        }
      }
      if (next.state == ScanState.notFound) {
        if (next.batchMode && next.result != null) {
          ref.read(scannerProvider.notifier).queueToBatch(next.result!);
          if (_webcamMode) {
            _resumeWebcamScanningSafely();
          } else {
            ref.read(scannerProvider.notifier).reset();
          }
        } else if (PlatformCapability.hasCoverOcr) {
          _showNotFoundDialog(next.result);
        } else {
          context.go('/scan/confirm');
        }
      }
      if (next.state == ScanState.disambiguating) {
        if (next.batchMode && next.result != null) {
          ref.read(scannerProvider.notifier).queueToBatch(next.result!);
          if (_webcamMode) {
            _resumeWebcamScanningSafely();
          } else {
            ref.read(scannerProvider.notifier).reset();
          }
        } else {
          context.go('/scan/disambiguate');
        }
      }
      if (next.state == ScanState.error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error ?? 'Lookup failed'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        if (_webcamMode) {
          _resumeWebcamScanningSafely();
        } else {
          ref.read(scannerProvider.notifier).reset();
        }
      }
      if (next.state == ScanState.idle) {
        if (!_webcamMode) {
          _controller.clear();
          _focusNode.requestFocus();
        }
        if (_webcamMode && _hasScanned) {
          _resumeWebcamScanningSafely();
        }
      }
      if (next.state == ScanState.duplicate && _webcamMode) {
        _showDuplicateDialog();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Batch'),
              Switch(
                value: scannerState.batchMode,
                onChanged: (_) =>
                    ref.read(scannerProvider.notifier).toggleBatchMode(),
              ),
              if (scannerState.batchMode && scannerState.batchCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: BatchScanCounter(count: scannerState.batchCount),
                ),
            ],
          ),
          if (PlatformCapability.canUseCamera)
            IconButton(
              icon: Icon(_webcamMode ? Icons.keyboard : Icons.videocam),
              onPressed: _toggleWebcam,
              tooltip: _webcamMode ? 'Switch to keyboard' : 'Use webcam',
            ),
        ],
      ),
      body: _webcamMode
          ? _buildWebcamBody(scannerState)
          : _buildKeyboardBody(scannerState),
    );
  }

  Widget _buildWebcamBody(ScannerState scannerState) {
    return Column(
      children: [
        // Controls bar
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SaveTargetToggle(),
              SizedBox(width: 16),
              ScanModeToggle(),
              SizedBox(width: 16),
              Expanded(child: MediaTypeToggles()),
            ],
          ),
        ),
        // Camera view
        Expanded(
          child: Stack(
            children: [
              _buildCameraPreview(),
              // Crosshair overlay
              Center(
                child: Container(
                  width: 280,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (scannerState.state == ScanState.lookingUp)
                Container(
                  color: Colors.black54,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const LoadingIndicator(message: 'Looking up metadata...'),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        onPressed: () {
                          ref.read(scannerProvider.notifier).cancel();
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the camera preview widget via the service abstraction.
  Widget _buildCameraPreview() {
    if (_cameraError != null) {
      return _buildCameraError(_cameraError!);
    }

    final service = _cameraService;
    if (service == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return service.buildPreview(errorBuilder: _buildCameraError);
  }

  Widget _buildCameraError(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.videocam_off,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: _toggleWebcam,
            child: const Text('Switch to keyboard input'),
          ),
        ],
      ),
    );
  }

  void _showDuplicateDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Duplicate Barcode'),
        content: const Text('This barcode already exists in your collection.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _resumeWebcamScanningSafely();
            },
            child: const Text('Scan again'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/scan/confirm');
            },
            child: const Text('Add anyway'),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardBody(ScannerState scannerState) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Scan with USB scanner or type barcode',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          const SaveTargetToggle(),
          const SizedBox(height: 12),
          const ScanModeToggle(),
          const SizedBox(height: 16),
          Text('Look up as:', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          const MediaTypeToggles(),
          const SizedBox(height: 16),
          SizedBox(
            width: 400,
            child: KeyboardListener(
              focusNode: _keyboardFocusNode,
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  _controller.clear();
                  ref.read(scannerProvider.notifier).reset();
                  _focusNode.requestFocus();
                }
              },
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Barcode / ISBN / IMDb ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                onSubmitted: _onSubmitted,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\dXxTt]')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (scannerState.state == ScanState.lookingUp) ...[
            const LoadingIndicator(message: 'Looking up metadata...'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(scannerProvider.notifier).cancel();
              },
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
            ),
          ],
          if (scannerState.state == ScanState.error)
            Text(
              scannerState.error ?? 'Unknown error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (scannerState.state == ScanState.duplicate)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'This barcode already exists in your collection.',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            ref.read(scannerProvider.notifier).reset();
                            _controller.clear();
                            _focusNode.requestFocus();
                          },
                          child: const Text('Scan again'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => context.go('/scan/confirm'),
                          child: const Text('Add anyway'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showNotFoundDialog(ScanResult? result) {
    final barcode = switch (result) {
      NotFoundScanResult(:final barcode) => barcode,
      _ => '',
    };
    final barcodeType = switch (result) {
      NotFoundScanResult(:final barcodeType) => barcodeType,
      _ => '',
    };

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Barcode Not Found'),
        content: Text(
          'No metadata found for barcode $barcode. '
          'You can scan the cover to search by title, or enter details manually.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(scannerProvider.notifier).reset();
            },
            child: const Text('Try again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/scan/confirm');
            },
            child: const Text('Enter manually'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _scanCover(barcode, barcodeType);
            },
            icon: Icon(_webcamMode ? Icons.camera_alt : Icons.image_search),
            label: Text(_webcamMode ? 'Capture cover' : 'Pick cover image'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanCover(String barcode, String barcodeType) async {
    final ocr = CoverOcrHelper();
    String? capturedPath;
    try {
      // If the webcam is active and supports still capture (Windows/Linux),
      // capture directly from the camera instead of opening the gallery.
      capturedPath = _webcamMode
          ? await _cameraService?.captureImage()
          : null;

      final ocrResult = capturedPath != null
          ? await ocr.extractStructuredFromFile(capturedPath)
          : await ocr.pickAndExtractStructured();

      if (!ocrResult.isEmpty && mounted) {
        await ref
            .read(scannerProvider.notifier)
            .onCoverOcrResult(ocrResult, barcode, barcodeType);
      } else if (mounted) {
        context.go('/scan/confirm');
      }
    } finally {
      await ocr.dispose();
      // camera_desktop.takePicture() writes to the system temp directory;
      // delete when we're done to avoid long-running accumulation.
      if (capturedPath != null) {
        try {
          await File(capturedPath).delete();
        } catch (_) {}
      }
    }
  }
}
