import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/presentation/providers/series_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/editable_metadata_form.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/title_search_field.dart';
import 'package:mymediascanner/presentation/widgets/duplicate_check_helper.dart';
import 'package:mymediascanner/presentation/widgets/ocr_confidence_indicator.dart';

class MetadataConfirmScreen extends ConsumerWidget {
  const MetadataConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerState = ref.watch(scannerProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isNotFound = scannerState.result is NotFoundScanResult;
    final ocrContext = scannerState.ocrSearchResult;
    final metadata = switch (scannerState.result) {
      SingleScanResult(:final metadata) => metadata,
      NotFoundScanResult(:final barcode, :final barcodeType) =>
        MetadataResult(barcode: barcode, barcodeType: barcodeType),
      _ => null,
    };

    // Pre-fill metadata from OCR inferred values when fields are empty
    final effectiveMetadata = metadata != null && ocrContext != null
        ? metadata.copyWith(
            title: metadata.title ?? ocrContext.ocrResult.inferredTitle,
            subtitle: metadata.subtitle ?? ocrContext.inferredArtist,
            year: metadata.year ?? ocrContext.inferredYear,
          )
        : metadata;

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
              // OCR confidence banner
              if (ocrContext != null) ...[
                OcrConfidenceIndicator(
                  confidence: ocrContext.confidence,
                  searchTermUsed: ocrContext.searchTermUsed,
                ),
                const SizedBox(height: 12),
              ],
              if (isNotFound) ...[
                // Not-found info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: colors.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No metadata found for barcode '
                              '${metadata.barcode}',
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Search by title below, or fill in the details '
                        'manually.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TitleSearchField(
                        initialText: ocrContext?.ocrResult.inferredTitle,
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
                const SizedBox(height: 16),
                Text(
                  'OR ENTER DETAILS MANUALLY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              EditableMetadataForm(
                initial: effectiveMetadata!,
                onSave: (edited) async {
                  debugPrint('[MMS-save] onSave start barcode=${edited.barcode}'
                      ' title=${edited.title}');
                  final repository = ref.read(mediaItemRepositoryProvider);
                  final proceed = await confirmSaveOrSkipIfDuplicate(
                    context: context,
                    repository: repository,
                    barcode: edited.barcode,
                    title: edited.title,
                    year: edited.year,
                  );
                  debugPrint('[MMS-save] duplicate check proceed=$proceed');
                  if (!proceed) return;
                  final useCase = ref.read(saveMediaItemUseCaseProvider);
                  await useCase.execute(edited);
                  debugPrint('[MMS-save] DB write complete');

                  final scanner = ref.read(scannerProvider.notifier);
                  if (ref.read(scannerProvider).batchMode) {
                    scanner.incrementBatchCount();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('${edited.title ?? "Item"} saved')),
                      );
                      debugPrint('[MMS-save] batch: navigate /scan');
                      context.go('/scan');
                    }
                  } else {
                    debugPrint('[MMS-save] calling scanner.reset()');
                    scanner.reset();
                    debugPrint('[MMS-save] scanner.reset() returned');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('${edited.title ?? "Item"} saved')),
                      );
                      debugPrint('[MMS-save] navigate /');
                      context.go('/');
                    }
                  }
                  debugPrint('[MMS-save] onSave done');
                },
                onSaveToWishlist: (edited) async {
                  final repository = ref.read(mediaItemRepositoryProvider);
                  final proceed = await confirmSaveOrSkipIfDuplicate(
                    context: context,
                    repository: repository,
                    barcode: edited.barcode,
                    title: edited.title,
                    year: edited.year,
                  );
                  if (!proceed) return;
                  final useCase = ref.read(saveMediaItemUseCaseProvider);
                  await useCase.execute(
                    edited,
                    ownershipStatus: OwnershipStatus.wishlist,
                  );

                  ref.read(scannerProvider.notifier).reset();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${edited.title ?? "Item"} added to wishlist'),
                      ),
                    );
                    context.go('/wishlist');
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
