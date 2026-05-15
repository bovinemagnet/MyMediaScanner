// Trash screen — lists soft-deleted media items with restore + permanent
// delete actions.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/presentation/providers/trash_provider.dart';
import 'package:mymediascanner/presentation/widgets/empty_state.dart';
import 'package:mymediascanner/presentation/widgets/error_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(deletedItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trash')),
      body: async.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(deletedItemsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.delete_outline,
              message:
                  'Nothing in trash.\nSoft-deleted items appear here so '
                  'you can restore them.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) =>
                _TrashRow(item: items[index]),
          );
        },
      ),
    );
  }
}

class _TrashRow extends ConsumerWidget {
  const _TrashRow({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final trashedAt = DateTime.fromMillisecondsSinceEpoch(item.updatedAt);
    final formatter = DateFormat.yMMMd().add_jm();

    return Container(
      key: Key('trash-row-${item.id}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${item.mediaType.name.toUpperCase()} • '
            'Trashed ${formatter.format(trashedAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => restoreDeletedItem(ref, item.id),
                icon: const Icon(Icons.restore_from_trash, size: 18),
                label: const Text('Restore'),
              ),
              OutlinedButton.icon(
                onPressed: () => _confirmHardDelete(context, ref, item),
                icon: const Icon(Icons.delete_forever, size: 18),
                label: const Text('Delete forever'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmHardDelete(
      BuildContext context, WidgetRef ref, MediaItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete forever?'),
        content: Text(
          '"${item.title}" will be removed permanently from this device. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete forever'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await hardDeleteItem(ref, item.id);
    }
  }
}
