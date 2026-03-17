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

/// Full-screen mobile camera barcode scanner.
class MobileScanScreen extends ConsumerStatefulWidget {
  const MobileScanScreen({super.key});

  @override
  ConsumerState<MobileScanScreen> createState() => _MobileScanScreenState();
}

class _MobileScanScreenState extends ConsumerState<MobileScanScreen> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 500,
  );

  bool _hasScanned = false;
  bool _externalScannerMode = false;
  final _externalController = TextEditingController();
  final _externalFocusNode = FocusNode();

  @override
  void dispose() {
    _cameraController.dispose();
    _externalController.dispose();
    _externalFocusNode.dispose();
    super.dispose();
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
    ref.read(scannerProvider.notifier).reset();
    _hasScanned = false;
    _cameraController.start();
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
            hintText: 'Barcode / ISBN',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.qr_code),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\dXx]')),
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

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerProvider);

    ref.listen(scannerProvider, (prev, next) {
      if (next.state == ScanState.found || next.state == ScanState.notFound) {
        if (next.batchMode) {
          ref.read(scannerProvider.notifier).incrementBatchCount();
          _resumeScanning();
        } else {
          context.go('/scan/confirm');
        }
      }
      if (next.state == ScanState.disambiguating) {
        context.go('/scan/disambiguate');
      }
      if (next.state == ScanState.duplicate) {
        _showDuplicateDialog();
      }
      if (next.state == ScanState.error) {
        _resumeScanning();
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Scan Barcode'),
        actions: [
          // Batch mode toggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (scannerState.batchMode && scannerState.batchCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: BatchScanCounter(count: scannerState.batchCount),
                ),
              const Text(
                'Batch',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              Switch(
                value: scannerState.batchMode,
                onChanged: (_) =>
                    ref.read(scannerProvider.notifier).toggleBatchMode(),
              ),
            ],
          ),
          // Flash toggle
          ValueListenableBuilder(
            valueListenable: _cameraController,
            builder: (context, state, _) {
              final torchState = state.torchState;
              if (torchState == TorchState.unavailable) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: Icon(
                  torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                ),
                onPressed: _cameraController.toggleTorch,
                tooltip: 'Toggle flash',
              );
            },
          ),
          // External scanner mode toggle (Bluetooth/USB)
          IconButton(
            icon: Icon(
              _externalScannerMode ? Icons.camera_alt : Icons.bluetooth,
            ),
            onPressed: _toggleExternalScannerMode,
            tooltip: _externalScannerMode
                ? 'Switch to camera'
                : 'Bluetooth/USB scanner',
          ),
          // Manual entry
          if (!_externalScannerMode)
            IconButton(
              icon: const Icon(Icons.keyboard),
              onPressed: _showManualEntryDialog,
              tooltip: 'Enter barcode manually',
            ),
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
        // Scan mode and media type toggles at the bottom
        Positioned(
          left: 16,
          right: 16,
          bottom: 32,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScanModeToggle(),
                SizedBox(height: 8),
                MediaTypeToggles(),
              ],
            ),
          ),
        ),
        if (scannerState.state == ScanState.lookingUp)
          Container(
            color: Colors.black54,
            child: const LoadingIndicator(message: 'Looking up metadata...'),
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
                hintText: 'Barcode / ISBN',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
              onSubmitted: _onExternalBarcodeSubmitted,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\dXx]')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (scannerState.state == ScanState.lookingUp)
            const LoadingIndicator(message: 'Looking up metadata...'),
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
