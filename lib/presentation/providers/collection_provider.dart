import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
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
  final repo = ref.watch(mediaItemRepositoryProvider);
  final useCase = GetCollectionUseCase(repository: repo);

  // Two branches with deliberately different semantics:
  //   * no-search path: delegates filtering/ordering to the DAO via
  //     watchByStatus, then applies media-type and sort in memory. This is
  //     the common case and keeps wishlist items out of the stream at the
  //     SQL layer.
  //   * search path: routes through the usecase so FTS5 relevance ordering
  //     (ORDER BY rank) is preserved; the wishlist exclusion is applied in
  //     memory here because the FTS query does not know about ownership.
  final Stream<List<MediaItem>> baseStream = (filter.search == null ||
              filter.search!.trim().isEmpty)
      ? repo.watchByStatus(OwnershipStatus.owned).map((items) {
          final filtered = filter.mediaType == null
              ? items
              : items
                  .where((i) => i.mediaType == filter.mediaType)
                  .toList();
          final sortBy = filter.sortBy ?? 'dateAdded';
          final sorted = [...filtered]..sort((a, b) {
              int cmp;
              switch (sortBy) {
                case 'title':
                  cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
                  break;
                case 'year':
                  cmp = (a.year ?? 0).compareTo(b.year ?? 0);
                  break;
                case 'userRating':
                  cmp = (a.userRating ?? 0).compareTo(b.userRating ?? 0);
                  break;
                case 'mediaType':
                  cmp = a.mediaType.name.compareTo(b.mediaType.name);
                  break;
                case 'dateAdded':
                default:
                  cmp = a.dateAdded.compareTo(b.dateAdded);
              }
              return filter.ascending ? cmp : -cmp;
            });
          return sorted;
        })
      : useCase
          .execute(
            mediaType: filter.mediaType,
            searchQuery: filter.search,
            sortBy: filter.sortBy,
            ascending: filter.ascending,
          )
          .map((items) => items
              .where((i) => i.ownershipStatus == OwnershipStatus.owned)
              .toList());

  final stream = baseStream;

  final needsLentFilter = filter.lentOnly;
  final needsRippedFilter =
      filter.rippedOnly || filter.ripStatusFilter != RipStatusFilter.all;

  if (!needsLentFilter && !needsRippedFilter) return stream;

  final lentIds = ref.watch(lentItemIdsProvider).value ?? <String>{};
  final rippedIds = ref.watch(rippedItemIdsProvider).value ?? <String>{};
  final qualityCache =
      ref.watch(ripQualityStatusCacheProvider).value ?? <String, RipStatus>{};
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
        case RipStatusFilter.verified:
          if (qualityCache[item.id] != RipStatus.verified) return false;
        case RipStatusFilter.qualityIssues:
          if (qualityCache[item.id] != RipStatus.qualityIssues) return false;
      }
      return true;
    }).toList(),
  );
});
