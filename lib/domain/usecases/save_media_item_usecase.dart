import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:uuid/uuid.dart';

class SaveMediaItemUseCase {
  const SaveMediaItemUseCase({required IMediaItemRepository repository})
      : _repo = repository;

  final IMediaItemRepository _repo;
  static const _uuid = Uuid();

  Future<MediaItem> execute(MetadataResult metadata) async {
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
      dateAdded: now,
      dateScanned: now,
      updatedAt: now,
    );

    await _repo.save(item);
    return item;
  }
}
