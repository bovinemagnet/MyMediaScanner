/// Dialog previewing batch tag changes before they are applied.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/batch_metadata_edit_provider.dart';

/// Shows a summary of which tags will change (old → new) across the selected
/// tracks and albums.  Offers "Back" and "Confirm & Apply" buttons.
class BatchTagPreviewDialog extends ConsumerWidget {
  const BatchTagPreviewDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batchMetadataEditProvider);
    final theme = Theme.of(context);

    // Collect unique tag keys being changed.
    final changedTagKeys = <String>{};
    for (final changes in state.pendingChanges.values) {
      changedTagKeys.addAll(changes.keys);
    }

    // Collect old → new samples per tag key.
    final tagSamples = <String, ({String? oldValue, String newValue})>{};
    for (final key in changedTagKeys) {
      // Find the first track that has both original and pending.
      String? oldVal;
      String? newVal;
      for (final trackId in state.pendingChanges.keys) {
        if (state.pendingChanges[trackId]?.containsKey(key) == true) {
          newVal = state.pendingChanges[trackId]![key];
          oldVal = state.originalValues[trackId]?[key];
          break;
        }
      }
      if (newVal != null) {
        tagSamples[key] = (oldValue: oldVal, newValue: newVal);
      }
    }

    return AlertDialog(
      title: Text(
        'Preview — ${state.affectedAlbumCount} '
        'Album${state.affectedAlbumCount == 1 ? '' : 's'} '
        '(${state.affectedTrackCount} '
        'track${state.affectedTrackCount == 1 ? '' : 's'})',
      ),
      content: SizedBox(
        width: 480,
        child: state.pendingChanges.isEmpty
            ? const Text('No changes to apply.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The following tags will be written to all '
                    '${state.affectedTrackCount} selected '
                    'track${state.affectedTrackCount == 1 ? '' : 's'}:',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ...tagSamples.entries.map((entry) {
                    final key = entry.key;
                    final sample = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TagChangeRow(
                        tagKey: key,
                        oldValue: sample.oldValue,
                        newValue: sample.newValue,
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Text(
                    'An undo option will be available for 30 seconds after applying.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back'),
        ),
        FilledButton(
          onPressed: state.pendingChanges.isEmpty
              ? null
              : () async {
                  Navigator.of(context).pop();
                  await ref
                      .read(batchMetadataEditProvider.notifier)
                      .applyChanges();

                  if (!context.mounted) return;
                  final updatedState = ref.read(batchMetadataEditProvider);
                  if (updatedState.status == BatchEditStatus.applied) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tags updated on ${updatedState.affectedTrackCount} tracks '
                          'across ${updatedState.affectedAlbumCount} albums.',
                        ),
                        duration: const Duration(seconds: 30),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () => ref
                              .read(batchMetadataEditProvider.notifier)
                              .undoChanges(),
                        ),
                      ),
                    );
                  } else if (updatedState.status == BatchEditStatus.error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text(updatedState.error ?? 'An error occurred.'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                },
          child: const Text('Confirm & Apply'),
        ),
      ],
    );
  }
}

/// Displays a single tag change row: KEY: old → new.
class _TagChangeRow extends StatelessWidget {
  const _TagChangeRow({
    required this.tagKey,
    required this.oldValue,
    required this.newValue,
  });

  final String tagKey;
  final String? oldValue;
  final String newValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            tagKey,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (oldValue != null && oldValue!.isNotEmpty) ...[
                Text(
                  oldValue!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                newValue,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
