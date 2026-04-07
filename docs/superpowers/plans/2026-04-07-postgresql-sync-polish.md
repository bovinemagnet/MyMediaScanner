# PostgreSQL Sync Polish

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Polish the PostgreSQL sync experience with user-facing conflict resolution, sync progress indicators, a sync log viewer, connection health monitoring, and manual sync trigger with feedback. Currently sync uses automatic last-write-wins resolution with no user visibility into conflicts, progress, or history.

**Architecture:** Extends the existing `ISyncRepository` / `SyncRepositoryImpl` with conflict detection, enriched status reporting, and a new sync log viewer screen. New domain entities model detected conflicts. A background health-check timer validates connectivity on a configurable interval. All new UI follows the existing design system (tonal containers, glassmorphism, "Obsidian Lens" / "Precision Editorial" themes).

**Tech Stack:** Flutter, Drift (SQLite), Riverpod 3.x (hand-written providers), postgres package, Freezed

**Author:** Paul Snow

**Version:** 0.0.0

**Depends on:** Existing sync infrastructure from Slice 5

---

## Current State Analysis

### What exists
- `PostgresSyncClient` — direct Postgres connection with `testConnection()`, `upsertRecords()`, `pullRecords()`
- `SyncStrategy.mergeFields()` — whole-record last-write-wins (no per-field granularity despite the doc comment)
- `SyncRepositoryImpl` — push/pull cycle with `StreamController<SyncStatus>` broadcast; `pullChanges()` has TODO stubs for insert and persist
- `SyncLogDao` — records pending operations; `getPending()`, `watchPendingCount()`, `markSynced()`
- `SyncLogTable` — columns: `id`, `entityType`, `entityId`, `operation`, `payloadJson`, `createdAt`, `attemptedAt`, `synced`
- `SyncCollectionUseCase` — orchestrates push then pull
- `SyncStatusTile` — simple tile showing pending count, last sync time, error, manual sync button
- `syncStatusProvider` — streams `SyncStatus` from repository
- `PostgresConfigForm` — host/port/db/user/pass/TLS config with test connection button

### What is missing
1. No conflict detection — merges silently, user never sees what changed
2. No sync progress (no item-level progress during push/pull)
3. No sync history viewer (log entries exist but are not surfaced)
4. No connection health monitoring (only manual test)
5. Manual sync has no completion feedback (no snackbar/toast on success or failure)
6. `pullChanges()` has TODO stubs — new remote items are skipped, merged results are not persisted
7. `SyncStatus.lastSyncedAt` is set to `DateTime.now()` rather than actual last successful sync timestamp

---

## File Structure (New & Modified)

```
lib/
  domain/
    entities/
      sync_conflict.dart                  (CREATE)
    repositories/
      i_sync_repository.dart              (MODIFY)
  data/
    local/
      database/
        tables/
          sync_log_table.dart             (MODIFY)
        app_database.dart                 (MODIFY)
      dao/
        sync_log_dao.dart                 (MODIFY)
    remote/
      sync/
        sync_strategy.dart                (MODIFY)
        postgres_sync_client.dart         (MODIFY)
    repositories/
      sync_repository_impl.dart           (MODIFY)
  presentation/
    providers/
      sync_provider.dart                  (MODIFY)
    screens/
      settings/
        widgets/
          sync_status_tile.dart           (MODIFY)
          sync_log_viewer.dart            (CREATE)
          sync_conflict_dialog.dart       (CREATE)
          connection_health_indicator.dart (CREATE)
    widgets/
      sync_badge.dart                     (CREATE)
test/
  unit/
    data/
      sync/
        sync_strategy_test.dart           (MODIFY)
    domain/
      sync_conflict_test.dart             (CREATE)
  presentation/
    screens/
      settings/
        widgets/
          sync_log_viewer_test.dart       (CREATE)
          sync_conflict_dialog_test.dart  (CREATE)
          connection_health_indicator_test.dart (CREATE)
```

---

## Task 1: Domain — Sync Conflict Entity

**Files:**
- Create: `lib/domain/entities/sync_conflict.dart`

- [ ] **Step 1: Create SyncConflict Freezed model**

