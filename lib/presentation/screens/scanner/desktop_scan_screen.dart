import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';
import 'package:mymediascanner/presentation/screens/scanner/widgets/batch_scan_counter.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

class DesktopScanScreen extends ConsumerStatefulWidget {
  const DesktopScanScreen({super.key});

  @override
  ConsumerState<DesktopScanScreen> createState() => _DesktopScanScreenState();
}

class _DesktopScanScreenState extends ConsumerState<DesktopScanScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSubmitted(String barcode) {
    if (barcode.trim().isEmpty) return;
    ref.read(scannerProvider.notifier).onBarcodeScanned(barcode.trim());
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerProvider);

    ref.listen(scannerProvider, (prev, next) {
      if (next.state == ScanState.found || next.state == ScanState.notFound) {
        context.go('/scan/confirm');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: Padding(
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Batch mode'),
                Switch(
                  value: scannerState.batchMode,
                  onChanged: (_) =>
                      ref.read(scannerProvider.notifier).toggleBatchMode(),
                ),
                if (scannerState.batchMode && scannerState.batchCount > 0)
                  BatchScanCounter(count: scannerState.batchCount),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
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
            const SizedBox(height: 16),
            if (scannerState.state == ScanState.lookingUp)
              const LoadingIndicator(message: 'Looking up metadata...'),
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
      ),
    );
  }
}
