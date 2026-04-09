import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/usecases/get_collection_usecase.dart';
import 'package:mymediascanner/presentation/providers/collection_rip_status_provider.dart';
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
  RipStatusFilter ripStatusFilter,
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
      ripStatusFilter: RipStatusFilter.all,
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
      ripStatusFilter: state.ripStatusFilter,
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
      ripStatusFilter: state.ripStatusFilter,
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
      ripStatusFilter: state.ripStatusFilter,
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
      ripStatusFilter: state.ripStatusFilter,
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
      ripStatusFilter: state.ripStatusFilter,
    );
  }

  void setRipStatusFilter(RipStatusFilter filter) {
    state = (
      mediaType: state.mediaType,
      search: state.search,
      sortBy: state.sortBy,
      ascending: state.ascending,
      lentOnly: state.lentOnly,
      rippedOnly: state.rippedOnly,
      ripStatusFilter: filter,
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

  final needsLentFilter = filter.lentOnly;
  final needsRippedFilter =
      filter.rippedOnly || filter.ripStatusFilter != RipStatusFilter.all;

  if (!needsLentFilter && !needsRippedFilter) return stream;

  final lentIds = ref.watch(lentItemIdsProvider).value ?? <String>{};
  final rippedIds = ref.watch(rippedItemIdsProvider).value ?? <String>{};
  return stream.map(
    (items) => items.where((item) {
      if (filter.lentOnly && !lentIds.contains(item.id)) return false;
      if (filter.rippedOnly && !rippedIds.contains(item.id)) return false;
      switch (filter.ripStatusFilter) {
        case RipStatusFilter.all:
          break;
        case RipStatusFilter.hasRip:
          if (!rippedIds.contains(item.id)) return false;
        case RipStatusFilter.noRip:
          if (rippedIds.contains(item.id)) return false;
        // verified and qualityIssues require per-item async data — fall back to
        // hasRip so the list is at least narrowed to ripped items.
        case RipStatusFilter.verified:
          if (!rippedIds.contains(item.id)) return false;
        case RipStatusFilter.qualityIssues:
          if (!rippedIds.contains(item.id)) return false;
      }
      return true;
    }).toList(),
  );
});