Define a `SyncConflict` entity with fields: `entityType` (String), `entityId` (String), `fieldName` (String), `localValue` (dynamic), `remoteValue` (dynamic), `localUpdatedAt` (int), `remoteUpdatedAt` (int). Also define `ConflictResolution` enum: `keepLocal`, `keepRemote`, `keepBoth`.

- [ ] **Step 2: Run build_runner**
- [ ] **Step 3: Write unit tests** in `test/unit/domain/sync_conflict_test.dart`
- [ ] **Step 4: Run tests**
- [ ] **Step 5: Commit**

---

## Task 2: Enhance SyncStrategy — Conflict Detection

**Files:**
- Modify: `lib/data/remote/sync/sync_strategy.dart`
- Modify: `test/unit/data/sync/sync_strategy_test.dart`

- [ ] **Step 1: Add `detectConflicts` method** — returns `List<SyncConflict>` for fields where values differ and timestamps are within a configurable threshold (default 60s)
- [ ] **Step 2: Add `mergeWithResolutions` method** — accepts user choices and applies them to the merged record
- [ ] **Step 3: Write tests** (no conflict when timestamps far apart, conflict when close + different values, no conflict when values identical, multiple field conflicts)
- [ ] **Step 4: Run tests**
- [ ] **Step 5: Commit**

---

## Task 3: Enrich SyncLog Table & DAO

**Files:**
- Modify: `lib/data/local/database/tables/sync_log_table.dart`
- Modify: `lib/data/local/dao/sync_log_dao.dart`
- Modify: `lib/data/local/database/app_database.dart`

- [ ] **Step 1: Add nullable columns** — `errorMessage` (Text), `durationMs` (Integer), `direction` (Text: push/pull), `resolvedBy` (Text: auto/user)
- [ ] **Step 2: Bump schema version 5 → 6**, add ALTER TABLE migration
- [ ] **Step 3: Add DAO methods** — `watchAll()`, `getHistory({limit, offset})`, `purgeOlderThan(epochMs)`, `getFailedEntries()`
- [ ] **Step 4: Run build_runner**
- [ ] **Step 5: Commit**

---

## Task 4: Fix SyncRepositoryImpl — Progress, Conflicts, Logging

**Files:**
- Modify: `lib/domain/repositories/i_sync_repository.dart`
- Modify: `lib/data/repositories/sync_repository_impl.dart`

- [ ] **Step 1: Extend ISyncRepository** — add `Stream<SyncProgress> watchSyncProgress()`, `Future<List<SyncConflict>> getConflicts()`, `Future<void> resolveConflicts(...)`, `Future<List<SyncLogTableData>> getSyncHistory(...)`, `Future<void> purgeSyncHistory(...)`
- [ ] **Step 2: Add SyncProgress class** — `phase` (push/pull/idle), `current`, `total`, `currentEntityType`, `fraction` getter
- [ ] **Step 3: Implement progress reporting** — emit `SyncProgress` events per record in push/pull
- [ ] **Step 4: Implement conflict detection in pullChanges()** — store conflicts in `_pendingConflicts`, pause sync for those items
- [ ] **Step 5: Fix TODO stubs** — insert new remote items locally, persist merged results
- [ ] **Step 6: Fix lastSyncedAt** — store in SharedPreferences, only update on successful completion
- [ ] **Step 7: Enrich sync log entries** — populate direction, durationMs, errorMessage, resolvedBy
- [ ] **Step 8: Implement getSyncHistory and purgeSyncHistory**
- [ ] **Step 9: Write tests**
- [ ] **Step 10: Commit**

---

## Task 5: Connection Health Monitoring

**Files:**
- Modify: `lib/data/remote/sync/postgres_sync_client.dart`
- Create: `lib/presentation/providers/connection_health_provider.dart`

- [ ] **Step 1: Add `ping()` method** — `SELECT 1` with 5s timeout, returns `ConnectionHealth` enum (connected/disconnected/timeout/unconfigured)
- [ ] **Step 2: Create connection health provider** — StreamNotifier pinging every 60s, pauses when backgrounded, pings on resume
- [ ] **Step 3: Write tests**
- [ ] **Step 4: Commit**

---

## Task 6: Sync Providers — Progress, Conflicts, Log, Health

**Files:**
- Modify: `lib/presentation/providers/sync_provider.dart`

