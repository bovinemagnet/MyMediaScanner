import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mymediascanner/domain/usecases/export_collection_usecase.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/providers/loan_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
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
    final lentIds = ref.watch(lentItemIdsProvider).value ?? <String>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export collection',
            onPressed: () => _showExportDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Collection Statistics',
            onPressed: () => context.go('/statistics'),
          ),
          const SortSelector(),
        ],
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
                    isLent: lentIds.contains(items[index].id),
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

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Export Collection'),
        content: const Text(
          'Choose a format to export your collection.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _exportCollection(context, ref, ExportFormat.csv);
            },
            child: const Text('Export as CSV'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _exportCollection(context, ref, ExportFormat.json);
            },
            child: const Text('Export as JSON'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCollection(
    BuildContext context,
    WidgetRef ref,
    ExportFormat format,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final useCase = ExportCollectionUseCase(
        repository: ref.read(mediaItemRepositoryProvider),
      );

      final directory = await getApplicationDocumentsDirectory();
      final filePath = await useCase.execute(
        format: format,
        outputDirectory: directory.path,
      );

      messenger.showSnackBar(
        SnackBar(
          content: Text('Collection exported to $filePath'),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
