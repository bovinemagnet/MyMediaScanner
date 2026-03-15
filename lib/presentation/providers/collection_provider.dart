import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/usecases/get_collection_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

/// Filter state for the collection screen.
typedef CollectionFilterState = ({
  MediaType? mediaType,
  String? search,
  String? sortBy,
  bool ascending,
});

class CollectionFilter extends Notifier<CollectionFilterState> {
  @override
  CollectionFilterState build() {
    return (mediaType: null, search: null, sortBy: 'dateAdded', ascending: false);
  }

  void setMediaType(MediaType? type) {
    state = (
      mediaType: type,
      search: state.search,
      sortBy: state.sortBy,
      ascending: state.ascending,
    );
  }

  void setSearch(String? query) {
    state = (
      mediaType: state.mediaType,
      search: query?.isEmpty == true ? null : query,
      sortBy: state.sortBy,
      ascending: state.ascending,
    );
  }

  void setSort(String sortBy, {bool? ascending}) {
    state = (
      mediaType: state.mediaType,
      search: state.search,
      sortBy: sortBy,
      ascending: ascending ?? state.ascending,
    );
  }
}

final collectionFilterProvider =
    NotifierProvider<CollectionFilter, CollectionFilterState>(
        () => CollectionFilter());

final collectionProvider = StreamProvider<List<MediaItem>>((ref) {
  final filter = ref.watch(collectionFilterProvider);
  final useCase = GetCollectionUseCase(
    repository: ref.watch(mediaItemRepositoryProvider),
  );
  return useCase.execute(
    mediaType: filter.mediaType,
    searchQuery: filter.search,
    sortBy: filter.sortBy,
    ascending: filter.ascending,
  );
});
