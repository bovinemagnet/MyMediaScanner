import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/resolve_series_usecase.dart';
import 'package:uuid/uuid.dart';

class SaveMediaItemUseCase {
  const SaveMediaItemUseCase({
    required IMediaItemRepository repository,
    ResolveSeriesUseCase? resolveSeries,
  })  : _repo = repository,
        _resolveSeries = resolveSeries;

  final IMediaItemRepository _repo;
  final ResolveSeriesUseCase? _resolveSeries;
  static const _uuid = Uuid();

  Future<MediaItem> execute(
    MetadataResult metadata, {
    OwnershipStatus ownershipStatus = OwnershipStatus.owned,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final item = MediaItem(
      id: _uuid.v7(),
      barcode: metadata.barcode,
      barcodeType: metadata.barcodeType,
      mediaType: metadata.mediaType ?? MediaType.unknown,
      title: metadata.title ?? 'Unknown',
      subtitle: metadata.subtitle,
      description: metadata.description,
      coverUrl: metadata.coverUrl,
      year: metadata.year,
      publisher: metadata.publisher,
      format: metadata.format,
      genres: metadata.genres,
      extraMetadata: metadata.extraMetadata,
      sourceApis: metadata.sourceApis,
      criticScore: metadata.criticScore,
      criticSource: metadata.criticSource,
      ownershipStatus: ownershipStatus,
      // Only stamp acquiredAt when the item actually enters the collection.
      acquiredAt:
          ownershipStatus == OwnershipStatus.owned ? now : null,
      dateAdded: now,
      dateScanned: now,
      updatedAt: now,
    );

    await _repo.save(item);

    final resolveSeries = _resolveSeries;
    if (resolveSeries != null) {
      return resolveSeries.execute(item, metadata);
    }
    return item;
  }
}
