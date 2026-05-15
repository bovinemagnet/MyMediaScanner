import 'package:mymediascanner/data/mappers/discogs_marketplace_mapper.dart';
import 'package:mymediascanner/data/mappers/pricecharting_mapper.dart';
import 'package:mymediascanner/data/remote/api/discogs/discogs_api.dart';
import 'package:mymediascanner/data/remote/api/pricecharting/pricecharting_api.dart';
import 'package:mymediascanner/domain/entities/marketplace_price.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
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
    required DiscogsApi? discogsApi,
    required IMediaItemRepository repository,
    PriceChartingApi? priceChartingApi,
    String? priceChartingToken,
  })  : _discogs = discogsApi,
        _priceCharting = priceChartingApi,
        _priceChartingToken = priceChartingToken,
        _repo = repository;

  final DiscogsApi? _discogs;
  final PriceChartingApi? _priceCharting;
  final String? _priceChartingToken;
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
      return _priceCharting != null &&
          _priceChartingToken != null &&
          (item.extraMetadata.containsKey('pricecharting_id') ||
              item.barcode.isNotEmpty);
    }
    return _discogs != null &&
        item.extraMetadata.containsKey('discogs_release_id');
  }

  Future<MarketplacePrice?> _lookupDiscogs(
      MediaItem item, int fetchedAt) async {
    final api = _discogs;
    if (api == null) return null;
    final releaseId = _discogsReleaseIdFor(item);
    if (releaseId == null) return null;
    final dto = await api.getMarketplaceStats(releaseId);
    return DiscogsMarketplaceMapper.fromDto(dto, fetchedAt: fetchedAt);
  }

  Future<MarketplacePrice?> _lookupGame(MediaItem item, int fetchedAt) async {
    final api = _priceCharting;
    final token = _priceChartingToken;
    if (api == null || token == null || token.isEmpty) return null;

    final productId = item.extraMetadata['pricecharting_id']?.toString();
    final dto = productId != null && productId.isNotEmpty
        ? await api.lookupById(token, productId)
        : await api.lookupByUpc(token, item.barcode);
    return PriceChartingMapper.fromDto(dto, fetchedAt: fetchedAt);
  }

  int? _discogsReleaseIdFor(MediaItem item) {
    final raw = item.extraMetadata['discogs_release_id'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }
}
