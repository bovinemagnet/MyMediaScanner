// Fetches a missing cover image for a [MediaItem] by re-querying the
// metadata pipeline against the item's barcode and falling back to a
// title search if the barcode yields nothing useful.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';

/// Outcome of a single cover-lookup attempt.
enum FetchCoverOutcome {
  /// The item already had a cover; the use case was a no-op.
  alreadyHasCover,

  /// Barcode lookup or title search returned a cover and the item was
  /// updated.
  updated,

  /// No cover URL could be found via any path. The item is unchanged.
  notFound,
}

/// Looks up a missing cover for a single [MediaItem].
///
/// The strategy mirrors the scan-time lookup order:
///
/// 1. If the item already has a [MediaItem.coverUrl], return
///    [FetchCoverOutcome.alreadyHasCover] without touching the network.
/// 2. If the item has a [MediaItem.barcode], run a barcode lookup with
///    the item's [MediaType] as a type hint. Any returned cover URL wins.
/// 3. Otherwise, or if the barcode returned no cover, fall back to a
///    title search via the same repository.
/// 4. On a hit, persist the new [MediaItem.coverUrl] via
///    [IMediaItemRepository.update] and return [FetchCoverOutcome.updated].
class FetchMissingCoverUseCase {
  FetchMissingCoverUseCase({
    required IMetadataRepository metadataRepository,
    required IMediaItemRepository mediaItemRepository,
    DateTime Function()? now,
  })  : _metadata = metadataRepository,
        _items = mediaItemRepository,
        _now = now ?? DateTime.now;

  final IMetadataRepository _metadata;
  final IMediaItemRepository _items;
  final DateTime Function() _now;

  Future<FetchCoverOutcome> execute(MediaItem item) async {
    if (item.coverUrl != null && item.coverUrl!.isNotEmpty) {
      return FetchCoverOutcome.alreadyHasCover;
    }

    String? coverUrl = await _tryBarcode(item);
    coverUrl ??= await _tryTitle(item);

    if (coverUrl == null || coverUrl.isEmpty) {
      return FetchCoverOutcome.notFound;
    }

    final updated = item.copyWith(
      coverUrl: coverUrl,
      updatedAt: _now().millisecondsSinceEpoch,
    );
    await _items.update(updated);
    return FetchCoverOutcome.updated;
  }

  Future<String?> _tryBarcode(MediaItem item) async {
    if (item.barcode.isEmpty) return null;
    try {
      final result = await _metadata.lookupBarcode(
        item.barcode,
        typeHint: item.mediaType,
      );
      return _coverFromResult(result);
    } on Exception {
      return null;
    }
  }

  Future<String?> _tryTitle(MediaItem item) async {
    if (item.title.isEmpty) return null;
    try {
      final result = await _metadata.searchByTitle(
        item.title,
        item.barcode,
        item.barcodeType,
        typeHint: item.mediaType,
      );
      return _coverFromResult(result);
    } on Exception {
      return null;
    }
  }

  String? _coverFromResult(ScanResult result) {
    if (result is SingleScanResult) {
      final url = result.metadata.coverUrl;
      return (url != null && url.isNotEmpty) ? url : null;
    }
    // Multi-match / not-found contribute nothing the user can auto-accept.
    return null;
  }
}
