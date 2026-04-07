# Design: Performance Optimisation for Large Collections

**Author:** Paul Snow
**Version:** 0.0.0
**Date:** 2026-04-08

## Context

The app currently loads the entire media_items table into memory, sorts and filters in Dart, syncs records one at a time, and recomputes statistics on every collection change. With under 100 items this is already causing noticeable sluggishness in sync, UI responsiveness, and statistics loading. At the target of 1000+ items these bottlenecks will become blocking. This spec addresses the six highest-impact optimisations.

## 1. Database Indexes

**Problem:** The `media_items` table has no indexes beyond the primary key on `id`. Every `watchAll()` query with `deleted.equals(0)` does a full table scan. Sorting and filtering by `mediaType`, `dateAdded`, or `userRating` are also unindexed.

**Solution:** Add a schema version 8 migration that creates indexes on frequently queried columns.

**Indexes to add:**

| Table | Index | Columns | Rationale |
|-------|-------|---------|-----------|
| `media_items` | `idx_media_items_deleted` | `deleted` | Every query filters on this |
| `media_items` | `idx_media_items_type_date` | `media_type, date_added` | Collection filtering + default sort |
| `media_items` | `idx_media_items_updated` | `updated_at` | Sync delta queries |
| `media_items` | `idx_media_items_barcode` | `barcode` | Duplicate check on scan |
| `sync_log` | `idx_sync_log_synced` | `synced` | Finding unsynced records |
| `loans` | `idx_loans_borrower` | `borrower_id` | Loans-for-borrower queries |
| `loans` | `idx_loans_active` | `returned_at` | Active loans filter |

**File:** `lib/data/local/database/app_database.dart` — bump `schemaVersion` to 8, add `from < 8` migration block with `CREATE INDEX IF NOT EXISTS` statements.

## 2. SQL-Level Sorting

**Problem:** `MediaItemsDao.watchAll()` returns all rows unsorted. The repository and provider layers sort in Dart after loading the full result set.

**Solution:** Add an `orderBy` parameter to `watchAll()` that maps sort field names to SQL `ORDER BY` clauses.

**Supported sort fields:**
- `dateAdded` → `date_added` (default, descending)
- `title` → `title` (ascending)
- `year` → `year` (descending)
- `userRating` → `user_rating` (descending)
- `mediaType` → `media_type` (ascending)

**Files:**
- `lib/data/local/dao/media_items_dao.dart` — add `sortBy` and `ascending` parameters to `watchAll()`, apply `query.orderBy()`
- `lib/data/repositories/media_item_repository_impl.dart` — pass sort params through to DAO instead of sorting in Dart
- `lib/domain/usecases/get_collection_usecase.dart` — pass sort params through (if not already)

## 3. SQL-Level Filtering

**Problem:** Media type filtering happens in the provider layer after loading all items. The `lentOnly` and `rippedOnly` filters require cross-referencing loan/rip data, which is done in Dart.

**Solution:** Push the `mediaType` filter into the SQL query. Keep `lentOnly` and `rippedOnly` as in-memory filters (they require joining across tables and the loan/rip ID sets are small).

**Changes to `watchAll()`:**
```dart
Stream<List<MediaItemsTableData>> watchAll({
  bool includeDeleted = false,
  String? mediaType,       // NEW
  String? sortBy,          // NEW
  bool ascending = false,  // NEW
}) {
  final query = select(mediaItemsTable);
  if (!includeDeleted) {
    query.where((t) => t.deleted.equals(0));
  }
  if (mediaType != null) {
    query.where((t) => t.mediaType.equals(mediaType));
  }
  // Apply ORDER BY based on sortBy...
  return query.watch();
}
```

**Files:**
- `lib/data/local/dao/media_items_dao.dart` — add `mediaType` filter parameter
- `lib/data/repositories/media_item_repository_impl.dart` — pass `mediaType` through
- `lib/presentation/providers/collection_provider.dart` — remove in-memory media type filtering, pass to use case

## 4. Batch Sync Operations

**Problem:** `PostgresSyncClient.upsertRecords()` loops through records one at a time, executing a separate `INSERT ... ON CONFLICT` for each record. With 100 changed items, that's 100 round-trips to PostgreSQL.

**Solution:** Build a single multi-row INSERT statement per batch.

**Approach:**
```sql
INSERT INTO media_items (id, title, ...) VALUES
  ($1, $2, ...), ($3, $4, ...), ($5, $6, ...)
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, ...
```

- Group records into batches of 50 (configurable)
- Build parameterised multi-row INSERT with numbered placeholders
- Single round-trip per batch instead of per record

**Files:**
- `lib/data/remote/sync/postgres_sync_client.dart` — rewrite `upsertRecords()` to batch

## 5. Cached Statistics

**Problem:** `CollectionStatistics.fromItems()` iterates the full collection multiple times on every change. The `insightsProvider` watches multiple streams and recomputes everything when any stream emits.

**Solution:** Debounce statistics computation and cache the result.

**Approach:**
- Create a `CachedStatisticsNotifier` (hand-written Riverpod `AsyncNotifier`) that:
  - Listens to `collectionProvider` changes
  - Debounces recomputation by 500ms (using a `Timer`)
  - Caches the last computed `InsightsData`
  - Only recomputes when the debounce timer fires
- Replace direct `insightsProvider` usage with the cached version
- Combine the multi-loop statistics computation into a single pass where practical

**Files:**
- `lib/presentation/providers/statistics_provider.dart` — add debounced caching notifier
- `lib/presentation/screens/collection/statistics_screen.dart` — use cached provider

## 6. Virtualised Table View

**Problem:** `DataTable2` in `CollectionTableView` builds all rows eagerly via `.map().toList()`. With 1000 items this creates 1000 row widgets at once.

**Solution:** Replace `DataTable2` with a `PaginatedDataTable2` or a custom `ListView.builder`-based table that only builds visible rows.

**Approach:** `DataTable2` supports `PaginatedDataTable2` which virtualises rows and adds pagination controls. This is the lowest-friction change since it stays within the same package.

- Convert `CollectionTableView` to use `PaginatedDataTable2` with a `DataTableSource`
- Set `rowsPerPage` to 50 (configurable)
- The `DataTableSource` lazily provides rows on demand
- Keep keyboard navigation working by updating the `TableKeyboardNavigation` to respect pagination boundaries

**Files:**
- `lib/presentation/screens/collection/widgets/collection_table_view.dart` — switch to `PaginatedDataTable2`
- `lib/presentation/widgets/table_keyboard_navigation.dart` — handle page boundaries if needed

## Verification

1. **Indexes:** `flutter test` passes; manual check with `EXPLAIN QUERY PLAN` on SQLite queries shows index usage
2. **SQL sorting:** Collection displays items in correct order without Dart-side sort; verify with 100+ items that order is consistent
3. **SQL filtering:** Filter by media type, verify database query includes WHERE clause (debug SQL logging)
4. **Batch sync:** Push 100 items, verify single batch INSERT executes (add timing log); compare push duration before/after
5. **Cached statistics:** Navigate to insights, change an item, verify stats don't flicker/recompute immediately; verify they update after ~500ms debounce
6. **Table virtualisation:** Load 1000 items, open table view, verify smooth scrolling; check widget count in DevTools (should be ~20-30 visible rows, not 1000)
7. **Full regression:** `flutter test` — all 667+ tests pass
