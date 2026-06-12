import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';

/// Use case backing the item edit screen: applies user-edited metadata
/// onto an existing [MediaItem] and persists it.
///
/// Unlike [RefreshMetadataUseCase] (which merges API results and keeps
/// the local value when the API returns nothing), the user's edits are
/// authoritative — a field the user cleared in the form clears the
/// stored value. Identity and user data (id, barcode, ownership,
/// rating, review, progress, dates) are never touched by the form and
/// are preserved.
///
/// Author: Paul Snow
/// Since: 0.0.0
class EditItemMetadataUseCase {
  const EditItemMetadataUseCase({
    required IMediaItemRepository repository,
  }) : _repo = repository;

  final IMediaItemRepository _repo;

  /// Map an existing item into the [MetadataResult] shape the shared
  /// `EditableMetadataForm` takes as its initial values.
  static MetadataResult toMetadataResult(MediaItem item) => MetadataResult(
        barcode: item.barcode,
        barcodeType: item.barcodeType,
        mediaType: item.mediaType,
        title: item.title,
        subtitle: item.subtitle,
        description: item.description,
        coverUrl: item.coverUrl,
        year: item.year,
        publisher: item.publisher,
        format: item.format,
        genres: item.genres,
        extraMetadata: item.extraMetadata,
        sourceApis: item.sourceApis,
        criticScore: item.criticScore,
        criticSource: item.criticSource,
      );

  /// Apply [edited] onto [item], stamp `updatedAt`, persist, and return
  /// the updated item.
  Future<MediaItem> execute(MediaItem item, MetadataResult edited) async {
    final updated = item.copyWith(
      mediaType: edited.mediaType ?? item.mediaType,
      // Title is the one non-nullable metadata field on MediaItem; an
      // empty edit falls back rather than producing a blank row.
      title: (edited.title?.trim().isNotEmpty ?? false)
          ? edited.title!.trim()
          : item.title,
      subtitle: edited.subtitle,
      description: edited.description,
      coverUrl: edited.coverUrl,
      year: edited.year,
      publisher: edited.publisher,
      format: edited.format,
      genres: edited.genres,
      extraMetadata: edited.extraMetadata,
      sourceApis: edited.sourceApis,
      criticScore: edited.criticScore,
      criticSource: edited.criticSource,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _repo.update(updated);
    return updated;
  }
}
