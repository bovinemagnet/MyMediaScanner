import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/usecases/manage_shelves_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/shelf_provider.dart';

/// Dialog that lets the user pick a shelf to add an item to.
class ShelfPickerDialog extends ConsumerWidget {
  const ShelfPickerDialog({super.key, required this.mediaItemId});

  final String mediaItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelvesAsync = ref.watch(allShelvesProvider);

    return AlertDialog(
      title: const Text('Add to shelf'),
      content: SizedBox(
        width: 300,
        child: shelvesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (shelves) {
            if (shelves.isEmpty) {
              return const Text('No shelves yet. Create one first.');
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: shelves.length,
              itemBuilder: (context, index) {
                final shelf = shelves[index];
                return ListTile(
                  leading: const Icon(Icons.shelves),
                  title: Text(shelf.name),
                  onTap: () async {
                    final useCase = ManageShelvesUseCase(
                      repository: ref.read(shelfRepositoryProvider),
                    );
                    await useCase.addItem(
                      shelfId: shelf.id,
                      mediaItemId: mediaItemId,
                      position: 0,
                    );
                    ref.invalidate(shelfItemIdsProvider(shelf.id));
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added to "${shelf.name}"'),
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
