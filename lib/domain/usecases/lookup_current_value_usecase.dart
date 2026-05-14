import 'package:mymediascanner/data/mappers/discogs_marketplace_mapper.dart';
import 'package:mymediascanner/data/remote/api/discogs/discogs_api.dart';
import 'package:mymediascanner/domain/entities/marketplace_price.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
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
  })  : _api = discogsApi,
        _repo = repository;

  final DiscogsApi? _api;
  final IMediaItemRepository _repo;

  Future<MarketplacePrice?> execute(MediaItem item) async {
    final api = _api;
    if (api == null) return null;
    final releaseId = _discogsReleaseIdFor(item);
    if (releaseId == null) return null;

    try {
      final dto = await api.getMarketplaceStats(releaseId);
      final fetchedAt = DateTime.now().millisecondsSinceEpoch;
      final price =
          DiscogsMarketplaceMapper.fromDto(dto, fetchedAt: fetchedAt);
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

  int? _discogsReleaseIdFor(MediaItem item) {
    final raw = item.extraMetadata['discogs_release_id'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }
}
