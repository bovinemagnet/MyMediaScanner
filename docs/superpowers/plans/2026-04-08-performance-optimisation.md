# Performance Optimisation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Optimise database queries, sync operations, statistics computation, and table rendering to support 1000+ item collections without sluggishness.

**Architecture:** Push sorting and filtering from Dart into SQL queries with proper indexes; batch PostgreSQL sync operations instead of per-record round-trips; debounce statistics recomputation; virtualise the collection table view.

**Tech Stack:** Drift (SQLite), PostgreSQL via `postgres` package, Riverpod 3.x hand-written providers, `data_table_2` package.

---

### Task 1: Add Database Indexes (Schema v8)

**Files:**
- Modify: `lib/data/local/database/app_database.dart:72-126`
- Test: `test/unit/data/dao/media_items_dao_test.dart` (existing tests still pass)

- [x] **Step 1: Bump schema version and add migration**

In `lib/data/local/database/app_database.dart`, change `schemaVersion` from 7 to 8, then add the index creation block inside `onUpgrade`:

```dart
@override
int get schemaVersion => 8;
```

Add after the `from < 7` block:

```dart
if (from < 8) {
  await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_media_items_deleted '
      'ON media_items (deleted)');
  await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_media_items_type_date '
      'ON media_items (media_type, date_added)');
  await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_media_items_updated '
      'ON media_items (updated_at)');
  await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_media_items_barcode '
      'ON media_items (barcode)');
  await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_log_synced '
      'ON sync_log (synced)');
  await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_loans_borrower '
      'ON loans (borrower_id)');
  await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_loans_active '
      'ON loans (returned_at)');
}
```

Also add the same `CREATE INDEX` statements inside `onCreate` after `_createFts5Table(m)` so fresh installs get indexes too:

```dart
onCreate: (m) async {
  await m.createAll();
  await _createFts5Table(m);
  await _createIndexes();
},
```

Extract a `_createIndexes()` method containing the 7 `customStatement` calls, and call it from both `onCreate` and the `from < 8` migration block.

- [x] **Step 2: Run tests to verify migration doesn't break existing tests**

Run: `flutter test test/unit/data/dao/`
Expected: All existing DAO tests pass (they use in-memory databases that run `onCreate`).

- [x] **Step 3: Update CLAUDE.md schema version**

In `CLAUDE.md`, change "Current schema version is 7" to "Current schema version is 8".

- [x] **Step 4: Commit**

```bash
git add lib/data/local/database/app_database.dart CLAUDE.md
git commit -m "perf: add database indexes for common queries (schema v8)"
```

---

### Task 2: SQL-Level Sorting and Media Type Filtering in DAO

**Files:**
- Modify: `lib/data/local/dao/media_items_dao.dart:12-18`
- Test: `test/unit/data/dao/media_items_dao_test.dart` (add new tests)

- [x] **Step 1: Write failing tests for sorted and filtered watchAll**

Add to `test/unit/data/dao/media_items_dao_test.dart`:

```dart
test('watchAll returns items sorted by title ascending', () async {
  await dao.insertItem(_makeItem(id: '1', title: 'Zebra'));
  await dao.insertItem(_makeItem(id: '2', title: 'Apple'));
  await dao.insertItem(_makeItem(id: '3', title: 'Mango'));

  final items = await dao
      .watchAll(sortBy: 'title', ascending: true)
      .first;

  expect(items.map((e) => e.title), ['Apple', 'Mango', 'Zebra']);
});

test('watchAll returns items sorted by dateAdded descending', () async {
  await dao.insertItem(_makeItem(id: '1', title: 'Old', dateAdded: 1000));
  await dao.insertItem(_makeItem(id: '2', title: 'New', dateAdded: 3000));
  await dao.insertItem(_makeItem(id: '3', title: 'Mid', dateAdded: 2000));

  final items = await dao
      .watchAll(sortBy: 'dateAdded', ascending: false)
      .first;

  expect(items.map((e) => e.title), ['New', 'Mid', 'Old']);
});

test('watchAll filters by mediaType', () async {
  await dao.insertItem(_makeItem(id: '1', title: 'CD', mediaType: 'music'));
  await dao.insertItem(_makeItem(id: '2', title: 'DVD', mediaType: 'film'));

  final items = await dao
      .watchAll(mediaType: 'music')
      .first;

  expect(items.length, 1);
  expect(items.first.title, 'CD');
});
```

