import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/shelf.dart';
import 'package:mymediascanner/domain/usecases/manage_shelves_usecase.dart';
import 'package:mymediascanner/presentation/providers/metadata_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/selected_shelf_provider.dart';
import 'package:mymediascanner/presentation/providers/shelf_provider.dart';
import 'package:mymediascanner/presentation/widgets/context_menu_actions.dart';
import 'package:mymediascanner/presentation/widgets/desktop_context_menu.dart';
import 'package:mymediascanner/presentation/widgets/empty_state.dart';
import 'package:mymediascanner/presentation/widgets/gradient_button.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';
import 'package:mymediascanner/presentation/widgets/master_detail_layout.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';

class ShelvesScreen extends ConsumerWidget {
  const ShelvesScreen({super.key});

  void _onShelfTap(BuildContext context, WidgetRef ref, String shelfId) {
    final width = MediaQuery.sizeOf(context).width;
    final useDetailPanel = PlatformCapability.isDesktop && width >= 900;
    if (useDetailPanel) {
      ref.read(selectedShelfProvider.notifier).select(shelfId);
    } else {
      context.go('/shelves/$shelfId');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelvesAsync = ref.watch(allShelvesProvider);
    final selectedShelfId = ref.watch(selectedShelfProvider);

    final masterContent = shelvesAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (shelves) {
        if (shelves.isEmpty) {
          return EmptyState(
            message:
                'No shelves yet. Create one to organise your collection!',
            icon: Icons.shelves,
            action: FilledButton.icon(
              onPressed: () => _showCreateShelfDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New Shelf'),
            ),
          );
        }
        return ListView.builder(
          itemCount: shelves.length,
          itemBuilder: (context, index) {
            final shelf = shelves[index];
            return DesktopContextMenu(
              actions: PlatformCapability.isDesktop
                  ? ContextMenuActions.forShelf(
                      onRename: () =>
                          _showRenameShelfDialog(context, ref, shelf),
                      onDelete: () =>
                          _confirmDeleteShelf(context, ref, shelf),
                    )
                  : const [],
              child: ListTile(
                leading: const Icon(Icons.shelves),
                title: Text(shelf.name),
                subtitle: shelf.description != null
                    ? Text(shelf.description!)
                    : null,
                trailing: const Icon(Icons.chevron_right),
                selected: shelf.id == selectedShelfId,
                onTap: () => _onShelfTap(context, ref, shelf.id),
              ),
            );
          },
        );
      },
    );

    final isDesktop = PlatformCapability.isDesktop;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Shelves'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/collection'),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'New Shelf',
                  onPressed: () => _showCreateShelfDialog(context, ref),
                ),
              ],
            ),
      body: Column(
        children: [
          if (isDesktop)
            ScreenHeader(
              title: 'Shelves',
              subtitle: 'Organise your collection into physical shelves.',
              actions: [
                GradientButton(
                  onPressed: () => _showCreateShelfDialog(context, ref),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 18),
                      SizedBox(width: 6),
                      Text('New Shelf'),
                    ],
                  ),
                ),
              ],
            ),
          Expanded(
            child: MasterDetailLayout(
              master: masterContent,
              detail: selectedShelfId != null
                  ? _ShelfDetailPanel(shelfId: selectedShelfId)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showRenameShelfDialog(
      BuildContext context, WidgetRef ref, Shelf shelf) {
    final nameController = TextEditingController(text: shelf.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Shelf'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Shelf name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != shelf.name) {
                final updated = shelf.copyWith(
                  name: newName,
                  updatedAt: DateTime.now().millisecondsSinceEpoch,
                );
                await ref.read(shelfRepositoryProvider).save(updated);
                ref.invalidate(allShelvesProvider);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteShelf(
      BuildContext context, WidgetRef ref, Shelf shelf) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete shelf?'),
        content: Text(
            'The shelf "${shelf.name}" will be removed. Items in it will not be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () async {
              final useCase = ManageShelvesUseCase(
                repository: ref.read(shelfRepositoryProvider),
              );
              await useCase.deleteShelf(shelf.id);
              ref.invalidate(allShelvesProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateShelfDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Shelf'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Shelf name'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration:
                  const InputDecoration(hintText: 'Description (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final useCase = ManageShelvesUseCase(
                    repository: ref.read(shelfRepositoryProvider));
                await useCase.createShelf(
                  name: nameController.text.trim(),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                );
                ref.invalidate(allShelvesProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

/// Embedded shelf contents panel for master-detail layout.
class _ShelfDetailPanel extends ConsumerWidget {
  const _ShelfDetailPanel({required this.shelfId});

  final String shelfId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemIdsAsync = ref.watch(shelfItemIdsProvider(shelfId));

    return Column(
      children: [
        Material(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Shelf Contents'),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'Close panel',
                  onPressed: () =>
                      ref.read(selectedShelfProvider.notifier).clear(),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: itemIdsAsync.when(
            loading: () => const LoadingIndicator(),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (itemIds) {
              if (itemIds.isEmpty) {
                return const Center(
                  child: Text('No items in this shelf yet.'),
                );
              }
              return ListView.builder(
                itemCount: itemIds.length,
                itemBuilder: (context, index) {
                  final itemAsync =
                      ref.watch(mediaItemProvider(itemIds[index]));
                  return ListTile(
                    title: itemAsync.when(
                      loading: () => const Text('Loading\u2026'),
                      error: (_, _) => const Text('Error'),
                      data: (item) => Text(item?.title ?? 'Unknown'),
                    ),
                    onTap: () => context.go('/collection/item/${itemIds[index]}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
