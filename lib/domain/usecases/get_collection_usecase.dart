import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';

class GetCollectionUseCase {
  const GetCollectionUseCase({required IMediaItemRepository repository})
      : _repo = repository;

  final IMediaItemRepository _repo;

  Stream<List<MediaItem>> execute({
    MediaType? mediaType,
    String? searchQuery,
    List<String>? tagIds,
    String? sortBy,
    bool ascending = true,
  }) {
    return _repo.watchAll(
      mediaType: mediaType,
      searchQuery: searchQuery,
      tagIds: tagIds,
      sortBy: sortBy,
      ascending: ascending,
    );
  }
}
