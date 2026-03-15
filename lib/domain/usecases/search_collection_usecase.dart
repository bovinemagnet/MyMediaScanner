import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';

class SearchCollectionUseCase {
  const SearchCollectionUseCase({required IMediaItemRepository repository})
      : _repo = repository;

  final IMediaItemRepository _repo;

  Stream<List<MediaItem>> execute(String query) {
    return _repo.watchAll(searchQuery: query);
  }
}
