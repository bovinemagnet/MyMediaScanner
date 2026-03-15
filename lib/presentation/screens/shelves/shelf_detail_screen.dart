import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/presentation/providers/metadata_provider.dart';
import 'package:mymediascanner/presentation/providers/shelf_provider.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

class ShelfDetailScreen extends ConsumerWidget {
  const ShelfDetailScreen({super.key, required this.shelfId});

  final String shelfId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemIdsAsync = ref.watch(shelfItemIdsProvider(shelfId));

    return Scaffold(
      appBar: AppBar(title: const Text('Shelf')),
      body: itemIdsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (itemIds) {
          if (itemIds.isEmpty) {
            return const Center(
              child: Text('No items in this shelf yet.'),
            );
          }
          return ReorderableListView.builder(
            itemCount: itemIds.length,
            onReorder: (oldIndex, newIndex) {
              // Reorder logic handled by provider
            },
            itemBuilder: (context, index) {
              final itemAsync = ref.watch(mediaItemProvider(itemIds[index]));
              return ListTile(
                key: ValueKey(itemIds[index]),
                title: itemAsync.when(
                  loading: () => const Text('Loading...'),
                  error: (_, __) => const Text('Error'),
                  data: (item) => Text(item?.title ?? 'Unknown'),
                ),
                onTap: () => context.go('/item/${itemIds[index]}'),
              );
            },
          );
        },
      ),
    );
  }
}
