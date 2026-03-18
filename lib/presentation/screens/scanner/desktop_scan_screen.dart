import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';
import 'package:mymediascanner/presentation/screens/scanner/widgets/batch_scan_counter.dart';
import 'package:mymediascanner/presentation/screens/scanner/widgets/media_type_toggles.dart';
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
  MobileScannerController? _cameraController;
  bool _hasScanned = false;

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
    _cameraController?.dispose();
    super.dispose();
  }

  void _toggleWebcam() {
    setState(() {
      _webcamMode = !_webcamMode;
      if (_webcamMode) {
        _cameraController = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          detectionTimeoutMs: 500,
        );
        _hasScanned = false;
      } else {
        _cameraController?.dispose();
        _cameraController = null;
        _focusNode.requestFocus();
      }
    });
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcodeValue = barcodes.first.rawValue ?? barcodes.first.displayValue;
    if (barcodeValue == null || barcodeValue.trim().isEmpty) return;

    _hasScanned = true;
    _cameraController?.stop();

    ref.read(scannerProvider.notifier).onBarcodeScanned(barcodeValue.trim());
  }

  void _resumeWebcamScanning() {
    ref.read(scannerProvider.notifier).reset();
    _hasScanned = false;
    _cameraController?.start();
  }

  void _onSubmitted(String barcode) {
    if (barcode.trim().isEmpty) return;
    _controller.clear();
    ref.read(scannerProvider.notifier).onBarcodeScanned(barcode.trim());
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerProvider);

    ref.listen(scannerProvider, (prev, next) {
      if (next.state == ScanState.found || next.state == ScanState.notFound) {
        if (next.batchMode) {
          ref.read(scannerProvider.notifier).incrementBatchCount();
          if (_webcamMode) {
            _resumeWebcamScanning();
          } else {
            ref.read(scannerProvider.notifier).reset();
          }
        } else {
          context.go('/scan/confirm');
        }
      }
      if (next.state == ScanState.disambiguating) {
        context.go('/scan/disambiguate');
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
          _resumeWebcamScanning();
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
          _resumeWebcamScanning();
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
      body: _webcamMode ? _buildWebcamBody(scannerState) : _buildKeyboardBody(scannerState),
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
              if (_cameraController != null)
                MobileScanner(
                  controller: _cameraController!,
                  onDetect: _onBarcodeDetected,
                  errorBuilder: (context, error) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.videocam_off,
                              size: 48,
                              color: Theme.of(context).colorScheme.error),
                          const SizedBox(height: 16),
                          Text(
                            'Camera error: ${error.errorCode.message}',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.tonal(
                            onPressed: _toggleWebcam,
                            child: const Text('Switch to keyboard input'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
                      const LoadingIndicator(
                          message: 'Looking up metadata...'),
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
              _resumeWebcamScanning();
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
          const ScanModeToggle(),
          const SizedBox(height: 16),
          Text(
            'Look up as:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
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
                  hintText: 'Barcode / ISBN',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                onSubmitted: _onSubmitted,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\dXx]')),
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
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error),
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
}
