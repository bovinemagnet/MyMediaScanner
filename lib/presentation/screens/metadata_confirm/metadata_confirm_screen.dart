import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';
import 'package:mymediascanner/presentation/providers/series_provider.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/editable_metadata_form.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/tmdb_account_panel.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/title_search_field.dart';
import 'package:mymediascanner/presentation/widgets/duplicate_check_helper.dart';
import 'package:mymediascanner/presentation/widgets/ocr_confidence_indicator.dart';

class MetadataConfirmScreen extends ConsumerStatefulWidget {
  const MetadataConfirmScreen({super.key});

  @override
  ConsumerState<MetadataConfirmScreen> createState() =>
      _MetadataConfirmScreenState();
}

class _MetadataConfirmScreenState extends ConsumerState<MetadataConfirmScreen> {
  /// Rating applied from the TMDB account panel. `null` means not set.
  double? _userRating;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final settings = ref.read(tmdbAccountSyncSettingsProvider);
      if (!settings.enabled || !settings.enrichScans) return;
      final tmdbId = _resolveTmdbId();
      final mediaType = _resolveApiMediaType();
      if (tmdbId != null && (mediaType == 'movie' || mediaType == 'tv')) {
        ref
            .read(enrichScanWithTmdbAccountUseCaseProvider)
            .call(tmdbId: tmdbId, mediaType: mediaType!);
      }
    });
  }

  /// Returns the TMDB integer ID from the resolved metadata's extraMetadata,
  /// or null if not present.
  int? _resolveTmdbId() {
    final meta = _resolvedMetadata();
    if (meta == null) return null;
    final raw = meta.extraMetadata['tmdb_id'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return null;
  }

  /// Returns the TMDB API media-type string ('movie' or 'tv') from the
  /// resolved metadata's extraMetadata. TmdbMapper now writes 'movie'
  /// directly, so no normalisation is required here.
  String? _resolveApiMediaType() {
    final meta = _resolvedMetadata();
    if (meta == null) return null;
    final raw = meta.extraMetadata['media_type'];
    if (raw is! String) return null;
    return raw;
  }

  MetadataResult? _resolvedMetadata() {
    final scannerState = ref.read(scannerProvider);
    return switch (scannerState.result) {
      SingleScanResult(:final metadata) => metadata,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isNotFound = scannerState.result is NotFoundScanResult;
    final ocrContext = scannerState.ocrSearchResult;
    final metadata = switch (scannerState.result) {
      SingleScanResult(:final metadata) => metadata,
      NotFoundScanResult(:final barcode, :final barcodeType) => MetadataResult(
        barcode: barcode,
        barcodeType: barcodeType,
      ),
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

    // Resolve TMDB account-sync state for the panel (outside the save
    // callback so it can be watched reactively).
    final settings = ref.watch(tmdbAccountSyncSettingsProvider);
    final tmdbId = _resolveTmdbId();
    final apiMediaType = _resolveApiMediaType();
    final showPanel = settings.enabled &&
        tmdbId != null &&
        (apiMediaType == 'movie' || apiMediaType == 'tv');

    final accountPanel = showPanel
        // Both tmdbId and apiMediaType are non-null when showPanel is true.
        ? ref
              .watch(
                tmdbBridgeForIdProvider(
                  (tmdbId: tmdbId, mediaType: apiMediaType!),
                ),
              )
              .maybeWhen(
                data: (bridge) => bridge == null
                    ? null
                    : TmdbAccountPanel(
                        bridge: bridge,
                        localRating: _userRating,
                        onApplyRating: (rating) =>
                            setState(() => _userRating = rating),
                      ),
                orElse: () => null,
              )
        : null;

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
        // `SafeArea(bottom: true)` eats the Android gesture / 3-button
        // navigation bar inset so the Save button is never hidden beneath
        // `< O =`. Top is already handled by AppBar.
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
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
                            Icon(
                              Icons.info_outline,
                              color: colors.primary,
                              size: 20,
                            ),
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
                          isLoading: scannerState.state == ScanState.lookingUp,
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
                  primarySaveLabel:
                      scannerState.saveTarget == SaveTarget.wishlist
                      ? 'Save to Wishlist'
                      : 'Save to Collection',
                  primarySaveIcon:
                      scannerState.saveTarget == SaveTarget.wishlist
                      ? Icons.favorite
                      : Icons.save,
                  onSave: (edited) async {
                    final targetsWishlist =
                        scannerState.saveTarget == SaveTarget.wishlist;
                    // Avoid leaking the user's scanned barcode and title
                    // into release logs — both are personal collection
                    // data with no operational value in production.
                    if (kDebugMode) {
                      debugPrint(
                        '[MMS-save] onSave start barcode=${edited.barcode}'
                        ' title=${edited.title}'
                        ' target=${scannerState.saveTarget.name}',
                      );
                    }
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
                    final savedItem = await useCase.execute(
                      edited,
                      ownershipStatus: targetsWishlist
                          ? OwnershipStatus.wishlist
                          : OwnershipStatus.owned,
                    );
                    debugPrint('[MMS-save] DB write complete');

                    // Apply TMDB-sourced rating if the user tapped
                    // "Apply to local rating" from the account panel.
                    // Guard on savedItem.userRating == null so that any
                    // rating already embedded in the saved item (e.g. from
                    // a future form field) is not clobbered.
                    // Stamp a fresh updatedAt so sync's last-write-wins
                    // conflict resolution sees this as a distinct write.
                    final appliedRating = _userRating;
                    if (appliedRating != null &&
                        savedItem.userRating == null) {
                      await repository.update(
                        savedItem.copyWith(
                          userRating: appliedRating,
                          updatedAt: DateTime.now().millisecondsSinceEpoch,
                        ),
                      );
                      debugPrint(
                          '[MMS-save] TMDB rating applied: $appliedRating');
                    }

                    final scanner = ref.read(scannerProvider.notifier);
                    final snackText = targetsWishlist
                        ? '${edited.title ?? "Item"} added to wishlist'
                        : '${edited.title ?? "Item"} saved';

                    if (ref.read(scannerProvider).batchMode) {
                      scanner.incrementBatchCount();
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(snackText)));
                        debugPrint('[MMS-save] batch: navigate /scan');
                        context.go('/scan');
                      }
                    } else {
                      debugPrint('[MMS-save] calling scanner.reset()');
                      scanner.reset();
                      debugPrint('[MMS-save] scanner.reset() returned');
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(snackText)));
                        final destination = targetsWishlist ? '/wishlist' : '/';
                        debugPrint('[MMS-save] navigate $destination');
                        context.go(destination);
                      }
                    }
                    debugPrint('[MMS-save] onSave done');
                  },
                ),
                // TMDB account-state panel — shown when account sync is
                // enabled and a bridge row exists for the resolved title.
                ?accountPanel,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