- [ ] **Step 1: Add providers** — `syncProgressProvider`, `syncConflictsProvider`, `syncHistoryProvider` (family by page), `connectionHealthProvider`
- [ ] **Step 2: Add syncTriggerProvider** — AsyncNotifier exposing `triggerSync()`, tracks loading/data/error, returns summary (pushed/pulled/conflicts)
- [ ] **Step 3: Commit**

---

## Task 7: UI — Enhanced Sync Status Tile

**Files:**
- Modify: `lib/presentation/screens/settings/widgets/sync_status_tile.dart`

- [ ] **Step 1: Add progress bar** — `LinearProgressIndicator` when syncing, text like "Pushing 3/12 media items..."
- [ ] **Step 2: Format last sync time** — relative (e.g. "2 minutes ago", "Yesterday at 14:32")
- [ ] **Step 3: Add completion feedback** — SnackBar with summary on sync complete/fail
- [ ] **Step 4: Add connection health badge** — coloured dot (green/amber/red) next to sync icon
- [ ] **Step 5: Write widget tests**
- [ ] **Step 6: Commit**

---

## Task 8: UI — Conflict Resolution Dialog

**Files:**
- Create: `lib/presentation/screens/settings/widgets/sync_conflict_dialog.dart`

- [ ] **Step 1: Create SyncConflictDialog** — modal showing each conflict with field name, local/remote values, timestamps, radio toggles per field, bulk "Apply all local/remote" buttons, "Resolve" action
- [ ] **Step 2: Integrate with sync flow** — show dialog automatically when conflicts detected post-pull
- [ ] **Step 3: Write widget tests**
- [ ] **Step 4: Commit**

---

## Task 9: UI — Sync Log Viewer

**Files:**
- Create: `lib/presentation/screens/settings/widgets/sync_log_viewer.dart`
- Modify: `lib/presentation/screens/settings/settings_screen.dart`
- Modify: `lib/app/router.dart`

- [ ] **Step 1: Create SyncLogViewer screen** — scrollable list with direction icon, entity type, timestamp, status chip, error expansion, retry button, clear history action. Paginated (50 per page).
- [ ] **Step 2: Add `/settings/sync-log` route**
- [ ] **Step 3: Add "Sync History" tile** in Settings sync section
- [ ] **Step 4: Write widget tests**
- [ ] **Step 5: Commit**

---

## Task 10: UI — Global Sync Badge

**Files:**
- Create: `lib/presentation/widgets/sync_badge.dart`
- Modify: `lib/presentation/widgets/app_scaffold.dart`

- [ ] **Step 1: Create SyncBadge widget** — green dot (connected/idle), animated sync icon (active), amber dot (pending changes), red dot (disconnected/error), tooltip with summary
- [ ] **Step 2: Add to app scaffold** — desktop sidebar footer and mobile bottom nav area, only when sync is configured
- [ ] **Step 3: Write widget tests**
- [ ] **Step 4: Commit**

---

## Task 11: Integration Testing & Final Verification

- [ ] **Step 1: Run full test suite** — `flutter test`, verify no regressions
- [ ] **Step 2: Run static analysis** — `flutter analyze`, verify no issues
- [ ] **Step 3: Manual smoke test** — configure Postgres, verify health indicator, add item, trigger sync, check progress bar and snackbar, open sync log, simulate conflict, resolve, disconnect/reconnect
- [ ] **Step 4: Final commit**

---

## Architecture Notes

**Conflict Detection Threshold:** Conflicts are only surfaced when both local and remote records have been modified within a configurable window (default 60 seconds). Outside this window, standard last-write-wins applies silently. This avoids overwhelming the user with trivial conflicts whilst still catching genuine concurrent edits.

**Sync Progress Stream:** A separate `StreamController<SyncProgress>` sits alongside the existing `StreamController<SyncStatus>`. Progress events are high-frequency (per-record), whilst status events are state transitions (idle/syncing/error).

**Connection Health:** The health monitor uses a lightweight `SELECT 1` query rather than a full sync cycle. It respects app lifecycle — pausing when backgrounded to avoid unnecessary database connections on mobile.

**Sync Log Retention:** Old sync log entries are automatically purged after 30 days by `purgeSyncHistory`. The purge runs once per sync cycle to avoid unbounded table growth.

**Backwards Compatibility:** The new `sync_log` columns are all nullable, so the schema migration is non-destructive. Existing log entries will have null values for the new columns.
