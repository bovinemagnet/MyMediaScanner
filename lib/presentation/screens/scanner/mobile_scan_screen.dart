// Mobile camera barcode scanner screen using the `mobile_scanner` package.
//
// Provides a full-screen camera viewfinder with scan overlay, flash toggle,
// manual barcode entry, batch mode support, and duplicate detection handling.
//
// Author: Paul Snow
// Since: 0.0.0
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';
import 'package:mymediascanner/presentation/screens/scanner/widgets/batch_scan_counter.dart';
import 'package:mymediascanner/presentation/screens/scanner/widgets/media_type_toggles.dart';
import 'package:mymediascanner/presentation/screens/scanner/widgets/scan_mode_toggle.dart';
import 'package:mymediascanner/presentation/screens/scanner/widgets/scan_overlay.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';
import 'package:mymediascanner/core/utils/cover_ocr_helper.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';

/// Full-screen mobile camera barcode scanner.
class MobileScanScreen extends ConsumerStatefulWidget {
  const MobileScanScreen({super.key});

  @override
  ConsumerState<MobileScanScreen> createState() => _MobileScanScreenState();
}

class _MobileScanScreenState extends ConsumerState<MobileScanScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 500,
  );

  bool _hasScanned = false;
  bool _externalScannerMode = false;
  final _externalController = TextEditingController();
  final _externalFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController.dispose();
    _externalController.dispose();
    _externalFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed &&
        !_externalScannerMode &&
        _hasScanned) {
      _resumeScanning();
    }
  }

  void _toggleExternalScannerMode() {
    setState(() {
      _externalScannerMode = !_externalScannerMode;
      if (_externalScannerMode) {
        _cameraController.stop();
        // Delay focus request to after the build
        Future.microtask(() => _externalFocusNode.requestFocus());
      } else {
        _cameraController.start();
        _hasScanned = false;
      }
    });
  }

  void _onExternalBarcodeSubmitted(String barcode) {
    if (barcode.trim().isEmpty) return;
    _externalController.clear();
    HapticFeedback.mediumImpact();
    ref.read(scannerProvider.notifier).onBarcodeScanned(barcode.trim());
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcodeValue = barcodes.first.rawValue ?? barcodes.first.displayValue;
    if (barcodeValue == null || barcodeValue.trim().isEmpty) return;

    _hasScanned = true;
    HapticFeedback.mediumImpact();

    // Pause scanning to prevent duplicate detections.
    _cameraController.stop();

    ref.read(scannerProvider.notifier).onBarcodeScanned(barcodeValue.trim());
  }

  void _resumeScanning() {
    debugPrint('[MMS-scan] _resumeScanning enter (was hasScanned=$_hasScanned)');
    // Clear `_hasScanned` BEFORE reset(). Riverpod fires `ref.listen`
    // callbacks synchronously, so reset() re-enters this widget's idle
    // listener (line ~308) — leaving `_hasScanned` true would make that
    // listener call `_resumeScanning` again and recurse to a stack
    // overflow that hangs the camera on Android.
    _hasScanned = false;
    ref.read(scannerProvider.notifier).reset();
    _cameraController.start();
    debugPrint('[MMS-scan] _resumeScanning exit (camera.start dispatched)');
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enter Barcode'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Barcode / ISBN / IMDb ID',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.qr_code),
          ),
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\dXxTt]')),
          ],
          onSubmitted: (value) {
            Navigator.of(dialogContext).pop();
            if (value.trim().isNotEmpty) {
              _hasScanned = true;
              _cameraController.stop();
              ref
                  .read(scannerProvider.notifier)
                  .onBarcodeScanned(value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              Navigator.of(dialogContext).pop();
              if (value.isNotEmpty) {
                _hasScanned = true;
                _cameraController.stop();
                ref.read(scannerProvider.notifier).onBarcodeScanned(value);
              }
            },
            child: const Text('Look up'),
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
        content:
            const Text('This barcode already exists in your collection.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _resumeScanning();
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

  void _showNotFoundDialog(ScanResult? result) {
    final notFound = result is NotFoundScanResult ? result : null;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Barcode Not Found'),
        content: const Text(
          'This barcode was not found in any database. '
          'You can photograph the cover to search by title, '
          'or enter details manually.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _resumeScanning();
            },
            child: const Text('Scan again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/scan/confirm');
            },
            child: const Text('Enter manually'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _scanCover(notFound);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scan cover'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanCover(NotFoundScanResult? notFound) async {
    if (notFound == null) {
      _resumeScanning();
      return;
    }

    final ocr = CoverOcrHelper();
    try {
      final ocrResult = await ocr.captureAndExtractStructured();
      if (!ocrResult.isEmpty && mounted) {
        await ref.read(scannerProvider.notifier).onCoverOcrResult(
              ocrResult,
              notFound.barcode,
              notFound.barcodeType,
            );
      } else if (mounted) {
        // OCR failed or user cancelled — go to manual entry
        context.go('/scan/confirm');
      }
    } catch (_) {
      if (mounted) _resumeScanning();
    } finally {
      await ocr.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerProvider);

    ref.listen(scannerProvider, (prev, next) {
      debugPrint('[MMS-scan] state ${prev?.state} -> ${next.state} '
          '(hasScanned=$_hasScanned, batch=${next.batchMode})');
      if (next.state == ScanState.found) {
        if (next.batchMode && next.result != null) {
          ref.read(scannerProvider.notifier).queueToBatch(next.result!);
          _resumeScanning();
        } else {
          context.go('/scan/confirm');
        }
      }
      if (next.state == ScanState.notFound) {
        if (next.batchMode && next.result != null) {
          ref.read(scannerProvider.notifier).queueToBatch(next.result!);
          _resumeScanning();
        } else if (PlatformCapability.hasCoverOcr) {
          _showNotFoundDialog(next.result);
        } else {
          context.go('/scan/confirm');
        }
      }
      if (next.state == ScanState.disambiguating) {
        if (next.batchMode && next.result != null) {
          ref.read(scannerProvider.notifier).queueToBatch(next.result!);
          _resumeScanning();
        } else {
          context.go('/scan/disambiguate');
        }
      }
      if (next.state == ScanState.duplicate) {
        if (next.batchMode && next.result != null) {
          ref.read(scannerProvider.notifier).queueToBatch(next.result!);
          _resumeScanning();
        } else {
          _showDuplicateDialog();
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
        _resumeScanning();
      }
      if (next.state == ScanState.idle && _hasScanned) {
        _resumeScanning();
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        title: const Text('MyMediaScanner'),
        titleTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
        actions: [
          // Batch mode toggle
          if (scannerState.batchMode && scannerState.batchCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: BatchScanCounter(count: scannerState.batchCount),
            ),
          const Text('Batch',
              style: TextStyle(color: Colors.white70, fontSize: 11)),
          Switch(
            value: scannerState.batchMode,
            onChanged: (_) =>
                ref.read(scannerProvider.notifier).toggleBatchMode(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _externalScannerMode
          ? _buildExternalScannerBody(scannerState)
          : _buildCameraBody(scannerState),
    );
  }

  Widget _buildCameraBody(ScannerState scannerState) {
    return Stack(
      children: [
        MobileScanner(
          controller: _cameraController,
          onDetect: _onBarcodeDetected,
          errorBuilder: (context, error) {
            if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
              return _PermissionDeniedView(
                onOpenSettings: () async {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please grant camera permission in your device '
                          'settings.',
                        ),
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                },
              );
            }
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    error.errorCode.message,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
        const ScanOverlay(),

        // Floating action buttons — right edge
        Positioned(
          right: 16,
          top: MediaQuery.of(context).padding.top + 72,
          child: Column(
            children: [
              // Flash toggle
              ValueListenableBuilder(
                valueListenable: _cameraController,
                builder: (context, state, _) {
                  final torchState = state.torchState;
                  if (torchState == TorchState.unavailable) {
                    return const SizedBox.shrink();
                  }
                  return _GlassActionButton(
                    icon: torchState == TorchState.on
                        ? Icons.flash_on
                        : Icons.flash_off,
                    onTap: _cameraController.toggleTorch,
                  );
                },
              ),
              const SizedBox(height: 10),
              _GlassActionButton(
                icon: Icons.cameraswitch,
                onTap: _cameraController.switchCamera,
              ),
              const SizedBox(height: 10),
              _GlassActionButton(
                icon: _externalScannerMode
                    ? Icons.camera_alt
                    : Icons.bluetooth,
                onTap: _toggleExternalScannerMode,
              ),
              const SizedBox(height: 10),
              _GlassActionButton(
                icon: Icons.keyboard,
                onTap: _showManualEntryDialog,
              ),
            ],
          ),
        ),

        // Bottom controls — scan mode + media type toggles + status
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ScanModeToggle(),
                const SizedBox(height: 8),
                const MediaTypeToggles(),
                if (scannerState.state == ScanState.lookingUp) ...[
                  const SizedBox(height: 12),
                  _StatusStrip(
                    label: 'SCANNING METADATA\u2026',
                    color: Theme.of(context).colorScheme.primary,
                    onCancel: () =>
                        ref.read(scannerProvider.notifier).cancel(),
                  ),
                ] else if (scannerState.batchMode &&
                    scannerState.batchCount > 0) ...[
                  const SizedBox(height: 12),
                  _StatusStrip(
                    label:
                        '${scannerState.batchCount} items queued to batch',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExternalScannerBody(ScannerState scannerState) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_searching,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Bluetooth / USB Scanner Mode',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Scan a barcode with your external scanner, or type it below',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const ScanModeToggle(),
          const SizedBox(height: 12),
          const MediaTypeToggles(),
          const SizedBox(height: 24),
          SizedBox(
            width: 400,
            child: TextField(
              controller: _externalController,
              focusNode: _externalFocusNode,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Barcode / ISBN / IMDb ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
              onSubmitted: _onExternalBarcodeSubmitted,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\dXxTt]')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (scannerState.state == ScanState.lookingUp) ...[
            const LoadingIndicator(message: 'Looking up metadata...'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(scannerProvider.notifier).cancel();
                _externalController.clear();
                _externalFocusNode.requestFocus();
              },
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
            ),
          ],
          if (scannerState.state == ScanState.error)
            Text(
              scannerState.error ?? 'Unknown error',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          if (scannerState.state == ScanState.duplicate)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                        'This barcode already exists in your collection.'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            ref.read(scannerProvider.notifier).reset();
                            _externalController.clear();
                            _externalFocusNode.requestFocus();
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
}

/// Widget shown when camera permission is denied.
class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Camera Permission Required',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'MyMediaScanner needs camera access to scan barcodes on '
                'your media items. Please grant camera permission in your '
                'device settings.',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onOpenSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Frosted-glass floating action button for the scanner screen.
class _GlassActionButton extends StatelessWidget {
  const _GlassActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

/// Status strip shown at the bottom of the scanner.
class _StatusStrip extends StatelessWidget {
  const _StatusStrip({
    required this.label,
    required this.color,
    this.onCancel,
  });

  final String label;
  final Color color;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
          if (onCancel != null)
            GestureDetector(
              onTap: onCancel,
              child: Icon(Icons.close, color: color, size: 18),
            ),
        ],
      ),
    );
  }
}
