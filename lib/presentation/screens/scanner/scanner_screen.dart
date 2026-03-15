import 'package:flutter/material.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/presentation/screens/scanner/desktop_scan_screen.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (PlatformCapability.isDesktop) {
      return const DesktopScanScreen();
    }

    // Mobile camera scanner — requires mobile_scanner package
    // Implemented conditionally to avoid desktop build issues
    return const _MobileScannerPlaceholder();
  }
}

class _MobileScannerPlaceholder extends StatelessWidget {
  const _MobileScannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: const Center(
        child: Text('Camera scanning available on Android/iOS only'),
      ),
    );
  }
}
