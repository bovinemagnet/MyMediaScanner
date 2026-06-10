import 'package:mymediascanner/domain/entities/marketplace_price.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/repositories/i_current_value_source.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';

/// Looks up the current marketplace value for a media item and stamps the
/// result onto the persisted record.
///
/// The use case is best-effort: it returns `null` and skips persistence
/// when Discogs credentials are not configured or the item has no
/// resolvable Discogs release ID. When the lookup succeeds but returns no
/// usable price, the item's `currentValueAsOf` is still updated so the UI
/// can show "checked but no price available".
///
/// Author: Paul Snow
/// @since 0.0.0
class LookupCurrentValueUseCase {
  const LookupCurrentValueUseCase({
    required ICurrentValueSource source,
    required IMediaItemRepository repository,
  })  : _source = source,
        _repo = repository;

  final ICurrentValueSource _source;
  final IMediaItemRepository _repo;

  Future<MarketplacePrice?> execute(MediaItem item) async {
    final fetchedAt = DateTime.now().millisecondsSinceEpoch;

    try {
      MarketplacePrice? price;
      if (item.mediaType == MediaType.game) {
        price = await _lookupGame(item, fetchedAt);
      } else {
        price = await _lookupDiscogs(item, fetchedAt);
      }
      if (price == null && !_supports(item)) {
        return null;
      }
      await _repo.update(item.copyWith(
        currentValue: price?.value,
        currentValueAsOf: fetchedAt,
        updatedAt: fetchedAt,
      ));
      return price;
    } catch (_) {
      return null;
    }
  }

  bool _supports(MediaItem item) {
    if (item.mediaType == MediaType.game) {
      return _source.supportsPriceCharting &&
          (item.extraMetadata.containsKey('pricecharting_id') ||
              item.barcode.isNotEmpty);
    }
    return _source.supportsDiscogs &&
        item.extraMetadata.containsKey('discogs_release_id');
  }

  Future<MarketplacePrice?> _lookupDiscogs(
      MediaItem item, int fetchedAt) async {
    if (!_source.supportsDiscogs) return null;
    final releaseId = _discogsReleaseIdFor(item);
    if (releaseId == null) return null;
    return _source.lookupDiscogsPrice(
        releaseId: releaseId, fetchedAt: fetchedAt);
  }

  Future<MarketplacePrice?> _lookupGame(MediaItem item, int fetchedAt) async {
    if (!_source.supportsPriceCharting) return null;
    final productId = item.extraMetadata['pricecharting_id']?.toString();
    return _source.lookupGamePrice(
      productId: productId,
      barcode: item.barcode,
      fetchedAt: fetchedAt,
    );
  }

  int? _discogsReleaseIdFor(MediaItem item) {
    final raw = item.extraMetadata['discogs_release_id'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }
}
