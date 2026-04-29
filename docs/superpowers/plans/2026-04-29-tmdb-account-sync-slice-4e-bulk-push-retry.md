# TMDB Account Sync — Slice 4e (Bulk Push-Retry UX) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current single-row "Push pending now" surface with a richer pending-changes view where the user can see which rows are pending, see per-row errors when a push fails, retry one row or just the failed ones, and watch live progress during a bulk push. Conflicts get their own row in the settings card linking to the existing `/tmdb/conflicts` screen.

**Architecture:** A new `TmdbPendingChange` view-model is composed in-memory from a stream of dirty (non-conflict) bridge rows and a side lookup of local media-item titles. A new `RetryPushUseCase` drives `pushOne()` per row and pushes progress through a Riverpod notifier so the dialog and any caller (including the existing "Push all now" quick-fire button) share live progress. No schema changes, no new DAO joins (in-memory composition for simplicity), no changes to the conflict resolution screen.

**Tech Stack:** Flutter 3.x, Dart 3 sealed classes + switch expressions, Riverpod 3 Notifier/StreamProvider, Drift (in-memory composition only), mocktail for tests.

**Source spec:** `docs/superpowers/specs/2026-04-29-tmdb-account-sync-slice-4e-bulk-push-retry-design.md`

---

## File Layout

### Create

| Path | Purpose |
|---|---|
| `lib/domain/entities/tmdb_pending_change.dart` | View-model bundling bridge row + title + chips. |
| `lib/domain/entities/tmdb_push_progress.dart` | Tiny `{inFlight, current, total}` value type. |
| `lib/domain/usecases/retry_push_usecase.dart` | Orchestrator: iterates `pushOne` calls, pushes progress. |
| `lib/presentation/screens/settings/widgets/tmdb_pending_changes_dialog.dart` | Modal dialog with header progress + per-row retry. |
| `test/unit/domain/entities/tmdb_pending_change_test.dart` | Action-derivation cases. |
| `test/unit/domain/usecases/retry_push_usecase_test.dart` | Use-case tests with mocked repo + real notifier. |
| `test/widget/screens/settings/widgets/tmdb_pending_changes_dialog_test.dart` | Stream-driven widget tests. |

### Modify

| Path | Change |
|---|---|
| `lib/domain/entities/tmdb_bridge_bucket.dart` | Confirm/extend `TmdbBridgeKey` (it already exists from slice 4a — no change expected). |
| `lib/data/local/dao/tmdb_account_sync_dao.dart` | Add `watchPendingDirty()` — stream of dirty rows EXCLUDING conflict-marker rows. |
| `lib/presentation/providers/tmdb_account_sync_provider.dart` | Add 3 providers: `tmdbPendingChangesProvider`, `tmdbConflictCountProvider`, `tmdbPushProgressProvider`. |
| `lib/presentation/providers/repository_providers.dart` | Add `retryPushUseCaseProvider`. |
| `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart` | Replace single-row inline with two-row layout (pending + conflicts) + new dialog launch + rewire "Push all now" through the new use case. |
| `src/docs/modules/ROOT/pages/tmdb-account-sync.adoc` | Document the new dialog + conflict row. |

No new files at the data-layer boundary beyond what's listed. No schema migration.

---

## Convention notes

- The bridge table's `lastError` text is the **only** persisted error surface today. `lastError == 'conflict:user-resolution-required'` is the existing convention for conflicts (slice 2). The new `watchPendingDirty()` excludes those rows.
- `TmdbPendingChange.title` is sourced from the bridge's `titleSnapshot` column (populated during pull/import) and falls back to `null` when missing. We do NOT join to `media_items` — the snapshot is good enough for the typical pending row, simpler, and avoids a JSON-column query.
- Action chips are derived directly from the bridge row's columns (`watchlist`, `favorite`, `localRatingSnapshot`). We don't need to know which specific field was edited; the user wants to see "what's about to be pushed". Chips are shown only for non-default values (so a row dirty only because of rating shows just the rating chip).
- The progress notifier uses `try/finally` so a thrown `pushOne` cleanly returns the dialog to idle state.
- The "Push all now" button on the section card is rewired through `RetryPushUseCase.retry(allKeys)` so both entry points share the same progress plumbing.

---

## Task 1: `TmdbPendingChange` view-model + `derivePendingActions` (TDD)

**Files:**
- Create: `lib/domain/entities/tmdb_pending_change.dart`
- Create: `test/unit/domain/entities/tmdb_pending_change_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/unit/domain/entities/tmdb_pending_change_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/tmdb_pending_change.dart';

void main() {
  group('derivePendingActions', () {
    test('rating only', () {
      final actions = derivePendingActions(
        watchlist: false,
        favorite: false,
        localRatingSnapshot: 4.5,
      );
      expect(actions, [const TmdbPendingAction.rating(4.5)]);
    });

    test('watchlist + favourite (no rating)', () {
      final actions = derivePendingActions(
        watchlist: true,
        favorite: true,
        localRatingSnapshot: null,
      );
      expect(actions, [
        const TmdbPendingAction.watchlist(),
        const TmdbPendingAction.favourite(),
      ]);
    });

    test('all three', () {
      final actions = derivePendingActions(
        watchlist: true,
        favorite: true,
        localRatingSnapshot: 3.0,
      );
      expect(actions, [
        const TmdbPendingAction.rating(3.0),
        const TmdbPendingAction.watchlist(),
        const TmdbPendingAction.favourite(),
      ]);
    });

    test('all-default returns empty list', () {
      final actions = derivePendingActions(
        watchlist: false,
        favorite: false,
        localRatingSnapshot: null,
      );
      expect(actions, isEmpty);
    });
  });

  group('TmdbPendingChange.hasFailed', () {
    test('null lastError → false', () {
      final c = TmdbPendingChange(
        tmdbId: 1,
        mediaType: 'movie',
        title: 'Fight Club',
        actions: const [],
        lastPushedAt: null,
        lastError: null,
      );
      expect(c.hasFailed, isFalse);
    });

    test('non-null lastError → true', () {
      final c = TmdbPendingChange(
        tmdbId: 1,
        mediaType: 'movie',
        title: 'Fight Club',
        actions: const [],
        lastPushedAt: null,
        lastError: 'connection failed',
      );
      expect(c.hasFailed, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run the test (will fail)**

Run: `flutter test test/unit/domain/entities/tmdb_pending_change_test.dart`
Expected: FAIL — file doesn't exist.

- [ ] **Step 3: Implement the entity**

Create `lib/domain/entities/tmdb_pending_change.dart`:

```dart
/// View-model rendered by [TmdbPendingChangesDialog]. Composed in
/// memory from a bridge row (and optionally a looked-up local media
/// item title); pure Dart so it can be unit-tested in isolation.
class TmdbPendingChange {
  const TmdbPendingChange({
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    required this.actions,
    required this.lastPushedAt,
    required this.lastError,
  });

