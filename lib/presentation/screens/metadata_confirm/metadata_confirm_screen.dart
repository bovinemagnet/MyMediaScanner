import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/editable_metadata_form.dart';

class MetadataConfirmScreen extends ConsumerWidget {
  const MetadataConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerState = ref.watch(scannerProvider);
    final metadata = switch (scannerState.result) {
      SingleScanResult(:final metadata) => metadata,
      _ => null,
    };

    if (metadata == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Confirm')),
        body: const Center(child: Text('No scan result')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Metadata'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(scannerProvider.notifier).reset();
            context.go('/scan');
          },
        ),
      ),
      body: EditableMetadataForm(
        initial: metadata,
        onSave: (edited) async {
          final useCase = SaveMediaItemUseCase(
            repository: ref.read(mediaItemRepositoryProvider),
          );
          await useCase.execute(edited);

          final scanner = ref.read(scannerProvider.notifier);
          if (ref.read(scannerProvider).batchMode) {
            scanner.incrementBatchCount();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${edited.title ?? "Item"} saved')),
              );
              context.go('/scan');
            }
          } else {
            scanner.reset();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${edited.title ?? "Item"} saved')),
              );
              context.go('/');
            }
          }
        },
      ),
    );
  }
}
