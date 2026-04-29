# TMDB Account Sync — Slice 4e (Bulk Push-Retry UX) Design Spec

> **Author:** Paul Snow
> **Date:** 2026-04-29
> **Version:** 0.0.0
> **Status:** Approved

## Goal

Replace the spartan one-row "Push pending now" surface with a richer pending-changes view so the user can see *which* rows are pending, *what* failed, and retry individual rows or just-the-failed ones. Conflicts continue to go through the existing `TmdbResolveConflictsScreen`; slice 4e simply surfaces them separately on the settings card and links to that screen.

Today the section card shows:

```
☁ N pending change(s) to push     [Push pending now]
```

After tapping, a SnackBar reports `Pushed X of Y; Z failed` and the user has no idea which Z. The persisted per-row `last_error` text never reaches the UI. This slice closes that gap.

## Non-goals

- Schema migrations. The bridge table already carries `localDirty`, `lastError`, `lastPushedAt`, `localRatingSnapshot`, `tmdbId`, `tmdbMediaType`. Conflicts are identified by `lastError == 'conflict:user-resolution-required'` (existing convention from slice 2).
- Changing the conflict-resolution flow. `TmdbResolveConflictsScreen` stays unchanged; slice 4e just adds a *second* row in the settings card linking to it when conflicts exist.
- Auto-retry, exponential backoff, or background sync. The user remains in control of when bulk pushes run.
- Per-row spinner during a bulk push. A single header progress indicator with `Pushing X of Y...` is sufficient.
- Persisting push history beyond the existing `lastError` text. The dialog only shows the *current* per-row state.

## Architecture overview

```
TmdbAccountSyncSection (existing)
  ├─ "N pending change(s) to push      [View & retry] [Push all now]"
  │    [View & retry] → showDialog → TmdbPendingChangesDialog (new)
  │    [Push all now] → RetryPushUseCase.retryAll(allDirty) (new)
  │
  └─ "M conflict(s) need resolution    [Resolve]"   (only when M > 0)
       [Resolve] → context.go('/settings/tmdb-resolve-conflicts')

TmdbPendingChangesDialog (new)
  ├─ watches tmdbPendingChangesProvider (StreamProvider<List<TmdbPendingChange>>)
  ├─ watches tmdbPushProgressProvider (NotifierProvider<TmdbPushProgress>)
  ├─ header: title, dirty/failed counts, [Retry all failed] (when failures > 0)
  ├─ ListView of _PendingChangeTile
  │    ├─ title (looked up via media_items join, fallback "Untitled (TMDB id N)")
  │    ├─ action chips (Rating x★ / On watchlist / Favourited — derived from dirty fields)
  │    ├─ relative time of last push attempt
  │    ├─ inline error excerpt (red) when lastError != null
  │    └─ trailing Retry icon button → RetryPushUseCase.retryOne(key)
  └─ footer: Close button
```

## Components

### `TmdbPendingChange` (domain entity, new)

Pure Dart view-model. Lives at `lib/domain/entities/tmdb_pending_change.dart`.

```dart
class TmdbPendingChange {
  const TmdbPendingChange({
    required this.tmdbId,
    required this.mediaType,
    required this.title,           // null when there's no local row
    required this.actions,         // ['rating 4.5★', 'on watchlist'] etc
    required this.lastPushedAt,    // epoch ms, nullable
    required this.lastError,       // nullable
  });

  final int tmdbId;
  final String mediaType;
  final String? title;
  final List<TmdbPendingAction> actions;
  final int? lastPushedAt;
  final String? lastError;

  bool get hasFailed => lastError != null;
}

enum TmdbPendingAction { rating, watchlist, favourite, ownership }
```

Action derivation lives in a separate pure function `derivePendingActions(BridgeRow row)` so it's unit-testable in isolation. Logic:

- `rating`: `row.localRatingValue != row.localRatingSnapshot` (numeric or null/non-null change).
- `watchlist`: `row.localWatchlist != row.remoteWatchlistSnapshot`.
- `favourite`: `row.localFavourite != row.remoteFavouriteSnapshot`.
- `ownership`: `row.localOwnedSnapshot != row.remoteOwnedSnapshot` (movies-mirror state).

The exact field names will match what the existing bridge table actually exposes — to be confirmed during implementation; if any of the snapshot columns don't exist, `derivePendingActions` simply omits that action and the helper documents the omission. (No new schema, just a derivation read of what's there.)

### `TmdbPushProgress` (domain entity, new)

Pure Dart, used by the progress provider. Lives at `lib/domain/entities/tmdb_push_progress.dart`.

```dart
class TmdbPushProgress {
  const TmdbPushProgress({
    required this.inFlight,
    required this.current,
    required this.total,
  });

  factory TmdbPushProgress.idle() =>
      const TmdbPushProgress(inFlight: false, current: 0, total: 0);

  final bool inFlight;
  final int current;
  final int total;
}
```