  final int tmdbId;
  final String mediaType;

  /// Best-effort local title (from `titleSnapshot` on the bridge row,
  /// or null when no title was ever stored).
  final String? title;

  /// Chips to render — empty list when the row is dirty for an unknown
  /// reason (the dialog renders a generic "Pending change" pill in
  /// that case).
  final List<TmdbPendingAction> actions;

  /// Epoch ms of the last push attempt, or null if never attempted.
  final int? lastPushedAt;

  /// Persisted error from the last push attempt; null when none or
  /// when the error has been cleared.
  final String? lastError;

  bool get hasFailed => lastError != null;
}

/// Sealed action chip type. Each value carries any data the chip
/// needs to render itself.
sealed class TmdbPendingAction {
  const TmdbPendingAction();

  const factory TmdbPendingAction.rating(double value) =
      TmdbPendingActionRating;
  const factory TmdbPendingAction.watchlist() = TmdbPendingActionWatchlist;
  const factory TmdbPendingAction.favourite() = TmdbPendingActionFavourite;
}

class TmdbPendingActionRating extends TmdbPendingAction {
  const TmdbPendingActionRating(this.value);
  final double value;

  @override
  bool operator ==(Object other) =>
      other is TmdbPendingActionRating && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class TmdbPendingActionWatchlist extends TmdbPendingAction {
  const TmdbPendingActionWatchlist();

  @override
  bool operator ==(Object other) => other is TmdbPendingActionWatchlist;

  @override
  int get hashCode => 1;
}

class TmdbPendingActionFavourite extends TmdbPendingAction {
  const TmdbPendingActionFavourite();

  @override
  bool operator ==(Object other) => other is TmdbPendingActionFavourite;

  @override
  int get hashCode => 2;
}

/// Pure helper: derive the action chip list from the current bridge
/// row state. Order is stable so tests can match exact lists.
List<TmdbPendingAction> derivePendingActions({
  required bool watchlist,
  required bool favorite,
  required double? localRatingSnapshot,
}) {
  return [
    if (localRatingSnapshot != null) TmdbPendingAction.rating(localRatingSnapshot),
    if (watchlist) const TmdbPendingAction.watchlist(),
    if (favorite) const TmdbPendingAction.favourite(),
  ];
}
```

- [ ] **Step 4: Run the tests**

Run: `flutter test test/unit/domain/entities/tmdb_pending_change_test.dart`
Expected: 6/6 pass.

- [ ] **Step 5: Run analyzer**

Run: `flutter analyze lib/domain/entities/tmdb_pending_change.dart test/unit/domain/entities/tmdb_pending_change_test.dart`
Expected: zero issues.

- [ ] **Step 6: Commit**

```bash
git add lib/domain/entities/tmdb_pending_change.dart \
        test/unit/domain/entities/tmdb_pending_change_test.dart
git commit -m "feat(tmdb-sync): add TmdbPendingChange view-model + derivePendingActions"
```

---

## Task 2: `TmdbPushProgress` value type

**Files:**
- Create: `lib/domain/entities/tmdb_push_progress.dart`

No tests — pure data carrier exercised in Task 3.

- [ ] **Step 1: Create the entity**

Create `lib/domain/entities/tmdb_push_progress.dart`:

```dart
/// Live progress of a `RetryPushUseCase` invocation. Held by a
/// `Notifier<TmdbPushProgress>` so the dialog header (and any other
/// listener) can render a determinate progress bar.
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

  TmdbPushProgress copyWith({bool? inFlight, int? current, int? total}) =>
      TmdbPushProgress(
        inFlight: inFlight ?? this.inFlight,
        current: current ?? this.current,
        total: total ?? this.total,
      );

  @override
  bool operator ==(Object other) =>
      other is TmdbPushProgress &&
      other.inFlight == inFlight &&
      other.current == current &&
      other.total == total;

  @override
  int get hashCode => Object.hash(inFlight, current, total);
}
```

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze lib/domain/entities/tmdb_push_progress.dart`
Expected: zero issues.

- [ ] **Step 3: Commit**

```bash
git add lib/domain/entities/tmdb_push_progress.dart
git commit -m "feat(tmdb-sync): add TmdbPushProgress value type"
```

---

## Task 3: `RetryPushUseCase` (TDD)

**Files:**
- Create: `lib/domain/usecases/retry_push_usecase.dart`
- Create: `test/unit/domain/usecases/retry_push_usecase_test.dart`

The use case takes an `ITmdbAccountSyncRepository` for `pushOne(...)` calls and a callback bundle for progress so it doesn't depend on Riverpod. The provider in Task 5 wires the callbacks to the notifier.

- [ ] **Step 1: Write the failing test**

