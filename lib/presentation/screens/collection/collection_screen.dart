import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/usecases/delete_media_item_usecase.dart';
import 'package:mymediascanner/domain/usecases/export_collection_usecase.dart';
import 'package:mymediascanner/domain/usecases/refresh_metadata_usecase.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/providers/insights_export_provider.dart';
import 'package:mymediascanner/presentation/providers/loan_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/filter_bar.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/media_item_card.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/sort_selector.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/shelf_picker_dialog.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/borrower_picker_dialog.dart';
import 'package:mymediascanner/presentation/providers/collection_view_mode_provider.dart';
import 'package:mymediascanner/presentation/providers/selected_item_provider.dart';
import 'package:mymediascanner/presentation/screens/collection/collection_detail_panel.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/collection_table_view.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/view_mode_toggle.dart';
import 'package:mymediascanner/presentation/widgets/context_menu_actions.dart';
import 'package:mymediascanner/presentation/widgets/desktop_context_menu.dart';
import 'package:mymediascanner/presentation/widgets/gradient_button.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';
import 'package:mymediascanner/presentation/widgets/desktop_shortcuts.dart';
import 'package:mymediascanner/presentation/widgets/empty_state.dart';
import 'package:mymediascanner/presentation/widgets/error_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';
import 'package:mymediascanner/presentation/widgets/master_detail_layout.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onItemTap(BuildContext context, String itemId) {
    final width = MediaQuery.sizeOf(context).width;
    final useDetailPanel = PlatformCapability.isDesktop && width >= 900;
    if (useDetailPanel) {
      ref.read(selectedItemProvider.notifier).select(itemId);
    } else {
      context.go('/collection/item/$itemId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectionAsync = ref.watch(collectionProvider);
    final lentIds = ref.watch(lentItemIdsProvider).value ?? <String>{};
    final rippedIds = ref.watch(rippedItemIdsProvider).value ?? <String>{};
    final selectedId = ref.watch(selectedItemProvider);
    final viewMode = ref.watch(collectionViewModeProvider);
    final isDesktop = PlatformCapability.isDesktop;

    final masterContent = Column(
      children: [
        if (isDesktop)
          ScreenHeader(
            title: 'Library',
            subtitle: 'Managing your media collection.',
            actions: [
              const ViewModeToggle(),
              IconButton(
                icon: const Icon(Icons.download),
                tooltip: 'Export collection',
                onPressed: () => _showExportDialog(context, ref),
              ),
              IconButton(
                icon: const Icon(Icons.bar_chart),
                tooltip: 'Collection Statistics',
                onPressed: () => context.go('/collection/statistics'),
              ),
              const SortSelector(),
              const SizedBox(width: 8),
              GradientButton(
                onPressed: () => context.go('/scan'),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 6),
                    Text('Add Media'),
                  ],
                ),
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SearchBar(
            focusNode: _searchFocusNode,
            hintText: 'Search collection...',
            leading: const Icon(Icons.search),
            onChanged: (query) =>
                ref.read(collectionFilterProvider.notifier).setSearch(query),
          ),
        ),
        if (!isDesktop)
          const PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: FilterBar(),
          ),
        if (isDesktop)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: FilterBar(),
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
              if (isDesktop &&
                  viewMode == CollectionViewMode.table) {
                return CollectionTableView(
                  items: items,
                  lentIds: lentIds,
                  rippedIds: rippedIds,
                  onItemTap: (id) => _onItemTap(context, id),
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
                itemBuilder: (context, index) {
                  final item = items[index];
                  return MediaItemCard(
                    item: item,
                    isLent: lentIds.contains(item.id),
                    isRipped: rippedIds.contains(item.id),
                    onTap: () => _onItemTap(context, item.id),
                    contextMenuActions: isDesktop
                        ? _buildItemContextActions(
                            context, ref, item)
                        : const [],
                  );
                },
              );
            },
          ),
        ),
      ],
    );

    return NotificationListener<SearchFocusNotification>(
      onNotification: (_) {
        _searchFocusNode.requestFocus();
        return true;
      },
      child: Scaffold(
        appBar: isDesktop
            ? null
            : AppBar(
                title: const Text('Library'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.shelves),
                    tooltip: 'Shelves',
                    onPressed: () => context.go('/shelves'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: 'Export collection',
                    onPressed: () => _showExportDialog(context, ref),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bar_chart),
                    tooltip: 'Statistics',
                    onPressed: () => context.go('/collection/statistics'),
                  ),
                  const SortSelector(),
                ],
              ),
        body: MasterDetailLayout(
          master: masterContent,
          detail: selectedId != null
              ? CollectionDetailPanel(itemId: selectedId)
              : null,
        ),
      ),
    );
  }

  List<ContextMenuAction> _buildItemContextActions(
    BuildContext context,
    WidgetRef ref,
    MediaItem item,
  ) {
    return ContextMenuActions.forMediaItem(
      onEdit: () => context.go('/collection/item/${item.id}/edit'),
      onDelete: () => _confirmDeleteItem(context, ref, item.id),
      onAddToShelf: () => showDialog<void>(
        context: context,
        builder: (_) => ShelfPickerDialog(mediaItemId: item.id),
      ),
      onLend: () => showDialog<void>(
        context: context,
        builder: (_) => BorrowerPickerDialog(mediaItemId: item.id),
      ),
      onRefreshMetadata: () => _refreshItemMetadata(context, ref, item),
    );
  }

  void _confirmDeleteItem(
      BuildContext context, WidgetRef ref, String itemId) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('This item will be removed from your collection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await DeleteMediaItemUseCase(
                repository: ref.read(mediaItemRepositoryProvider),
              ).execute(itemId);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshItemMetadata(
    BuildContext context,
    WidgetRef ref,
    MediaItem item,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Refreshing metadata\u2026')),
    );
    try {
      await RefreshMetadataUseCase(
        metadataRepository: ref.read(metadataRepositoryProvider),
        mediaItemRepository: ref.read(mediaItemRepositoryProvider),
      ).execute(item);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Metadata refreshed')),
        );
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Failed to refresh metadata: $e')),
        );
    }
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
    final filePath =
        await ref.read(insightsExportProvider.notifier).export(format);

    if (filePath != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Collection exported to $filePath'),
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      final error =
          ref.read(insightsExportProvider).error ?? 'Unknown error';
      messenger.showSnackBar(
        SnackBar(
          content: Text('Export failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
