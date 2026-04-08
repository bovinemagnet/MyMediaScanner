# Batch Scanning Improvements

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Harden the batch scanning workflow with queue persistence across app restarts, undo/redo support, progress indicators during bulk saves, within-batch duplicate detection, and a batch history log of past sessions.

**Architecture:** Extend the existing `BatchEditorNotifier` (Riverpod 3.x hand-written Notifier) and Drift database. New Drift tables (`batch_sessions` and `batch_queue_items`) persist the queue to SQLite. An undo/redo stack tracks reversible actions in the provider. A `BatchSessionHistory` screen surfaces completed sessions. Duplicate detection compares barcodes within the current batch and against the existing collection.

**Tech Stack:** Flutter, Riverpod 3.x (hand-written Notifier/AsyncNotifier), Drift (SQLite), Freezed, GoRouter

**Author:** Paul Snow

**Version:** 0.0.0

---

## Current State Analysis

The batch editor currently:
- Stores all queue state in-memory via `BatchEditorNotifier` (a Riverpod `Notifier<BatchEditorState>`)
- `BatchItem` holds barcode, status, metadata, and scan result — all lost on app restart
- Scanner provider has `batchMode` toggle and `queueToBatch()` to push scan results into the batch
- Batch screen supports filter tabs (all/needs review/confirmed/saved), stats row, conflict resolution dialog, and desktop table / mobile list views
- `saveAllConfirmed()` iterates items sequentially with no progress feedback
- No duplicate detection within a batch (only `isDuplicate` from the scan use case, which checks the collection)
- No undo/redo capability
- No record of past batch sessions
- Database schema is at version 6 with 11 tables

---

## Chunk 1: Queue Persistence (Survive App Restart)

### Task 1.1: Create Drift Tables for Batch Persistence

**Files:**
- Create: `lib/data/local/database/tables/batch_sessions_table.dart`
- Create: `lib/data/local/database/tables/batch_queue_items_table.dart`
- Modify: `lib/data/local/database/app_database.dart` (register tables, bump schema to 7, add migration)

- [x] **Step 1: Write failing test for batch session DAO**

Create `test/unit/data/dao/batch_session_dao_test.dart` with tests that verify:
- Creating a new batch session with a timestamp and status
- Listing active (non-completed) sessions
- Marking a session as completed

Run: `flutter test test/unit/data/dao/batch_session_dao_test.dart`
Expected: FAIL — tables and DAO do not exist yet.

- [x] **Step 2: Create `batch_sessions_table.dart`**

Columns: `id` (text PK, UUID v7), `created_at` (int, epoch ms), `completed_at` (int nullable), `status` (text: 'active'|'completed'|'discarded'), `item_count` (int, denormalised for quick display)

- [x] **Step 3: Create `batch_queue_items_table.dart`**

Columns: `id` (text PK, UUID v7), `session_id` (text FK → batch_sessions), `barcode` (text), `barcode_type` (text), `status` (text, mirrors BatchItemStatus), `scanned_at` (int, epoch ms), `metadata_json` (text nullable, JSON-encoded MetadataResult), `scan_result_json` (text nullable, JSON-encoded ScanResult for conflict resolution), `sort_order` (int, insertion position)

- [x] **Step 4: Create `BatchSessionDao`**

**Files:**
- Create: `lib/data/local/dao/batch_session_dao.dart`

Methods:
- `createSession() → Future<String>` — inserts a new active session, returns ID
- `getActiveSession() → Future<BatchSession?>` — returns the current active session (at most one)
- `completeSession(String id, {required String status})` — sets `completed_at` and status
- `getSessionHistory({int limit, int offset}) → Future<List<BatchSession>>`
- `upsertQueueItem(BatchQueueItem)` — insert or update a queue item
- `getQueueItems(String sessionId) → Future<List<BatchQueueItem>>`
- `deleteQueueItem(String id)`
- `deleteSessionQueueItems(String sessionId)` — bulk delete for discard

- [x] **Step 5: Register tables and DAO in `app_database.dart`**

Add `BatchSessionsTable` and `BatchQueueItemsTable` to the `@DriftDatabase` tables list. Add `BatchSessionDao` to the daos list. Bump `schemaVersion` to 7. Add migration.

- [x] **Step 6: Run `build_runner` and verify tests pass**