Create `test/unit/domain/usecases/retry_push_usecase_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/retry_push_usecase.dart';

class _MockRepo extends Mock implements ITmdbAccountSyncRepository {}

void main() {
  late _MockRepo repo;
  late List<int> startedTotals;
  late int advanceCount;
  late int finishCount;
  late RetryPushUseCase uc;

  setUp(() {
    repo = _MockRepo();
    startedTotals = [];
    advanceCount = 0;
    finishCount = 0;
    uc = RetryPushUseCase(
      repo: repo,
      startProgress: (n) => startedTotals.add(n),
      advanceProgress: () => advanceCount++,
      finishProgress: () => finishCount++,
    );
  });

  TmdbBridgeKey key(int id) =>
      TmdbBridgeKey(tmdbId: id, mediaType: 'movie');

  test('retry empty list returns idle summary, no progress', () async {
    final summary = await uc.retry(const []);
    expect(summary.attempted, 0);
    expect(summary.succeeded, 0);
    expect(summary.failed, 0);
    expect(startedTotals, isEmpty);
    expect(advanceCount, 0);
    expect(finishCount, 0);
    verifyNever(() => repo.pushOne(
        tmdbId: any(named: 'tmdbId'),
        mediaType: any(named: 'mediaType')));
  });

  test('retry two keys: both succeed', () async {
    when(() => repo.pushOne(
            tmdbId: any(named: 'tmdbId'),
            mediaType: any(named: 'mediaType')))
        .thenAnswer((_) async => const TmdbPushResult(success: true));

    final summary = await uc.retry([key(1), key(2)]);

    expect(summary.attempted, 2);
    expect(summary.succeeded, 2);
    expect(summary.failed, 0);
    expect(startedTotals, [2]);
    expect(advanceCount, 2);
    expect(finishCount, 1);
  });

  test('retry mixed success/failure reports lastError of last failure',
      () async {
    var calls = 0;
    when(() => repo.pushOne(
            tmdbId: any(named: 'tmdbId'),
            mediaType: any(named: 'mediaType')))
        .thenAnswer((_) async {
      calls++;
      if (calls == 1) return const TmdbPushResult(success: true);
      if (calls == 2) {
        return const TmdbPushResult(
            success: false, error: 'first failure');
      }
      return const TmdbPushResult(
          success: false, error: 'second failure');
    });

    final summary = await uc.retry([key(1), key(2), key(3)]);

    expect(summary.attempted, 3);
    expect(summary.succeeded, 1);
    expect(summary.failed, 2);
    expect(summary.lastError, 'second failure');
    expect(advanceCount, 3);
    expect(finishCount, 1);
  });

  test('finish runs even when pushOne throws', () async {
    when(() => repo.pushOne(
            tmdbId: any(named: 'tmdbId'),
            mediaType: any(named: 'mediaType')))
        .thenThrow(StateError('boom'));

    expect(() => uc.retry([key(1)]), throwsStateError);
    // Allow the microtask queue to drain so finally runs.
    await Future<void>.delayed(Duration.zero);
    expect(finishCount, 1);
  });

  test('retryOne wraps retry([key])', () async {
    when(() => repo.pushOne(
            tmdbId: any(named: 'tmdbId'),
            mediaType: any(named: 'mediaType')))
        .thenAnswer((_) async => const TmdbPushResult(success: true));

    final result = await uc.retryOne(key(7));

    expect(result.success, isTrue);
    expect(result.error, isNull);
    expect(advanceCount, 1);
    expect(finishCount, 1);
  });

  setUpAll(() {
    registerFallbackValue(const TmdbPushResult(success: false));
  });
}
```