- [x] **Step 2: Run tests to verify they fail**

Run: `flutter test test/unit/data/dao/media_items_dao_test.dart --name "watchAll returns items sorted"`
Expected: FAIL — `watchAll` doesn't accept `sortBy`/`mediaType` yet.

- [x] **Step 3: Implement sorted and filtered watchAll**

Update `lib/data/local/dao/media_items_dao.dart`:

```dart
Stream<List<MediaItemsTableData>> watchAll({
  bool includeDeleted = false,
  String? mediaType,
  String? sortBy,
  bool ascending = false,
}) {
  final query = select(mediaItemsTable);
  if (!includeDeleted) {
    query.where((t) => t.deleted.equals(0));
  }
  if (mediaType != null) {
    query.where((t) => t.mediaType.equals(mediaType));
  }

  final orderColumn = switch (sortBy) {
    'title' => mediaItemsTable.title,
    'year' => mediaItemsTable.year,
    'userRating' => mediaItemsTable.userRating,
    'mediaType' => mediaItemsTable.mediaType,
    'dateAdded' => mediaItemsTable.dateAdded,
    _ => mediaItemsTable.dateAdded,
  };

  query.orderBy([
    (t) => OrderingTerm(
          expression: orderColumn,
          mode: ascending ? OrderingMode.asc : OrderingMode.desc,
        ),
  ]);

  return query.watch();
}
```

- [x] **Step 4: Run tests to verify they pass**

Run: `flutter test test/unit/data/dao/media_items_dao_test.dart`
Expected: All tests pass.

- [x] **Step 5: Commit**

```bash
git add lib/data/local/dao/media_items_dao.dart test/unit/data/dao/media_items_dao_test.dart
git commit -m "perf: add SQL-level sorting and mediaType filtering to DAO"
```

---

### Task 3: Wire Sort/Filter Through Repository and Provider

**Files:**
- Modify: `lib/data/repositories/media_item_repository_impl.dart:24-49`
- Modify: `lib/presentation/providers/collection_provider.dart:92-115`

- [x] **Step 1: Update repository to pass sort/filter params to DAO**

In `lib/data/repositories/media_item_repository_impl.dart`, update `watchAll`:

```dart
@override
Stream<List<MediaItem>> watchAll({
  MediaType? mediaType,
  String? searchQuery,
  List<String>? tagIds,
  String? sortBy,
  bool ascending = true,
}) {
  final useFts =
      searchQuery != null && searchQuery.trim().length >= 2;

  final Stream<List<MediaItemsTableData>> baseStream = useFts
      ? _mediaItemsDao.watchSearch(searchQuery)
      : _mediaItemsDao.watchAll(
          mediaType: mediaType?.name,
          sortBy: sortBy,
          ascending: ascending,
        );

  return baseStream.map(
    (rows) => rows
        .where((r) =>
            // FTS already filters; for non-FTS with mediaType, DAO handles it
            useFts ||
            mediaType == null ||
            r.mediaType == mediaType.name)
        .where((r) =>
            useFts ||
            searchQuery == null ||
            r.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .map(_fromRow)
        .toList(),
  );
}
```