### Task 1.2: Add JSON Serialisation to BatchItem / MetadataResult

**Files:**
- Modify: `lib/presentation/providers/batch_editor_provider.dart` (add `toJson`/`fromJson` on `BatchItem`)
- Create: `lib/data/mappers/batch_item_mapper.dart` (maps between `BatchQueueItem` and `BatchItem`)

- [x] **Step 1: Write failing test for round-trip serialisation**

Create `test/unit/data/mappers/batch_item_mapper_test.dart`:
- Serialise a `BatchItem` with confirmed status and metadata → write to DB row → read back → assert equality
- Serialise a conflict `BatchItem` with `MultiMatchScanResult` → round-trip → candidates preserved

- [x] **Step 2: Implement `batch_item_mapper.dart`**

Use `MetadataResult.toJson()` (already available via Freezed) to encode metadata as JSON text for the `metadata_json` column. Likewise encode `ScanResult` to JSON for the `scan_result_json` column.

- [x] **Step 3: Run mapper tests**

### Task 1.3: Wire Persistence into BatchEditorNotifier

**Files:**
- Modify: `lib/presentation/providers/batch_editor_provider.dart`
- Modify: `lib/presentation/providers/repository_providers.dart` (expose `BatchSessionDao`)

- [x] **Step 1: Write failing integration test**

Create `test/unit/presentation/providers/batch_editor_persistence_test.dart`:
- Add items to batch → dispose container → create new container → verify items restored
- Discard batch → verify session marked as discarded in DB
- Save all → verify session marked as completed

- [x] **Step 2: Convert `BatchEditorNotifier` to `AsyncNotifier`**

Change `Notifier<BatchEditorState>` to `AsyncNotifier<BatchEditorState>`. The `build()` method now:
1. Checks for an active session in DB via `BatchSessionDao.getActiveSession()`
2. If found, loads queue items and maps them to `BatchItem` list
3. If not found, creates a new session

- [x] **Step 3: Persist on every mutation**

Each mutation method (`addScanResult`, `resolveItem`, `removeItem`, `saveItem`, `saveAllConfirmed`, `clearBatch`) must also write through to the DAO.

- [x] **Step 4: Update batch screen to handle `AsyncValue`**

`BatchPlaceholderScreen` currently does `ref.watch(batchEditorProvider)` which returns `BatchEditorState` synchronously. After the notifier becomes async, it returns `AsyncValue<BatchEditorState>`. Update the screen to handle loading/error states.

- [x] **Step 5: Update existing tests**

Adapt `test/unit/presentation/providers/batch_editor_provider_test.dart` for the async notifier pattern.

- [x] **Step 6: Run full test suite**

---

## Chunk 2: Undo/Redo Support

### Task 2.1: Implement Undo/Redo Stack in Provider

**Files:**
- Modify: `lib/presentation/providers/batch_editor_provider.dart`

- [x] **Step 1: Write failing tests for undo/redo**

Add to `test/unit/presentation/providers/batch_editor_provider_test.dart`:
- Add item → undo → item removed, undo stack empty, redo stack has one entry
- Add item → undo → redo → item restored
- Remove item → undo → item restored with original status
- Resolve conflict → undo → item back to conflict status
- Multiple operations → undo three times → verify correct ordering
- Undo when stack empty → no-op
- Redo when stack empty → no-op
- New action after undo → redo stack cleared

- [x] **Step 2: Define `BatchAction` sealed class**

```dart
sealed class BatchAction {
  const BatchAction();
}
class AddAction extends BatchAction { final BatchItem item; }
class RemoveAction extends BatchAction { final BatchItem item; final int index; }
class ResolveAction extends BatchAction { final String itemId; final BatchItem previousState; }
class SaveAction extends BatchAction { final String itemId; final BatchItem previousState; }
```

- [x] **Step 3: Add undo/redo stacks to `BatchEditorState`**

Add `List<BatchAction> undoStack` and `List<BatchAction> redoStack` fields (not persisted to DB — undo history is session-only).

- [x] **Step 4: Implement `undo()` and `redo()` methods**

Each method pops from one stack, applies the inverse operation, pushes onto the other stack, and persists the resulting state to DB.

- [x] **Step 5: Add `canUndo` / `canRedo` getters to state**

- [x] **Step 6: Run tests**

### Task 2.2: Add Undo/Redo Controls to Batch Screen

