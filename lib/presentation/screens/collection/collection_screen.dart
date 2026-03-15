import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/filter_bar.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/media_item_card.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/sort_selector.dart';
import 'package:mymediascanner/presentation/widgets/empty_state.dart';
import 'package:mymediascanner/presentation/widgets/error_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionAsync = ref.watch(collectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collection'),
        actions: const [SortSelector()],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: FilterBar(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBar(
              hintText: 'Search collection...',
              leading: const Icon(Icons.search),
              onChanged: (query) =>
                  ref.read(collectionFilterProvider.notifier).setSearch(query),
            ),
          ),
          Expanded(
            child: collectionAsync.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => ErrorState(
                message: e.toString(),
                onRetry: () => ref.invalidate(collectionProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(
                    message: 'No items yet. Scan a barcode to get started!',
                    icon: Icons.library_music_outlined,
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) => MediaItemCard(
                    item: items[index],
                    onTap: () => context.go('/item/${items[index].id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
