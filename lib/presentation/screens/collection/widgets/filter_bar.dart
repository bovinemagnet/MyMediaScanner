import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(collectionFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: filter.mediaType == null,
            onSelected: (_) =>
                ref.read(collectionFilterProvider.notifier).setMediaType(null),
          ),
          const SizedBox(width: 8),
          ...MediaType.values
              .where((t) => t != MediaType.unknown)
              .map((type) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type.label),
                      selected: filter.mediaType == type,
                      onSelected: (_) => ref
                          .read(collectionFilterProvider.notifier)
                          .setMediaType(
                              filter.mediaType == type ? null : type),
                    ),
                  )),
          FilterChip(
            label: const Text('Lent out'),
            selected: filter.lentOnly,
            onSelected: (_) =>
                ref.read(collectionFilterProvider.notifier).toggleLentOnly(),
          ),
        ],
      ),
    );
  }
}