**Files:**
- Modify: `lib/presentation/screens/batch/batch_placeholder_screen.dart`

- [x] **Step 1: Add undo/redo buttons to the header actions (desktop) and app bar (mobile)**

Desktop: Add `IconButton` pair (undo / redo) before the existing "Discard Batch" button in `ScreenHeader.actions`.

Mobile: Add undo/redo `IconButton`s to the `AppBar.actions` list.

Both buttons disabled when `canUndo` / `canRedo` is false.

- [x] **Step 2: Add keyboard shortcuts (desktop only)**

Wrap the batch screen body in a `Shortcuts` + `Actions` widget:
- `Ctrl+Z` → undo
- `Ctrl+Shift+Z` / `Ctrl+Y` → redo

- [x] **Step 3: Show snackbar on undo/redo with action description**

After undo/redo, show a brief snackbar: "Undid: removed item 'Album Name'" / "Redid: added item 'Album Name'".

- [x] **Step 4: Manual verification**

---

## Chunk 3: Batch Progress Indicators

### Task 3.1: Granular Save Progress in Provider

**Files:**
- Modify: `lib/presentation/providers/batch_editor_provider.dart`

- [x] **Step 1: Write failing tests for progress tracking**

Add tests:
- `saveAllConfirmed` with 3 items → progress callbacks at 0/3, 1/3, 2/3, 3/3
- State exposes `saveProgress` (nullable `BatchSaveProgress` with `current` and `total` fields)
- Progress is null when not saving

- [x] **Step 2: Add `BatchSaveProgress` to state**

```dart
class BatchSaveProgress {
  const BatchSaveProgress({required this.current, required this.total});
  final int current;
  final int total;
  double get fraction => total == 0 ? 0 : current / total;
}
```

Add `BatchSaveProgress? saveProgress` to `BatchEditorState`. Replace the boolean `isSaving` field (or keep it as a convenience getter: `bool get isSaving => saveProgress != null`).

- [x] **Step 3: Update `saveAllConfirmed` to emit progress**

Before each item save, update `state` with incremented `saveProgress.current`.

- [x] **Step 4: Run tests**

### Task 3.2: Progress UI in Batch Screen

**Files:**
- Modify: `lib/presentation/screens/batch/batch_placeholder_screen.dart`

- [x] **Step 1: Replace the spinner with a `LinearProgressIndicator`**

When `state.saveProgress != null`, show:
- A `LinearProgressIndicator` with `value: saveProgress.fraction`
- Text: "Saving item {current} of {total}..."
- Disable all action buttons during save

- [x] **Step 2: Show completion summary**

After `saveAllConfirmed` completes, show a snackbar or inline banner: "Saved {n} items to collection."

- [x] **Step 3: Manual verification**

---

## Chunk 4: Within-Batch Duplicate Detection

### Task 4.1: Detect Duplicates on Add

**Files:**
- Modify: `lib/presentation/providers/batch_editor_provider.dart`

- [x] **Step 1: Write failing tests**

Add to batch editor tests:
- Add single result with barcode "123" → add another single result with barcode "123" → second item has status `duplicate`
- Add single result → add multi-match with same barcode → second item marked `duplicate`
- Duplicate detection is case-insensitive and ignores leading zeroes

- [x] **Step 2: Implement barcode duplicate check in `addScanResult`**

Before inserting a new `BatchItem`, check if any existing (non-saved) item in the current batch has the same normalised barcode. If so, set the new item's status to `BatchItemStatus.duplicate`.

- [x] **Step 3: Add visual indicator for within-batch duplicates**

Add a `duplicateSource` field to `BatchItem`:

```dart
enum DuplicateSource { collection, batch }
```

- [x] **Step 4: Allow user to force-keep a batch duplicate**

Add an action button "Keep Anyway" on duplicate items that changes their status to `confirmed`.

- [x] **Step 5: Run tests**

---

## Chunk 5: Batch History

### Task 5.1: Batch Session Lifecycle

**Files:**
- Modify: `lib/presentation/providers/batch_editor_provider.dart`

- [x] **Step 1: Write failing tests for session lifecycle**

- Starting a new batch after completing/discarding the previous one creates a new session
- Completed sessions retain their queue items in the DB (read-only)
- `getSessionHistory` returns sessions ordered by `created_at` descending

