import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/providers/selected_item_provider.dart';
import 'package:mymediascanner/presentation/widgets/table_keyboard_navigation.dart';

/// Sortable, virtualised data table for the collection, used on desktop.
///
/// Uses [PaginatedDataTable2] with a [DataTableSource] so that only
/// visible rows are built — essential for collections with 1000+ items.
class CollectionTableView extends ConsumerStatefulWidget {
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
  ConsumerState<CollectionTableView> createState() =>
      _CollectionTableViewState();
}

class _CollectionTableViewState extends ConsumerState<CollectionTableView> {
  late _CollectionDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = _CollectionDataSource(
      items: widget.items,
      onItemTap: widget.onItemTap,
    );
  }

  @override
  void didUpdateWidget(covariant CollectionTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items ||
        oldWidget.onItemTap != widget.onItemTap) {
      _dataSource.updateItems(widget.items, widget.onItemTap);
    }
  }

  @override
  void dispose() {
    _dataSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(collectionFilterProvider);
    final selectedId = ref.watch(selectedItemProvider);

    // Keep the data source in sync with the currently selected item.
    _dataSource._selectedId = selectedId;

    final itemIds = widget.items.map((e) => e.id).toList();

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
        if (id != null) widget.onItemTap(id);
      },
      onDelete: () {
        final id = selectedId;
        if (id != null) widget.onDeleteItem?.call(id);
      },
      onClearSelection: () =>
          ref.read(selectedItemProvider.notifier).clear(),
      child: PaginatedDataTable2(
        columnSpacing: 12,
        horizontalMargin: 16,
        rowsPerPage: 50,
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
        source: _dataSource,
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

/// Lazily provides [DataRow2] instances for [PaginatedDataTable2].
///
/// Only rows currently visible in the viewport are materialised,
/// which dramatically reduces widget count for large collections.
class _CollectionDataSource extends DataTableSource {
  _CollectionDataSource({
    required List<MediaItem> items,
    required this.onItemTap,
  }) : _items = items;

  List<MediaItem> _items;
  ValueChanged<String> onItemTap;
  String? _selectedId;

  final DateFormat _dateFormat = DateFormat.yMMMd();

  void updateItems(List<MediaItem> items, ValueChanged<String> onTap) {
    _items = items;
    onItemTap = onTap;
    notifyListeners();
  }

  @override
  int get rowCount => _items.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedId != null ? 1 : 0;

  @override
  DataRow2? getRow(int index) {
    if (index >= _items.length) return null;
    final item = _items[index];
    final isSelected = item.id == _selectedId;

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
        DataCell(Text(item.mediaType.label)),
        DataCell(Text(item.format ?? '')),
        DataCell(Text(item.barcode)),
        DataCell(Text(_dateFormat.format(
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
  }
}
