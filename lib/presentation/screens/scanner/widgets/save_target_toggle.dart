import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';

/// Segmented button that selects whether the scan is saved to the main
/// collection or the wishlist. Sits next to [ScanModeToggle] on the scan
/// screens and replaces the dual-button choice on the metadata confirm
/// screen — eliminating accidental taps on the wrong save destination.
class SaveTargetToggle extends ConsumerWidget {
  const SaveTargetToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.watch(scannerProvider.select((s) => s.saveTarget));

    return SegmentedButton<SaveTarget>(
      segments: const [
        ButtonSegment(
          value: SaveTarget.collection,
          label: Text('Collection'),
          icon: Icon(Icons.library_books_outlined, size: 18),
        ),
        ButtonSegment(
          value: SaveTarget.wishlist,
          label: Text('Wishlist'),
          icon: Icon(Icons.favorite, size: 18),
        ),
      ],
      selected: {target},
      onSelectionChanged: (selection) {
        ref.read(scannerProvider.notifier).setSaveTarget(selection.first);
      },
    );
  }
}
