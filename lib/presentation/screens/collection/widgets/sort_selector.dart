import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';

class SortSelector extends ConsumerWidget {
  const SortSelector({super.key});

  static const _options = {
    'dateAdded': 'Date Added',
    'title': 'Title',
    'year': 'Year',
    'userRating': 'Rating',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(collectionFilterProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Flexible + isExpanded lets the dropdown shrink when the
        // selector lives in a narrow OverflowBar slot (master pane,
        // stacked actions). Text overflow ellipsises.
        Flexible(
          child: DropdownButton<String>(
            value: filter.sortBy,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: _options.entries
                .map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value,
                          overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(collectionFilterProvider.notifier).setSort(value);
              }
            },
          ),
        ),
        IconButton(
          icon: Icon(filter.ascending
              ? Icons.arrow_upward
              : Icons.arrow_downward),
          onPressed: () => ref
              .read(collectionFilterProvider.notifier)
              .setSort(filter.sortBy ?? 'dateAdded',
                  ascending: !filter.ascending),
          tooltip: filter.ascending ? 'Ascending' : 'Descending',
        ),
      ],
    );
  }
}