### DAO: `watchPendingChanges()` (new method on `TmdbAccountSyncDao`)

```dart
/// Stream of pending (dirty, non-conflict) bridge rows joined with their
/// local media-item title where available. Conflict rows are excluded —
/// they are handled by the existing [watchConflicts] stream and the
/// dedicated TmdbResolveConflictsScreen.
Stream<List<TmdbPendingChangeRow>> watchPendingChanges() { ... }
```

`TmdbPendingChangeRow` is the DAO's row-shape DTO: `{ bridge: TmdbAccountSyncItemsTableData, mediaItemTitle: String? }`. The mapper in `lib/data/mappers/tmdb_account_mapper.dart` converts it into the domain `TmdbPendingChange`.

The query is a left-join to `media_items` on `tmdb_id` (matching the bridge row's `tmdbId` against the JSON `extraMetadata->>tmdb_id` won't be needed because the bridge table has its own `tmdbId` column).

Actually — verify during implementation that the join key resolves correctly: bridge `tmdbId` is an `int` column. The `media_items` table stores TMDB IDs inside `extraMetadata` JSON. Drift can extract via `json_extract(extra_metadata, '$.tmdb_id')`. The query needs that pattern (already used elsewhere in this repo's DAOs — see `media_items_dao.dart` for the existing pattern; otherwise fall back to in-memory join in the mapper).

If the join is awkward in Drift, the mapper can do an in-memory join: stream `listDirty()` + a parallel `select(mediaItems)..where(extraMetadata contains tmdbId)` per row. Acceptable for the typical N (< 100 dirty rows) — but the join is preferable when it's clean.

### Riverpod providers (new)

```dart
/// Stream of pending changes for the new dialog.
final tmdbPendingChangesProvider =
    StreamProvider<List<TmdbPendingChange>>((ref) {
  final dao = ref.watch(tmdbAccountSyncDaoProvider);
  return dao.watchPendingChanges()
      .map((rows) => rows.map(toTmdbPendingChange).toList());
});

/// Stream of conflict count for the section card's second row.
/// (Already exists as a Future-returning method; widen to a stream
/// over watchConflicts().length.)
final tmdbConflictCountProvider = StreamProvider<int>((ref) {
  final dao = ref.watch(tmdbAccountSyncDaoProvider);
  return dao.watchConflicts().map((list) => list.length);
});

/// Live progress for any push operation kicked off via RetryPushUseCase.
class TmdbPushProgressNotifier extends Notifier<TmdbPushProgress> {
  @override
  TmdbPushProgress build() => TmdbPushProgress.idle();

  void start(int total) { state = TmdbPushProgress(inFlight: true, current: 0, total: total); }
  void advance() { state = state.copyWith(current: state.current + 1); }
  void finish() { state = TmdbPushProgress.idle(); }
}

final tmdbPushProgressProvider =
    NotifierProvider<TmdbPushProgressNotifier, TmdbPushProgress>(
        TmdbPushProgressNotifier.new);
```

### `RetryPushUseCase` (new domain use case)

```dart
class RetryPushUseCase {
  RetryPushUseCase({
    required this.repo,
    required this.progress,
  });

  final ITmdbAccountSyncRepository repo;
  final TmdbPushProgressNotifier progress;

  /// Retry every key in [keys]. If [keys] is empty, returns idle summary.
  Future<TmdbPushSummary> retry(List<TmdbBridgeKey> keys) async {
    if (keys.isEmpty) {
      return const TmdbPushSummary(
          attempted: 0, succeeded: 0, failed: 0);
    }
    progress.start(keys.length);
    int succeeded = 0;
    int failed = 0;
    String? lastError;
    for (final key in keys) {
      final result = await repo.pushOne(
          tmdbId: key.tmdbId, mediaType: key.mediaType);
      if (result.success) {
        succeeded++;
      } else {
        failed++;
        lastError = result.error;
      }
      progress.advance();
    }
    progress.finish();
    return TmdbPushSummary(
      attempted: keys.length,
      succeeded: succeeded,
      failed: failed,
      lastError: lastError,
    );
  }

  /// Convenience for a single retry.
  Future<TmdbPushResult> retryOne(TmdbBridgeKey key) async {
    final summary = await retry([key]);
    return TmdbPushResult(
      success: summary.failed == 0,
      error: summary.lastError,
    );
  }
}
```

`TmdbBridgeKey` already exists (`{tmdbId: int, mediaType: String}`). The settings card's existing **Push all now** button is rewired to call `useCase.retry(allDirty)` so progress is consistent across both entry points (button and dialog).

The progress notifier ensures `finish()` runs even if the loop throws — wrap the body in `try/finally` in the actual implementation.

### `TmdbPendingChangesDialog` (new widget)

Lives at `lib/presentation/screens/settings/widgets/tmdb_pending_changes_dialog.dart`.

```dart
class TmdbPendingChangesDialog extends ConsumerWidget {
  const TmdbPendingChangesDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(tmdbPendingChangesProvider);
    final progress = ref.watch(tmdbPushProgressProvider);
    // ... renders header, list, footer per the architecture diagram above.
  }
}
```

Dialog cannot be dismissed while `progress.inFlight` is true (override `WillPopScope` / `PopScope`).

### Settings card changes

Replace the existing single inline row in `TmdbAccountSyncSection` with two rows:

```dart
final pendingCount = ref.watch(tmdbPendingChangesProvider)
    .maybeWhen(data: (l) => l.length, orElse: () => 0);
final conflictCount = ref.watch(tmdbConflictCountProvider).valueOrNull ?? 0;

if (pendingCount > 0)
  Row([
    Icon(Icons.cloud_upload),
    Expanded(Text('$pendingCount pending change${pendingCount == 1 ? '' : 's'} to push')),
    TextButton('View & retry', onPressed: () => showDialog(...)),
    TextButton('Push all now', onPressed: () => useCase.retry(allKeys)),
  ]),
if (conflictCount > 0)
  Row([
    Icon(Icons.warning_amber),
    Expanded(Text('$conflictCount conflict${conflictCount == 1 ? '' : 's'} need resolution')),
    TextButton('Resolve', onPressed: () => context.go('/settings/tmdb-resolve-conflicts')),
  ]),
```

The conflict row uses GoRouter to navigate; the existing `TmdbResolveConflictsScreen` route already exists in `router.dart`. Confirm exact path during implementation (likely `/settings/tmdb-resolve-conflicts` or similar).

### Action chip rendering (UI detail)

In `_PendingChangeTile`, render each action as a `Chip` or compact pill:

- `TmdbPendingAction.rating` → `Rating 4.5★` (computed live from the bridge row's `localRatingValue`)
- `TmdbPendingAction.watchlist` → `On watchlist` or `Off watchlist` based on the local value
- `TmdbPendingAction.favourite` → `Favourited` or `Unfavourited`
- `TmdbPendingAction.ownership` → `Owned` or `Removed from list`

Empty actions list is unexpected (it means a row is dirty for an unknown reason) — render as `Pending change` to keep the UI honest about what's happening.

## Data flow — Retry-all-failed

1. User opens dialog. Stream emits 5 rows; 3 have `lastError != null`.
2. User taps **Retry all failed**. Dialog reads the current snapshot of the stream, filters to failed rows, calls `useCase.retry([key1, key3, key5])`.
3. Use case calls `progress.start(3)`. Dialog header re-renders to show `LinearProgressIndicator(value: 0/3)` and `Pushing 0 of 3...`.
4. Loop:
   - `pushOne(key1)` succeeds. DAO clears `localDirty` and `lastError`. Stream re-emits with row1 gone. Header updates to `Pushing 1 of 3...`.
   - `pushOne(key3)` fails (network). DAO records new `lastError`. Stream re-emits with row3 still present, error updated.
   - `pushOne(key5)` succeeds.
5. Use case calls `progress.finish()`. Dialog enables dismiss. Header shows static `1 of 3 still failing`.
6. User can now retry just row3 individually, or close.

## Data flow — Single-row retry

1. User taps the trailing Retry icon on a tile. Dialog calls `useCase.retryOne(key)`.
2. `progress.start(1)` → `pushOne(key)` → `progress.finish()`. Header progress shows briefly.
3. Stream re-emits; row either disappears (success) or shows updated error (failure).

## Error handling

- `pushOne()` already catches network errors, classifies them via the rate-limit interceptor, and persists `lastError`. No new error handling needed in the use case.
- The dialog shows the persisted `lastError` text directly. Long error strings truncate to two lines with `TextOverflow.ellipsis`.
- If the DAO query itself fails (vanishingly unlikely with SQLite), the dialog's `pendingAsync.when` shows an error placeholder with the existing app pattern.
- If `progress.finish()` doesn't run because of a bug, the dialog stays in "pushing" mode forever — wrap the use case in `try/finally` to ensure cleanup.

## Testing

### Unit tests

- `derivePendingActions(BridgeRow)` — fixture matrix: only-rating-dirty, watchlist+favourite-dirty, ownership-dirty, all-clean (returns empty), conflicts-marker-row (irrelevant for this helper because conflicts are filtered upstream).
- DAO `watchPendingChanges()` — insert dirty, conflict, and clean rows; assert only non-conflict dirty rows emit; assert join produces titles where a media_item exists and `null` where it doesn't.
- `RetryPushUseCase`:
  - `retry([])` returns idle summary, doesn't touch progress.
  - `retry([k1,k2])` advances progress monotonically (1→2), calls `pushOne` twice, finishes idle.
  - When `pushOne` throws, progress still finishes via `try/finally`. Summary reports `failed`.
  - `retryOne(k)` is equivalent to `retry([k])`.

### Widget tests

- `TmdbPendingChangesDialog`:
  - Renders one tile per pending change from a fake stream.
  - Header shows `N pending` count and `M failed` chip when failures present.
  - Tapping `Retry all failed` only iterates failed rows.
  - Tapping a row's Retry icon retries only that row.
  - Header `LinearProgressIndicator` is visible while `progress.inFlight == true`.
  - Dialog cannot be dismissed (back button suppressed) while in-flight.
  - When the stream emits zero rows, the dialog shows an empty state (`All caught up — no pending changes`).
- `TmdbAccountSyncSection`:
  - When `pendingCount > 0` and `conflictCount > 0`, both rows render.
  - When only conflicts exist, only the conflict row renders.
  - `Push all now` is wired to the new use case (asserted via mocked use case + verify call).

## Acceptance criteria

- After a partial failure, the user can see *which* rows failed and *what* the error was, without leaving the settings screen.
- The user can retry a single failed row without re-attempting the others.
- The user can retry all failed rows in one tap.
- Conflict rows are no longer counted in the "pending push" surface; instead they appear in a separate row with a `Resolve` link to the existing screen.
- Bulk push shows live progress (`Pushing X of Y...`) while running.
- The dialog cannot be dismissed mid-push.
- All existing tests continue to pass; ~15 new tests cover the new pieces.
- `flutter analyze` clean. Linux + Android builds succeed.

## Out of scope (explicit)

- Changing the conflict-resolution flow.
- Auto-retry / exponential backoff.
- Schema migrations.
- Pushing during app startup or in the background.
- Showing push history beyond the per-row `lastError`.
- Per-row inline progress spinners (header progress is sufficient).

## Risks

- **DAO join awkwardness:** the bridge stores `tmdbId` as a column but `media_items` stores it inside `extraMetadata` JSON. The implementation may need `json_extract(extra_metadata, '$.tmdb_id')` in Drift, OR fall back to an in-memory join in the mapper. Both work; prefer the SQL join for performance, fall back gracefully if it adds undue complexity.
- **Action derivation accuracy:** if any of the snapshot fields (`localRatingSnapshot`, `remoteWatchlistSnapshot`, etc.) don't exist on the current schema, the helper omits that action and the row shows fewer chips. Not a regression — the user just sees less detail. Actual schema inspection happens during implementation.
- **Progress notifier leak:** if the dialog is dismissed during a push (we block it via PopScope, but a hot-reload or app-backgrounding might bypass), `progress.inFlight` could stick. The use case's `try/finally` is the guard.
- **"Push all now" button is now redundant with "View & retry":** intentional — the quick-fire button is faster for the common case (push everything without inspecting). UX studies of similar flows (Drive, Dropbox sync) keep both an inline action and a "view details" affordance.

## File layout

| Path | Created / Modified |
|---|---|
| `lib/domain/entities/tmdb_pending_change.dart` | created |
| `lib/domain/entities/tmdb_push_progress.dart` | created |
| `lib/domain/usecases/retry_push_usecase.dart` | created |
| `lib/data/local/dao/tmdb_account_sync_dao.dart` | modified — add `watchPendingChanges()` |
| `lib/data/mappers/tmdb_account_mapper.dart` | modified — add `toTmdbPendingChange` + `derivePendingActions` |
| `lib/presentation/providers/tmdb_account_sync_provider.dart` | modified — add 3 new providers |
| `lib/presentation/providers/repository_providers.dart` | modified — register `RetryPushUseCase` provider |
| `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart` | modified — replace single row with two rows + new dialog launch |
| `lib/presentation/screens/settings/widgets/tmdb_pending_changes_dialog.dart` | created |
| `test/unit/data/mappers/tmdb_account_mapper_test.dart` | modified — add `derivePendingActions` cases |
| `test/unit/data/local/dao/tmdb_account_sync_dao_test.dart` | modified — add `watchPendingChanges` cases |
| `test/unit/domain/usecases/retry_push_usecase_test.dart` | created |
| `test/widget/screens/settings/widgets/tmdb_pending_changes_dialog_test.dart` | created |
| `src/docs/modules/ROOT/pages/tmdb-account-sync.adoc` | modified — document the new dialog and conflict row |

No new files at the data-layer boundary beyond what's listed. No schema migration. No changes to the conflict resolution screen.
