import 'package:flutter/material.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/presentation/screens/scanner/desktop_scan_screen.dart';
import 'package:mymediascanner/presentation/screens/scanner/mobile_scan_screen.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (PlatformCapability.isDesktop) {
      return const DesktopScanScreen();
    }

    return const MobileScanScreen();
  }
}
