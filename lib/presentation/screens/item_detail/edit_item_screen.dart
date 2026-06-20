// Edit screen for an existing collection item — reuses the shared
// EditableMetadataForm with the item's current values pre-filled.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/usecases/edit_item_metadata_usecase.dart';
import 'package:mymediascanner/presentation/providers/metadata_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/editable_metadata_form.dart';
import 'package:mymediascanner/presentation/widgets/error_state.dart';

class EditItemScreen extends ConsumerWidget {
  const EditItemScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(mediaItemProvider(itemId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Item')),
      body: SafeArea(
        top: false,
        child: itemAsync.when(
          data: (item) {
            if (item == null) {
              return const ErrorState(message: 'Item not found');
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: EditableMetadataForm(
                initial: EditItemMetadataUseCase.toMetadataResult(item),
                primarySaveLabel: 'Save Changes',
                enableOnlineLookup: true,
                showFormatSuggestions: true,
                onSave: (edited) async {
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = GoRouter.of(context);
                  final useCase = EditItemMetadataUseCase(
                    repository: ref.read(mediaItemRepositoryProvider),
                  );
                  await useCase.execute(item, edited);
                  if (!context.mounted) return;
                  ref.invalidate(mediaItemProvider(itemId));
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Changes saved')),
                  );
                  navigator.pop();
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              ErrorState(message: 'Failed to load item: $e'),
        ),
      ),
    );
  }
}