- [ ] **Step 2: Run the test (will fail — file doesn't exist)**

Run: `flutter test test/unit/domain/usecases/retry_push_usecase_test.dart`
Expected: FAIL — `Target of URI doesn't exist`.

- [ ] **Step 3: Implement the use case**

Create `lib/domain/usecases/retry_push_usecase.dart`:

```dart
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

/// Drives a sequence of `pushOne` calls and reports live progress
/// through callbacks (so the use case stays platform/UI agnostic).
///
/// On non-error completion it leaves the progress in idle. On error
/// it re-throws after marking finish, so the caller's stack trace is
/// preserved.
class RetryPushUseCase {
  RetryPushUseCase({
    required this.repo,
    required this.startProgress,
    required this.advanceProgress,
    required this.finishProgress,
  });

  final ITmdbAccountSyncRepository repo;
  final void Function(int total) startProgress;
  final void Function() advanceProgress;
  final void Function() finishProgress;

  /// Attempt every key in [keys]. Returns a summary identical in shape
  /// to [TmdbPushSummary] from `pushAllDirty()`.
  Future<TmdbPushSummary> retry(List<TmdbBridgeKey> keys) async {
    if (keys.isEmpty) {
      return const TmdbPushSummary(
          attempted: 0, succeeded: 0, failed: 0);
    }
    startProgress(keys.length);
    int succeeded = 0;
    int failed = 0;
    String? lastError;
    try {
      for (final k in keys) {
        final result =
            await repo.pushOne(tmdbId: k.tmdbId, mediaType: k.mediaType);
        if (result.success) {
          succeeded++;
        } else {
          failed++;
          if (result.error != null) lastError = result.error;
        }
        advanceProgress();
      }
    } finally {
      finishProgress();
    }
    return TmdbPushSummary(
      attempted: keys.length,
      succeeded: succeeded,
      failed: failed,
      lastError: lastError,
    );
  }

  /// Convenience wrapper around [retry] with a single key. Returns a
  /// `TmdbPushResult` so callers can treat single retries the same way
  /// they treat the existing `pushOne` API.
  Future<TmdbPushResult> retryOne(TmdbBridgeKey key) async {
    final summary = await retry([key]);
    return TmdbPushResult(
      success: summary.failed == 0,
      error: summary.lastError,
    );
  }
}
```

- [ ] **Step 4: Run the tests**

Run: `flutter test test/unit/domain/usecases/retry_push_usecase_test.dart`
Expected: 5/5 pass.

- [ ] **Step 5: Run analyzer**

Run: `flutter analyze lib/domain/usecases/retry_push_usecase.dart test/unit/domain/usecases/retry_push_usecase_test.dart`
Expected: zero issues.

- [ ] **Step 6: Commit**

```bash
git add lib/domain/usecases/retry_push_usecase.dart \
        test/unit/domain/usecases/retry_push_usecase_test.dart
git commit -m "feat(tmdb-sync): add RetryPushUseCase with callback-based progress"
```

---

## Task 4: DAO `watchPendingDirty()` (TDD)

**Files:**
- Modify: `lib/data/local/dao/tmdb_account_sync_dao.dart`
- Modify: `test/unit/data/local/dao/tmdb_account_sync_dao_test.dart`

`watchPendingDirty()` excludes conflict-marker rows from `watchDirty`-style emission. We deliberately don't join media_items here — the dialog will use `titleSnapshot` from the bridge row directly.

- [ ] **Step 1: Read the existing DAO test file**

Read `test/unit/data/local/dao/tmdb_account_sync_dao_test.dart` to understand the in-memory drift setup. The existing tests likely insert rows via `dao.upsertByTmdbId(...)` or via raw `into(table).insert(...)`.

- [ ] **Step 2: Append the failing tests**

Append inside the existing `void main()`:

```dart
group('watchPendingDirty', () {
  test('emits only dirty non-conflict rows', () async {
    final now = DateTime.now().millisecondsSinceEpoch;
    // Clean row.
    await db.into(db.tmdbAccountSyncItemsTable).insert(
          TmdbAccountSyncItemsTableCompanion.insert(
            id: 'r1',
            tmdbId: 1,
            tmdbMediaType: 'movie',
            createdAt: now,
            updatedAt: now,
          ),
        );
    // Dirty row.
    await db.into(db.tmdbAccountSyncItemsTable).insert(
          TmdbAccountSyncItemsTableCompanion.insert(
            id: 'r2',
            tmdbId: 2,
            tmdbMediaType: 'movie',
            localDirty: const Value(true),
            titleSnapshot: const Value('Fight Club'),
            createdAt: now,
            updatedAt: now,
          ),
        );
    // Conflict row.
    await db.into(db.tmdbAccountSyncItemsTable).insert(
          TmdbAccountSyncItemsTableCompanion.insert(
            id: 'r3',
            tmdbId: 3,
            tmdbMediaType: 'movie',
            localDirty: const Value(true),
            lastError: const Value('conflict:user-resolution-required'),
            createdAt: now,
            updatedAt: now,
          ),
        );

    final emitted = await dao.watchPendingDirty().first;
    expect(emitted.map((r) => r.id), ['r2']);
  });

  test('orders by updatedAt ascending (oldest first)', () async {
    await db.into(db.tmdbAccountSyncItemsTable).insert(
          TmdbAccountSyncItemsTableCompanion.insert(
            id: 'r-newer',
            tmdbId: 10,
            tmdbMediaType: 'movie',
            localDirty: const Value(true),
            createdAt: 1000,
            updatedAt: 2000,
          ),
        );
    await db.into(db.tmdbAccountSyncItemsTable).insert(
          TmdbAccountSyncItemsTableCompanion.insert(
            id: 'r-older',
            tmdbId: 11,
            tmdbMediaType: 'movie',
            localDirty: const Value(true),
            createdAt: 1000,
            updatedAt: 1500,
          ),
        );

    final emitted = await dao.watchPendingDirty().first;
    expect(emitted.map((r) => r.id), ['r-older', 'r-newer']);
  });
});
```

The test uses `dao.watchPendingDirty()` — make sure `dao` and `db` are already in scope from the existing test setup. If the existing setup uses different variable names, adapt to match.

- [ ] **Step 3: Run the new tests (will fail)**

Run: `flutter test test/unit/data/local/dao/tmdb_account_sync_dao_test.dart --name "watchPendingDirty"`
Expected: FAIL — `watchPendingDirty` is not defined on `TmdbAccountSyncDao`.

- [ ] **Step 4: Add the DAO method**

In `lib/data/local/dao/tmdb_account_sync_dao.dart`, add (placement: directly below `watchConflicts`, around line 202):

```dart
/// Stream of dirty rows for the new pending-changes dialog. Excludes
/// conflict-marker rows — those go through [watchConflicts] and the
/// existing `TmdbResolveConflictsScreen`.
Stream<List<TmdbAccountSyncItemsTableData>> watchPendingDirty() {
  return (select(tmdbAccountSyncItemsTable)
        ..where((t) =>
            t.localDirty.equals(true) &
            (t.lastError.isNull() |
                t.lastError.equals('conflict:user-resolution-required').not()))
        ..orderBy([(t) => OrderingTerm.asc(t.updatedAt)]))
      .watch();
}
```

- [ ] **Step 5: Run the new tests**

Run: `flutter test test/unit/data/local/dao/tmdb_account_sync_dao_test.dart --name "watchPendingDirty"`
Expected: 2/2 pass.

- [ ] **Step 6: Run the full DAO test file (regression)**

Run: `flutter test test/unit/data/local/dao/tmdb_account_sync_dao_test.dart`
Expected: all pass.

- [ ] **Step 7: Run analyzer**

Run: `flutter analyze lib/data/local/dao/tmdb_account_sync_dao.dart test/unit/data/local/dao/tmdb_account_sync_dao_test.dart`
Expected: zero issues.

- [ ] **Step 8: Commit**

```bash
git add lib/data/local/dao/tmdb_account_sync_dao.dart \
        test/unit/data/local/dao/tmdb_account_sync_dao_test.dart
git commit -m "feat(tmdb-sync): add watchPendingDirty DAO query (excludes conflicts)"
```

---

## Task 5: Wire the providers

**Files:** Modify: `lib/presentation/providers/tmdb_account_sync_provider.dart` (add 3 providers); modify: `lib/presentation/providers/repository_providers.dart` (add `retryPushUseCaseProvider`).

- [ ] **Step 1: Read both files**

Skim both files. The slice 4d notifier `TmdbConnectDialogVisibleNotifier` is at the bottom of `tmdb_account_sync_provider.dart`. Slice 4d/2 providers in `repository_providers.dart` give you the pattern to follow.

- [ ] **Step 2: Add the providers in `tmdb_account_sync_provider.dart`**

Add at the bottom (after the slice-4d `tmdbConnectDialogVisibleProvider` block):

```dart
/// Stream of pending changes (dirty bridge rows excluding conflicts)
/// rendered by [TmdbPendingChangesDialog]. Each row is composed in
/// memory from the bridge row itself; titles come from
/// `titleSnapshot` and don't require a media-items join.
final tmdbPendingChangesProvider =
    StreamProvider<List<TmdbPendingChange>>((ref) {
  final dao = ref.watch(tmdbAccountSyncDaoProvider);
  return dao.watchPendingDirty().map((rows) => rows
      .map((r) => TmdbPendingChange(
            tmdbId: r.tmdbId,
            mediaType: r.tmdbMediaType,
            title: r.titleSnapshot,
            actions: derivePendingActions(
              watchlist: r.watchlist,
              favorite: r.favorite,
              localRatingSnapshot: r.localRatingSnapshot,
            ),
            lastPushedAt: r.lastPushedAt,
            lastError: r.lastError,
          ))
      .toList());
});

/// Stream of the conflict count for the section card's second row.
final tmdbConflictCountProvider = StreamProvider<int>((ref) {
  final dao = ref.watch(tmdbAccountSyncDaoProvider);
  return dao.watchConflicts().map((list) => list.length);
});

/// Live progress of any active push-retry. The dialog and any caller
/// observe this for the determinate progress indicator.
class TmdbPushProgressNotifier extends Notifier<TmdbPushProgress> {
  @override
  TmdbPushProgress build() => TmdbPushProgress.idle();

  void start(int total) {
    state = TmdbPushProgress(inFlight: true, current: 0, total: total);
  }

  void advance() {
    state = state.copyWith(current: state.current + 1);
  }

  void finish() {
    state = TmdbPushProgress.idle();
  }
}

final tmdbPushProgressProvider =
    NotifierProvider<TmdbPushProgressNotifier, TmdbPushProgress>(
        TmdbPushProgressNotifier.new);
```

Add the imports at the top of the file (alongside existing imports):

```dart
import 'package:mymediascanner/domain/entities/tmdb_pending_change.dart';
import 'package:mymediascanner/domain/entities/tmdb_push_progress.dart';
```

- [ ] **Step 3: Add `retryPushUseCaseProvider` in `repository_providers.dart`**

In `lib/presentation/providers/repository_providers.dart`, add at the end of the TMDB-account-sync section (after the existing `saveTmdbOnlyUseCaseProvider`):

```dart
final retryPushUseCaseProvider = Provider<RetryPushUseCase>((ref) {
  final notifier = ref.watch(tmdbPushProgressProvider.notifier);
  return RetryPushUseCase(
    repo: ref.watch(tmdbAccountSyncRepositoryProvider),
    startProgress: notifier.start,
    advanceProgress: notifier.advance,
    finishProgress: notifier.finish,
  );
});
```

Add the import at the top of the file:

```dart
import 'package:mymediascanner/domain/usecases/retry_push_usecase.dart';
```

(The notifier class lives in `tmdb_account_sync_provider.dart`. Riverpod will already see it through the existing provider graph; no new import needed at the top of `repository_providers.dart` for `tmdbPushProgressProvider` itself if it's exported from `tmdb_account_sync_provider.dart`. Confirm during implementation — if the linter complains, add `import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';`.)

- [ ] **Step 4: Run analyzer**

Run: `flutter analyze lib/presentation/providers/tmdb_account_sync_provider.dart lib/presentation/providers/repository_providers.dart`
Expected: zero issues.

- [ ] **Step 5: Run the full test suite (regression)**

Run: `flutter test`
Expected: all tests pass — none of the new providers are read yet.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/providers/tmdb_account_sync_provider.dart \
        lib/presentation/providers/repository_providers.dart
git commit -m "feat(tmdb-sync): wire pending-changes + push-progress + retry-push providers"
```

---

## Task 6: `TmdbPendingChangesDialog` widget

**Files:**
- Create: `lib/presentation/screens/settings/widgets/tmdb_pending_changes_dialog.dart`

The widget renders a header (title, count, retry-all button, progress), a `ListView` of tiles, and a footer Close button. PopScope blocks dismiss while `progress.inFlight`.

- [ ] **Step 1: Create the dialog**

Create `lib/presentation/screens/settings/widgets/tmdb_pending_changes_dialog.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/entities/tmdb_pending_change.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';

class TmdbPendingChangesDialog extends ConsumerWidget {
  const TmdbPendingChangesDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(tmdbPendingChangesProvider);
    final progress = ref.watch(tmdbPushProgressProvider);

    return PopScope(
      canPop: !progress.inFlight,
      child: AlertDialog(
        title: const Text('Pending TMDB changes'),
        content: SizedBox(
          width: 480,
          child: pendingAsync.when(
            loading: () => const SizedBox(
                height: 60,
                child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text('Error loading pending changes: $e'),
            data: (pending) {
              final failed = pending.where((p) => p.hasFailed).toList();
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text('${pending.length} pending '
                          '(${failed.length} failed)'),
                    ),
                    if (failed.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry all failed'),
                        onPressed: progress.inFlight
                            ? null
                            : () => _retryAllFailed(ref, failed),
                      ),
                  ]),
                  if (progress.inFlight) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                        value: progress.total == 0
                            ? null
                            : progress.current / progress.total),
                    const SizedBox(height: 4),
                    Text('Pushing ${progress.current} of ${progress.total}…'),
                  ],
                  const SizedBox(height: 12),
                  if (pending.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('All caught up — no pending changes.'),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: pending.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, i) => _PendingChangeTile(
                          change: pending[i],
                          onRetry: progress.inFlight
                              ? null
                              : () => _retryOne(ref, pending[i]),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: progress.inFlight
                  ? null
                  : () => Navigator.of(context).pop(),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _retryAllFailed(
      WidgetRef ref, List<TmdbPendingChange> failed) async {
    final keys = failed
        .map((p) => TmdbBridgeKey(tmdbId: p.tmdbId, mediaType: p.mediaType))
        .toList();
    await ref.read(retryPushUseCaseProvider).retry(keys);
  }

  Future<void> _retryOne(WidgetRef ref, TmdbPendingChange change) async {
    final key = TmdbBridgeKey(
        tmdbId: change.tmdbId, mediaType: change.mediaType);
    await ref.read(retryPushUseCaseProvider).retryOne(key);
  }
}

class _PendingChangeTile extends StatelessWidget {
  const _PendingChangeTile({required this.change, required this.onRetry});

  final TmdbPendingChange change;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(change.title ?? 'Untitled (TMDB id ${change.tmdbId})'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (change.actions.isEmpty)
            const Text('Pending change',
                style: TextStyle(fontStyle: FontStyle.italic))
          else
            Wrap(spacing: 6, runSpacing: 4, children: [
              for (final a in change.actions) _actionChip(a),
            ]),
          if (change.lastError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                change.lastError!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12),
              ),
            ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.refresh),
        tooltip: 'Retry this change',
        onPressed: onRetry,
      ),
    );
  }

  Widget _actionChip(TmdbPendingAction action) {
    final label = switch (action) {
      TmdbPendingActionRating(:final value) =>
        'Rating ${value.toStringAsFixed(1)}★',
      TmdbPendingActionWatchlist() => 'On watchlist',
      TmdbPendingActionFavourite() => 'Favourited',
    };
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze lib/presentation/screens/settings/widgets/tmdb_pending_changes_dialog.dart`
Expected: zero issues.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/screens/settings/widgets/tmdb_pending_changes_dialog.dart
git commit -m "feat(tmdb-sync): add TmdbPendingChangesDialog with per-row retry"
```

---

## Task 7: Widget tests for the new dialog

**Files:** Create: `test/widget/screens/settings/widgets/tmdb_pending_changes_dialog_test.dart`

- [ ] **Step 1: Write the tests**

Create `test/widget/screens/settings/widgets/tmdb_pending_changes_dialog_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/entities/tmdb_pending_change.dart';
import 'package:mymediascanner/domain/entities/tmdb_push_progress.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/retry_push_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_pending_changes_dialog.dart';

class _MockUseCase extends Mock implements RetryPushUseCase {}

void main() {
  late _MockUseCase useCase;

  setUp(() {
    useCase = _MockUseCase();
    when(() => useCase.retry(any()))
        .thenAnswer((_) async => const TmdbPushSummary(
              attempted: 0,
              succeeded: 0,
              failed: 0,
            ));
    when(() => useCase.retryOne(any()))
        .thenAnswer((_) async => const TmdbPushResult(success: true));
  });

  TmdbPendingChange change({
    required int id,
    String? error,
  }) =>
      TmdbPendingChange(
        tmdbId: id,
        mediaType: 'movie',
        title: 'Movie $id',
        actions: const [TmdbPendingAction.watchlist()],
        lastPushedAt: null,
        lastError: error,
      );

  Widget wrap(List<TmdbPendingChange> rows, {TmdbPushProgress? progress}) {
    return ProviderScope(
      overrides: [
        tmdbPendingChangesProvider.overrideWith((_) => Stream.value(rows)),
        tmdbPushProgressProvider.overrideWith(() {
          final n = TmdbPushProgressNotifier();
          if (progress != null) {
            // Coerce the initial state.
            return _ProgressOverride(progress);
          }
          return n;
        }),
        retryPushUseCaseProvider.overrideWithValue(useCase),
      ],
      child: const MaterialApp(
        home: Scaffold(body: TmdbPendingChangesDialog()),
      ),
    );
  }

  testWidgets('renders empty state when no rows', (tester) async {
    await tester.pumpWidget(wrap(const []));
    await tester.pumpAndSettle();
    expect(find.text('All caught up — no pending changes.'),
        findsOneWidget);
  });

  testWidgets('renders one tile per pending change', (tester) async {
    await tester.pumpWidget(wrap([change(id: 1), change(id: 2)]));
    await tester.pumpAndSettle();
    expect(find.text('Movie 1'), findsOneWidget);
    expect(find.text('Movie 2'), findsOneWidget);
  });

  testWidgets('shows error excerpt when lastError is set',
      (tester) async {
    await tester.pumpWidget(wrap([change(id: 1, error: 'boom')]));
    await tester.pumpAndSettle();
    expect(find.text('boom'), findsOneWidget);
  });

  testWidgets('Retry all failed is shown only when failures exist',
      (tester) async {
    await tester.pumpWidget(wrap([change(id: 1)]));
    await tester.pumpAndSettle();
    expect(find.text('Retry all failed'), findsNothing);

    await tester.pumpWidget(wrap([change(id: 1, error: 'boom')]));
    await tester.pumpAndSettle();
    expect(find.text('Retry all failed'), findsOneWidget);
  });

  testWidgets('tapping per-row retry calls useCase.retryOne',
      (tester) async {
    await tester.pumpWidget(wrap([change(id: 42)]));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Retry this change'));
    await tester.pumpAndSettle();
    verify(() => useCase.retryOne(
            const TmdbBridgeKey(tmdbId: 42, mediaType: 'movie')))
        .called(1);
  });

  setUpAll(() {
    registerFallbackValue(<TmdbBridgeKey>[]);
    registerFallbackValue(
        const TmdbBridgeKey(tmdbId: 0, mediaType: 'movie'));
  });
}

/// Notifier that returns a fixed initial state for tests that want to
/// pretend a push is already in flight (or already idle, etc).
class _ProgressOverride extends TmdbPushProgressNotifier {
  _ProgressOverride(this._initial);
  final TmdbPushProgress _initial;

  @override
  TmdbPushProgress build() => _initial;
}
```

- [ ] **Step 2: Run the new tests**

Run: `flutter test test/widget/screens/settings/widgets/tmdb_pending_changes_dialog_test.dart`
Expected: 5/5 pass.

- [ ] **Step 3: Run analyzer**

Run: `flutter analyze test/widget/screens/settings/widgets/tmdb_pending_changes_dialog_test.dart`
Expected: zero issues.

- [ ] **Step 4: Commit**

```bash
git add test/widget/screens/settings/widgets/tmdb_pending_changes_dialog_test.dart
git commit -m "test(tmdb-sync): cover TmdbPendingChangesDialog rendering + per-row retry"
```

---

## Task 8: Settings card — replace single row with two-row layout

**Files:** Modify: `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart`

- [ ] **Step 1: Read the file**

Read `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart`. The current pending-row block is around lines 98–126 (inside the `Column` children).

- [ ] **Step 2: Replace the pending-row block**

Find this block:

```dart
ref.watch(tmdbDirtyCountProvider).when(
  loading: () => const SizedBox.shrink(),
  error: (_, stack) => const SizedBox.shrink(),
  data: (count) {
    if (count == 0) return const SizedBox.shrink();
    return Row(children: [
      Icon(Icons.cloud_upload,
          size: 16,
          color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 6),
      Expanded(
          child: Text('$count pending change'
              '${count == 1 ? '' : 's'} to push')),
      TextButton.icon(
        icon: const Icon(Icons.sync, size: 16),
        label: const Text('Push pending now'),
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final summary =
              await ref.read(pushTmdbChangeUseCaseProvider).all();
          messenger.showSnackBar(SnackBar(
            content: Text('Pushed ${summary.succeeded} of '
                '${summary.attempted}; ${summary.failed} failed.'),
          ));
        },
      ),
    ]);
  },
),
```

Replace it with:

```dart
// Pending row — non-conflict dirty changes.
ref.watch(tmdbPendingChangesProvider).when(
  loading: () => const SizedBox.shrink(),
  error: (_, _) => const SizedBox.shrink(),
  data: (pending) {
    if (pending.isEmpty) return const SizedBox.shrink();
    return Row(children: [
      Icon(Icons.cloud_upload,
          size: 16,
          color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 6),
      Expanded(
          child: Text('${pending.length} pending change'
              '${pending.length == 1 ? '' : 's'} to push')),
      TextButton.icon(
        icon: const Icon(Icons.list, size: 16),
        label: const Text('View & retry'),
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const TmdbPendingChangesDialog(),
        ),
      ),
      const SizedBox(width: 4),
      TextButton.icon(
        icon: const Icon(Icons.sync, size: 16),
        label: const Text('Push all now'),
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final keys = pending
              .map((p) => TmdbBridgeKey(
                  tmdbId: p.tmdbId, mediaType: p.mediaType))
              .toList();
          final summary =
              await ref.read(retryPushUseCaseProvider).retry(keys);
          if (!context.mounted) return;
          messenger.showSnackBar(SnackBar(
            content: Text('Pushed ${summary.succeeded} of '
                '${summary.attempted}; ${summary.failed} failed.'),
          ));
        },
      ),
    ]);
  },
),
// Conflict row — only when at least one conflict exists.
ref.watch(tmdbConflictCountProvider).when(
  loading: () => const SizedBox.shrink(),
  error: (_, _) => const SizedBox.shrink(),
  data: (count) {
    if (count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(children: [
        Icon(Icons.warning_amber,
            size: 16,
            color: Theme.of(context).colorScheme.error),
        const SizedBox(width: 6),
        Expanded(
            child: Text('$count conflict'
                '${count == 1 ? '' : 's'} need resolution')),
        TextButton.icon(
          icon: const Icon(Icons.rule, size: 16),
          label: const Text('Resolve'),
          onPressed: () => context.go('/tmdb/conflicts'),
        ),
      ]),
    );
  },
),
```

Add the imports at the top of the file (if not already present):

```dart
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_pending_changes_dialog.dart';
```

(Note: `tmdbDirtyCountProvider` may now have no callers. Don't remove it — slice 4e leaves the provider in place; the disconnect-warning dialog still uses it via `dirtyCount` and there may be other readers. Only the inline UI usage moves.)

- [ ] **Step 3: Run analyzer**

Run: `flutter analyze lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart`
Expected: zero issues. If a `go_router` import is already present, the linter will complain — drop the duplicate.

- [ ] **Step 4: Run the full test suite (regression)**

Run: `flutter test`
Expected: all tests pass. The settings card has tests in this codebase — they may need provider overrides if they previously read `tmdbDirtyCountProvider`. If a test fails because it overrode `tmdbDirtyCountProvider` and now needs to override `tmdbPendingChangesProvider` instead, update the override (don't change production). Report DONE_WITH_CONCERNS if more than two test files need touching, and list them.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart
git commit -m "feat(tmdb-sync): two-row pending/conflict surface + new dialog launch"
```

