import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/usecases/get_collection_usecase.dart';
import 'package:mymediascanner/presentation/providers/loan_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

/// Filter state for the collection screen.
typedef CollectionFilterState = ({
  MediaType? mediaType,
  String? search,
  String? sortBy,
  bool ascending,
  bool lentOnly,
  bool rippedOnly,
});

class CollectionFilter extends Notifier<CollectionFilterState> {
  @override
  CollectionFilterState build() {
    return (
      mediaType: null,
      search: null,
      sortBy: 'dateAdded',
      ascending: false,
      lentOnly: false,
      rippedOnly: false,
    );
  }

  void setMediaType(MediaType? type) {
    state = (
      mediaType: type,
      search: state.search,
      sortBy: state.sortBy,
      ascending: state.ascending,
      lentOnly: state.lentOnly,
      rippedOnly: state.rippedOnly,
    );
  }

  void setSearch(String? query) {
    state = (
      mediaType: state.mediaType,
      search: query?.isEmpty == true ? null : query,
      sortBy: state.sortBy,
      ascending: state.ascending,
      lentOnly: state.lentOnly,
      rippedOnly: state.rippedOnly,
    );
  }

  void setSort(String sortBy, {bool? ascending}) {
    state = (
      mediaType: state.mediaType,
      search: state.search,
      sortBy: sortBy,
      ascending: ascending ?? state.ascending,
      lentOnly: state.lentOnly,
      rippedOnly: state.rippedOnly,
    );
  }

  void toggleLentOnly() {
    state = (
      mediaType: state.mediaType,
      search: state.search,
      sortBy: state.sortBy,
      ascending: state.ascending,
      lentOnly: !state.lentOnly,
      rippedOnly: state.rippedOnly,
    );
  }

  void toggleRippedOnly() {
    state = (
      mediaType: state.mediaType,
      search: state.search,
      sortBy: state.sortBy,
      ascending: state.ascending,
      lentOnly: state.lentOnly,
      rippedOnly: !state.rippedOnly,
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
  final stream = useCase.execute(
    mediaType: filter.mediaType,
    searchQuery: filter.search,
    sortBy: filter.sortBy,
    ascending: filter.ascending,
  );

  if (!filter.lentOnly && !filter.rippedOnly) return stream;

  final lentIds = ref.watch(lentItemIdsProvider).value ?? <String>{};
  final rippedIds = ref.watch(rippedItemIdsProvider).value ?? <String>{};
  return stream.map(
    (items) => items.where((item) {
      if (filter.lentOnly && !lentIds.contains(item.id)) return false;
      if (filter.rippedOnly && !rippedIds.contains(item.id)) return false;
      return true;
    }).toList(),
  );
});
