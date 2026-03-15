import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/usecases/manage_shelves_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/shelf_provider.dart';
import 'package:mymediascanner/presentation/widgets/empty_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

class ShelvesScreen extends ConsumerWidget {
  const ShelvesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelvesAsync = ref.watch(allShelvesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Shelves')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateShelfDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: shelvesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (shelves) {
          if (shelves.isEmpty) {
            return const EmptyState(
              message:
                  'No shelves yet. Create one to organise your collection!',
              icon: Icons.shelves,
            );
          }
          return ListView.builder(
            itemCount: shelves.length,
            itemBuilder: (context, index) {
              final shelf = shelves[index];
              return ListTile(
                leading: const Icon(Icons.shelves),
                title: Text(shelf.name),
                subtitle: shelf.description != null
                    ? Text(shelf.description!)
                    : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/shelves/${shelf.id}'),
              );
            },
          );
        },
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
