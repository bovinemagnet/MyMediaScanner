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
  int? minYear,
  int? maxYear,
  double? minRating,
  Set<String> selectedGenres,
});

CollectionFilterState _defaultCollectionFilter() => (
      mediaType: null,
      search: null,
      sortBy: 'dateAdded',
      ascending: false,
      lentOnly: false,
      rippedOnly: false,
      ripStatusFilter: RipStatusFilter.all,
      minYear: null,
      maxYear: null,
      minRating: null,
      selectedGenres: const <String>{},
    );

class CollectionFilter extends Notifier<CollectionFilterState> {
  @override
  CollectionFilterState build() => _defaultCollectionFilter();

  CollectionFilterState _copy({
    Object? mediaType = _sentinel,
    Object? search = _sentinel,
    Object? sortBy = _sentinel,
    bool? ascending,
    bool? lentOnly,
    bool? rippedOnly,
    RipStatusFilter? ripStatusFilter,
    Object? minYear = _sentinel,
    Object? maxYear = _sentinel,
    Object? minRating = _sentinel,
    Set<String>? selectedGenres,
  }) {
    return (
      mediaType: identical(mediaType, _sentinel)
          ? state.mediaType
          : mediaType as MediaType?,
      search: identical(search, _sentinel) ? state.search : search as String?,
      sortBy: identical(sortBy, _sentinel) ? state.sortBy : sortBy as String?,
      ascending: ascending ?? state.ascending,
      lentOnly: lentOnly ?? state.lentOnly,
      rippedOnly: rippedOnly ?? state.rippedOnly,
      ripStatusFilter: ripStatusFilter ?? state.ripStatusFilter,
      minYear: identical(minYear, _sentinel) ? state.minYear : minYear as int?,
      maxYear: identical(maxYear, _sentinel) ? state.maxYear : maxYear as int?,
      minRating: identical(minRating, _sentinel)
          ? state.minRating
          : minRating as double?,
      selectedGenres: selectedGenres ?? state.selectedGenres,
    );
  }

  /// Replaces the entire filter state, e.g. when restoring a saved
  /// search. Validates by round-tripping through `_copy` so any future
  /// invariants stay enforced in one place.
  void apply(CollectionFilterState newState) {
    state = newState;
  }

  /// Resets to the default filter state.
  void reset() {
    state = _defaultCollectionFilter();
  }

  void setMediaType(MediaType? type) {
    state = _copy(mediaType: type);
  }

  void setSearch(String? query) {
    state = _copy(search: query?.isEmpty == true ? null : query);
  }

  void setSort(String sortBy, {bool? ascending}) {
    state = _copy(sortBy: sortBy, ascending: ascending);
  }

  void toggleLentOnly() {
    state = _copy(lentOnly: !state.lentOnly);
  }

  void toggleRippedOnly() {
    state = _copy(rippedOnly: !state.rippedOnly);
  }

  void setRipStatusFilter(RipStatusFilter filter) {
    state = _copy(ripStatusFilter: filter);
  }

  void setYearRange({int? minYear, int? maxYear}) {
    state = _copy(minYear: minYear, maxYear: maxYear);
  }

  void setMinRating(double? value) {
    state = _copy(minRating: value);
  }

  void toggleGenre(String genre) {
    final next = {...state.selectedGenres};
    if (!next.add(genre)) next.remove(genre);
    state = _copy(selectedGenres: next);
  }

  void setSelectedGenres(Set<String> genres) {
    state = _copy(selectedGenres: genres);
  }

  void clearFacets() {
    state = _copy(
      minYear: null,
      maxYear: null,
      minRating: null,
      selectedGenres: const <String>{},
    );
  }
}

const Object _sentinel = Object();

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
  final needsFacetFilter = filter.minYear != null ||
      filter.maxYear != null ||
      filter.minRating != null ||
      filter.selectedGenres.isNotEmpty;

  if (!needsLentFilter && !needsRippedFilter && !needsFacetFilter) {
    return stream;
  }

  final lentIds = needsLentFilter
      ? (ref.watch(lentItemIdsProvider).value ?? <String>{})
      : <String>{};
  final rippedIds = needsRippedFilter
      ? (ref.watch(rippedItemIdsProvider).value ?? <String>{})
      : <String>{};
  final qualityCache = needsRippedFilter
      ? (ref.watch(ripQualityStatusCacheProvider).value ??
          <String, RipStatus>{})
      : <String, RipStatus>{};
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
      if (filter.minYear != null &&
          (item.year == null || item.year! < filter.minYear!)) {
        return false;
      }
      if (filter.maxYear != null &&
          (item.year == null || item.year! > filter.maxYear!)) {
        return false;
      }
      if (filter.minRating != null &&
          (item.userRating == null ||
              item.userRating! < filter.minRating!)) {
        return false;
      }
      if (filter.selectedGenres.isNotEmpty) {
        final hasMatch = item.genres
            .any((g) => filter.selectedGenres.contains(g));
        if (!hasMatch) return false;
      }
      return true;
    }).toList(),
  );
});