---

## Task 9: User docs

**Files:** Modify: `src/docs/modules/ROOT/pages/tmdb-account-sync.adoc`

- [ ] **Step 1: Find the section that documents pending-change pushing**

Open `src/docs/modules/ROOT/pages/tmdb-account-sync.adoc`. Find the section about "Push pending now" / two-way sync (likely around the *Two-Way Sync* heading near line 90).

- [ ] **Step 2: Append a subsection**

Add at the end of the relevant section:

```adoc
=== Reviewing and retrying pending changes

When the *TMDB Account Sync* settings card shows pending changes, two affordances appear next to the count:

* *View & retry* opens a dialog listing each pending change with its title, the action(s) it represents (rating, watchlist, favourite), and any error from the previous push attempt.
  Tap the refresh icon on a row to retry just that change, or *Retry all failed* in the dialog header to retry every row whose previous push failed.
* *Push all now* is the quick-fire equivalent — it pushes every pending change in one go and reports the result via a SnackBar.

While a push is running, the dialog shows a determinate progress bar (`Pushing X of Y…`) and cannot be dismissed until the operation completes.

Conflict rows — bridge rows that need user resolution because the local and remote values diverged — are surfaced in a separate row below the pending count: *N conflict(s) need resolution* with a *Resolve* button that opens the dedicated conflict resolution screen.
```

