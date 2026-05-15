// Persistence tests for SavedSearchesNotifier.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/providers/collection_rip_status_provider.dart';
import 'package:mymediascanner/presentation/providers/saved_searches_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

CollectionFilterState _filter({
  MediaType? mediaType,
  int? minYear,
  Set<String> selectedGenres = const {},
}) =>
    (
      mediaType: mediaType,
      search: null,
      sortBy: 'dateAdded',
      ascending: false,
      lentOnly: false,
      rippedOnly: false,
      ripStatusFilter: RipStatusFilter.all,
      minYear: minYear,
      maxYear: null,
      minRating: null,
      selectedGenres: selectedGenres,
    );

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('save persists a search and reload sees it', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(savedSearchesProvider.notifier)
        .save(SavedSearch(name: 'Unread sci-fi', filter: _filter(
          mediaType: MediaType.book,
          selectedGenres: {'Sci-Fi'},
        )));

    final loaded = await container.refresh(savedSearchesProvider.future);
    expect(loaded, hasLength(1));
    expect(loaded.first.name, 'Unread sci-fi');
    expect(loaded.first.filter.mediaType, MediaType.book);
    expect(loaded.first.filter.selectedGenres, equals({'Sci-Fi'}));
  });

  test('saving the same name overwrites', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(savedSearchesProvider.notifier);
    await notifier.save(SavedSearch(name: 'Q1', filter: _filter(minYear: 2024)));
    await notifier.save(SavedSearch(name: 'Q1', filter: _filter(minYear: 2026)));

    final loaded = await container.refresh(savedSearchesProvider.future);
    expect(loaded, hasLength(1));
    expect(loaded.first.filter.minYear, 2026);
  });

  test('remove deletes by name', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(savedSearchesProvider.notifier);
    await notifier.save(SavedSearch(name: 'A', filter: _filter()));
    await notifier.save(SavedSearch(name: 'B', filter: _filter()));
    await notifier.remove('A');

    final loaded = await container.refresh(savedSearchesProvider.future);
    expect(loaded.map((s) => s.name), equals(['B']));
  });
}
