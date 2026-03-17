import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/collection_view_mode_provider.dart';

/// Toggle button between grid and table view modes.
/// Desktop only — the parent should guard visibility.
class ViewModeToggle extends ConsumerWidget {
  const ViewModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(collectionViewModeProvider);

    return SegmentedButton<CollectionViewMode>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: CollectionViewMode.grid,
          icon: Icon(Icons.grid_view, size: 18),
        ),
        ButtonSegment(
          value: CollectionViewMode.table,
          icon: Icon(Icons.table_rows, size: 18),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (selection) {
        ref
            .read(collectionViewModeProvider.notifier)
            .setMode(selection.first);
      },
    );
  }
}