Match the existing British-spelling, calm-instructional tone.

- [ ] **Step 3: Validate the Antora build**

Run: `npx antora local-antora-playbook-search.yml`
Expected: clean exit.

- [ ] **Step 4: Commit**

```bash
git add src/docs/modules/ROOT/pages/tmdb-account-sync.adoc
git commit -m "docs: document pending-changes dialog and conflict surfacing"
```

---

## Task 10: Final verification

**Files:** none (read-only)

- [ ] **Step 1: Branch + HEAD check**

Run: `git branch --show-current` — must be `feat/tmdb-account-sync-slice-4e-bulk-push-retry`.
Run: `git log --oneline main..HEAD` — confirm 11 commits (1 spec + 1 plan + 9 task commits).

- [ ] **Step 2: Analyzer**

Run: `flutter analyze`
Expected: zero issues.

- [ ] **Step 3: Test suite**

Run: `flutter test`
Expected: all pass. Slice 4d landed at 1414 passing; this slice adds ~13 (entity 6 + use case 5 + DAO 2 + dialog 5) → expect ~1427 passing.

- [ ] **Step 4: Linux build**

Run: `flutter build linux --debug`
Expected: succeeds.

- [ ] **Step 5: Android build**

Run: `flutter build apk --debug --flavor dev`
Expected: succeeds.

