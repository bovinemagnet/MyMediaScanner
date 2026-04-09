import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/providers/collection_rip_status_provider.dart';

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
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Ripped'),
            selected: filter.rippedOnly,
            onSelected: (_) =>
                ref.read(collectionFilterProvider.notifier).toggleRippedOnly(),
          ),
          const SizedBox(width: 8),
          _RipStatusFilterChip(current: filter.ripStatusFilter),
        ],
      ),
    );
  }
}

class _RipStatusFilterChip extends ConsumerWidget {
  const _RipStatusFilterChip({required this.current});

  final RipStatusFilter current;

  String _label(RipStatusFilter f) => switch (f) {
        RipStatusFilter.all => 'Rip: All',
        RipStatusFilter.hasRip => 'Has Rip',
        RipStatusFilter.noRip => 'Not Ripped',
        RipStatusFilter.verified => 'Verified',
        RipStatusFilter.qualityIssues => 'Quality Issues',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = current != RipStatusFilter.all;

    return PopupMenuButton<RipStatusFilter>(
      offset: const Offset(0, 40),
      onSelected: (value) =>
          ref.read(collectionFilterProvider.notifier).setRipStatusFilter(value),
      itemBuilder: (_) => RipStatusFilter.values
          .map(
            (f) => PopupMenuItem(
              value: f,
              child: Row(
                children: [
                  if (current == f)
                    const Icon(Icons.check, size: 16)
                  else
                    const SizedBox(width: 16),
                  const SizedBox(width: 8),
                  Text(_label(f)),
                ],
              ),
            ),
          )
          .toList(),
      child: FilterChip(
        label: Text(_label(current)),
        selected: isActive,
        onSelected: (_) {}, // selection handled by PopupMenuButton
      ),
    );
  }
}
