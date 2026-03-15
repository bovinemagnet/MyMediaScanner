import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';

/// Use case to re-fetch metadata from the original API source and merge it
/// into an existing [MediaItem], preserving user data.
///
/// Author: Paul Snow
/// @since 0.0.0
class RefreshMetadataUseCase {
  const RefreshMetadataUseCase({
    required IMetadataRepository metadataRepository,
    required IMediaItemRepository mediaItemRepository,
  })  : _metadataRepo = metadataRepository,
        _mediaItemRepo = mediaItemRepository;

  final IMetadataRepository _metadataRepo;
  final IMediaItemRepository _mediaItemRepo;

  /// Re-fetches metadata for [item] from the API and merges the result,
  /// preserving user data (rating, review, tags, dateAdded).
  Future<MediaItem> execute(MediaItem item) async {
    final metadata = await _metadataRepo.lookupBarcode(
      item.barcode,
      typeHint: item.mediaType,
    );

    final now = DateTime.now().millisecondsSinceEpoch;

    final updated = item.copyWith(
      title: metadata.title ?? item.title,
      subtitle: metadata.subtitle ?? item.subtitle,
      description: metadata.description ?? item.description,
      coverUrl: metadata.coverUrl ?? item.coverUrl,
      year: metadata.year ?? item.year,
      publisher: metadata.publisher ?? item.publisher,
      format: metadata.format ?? item.format,
      genres: metadata.genres.isNotEmpty ? metadata.genres : item.genres,
      extraMetadata: metadata.extraMetadata.isNotEmpty
          ? metadata.extraMetadata
          : item.extraMetadata,
      sourceApis:
          metadata.sourceApis.isNotEmpty ? metadata.sourceApis : item.sourceApis,
      criticScore: metadata.criticScore ?? item.criticScore,
      criticSource: metadata.criticSource ?? item.criticSource,
      updatedAt: now,
    );

    await _mediaItemRepo.update(updated);
    return updated;
  }
}
