import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/presentation/providers/metadata_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/shelf_provider.dart';
import 'package:mymediascanner/presentation/widgets/empty_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

class ShelfDetailScreen extends ConsumerWidget {
  const ShelfDetailScreen({super.key, required this.shelfId});

  final String shelfId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemIdsAsync = ref.watch(shelfItemIdsProvider(shelfId));
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Shelf')),
      body: itemIdsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (itemIds) {
          if (itemIds.isEmpty) {
            return const EmptyState(
              message: 'No items in this shelf yet.',
              icon: Icons.shelves,
            );
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: itemIds.length,
            onReorder: (oldIndex, newIndex) async {
              // Flutter contract: if oldIndex < newIndex the destination
              // index is shifted by 1 because the dragged item hasn't
              // been removed yet. Compensate before persisting.
              final adjusted =
                  oldIndex < newIndex ? newIndex - 1 : newIndex;
              final movedId = itemIds[oldIndex];
              await ref
                  .read(shelfRepositoryProvider)
                  .reorderItem(shelfId, movedId, adjusted);
              ref.invalidate(shelfItemIdsProvider(shelfId));
            },
            itemBuilder: (context, index) {
              final itemAsync =
                  ref.watch(mediaItemProvider(itemIds[index]));
              return _ShelfItemTile(
                key: ValueKey(itemIds[index]),
                itemAsync: itemAsync,
                itemId: itemIds[index],
                theme: theme,
                colors: colors,
                onTap: () =>
                    context.go('/collection/item/${itemIds[index]}'),
              );
            },
          );
        },
      ),
    );
  }
}

class _ShelfItemTile extends StatelessWidget {
  const _ShelfItemTile({
    super.key,
    required this.itemAsync,
    required this.itemId,
    required this.theme,
    required this.colors,
    required this.onTap,
  });

  final AsyncValue itemAsync;
  final String itemId;
  final ThemeData theme;
  final ColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: itemAsync.when(
              loading: () => const SizedBox(
                height: 48,
                child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, _) => Row(
                children: [
                  Icon(Icons.error_outline,
                      color: colors.error, size: 20),
                  const SizedBox(width: 12),
                  const Text('Failed to load'),
                ],
              ),
              data: (item) {
                if (item == null) {
                  return const Text('Item not found');
                }
                return Row(
                  children: [
                    // Cover thumbnail
                    Container(
                      width: 40,
                      height: 56,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: item.coverUrl != null
                          ? CachedNetworkImage(
                              imageUrl: item.coverUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => Icon(
                                Icons.image,
                                size: 18,
                                color: colors.onSurfaceVariant,
                              ),
                            )
                          : Icon(
                              Icons.image_not_supported,
                              size: 18,
                              color: colors.onSurfaceVariant,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.subtitle != null)
                            Text(
                              item.subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.drag_handle,
                        color: colors.onSurfaceVariant, size: 20),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