- [ ] **Step 6: iOS / macOS**

Skip on Linux host. Document as `SKIPPED (host is Linux)`.

- [ ] **Step 7: Manual inspection**

Read each of:

1. `lib/domain/entities/tmdb_pending_change.dart` — sealed action union + `derivePendingActions` helper.
2. `lib/domain/entities/tmdb_push_progress.dart` — value type with `idle()` factory.
3. `lib/domain/usecases/retry_push_usecase.dart` — `retry`, `retryOne`, callback-based progress, try/finally.
4. `lib/data/local/dao/tmdb_account_sync_dao.dart` — new `watchPendingDirty()`.
5. `lib/presentation/providers/tmdb_account_sync_provider.dart` — three new providers + notifier.
6. `lib/presentation/providers/repository_providers.dart` — `retryPushUseCaseProvider`.
7. `lib/presentation/screens/settings/widgets/tmdb_pending_changes_dialog.dart` — header progress, list of tiles, PopScope guard.
8. `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart` — two-row pending/conflict surface, `View & retry` + `Push all now` buttons, `Resolve` link.
9. `src/docs/modules/ROOT/pages/tmdb-account-sync.adoc` — new subsection.
10. No new files outside the listed paths. No schema migration. No conflict-screen changes.

- [ ] **Step 8: Final report**