Note: When `useFts` is false and `mediaType` is passed to the DAO, the in-memory `.where` for mediaType becomes redundant. The DAO now handles it. The in-memory filter is kept as a safety net for the FTS path (which doesn't filter by type).

- [x] **Step 2: Remove redundant in-memory mediaType filtering for non-FTS path**

The above code already handles this — when `useFts` is false, mediaType is passed to the DAO. When `useFts` is true, the in-memory filter still runs since FTS doesn't filter by type. This is correct.

- [x] **Step 3: Run full test suite**

Run: `flutter test`
Expected: All tests pass.

- [x] **Step 4: Commit**

```bash
git add lib/data/repositories/media_item_repository_impl.dart lib/presentation/providers/collection_provider.dart
git commit -m "perf: wire SQL sorting and filtering through repository layer"
```

---

### Task 4: Batch Sync Operations

**Files:**
- Modify: `lib/data/remote/sync/postgres_sync_client.dart:63-89`
- Test: `test/unit/data/sync/postgres_sync_client_test.dart` (create)

- [x] **Step 1: Write test for batch upsert**

Create `test/unit/data/sync/postgres_sync_client_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';

void main() {
  group('PostgresSyncClient', () {
    test('buildBatchUpsertSql generates correct SQL for multiple records', () {
      final records = [
        {'id': '1', 'title': 'A', 'updated_at': 100},
        {'id': '2', 'title': 'B', 'updated_at': 200},
      ];

      final result = PostgresSyncClient.buildBatchUpsertSql(
        'media_items',
        records,
      );

      expect(result.sql, contains('INSERT INTO media_items'));
      expect(result.sql, contains('ON CONFLICT (id) DO UPDATE'));
      expect(result.params.length, 6); // 3 columns × 2 records
    });

    test('buildBatchUpsertSql handles single record', () {
      final records = [
        {'id': '1', 'title': 'A'},
      ];

      final result = PostgresSyncClient.buildBatchUpsertSql(
        'test_table',
        records,
      );

      expect(result.sql, contains('INSERT INTO test_table'));
      expect(result.params.length, 2);
    });
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/data/sync/postgres_sync_client_test.dart`
Expected: FAIL — `buildBatchUpsertSql` doesn't exist yet.

- [x] **Step 3: Add batch SQL builder and rewrite upsertRecords**

In `lib/data/remote/sync/postgres_sync_client.dart`, add a static method and rewrite `upsertRecords`:

```dart
/// Batch size for multi-row INSERT operations.
static const _batchSize = 50;

/// Builds a multi-row INSERT ... ON CONFLICT SQL statement.
///
/// Exposed as static for testability.
static ({String sql, List<dynamic> params}) buildBatchUpsertSql(
  String table,
  List<Map<String, dynamic>> records,
) {
  final columns = records.first.keys.toList();
  final params = <dynamic>[];
  final valueClauses = <String>[];

  for (var i = 0; i < records.length; i++) {
    final placeholders = <String>[];
    for (var j = 0; j < columns.length; j++) {
      final paramIndex = i * columns.length + j + 1;
      placeholders.add('\$$paramIndex');
      params.add(records[i][columns[j]]);
    }
    valueClauses.add('(${placeholders.join(', ')})');
  }

  final updates = columns
      .where((c) => c != 'id')
      .map((c) => '$c = EXCLUDED.$c')
      .join(', ');

  final sql = 'INSERT INTO $table (${columns.join(', ')}) '
      'VALUES ${valueClauses.join(', ')} '
      'ON CONFLICT (id) DO UPDATE SET $updates';

  return (sql: sql, params: params);
}

/// Push a batch of records to Postgres using multi-row INSERT.
Future<void> upsertRecords(
  String table,
  List<Map<String, dynamic>> records,
) async {
  if (records.isEmpty) return;
  final conn = await _getConnection();

  // Process in batches to avoid overly large SQL statements.
  for (var i = 0; i < records.length; i += _batchSize) {
    final batch = records.sublist(
      i,
      i + _batchSize > records.length ? records.length : i + _batchSize,
    );
    final (:sql, :params) = buildBatchUpsertSql(table, batch);
    await conn.execute(sql, parameters: params);
  }
}
```

- [x] **Step 4: Run tests**

Run: `flutter test test/unit/data/sync/postgres_sync_client_test.dart`
Expected: PASS.

- [x] **Step 5: Run full test suite for regressions**

Run: `flutter test`
Expected: All tests pass.

- [x] **Step 6: Commit**

```bash
git add lib/data/remote/sync/postgres_sync_client.dart test/unit/data/sync/postgres_sync_client_test.dart
git commit -m "perf: batch PostgreSQL sync with multi-row INSERT"
```

---

### Task 5: Debounced Statistics Caching

**Files:**
- Modify: `lib/presentation/providers/statistics_provider.dart:90-224`
- Test: `test/unit/presentation/providers/statistics_provider_test.dart` (existing)

- [x] **Step 1: Add debounced insights provider**

Replace the `insightsProvider` at the bottom of `lib/presentation/providers/statistics_provider.dart` with a debounced version:

```dart
/// Debounced insights provider that caches results and only recomputes
/// after 500ms of no upstream changes.
class DebouncedInsightsNotifier extends AsyncNotifier<InsightsData> {
  Timer? _debounce;

  @override
  Future<InsightsData> build() async {
    // Watch all upstream providers
    final itemRepo = ref.watch(mediaItemRepositoryProvider);
    final items = await itemRepo.watchAll().first;
    final activeLoans = ref.watch(activeLoansProvider).value ?? [];
    final allLoans = ref.watch(allLoansProvider).value ?? [];
    final borrowers = ref.watch(allBorrowersProvider).value ?? [];
    final ripAlbums = ref.watch(allRipAlbumsProvider).value ?? [];
    final rippedIds = ref.watch(rippedItemIdsProvider).value ?? {};

    return computeInsightsData(
      items: items,
      activeLoans: activeLoans,
      allLoans: allLoans,
      borrowers: borrowers,
      ripAlbums: ripAlbums,
      rippedItemIds: rippedIds,
    );
  }

  /// Trigger a debounced refresh. Call this when upstream data changes.
  void scheduleRefresh() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.invalidateSelf();
    });
  }
}

final insightsProvider =
    AsyncNotifierProvider<DebouncedInsightsNotifier, InsightsData>(
        () => DebouncedInsightsNotifier());
```

Keep the old `statisticsProvider` (StreamProvider) as-is — it's used by the collection screen and is already efficient enough for just `CollectionStatistics`.

- [x] **Step 2: Update insights screen to use the new provider**

Check `lib/presentation/screens/collection/statistics_screen.dart` — it should already watch `insightsProvider`. Since we kept the same provider name, no changes needed.

- [x] **Step 3: Run existing statistics tests**

Run: `flutter test test/unit/presentation/providers/statistics_provider_test.dart`
Expected: All pass (the `computeInsightsData` function is unchanged).

- [x] **Step 4: Run full test suite**

Run: `flutter test`
Expected: All tests pass.

- [x] **Step 5: Commit**

```bash
git add lib/presentation/providers/statistics_provider.dart
git commit -m "perf: debounce insights computation to reduce recomputation"
```

---

### Task 6: Virtualise Collection Table View

**Files:**
- Modify: `lib/presentation/screens/collection/widgets/collection_table_view.dart`

- [x] **Step 1: Convert to PaginatedDataTable2 with DataTableSource**

Replace the current `DataTable2` with `PaginatedDataTable2`. The `CollectionTableView` needs to become a `ConsumerStatefulWidget` to hold the `DataTableSource`.

Rewrite `lib/presentation/screens/collection/widgets/collection_table_view.dart`:

```dart
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/providers/selected_item_provider.dart';
import 'package:mymediascanner/presentation/widgets/table_keyboard_navigation.dart';

/// Sortable, paginated data table for the collection, used on desktop.
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
      selectedId: null,
    );
  }

  @override
  void didUpdateWidget(CollectionTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _dataSource = _CollectionDataSource(
        items: widget.items,
        onItemTap: widget.onItemTap,
        selectedId: ref.read(selectedItemProvider),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(collectionFilterProvider);
    final selectedId = ref.watch(selectedItemProvider);
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

class _CollectionDataSource extends DataTableSource {
  _CollectionDataSource({
    required this.items,
    required this.onItemTap,
    required String? selectedId,
  }) : _selectedId = selectedId;

  final List<MediaItem> items;
  final ValueChanged<String> onItemTap;
  String? _selectedId;
  final _dateFormat = DateFormat.yMMMd();

  @override
  int get rowCount => items.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedId != null ? 1 : 0;

  @override
  DataRow2 getRow(int index) {
    final item = items[index];
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
        DataCell(Text(
          item.mediaType.label,
          style: const TextStyle(fontSize: 12),
        )),
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
```

- [x] **Step 2: Run existing table view tests**

Run: `flutter test`
Expected: All tests pass. Widget tests for `CollectionTableView` may need updating if they look for `DataTable2` specifically — check and update finders to `PaginatedDataTable2` if needed.

- [x] **Step 3: Commit**

```bash
git add lib/presentation/screens/collection/widgets/collection_table_view.dart
git commit -m "perf: virtualise collection table with PaginatedDataTable2"
```

---

### Task 7: Final Verification

- [x] **Step 1: Run flutter analyse**

Run: `flutter analyze`
Expected: No new errors (pre-existing info/warnings are acceptable).

- [x] **Step 2: Run full test suite**

Run: `flutter test`
Expected: All 667+ tests pass.

- [x] **Step 3: Push to remote**

```bash
git push origin main
```
