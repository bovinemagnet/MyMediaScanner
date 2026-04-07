import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/providers/selected_item_provider.dart';
import 'package:mymediascanner/presentation/widgets/table_keyboard_navigation.dart';

/// Sortable data table for the collection, used on desktop.
class CollectionTableView extends ConsumerWidget {
  const CollectionTableView({
    super.key,
    required this.items,
    required this.lentIds,
    required this.rippedIds,
    required this.onItemTap,
    this.onDeleteItem,
  });

  final List<MediaItem> items;
  final Set<String> lentIds;
  final Set<String> rippedIds;
  final ValueChanged<String> onItemTap;
  final ValueChanged<String>? onDeleteItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(collectionFilterProvider);
    final selectedId = ref.watch(selectedItemProvider);
    final dateFormat = DateFormat.yMMMd();

    final itemIds = items.map((e) => e.id).toList();

    return TableKeyboardNavigation(
      onMoveUp: () =>
          ref.read(selectedItemProvider.notifier).movePrevious(itemIds),
      onMoveDown: () =>
          ref.read(selectedItemProvider.notifier).moveNext(itemIds),
      onMoveToFirst: () {
        if (itemIds.isNotEmpty) {
          ref.read(selectedItemProvider.notifier).select(itemIds.first);
        }
      },
      onMoveToLast: () {
        if (itemIds.isNotEmpty) {
          ref.read(selectedItemProvider.notifier).select(itemIds.last);
        }
      },
      onSelect: () {
        final id = selectedId;
        if (id != null) onItemTap(id);
      },
      onDelete: () {
        final id = selectedId;
        if (id != null) onDeleteItem?.call(id);
      },
      onClearSelection: () =>
          ref.read(selectedItemProvider.notifier).clear(),
      child: DataTable2(
      columnSpacing: 12,
      horizontalMargin: 16,
      sortColumnIndex: _sortColumnIndex(filter.sortBy),
      sortAscending: filter.ascending,
      headingRowDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      columns: [
        DataColumn2(
          label: const Text('Title'),
          size: ColumnSize.L,
          onSort: (_, ascending) => ref
              .read(collectionFilterProvider.notifier)
              .setSort('title', ascending: ascending),
        ),
        DataColumn2(
          label: const Text('Artist / Director'),
          size: ColumnSize.M,
          onSort: (_, ascending) => ref
              .read(collectionFilterProvider.notifier)
              .setSort('subtitle', ascending: ascending),
        ),
        DataColumn2(
          label: const Text('Type'),
          fixedWidth: 80,
          onSort: (_, ascending) => ref
              .read(collectionFilterProvider.notifier)
              .setSort('mediaType', ascending: ascending),
        ),
        DataColumn2(
          label: const Text('Format'),
          fixedWidth: 100,
          onSort: (_, ascending) => ref
              .read(collectionFilterProvider.notifier)
              .setSort('format', ascending: ascending),
        ),
        const DataColumn2(
          label: Text('Barcode'),
          fixedWidth: 140,
        ),
        DataColumn2(
          label: const Text('Added'),
          fixedWidth: 120,
          onSort: (_, ascending) => ref
              .read(collectionFilterProvider.notifier)
              .setSort('dateAdded', ascending: ascending),
        ),
        DataColumn2(
          label: const Text('Rating'),
          fixedWidth: 80,
          numeric: true,
          onSort: (_, ascending) => ref
              .read(collectionFilterProvider.notifier)
              .setSort('userRating', ascending: ascending),
        ),
      ],
      rows: items.map((item) {
        final isSelected = item.id == selectedId;
        return DataRow2(
          selected: isSelected,
          onTap: () => onItemTap(item.id),
          cells: [
            DataCell(Text(
              item.title,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )),
            DataCell(Text(
              item.subtitle ?? '',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )),
            DataCell(_TypeChip(type: item.mediaType)),
            DataCell(Text(item.format ?? '')),
            DataCell(Text(item.barcode)),
            DataCell(Text(dateFormat.format(
              DateTime.fromMillisecondsSinceEpoch(item.dateAdded),
            ))),
            DataCell(
              item.userRating != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star,
                            size: 14, color: Colors.amber.shade700),
                        const SizedBox(width: 2),
                        Text(item.userRating!.toStringAsFixed(1)),
                      ],
                    )
                  : const Text(''),
            ),
          ],
        );
      }).toList(),
      ),
    );
  }

  int? _sortColumnIndex(String? sortBy) => switch (sortBy) {
        'title' => 0,
        'subtitle' => 1,
        'mediaType' => 2,
        'format' => 3,
        'dateAdded' => 5,
        'userRating' => 6,
        _ => null,
      };
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final MediaType type;

  @override
  Widget build(BuildContext context) {
    return Text(
      type.label,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
