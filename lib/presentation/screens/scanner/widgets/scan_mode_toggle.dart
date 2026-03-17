import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';

/// Segmented button to choose between Barcode and ISBN scan modes.
class ScanModeToggle extends ConsumerWidget {
  const ScanModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      scannerProvider.select((s) => s.scanMode),
    );

    return SegmentedButton<ScanMode>(
      segments: const [
        ButtonSegment(
          value: ScanMode.barcode,
          label: Text('Barcode'),
          icon: Icon(Icons.qr_code, size: 18),
        ),
        ButtonSegment(
          value: ScanMode.isbn,
          label: Text('ISBN'),
          icon: Icon(Icons.menu_book, size: 18),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (selection) {
        ref.read(scannerProvider.notifier).setScanMode(selection.first);
      },
    );
  }
}
