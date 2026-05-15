// Bottom sheet exposing the faceted filters and saved-search bookmarks.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/providers/saved_searches_provider.dart';

/// Opens the facets sheet and returns once dismissed.
Future<void> showFacetsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _FacetsSheet(),
  );
}

class _FacetsSheet extends ConsumerStatefulWidget {
  const _FacetsSheet();

  @override
  ConsumerState<_FacetsSheet> createState() => _FacetsSheetState();
}

class _FacetsSheetState extends ConsumerState<_FacetsSheet> {
  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(collectionFilterProvider);
    final notifier = ref.read(collectionFilterProvider.notifier);
    final savedAsync = ref.watch(savedSearchesProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('More filters', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _YearRangeField(filter: filter, notifier: notifier),
            const SizedBox(height: 16),
            _MinRatingChips(filter: filter, notifier: notifier),
            const SizedBox(height: 16),
            _GenreChips(filter: filter, notifier: notifier),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    notifier.clearFacets();
                  },
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear facets'),
                ),
                FilledButton.icon(
                  onPressed: () => _saveCurrent(context),
                  icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                  label: const Text('Save current as…'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Saved searches', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            savedAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Failed: $e'),
              data: (searches) => searches.isEmpty
                  ? Text(
                      'You have no saved searches yet.',
                      style: theme.textTheme.bodySmall,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final search in searches)
                          ListTile(
                            key: Key('saved-search-${search.name}'),
                            contentPadding: EdgeInsets.zero,
                            title: Text(search.name),
                            trailing: IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => ref
                                  .read(savedSearchesProvider.notifier)
                                  .remove(search.name),
                            ),
                            onTap: () {
                              notifier.apply(search.filter);
                              Navigator.of(context).pop();
                            },
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCurrent(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save current filter'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Unread sci-fi'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;

    await ref.read(savedSearchesProvider.notifier).save(
          SavedSearch(name: name, filter: ref.read(collectionFilterProvider)),
        );
  }
}

class _YearRangeField extends StatelessWidget {
  const _YearRangeField({required this.filter, required this.notifier});

  final CollectionFilterState filter;
  final CollectionFilter notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: filter.minYear?.toString() ?? '',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'From year'),
            onChanged: (v) => notifier.setYearRange(
              minYear: int.tryParse(v),
              maxYear: filter.maxYear,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            initialValue: filter.maxYear?.toString() ?? '',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'To year'),
            onChanged: (v) => notifier.setYearRange(
              minYear: filter.minYear,
              maxYear: int.tryParse(v),
            ),
          ),
        ),
      ],
    );
  }
}

class _MinRatingChips extends StatelessWidget {
  const _MinRatingChips({required this.filter, required this.notifier});

  final CollectionFilterState filter;
  final CollectionFilter notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Min rating', style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            for (final option in [null, 2.0, 3.0, 4.0, 4.5])
              ChoiceChip(
                label: Text(option == null ? 'Any' : '$option+'),
                selected: filter.minRating == option,
                onSelected: (_) => notifier.setMinRating(option),
              ),
          ],
        ),
      ],
    );
  }
}

class _GenreChips extends ConsumerWidget {
  const _GenreChips({required this.filter, required this.notifier});

  final CollectionFilterState filter;
  final CollectionFilter notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allItems = ref.watch(collectionProvider).value ?? const [];
    final genres = <String>{};
    for (final item in allItems) {
      genres.addAll(item.genres);
    }
    final sorted = genres.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Genres', style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        if (sorted.isEmpty)
          Text(
            'No genres in your collection yet.',
            style: theme.textTheme.bodySmall,
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final genre in sorted)
                FilterChip(
                  label: Text(genre),
                  selected: filter.selectedGenres.contains(genre),
                  onSelected: (_) => notifier.toggleGenre(genre),
                ),
            ],
          ),
      ],
    );
  }
}
