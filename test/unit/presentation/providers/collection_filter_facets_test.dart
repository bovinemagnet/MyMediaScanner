// Filter facet tests for CollectionFilter.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/providers/collection_rip_status_provider.dart';

void main() {
  group('CollectionFilter facet setters', () {
    test('setYearRange writes both bounds', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(collectionFilterProvider.notifier)
          .setYearRange(minYear: 2000, maxYear: 2010);

      final state = container.read(collectionFilterProvider);
      expect(state.minYear, 2000);
      expect(state.maxYear, 2010);
    });

    test('setYearRange clears bounds when both null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(collectionFilterProvider.notifier);
      notifier.setYearRange(minYear: 2000, maxYear: 2010);
      notifier.setYearRange(minYear: null, maxYear: null);

      final state = container.read(collectionFilterProvider);
      expect(state.minYear, isNull);
      expect(state.maxYear, isNull);
    });

    test('setMinRating writes and clears', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(collectionFilterProvider.notifier);
      notifier.setMinRating(4.0);
      expect(container.read(collectionFilterProvider).minRating, 4.0);

      notifier.setMinRating(null);
      expect(container.read(collectionFilterProvider).minRating, isNull);
    });

    test('toggleGenre adds and removes from set', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(collectionFilterProvider.notifier);
      notifier.toggleGenre('Rock');
      notifier.toggleGenre('Jazz');
      expect(container.read(collectionFilterProvider).selectedGenres,
          equals({'Rock', 'Jazz'}));

      notifier.toggleGenre('Rock');
      expect(container.read(collectionFilterProvider).selectedGenres,
          equals({'Jazz'}));
    });

    test('clearFacets resets year/rating/genres only', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(collectionFilterProvider.notifier);
      notifier.setYearRange(minYear: 2000, maxYear: 2010);
      notifier.setMinRating(3.0);
      notifier.toggleGenre('Rock');
      notifier.toggleLentOnly();

      notifier.clearFacets();

      final state = container.read(collectionFilterProvider);
      expect(state.minYear, isNull);
      expect(state.maxYear, isNull);
      expect(state.minRating, isNull);
      expect(state.selectedGenres, isEmpty);
      // Non-facet filters survive a facet reset.
      expect(state.lentOnly, isTrue);
    });

    test('apply replaces full state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(collectionFilterProvider.notifier);
      notifier.apply((
        mediaType: null,
        search: 'star',
        sortBy: 'year',
        ascending: true,
        lentOnly: false,
        rippedOnly: false,
        ripStatusFilter: RipStatusFilter.all,
        minYear: 1977,
        maxYear: 2019,
        minRating: 4.0,
        selectedGenres: {'Sci-Fi'},
      ));

      final state = container.read(collectionFilterProvider);
      expect(state.search, 'star');
      expect(state.minYear, 1977);
      expect(state.selectedGenres, equals({'Sci-Fi'}));
    });
  });
}