- [x] **Step 2: Implement session completion logic**

When `saveAllConfirmed` finishes and no unsaved items remain, mark the session as `completed`. When `clearBatch` is called, mark the session as `discarded`. In both cases, create a fresh active session for the next batch.

- [x] **Step 3: Run tests**

### Task 5.2: Batch History Provider

**Files:**
- Create: `lib/presentation/providers/batch_history_provider.dart`

- [x] **Step 1: Write failing test**

Create `test/unit/presentation/providers/batch_history_provider_test.dart`:
- Provider loads paginated session list from DAO
- Each session summary includes: date, item count, status, saved count

- [x] **Step 2: Implement `BatchHistoryNotifier`**

An `AsyncNotifier<List<BatchSessionSummary>>` that loads from `BatchSessionDao.getSessionHistory()`. Expose a `loadMore()` method for pagination.

- [x] **Step 3: Run test**

### Task 5.3: Batch History Screen

**Files:**
- Create: `lib/presentation/screens/batch/batch_history_screen.dart`
- Modify: `lib/app/router.dart` (add `/batch/history` route)
- Modify: `lib/presentation/screens/batch/batch_placeholder_screen.dart` (add "History" button)

- [x] **Step 1: Create `batch_history_screen.dart`**

A read-only list of past batch sessions showing:
- Date and time
- Item count and saved count
- Session status badge (completed / discarded)
- Tap to expand and view the items from that session

Follow existing design system conventions.

- [x] **Step 2: Add route to GoRouter** — `/batch/history` → `BatchHistoryScreen`

- [x] **Step 3: Add "History" button to batch editor screen**

Desktop: `OutlinedButton` with `Icons.history` in `ScreenHeader.actions`.
Mobile: History icon button in `AppBar.actions`.

- [x] **Step 4: Manual verification**

---

## Summary of Files

### New Files
| File | Purpose |
|------|---------|
| `lib/data/local/database/tables/batch_sessions_table.dart` | Drift table for batch sessions |
| `lib/data/local/database/tables/batch_queue_items_table.dart` | Drift table for persisted queue items |
| `lib/data/local/dao/batch_session_dao.dart` | DAO for batch session and queue CRUD |
| `lib/data/mappers/batch_item_mapper.dart` | Maps DB rows to/from domain `BatchItem` |
| `lib/presentation/providers/batch_history_provider.dart` | Provider for past session listing |
| `lib/presentation/screens/batch/batch_history_screen.dart` | Read-only history of past batches |

### Modified Files
| File | Changes |
|------|---------|
| `lib/data/local/database/app_database.dart` | Register 2 new tables + DAO, schema v7, migration |
| `lib/presentation/providers/batch_editor_provider.dart` | AsyncNotifier, persistence, undo/redo, progress, duplicate detection |
| `lib/presentation/providers/repository_providers.dart` | Expose `BatchSessionDao` provider |
| `lib/presentation/screens/batch/batch_placeholder_screen.dart` | AsyncValue handling, undo/redo buttons, progress bar, history button, keyboard shortcuts |
| `lib/app/router.dart` | Add `/batch/history` route |

---

## Execution Order

1. **Chunk 1** (Queue Persistence) — foundation; all other chunks depend on the DB tables and async notifier
2. **Chunk 4** (Duplicate Detection) — small, self-contained change to `addScanResult`; do early to avoid rework
3. **Chunk 3** (Progress Indicators) — modifies `saveAllConfirmed` which is simpler before undo/redo is added
4. **Chunk 2** (Undo/Redo) — most complex provider changes; build on stable persistence layer
5. **Chunk 5** (Batch History) — depends on session lifecycle from Chunk 1; can be done last as it is additive

---

## Risk Notes

- Converting `Notifier` to `AsyncNotifier` is a breaking change to the provider contract. All consumers (batch screen, scanner provider's `queueToBatch`) must be updated in the same pass.
- `ScanResult` is a Freezed sealed class — verify `toJson()`/`fromJson()` round-trips correctly for all three variants before relying on JSON persistence.
- Undo/redo stacks are in-memory only (not persisted). This is intentional — undo history does not survive restart.
- The `batch_queue_items` table stores metadata as JSON text. This is acceptable for a transient queue but should not be used as a long-term data model.
- Schema migration must be tested with an existing database to avoid data loss.