```
Branch: feat/tmdb-account-sync-slice-4e-bulk-push-retry
HEAD: <SHA>
Commits since main: <count>
Test results: <count> passed
Linux build: <PASS/FAIL>
Android build: <PASS/FAIL>
iOS build: SKIPPED (Linux host)
macOS build: SKIPPED (Linux host)
Manual inspection: PASS / FAIL with notes

Concerns or follow-up: <list any>
```

Status: DONE / DONE_WITH_CONCERNS.

---

## Self-review

- **Spec coverage:** entity (Task 1), progress type (Task 2), use case (Task 3), DAO query (Task 4), providers (Task 5), dialog widget (Task 6), dialog tests (Task 7), settings card (Task 8), docs (Task 9), verification (Task 10). The simplification noted during plan-writing (action chips derived from current bridge fields, not snapshot diffs) is documented in Task 1 and the Convention notes section.
- **Placeholder scan:** no `TBD`, `TODO`, or `implement later`. Every step has the actual code or command.
- **Type consistency:** `TmdbPendingChange`, `TmdbPendingAction` (+ three concrete classes), `TmdbPushProgress`, `TmdbPushProgressNotifier`, `RetryPushUseCase`, `TmdbBridgeKey`, `tmdbPendingChangesProvider`, `tmdbConflictCountProvider`, `tmdbPushProgressProvider`, `retryPushUseCaseProvider` — all named consistently across tasks.
- **Test coverage:** parser-style entity tests (6), use-case tests (5), DAO query tests (2), widget tests (5). Hits all branches: empty, success, mixed, throw, retry-one. Hits the gate logic: filter by `localDirty`, exclude conflicts, order by `updatedAt`.
- **No backend behaviour change:** `pushOne()` is reused as-is. The new use case wraps it; the new DAO query is purely a filter. Conflict resolution flow is untouched.
- **The plan does NOT reach inside `media_items`:** titles come from `titleSnapshot` on the bridge row. The spec considered an in-memory join but the plan locks in the simpler approach because `titleSnapshot` is populated whenever a row is pulled or imported, which covers the practical case.
