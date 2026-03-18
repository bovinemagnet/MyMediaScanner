import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/editable_metadata_form.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/title_search_field.dart';

class MetadataConfirmScreen extends ConsumerWidget {
  const MetadataConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerState = ref.watch(scannerProvider);
    final isNotFound = scannerState.result is NotFoundScanResult;
    final metadata = switch (scannerState.result) {
      SingleScanResult(:final metadata) => metadata,
      NotFoundScanResult(:final barcode, :final barcodeType) =>
        MetadataResult(barcode: barcode, barcodeType: barcodeType),
      _ => null,
    };

    // Navigate to disambiguate if title search returned multi-match
    ref.listen(scannerProvider, (prev, next) {
      if (next.state == ScanState.disambiguating) {
        context.go('/scan/disambiguate');
      }
    });

    if (metadata == null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            context.go('/scan');
            ref.read(scannerProvider.notifier).reset();
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Confirm')),
          body: const Center(child: Text('No scan result')),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.go('/scan');
          ref.read(scannerProvider.notifier).reset();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(isNotFound ? 'Barcode Not Found' : 'Confirm Metadata'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.go('/scan');
            ref.read(scannerProvider.notifier).reset();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isNotFound) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color:
                                  Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No metadata found for barcode ${metadata.barcode}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                          'Search by title below, or fill in the details manually.'),
                      const SizedBox(height: 12),
                      TitleSearchField(
                        isLoading:
                            scannerState.state == ScanState.lookingUp,
                        onSearch: (title) {
                          final result = scannerState.result;
                          if (result is! NotFoundScanResult) return;
                          ref
                              .read(scannerProvider.notifier)
                              .searchByTitle(
                                title,
                                result.barcode,
                                result.barcodeType,
                              );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Or enter details manually:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
            ],
            EditableMetadataForm(
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
                      SnackBar(
                          content:
                              Text('${edited.title ?? "Item"} saved')),
                    );
                    context.go('/scan');
                  }
                } else {
                  scanner.reset();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('${edited.title ?? "Item"} saved')),
                    );
                    context.go('/');
                  }
                }
              },
            ),
          ],
        ),
      ),
    ),
    );
  }
}
