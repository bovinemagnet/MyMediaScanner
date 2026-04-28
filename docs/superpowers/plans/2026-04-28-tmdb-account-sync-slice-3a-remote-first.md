# TMDB Account Sync — Slice 3a (Remote-First Save Mode) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add remote-first save mode for film/TV — users can save scanned or manually-added titles as TMDB-only bridge rows (no local `media_items` entry) via a Settings opt-in toggle and a three-option save selector on the metadata-confirm and manual-add screens.

**Architecture:** Extend `TmdbBridgeBucket` with a 4th `saved` value to surface orphan bridge rows. Add `SaveTmdbOnlyUseCase` that creates a bridge row directly. Add a Settings toggle with confirmation dialog. Add a three-radio selector to the existing save screens; dispatch to the new use case when the user picks "TMDB only". Reuse the existing slice-A `TmdbBucketScreen` for the new bucket view. New `/tmdb/saved` route + conditional sidebar entry.

**Tech Stack:** Flutter, Drift (no schema migration), Riverpod 3, GoRouter (existing routes + 1 new), mocktail.

**Source spec:** `docs/superpowers/specs/2026-04-28-tmdb-account-sync-slice-3a-remote-first-design.md`

---

## File Layout

### Create

| Path | Responsibility |
|---|---|
| `lib/domain/usecases/save_tmdb_only_usecase.dart` | Creates a bridge row with `media_item_id = null` and no flags. Returns the bridge row id. |
| `lib/presentation/screens/metadata_confirm/widgets/remote_first_save_mode_selector.dart` | Three-radio widget with `SaveMode` enum. Embedded on metadata-confirm and manual-add. |
| `lib/presentation/screens/settings/widgets/remote_first_warning_dialog.dart` | First-flip-on confirmation dialog with PRD warning text. |
| `test/unit/domain/usecases/save_tmdb_only_usecase_test.dart` | Unit tests for happy path + idempotent re-save + media-type guard. |
| `test/widget/screens/metadata_confirm/widgets/remote_first_save_mode_selector_test.dart` | Visibility gating + selection callback. |
| `test/widget/screens/settings/widgets/remote_first_warning_dialog_test.dart` | Confirm/cancel return values. |

### Modify

| Path | Change |
|---|---|
| `lib/domain/entities/tmdb_bridge_bucket.dart` | Add `saved` enum value. |
| `lib/data/local/dao/tmdb_account_sync_dao.dart` | Extend `listByBucket`/`watchByBucket` switch arms for `saved` bucket. |
| `test/unit/data/local/dao/tmdb_account_sync_dao_test.dart` | Add tests for the saved bucket filter. |
| `lib/presentation/providers/settings_provider.dart` | Add `remoteFirstSaveEnabled` field on `TmdbAccountSyncSettings`, setter on the notifier, SharedPreferences key. |
| `lib/presentation/providers/repository_providers.dart` | Register `saveTmdbOnlyUseCaseProvider`. |
| `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart` | Add a 3rd toggle "Allow remote-first save (film/TV)" with warning-dialog hook. |
| `lib/presentation/screens/settings/widgets/tmdb_lists_section.dart` | Add a 4th tile "TMDB Saved (N)" gated on bucket count > 0. |
| `lib/presentation/screens/metadata_confirm/metadata_confirm_screen.dart` | Embed selector + branch on selected mode at save time. |
| `lib/presentation/screens/manual_add/manual_add_screen.dart` | Same. |
| `lib/presentation/screens/tmdb/tmdb_bucket_screen.dart` | Add `saved` to title/empty-message switch. |
| `lib/app/router.dart` | Add `/tmdb/saved` route as a new shell branch (positioned before the slice-2 resolve-conflicts branch). |
| `lib/presentation/widgets/app_scaffold.dart` | Add 4th conditional TMDB sidebar entry; update branch-index mapping comment. |
| `integration_test/tmdb_account_sync_test.dart` | Add a test for the save-tmdb-only round-trip. |

---

## Convention notes

- `TmdbBridgeBucket` is a Dart enum with British spelling for `favourite`. Adding a new value requires updating every exhaustive `switch` over the enum (DAO, bucket screen title/empty-message). The Dart compiler will flag missing cases.
- The DAO's `_dropPresent` upsert pattern means `SaveTmdbOnlyUseCase` writes only the columns it sets; everything else stays absent.
- Settings widgets follow the slice-2 pattern: state is derived from `tmdbAccountSyncSettingsProvider`, mutations go through the notifier's setters.
- Branch order matters: the new `/tmdb/saved` route is positioned at branch index 15 (replacing slice-2's resolve-conflicts at 15, which becomes 16). The sidebar entries follow the same order so the identity mapping holds.

---

## Task 1: Add `TmdbBridgeBucket.saved` enum value

**Files:**
- Modify: `lib/domain/entities/tmdb_bridge_bucket.dart`

- [ ] **Step 1: Add the new enum value**

In `lib/domain/entities/tmdb_bridge_bucket.dart`, change:

```dart
enum TmdbBridgeBucket { watchlist, rated, favourite }
```

to:

```dart
enum TmdbBridgeBucket { watchlist, rated, favourite, saved }
```

(Slice 3a is the first task to update this file. The `TmdbBridgeKey` class below the enum is unchanged.)

- [ ] **Step 2: Run analyzer to find missing switch cases**

Run: `flutter analyze`
Expected: at minimum 2 `non_exhaustive_switch` errors (DAO bucket switches in `tmdb_account_sync_dao.dart`) and 2 in `tmdb_bucket_screen.dart` (title + empty-message). Possibly more in other consumers. List them — Tasks 2 and 8 will fix them.

This step intentionally produces analyzer errors; we'll fix each in its own task. Don't address them here.

- [ ] **Step 3: Commit**

Verify branch is `feat/tmdb-account-sync-slice-3a-remote-first` via `git branch --show-current`.

```bash
git add lib/domain/entities/tmdb_bridge_bucket.dart
git commit -m "feat(tmdb-sync): add TmdbBridgeBucket.saved enum value"
```

The branch will have analyzer errors after this commit until Tasks 2 and 8 land. That's intentional — incremental commits — but stage all three before pushing.

Verify `git rev-parse feat/tmdb-account-sync-slice-3a-remote-first` == `git rev-parse HEAD`.

---

## Task 2: Extend DAO `listByBucket` / `watchByBucket` for the saved bucket

**Files:**
- Modify: `lib/data/local/dao/tmdb_account_sync_dao.dart`
- Modify: `test/unit/data/local/dao/tmdb_account_sync_dao_test.dart`

- [ ] **Step 1: Write failing tests**

Append to `test/unit/data/local/dao/tmdb_account_sync_dao_test.dart`:

```dart
test('listByBucket(saved) returns orphan bridge rows only', () async {
  // Orphan: no flags, no rating, no media-item link.
  await db.tmdbAccountSyncDao.upsertByTmdbId(
    TmdbAccountSyncItemsTableCompanion(
      id: const Value('orphan'),
      tmdbId: const Value(1),
      tmdbMediaType: const Value('movie'),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );
  // Watchlisted — should NOT appear in saved bucket.
  await db.tmdbAccountSyncDao.upsertByTmdbId(
    TmdbAccountSyncItemsTableCompanion(
      id: const Value('wl'),
      tmdbId: const Value(2),
      tmdbMediaType: const Value('movie'),
      watchlist: const Value(true),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );
  // Rated — should NOT appear in saved bucket.
  await db.tmdbAccountSyncDao.upsertByTmdbId(
    TmdbAccountSyncItemsTableCompanion(
      id: const Value('rt'),
      tmdbId: const Value(3),
      tmdbMediaType: const Value('movie'),
      tmdbRating: const Value(8.0),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );
  // Favourited — should NOT appear in saved bucket.
  await db.tmdbAccountSyncDao.upsertByTmdbId(
    TmdbAccountSyncItemsTableCompanion(
      id: const Value('fv'),
      tmdbId: const Value(4),
      tmdbMediaType: const Value('movie'),
      favorite: const Value(true),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );
  // Linked to local item — should NOT appear in any bucket view.
  await db.tmdbAccountSyncDao.upsertByTmdbId(
    TmdbAccountSyncItemsTableCompanion(
      id: const Value('linked'),
      tmdbId: const Value(5),
      tmdbMediaType: const Value('movie'),
      mediaItemId: const Value('mi-1'),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );

  final saved = await db.tmdbAccountSyncDao
      .listByBucket(TmdbBridgeBucket.saved);
  expect(saved.map((r) => r.tmdbId), [1]);
});

test('listByBucket(saved) excludes a row that gains a flag', () async {
  await db.tmdbAccountSyncDao.upsertByTmdbId(
    TmdbAccountSyncItemsTableCompanion(
      id: const Value('a'),
      tmdbId: const Value(1),
      tmdbMediaType: const Value('movie'),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );
  expect(
      (await db.tmdbAccountSyncDao.listByBucket(TmdbBridgeBucket.saved))
          .length,
      1);

  // Flip watchlist on.
  await db.tmdbAccountSyncDao.upsertByTmdbId(
    const TmdbAccountSyncItemsTableCompanion(
      tmdbId: Value(1),
      tmdbMediaType: Value('movie'),
      watchlist: Value(true),
    ),
  );
  expect(
      (await db.tmdbAccountSyncDao.listByBucket(TmdbBridgeBucket.saved)),
      isEmpty);
  expect(
      (await db.tmdbAccountSyncDao
              .listByBucket(TmdbBridgeBucket.watchlist))
          .length,
      1);
});
```

- [ ] **Step 2: Run tests (will fail)**

Run: `flutter test test/unit/data/local/dao/tmdb_account_sync_dao_test.dart`
Expected: FAIL — `listByBucket` switch is not exhaustive for `TmdbBridgeBucket.saved` (Dart compile error).

- [ ] **Step 3: Add the `saved` switch arm**

In `lib/data/local/dao/tmdb_account_sync_dao.dart`, find both `listByBucket` and `watchByBucket`. Each has a `switch (bucket)` with cases for `watchlist`, `favourite`, `rated`. Append a `saved` case to each:

```dart
case TmdbBridgeBucket.saved:
  query.where((t) =>
      t.watchlist.equals(false) &
      t.favorite.equals(false) &
      t.tmdbRating.isNull());
```

Both methods get the identical case clause (the base `mediaItemId.isNull()` filter is already applied above the switch).

- [ ] **Step 4: Run tests**

Run: `flutter test test/unit/data/local/dao/tmdb_account_sync_dao_test.dart`
Expected: 13/13 pass (slice 2 baseline 11 + 2 new).

- [ ] **Step 5: Run analyzer**

Run: `flutter analyze lib/data/local/dao/tmdb_account_sync_dao.dart`
Expected: zero issues. The DAO's switch is now exhaustive.

- [ ] **Step 6: Commit**

```bash
git add lib/data/local/dao/tmdb_account_sync_dao.dart \
        test/unit/data/local/dao/tmdb_account_sync_dao_test.dart
git commit -m "feat(tmdb-sync): extend DAO bucket queries for saved bucket"
```

Verify branch + HEAD match.

---

## Task 3: SaveTmdbOnlyUseCase

**Files:**
- Create: `lib/domain/usecases/save_tmdb_only_usecase.dart`
- Create: `test/unit/domain/usecases/save_tmdb_only_usecase_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/unit/domain/usecases/save_tmdb_only_usecase_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/local/dao/tmdb_account_sync_dao.dart';
import 'package:mymediascanner/data/repositories/tmdb_account_sync_repository_impl.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_account_api.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/usecases/save_tmdb_only_usecase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class _MockApi extends Mock implements TmdbAccountApi {}
class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AppDatabase db;
  late TmdbAccountSyncDao dao;
  late TmdbAccountSyncRepositoryImpl repo;
  late SaveTmdbOnlyUseCase useCase;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.tmdbAccountSyncDao;
    repo = TmdbAccountSyncRepositoryImpl(
      api: _MockApi(),
      dao: dao,
      mediaItemsDao: db.mediaItemsDao,
      storage: _MockStorage(),
    );
    useCase = SaveTmdbOnlyUseCase(repo);
  });

  tearDown(() async => db.close());

  test('creates a bridge row with no media_item_id and no flags', () async {
    await useCase(
      tmdbId: 550,
      mediaType: 'movie',
      title: 'Fight Club',
      posterPath: '/poster.jpg',
      barcode: '5051892002172',
    );

    final row = await dao.getByTmdbId(550, 'movie');
    expect(row, isNotNull);
    expect(row!.mediaItemId, isNull);
    expect(row.watchlist, isFalse);
    expect(row.favorite, isFalse);
    expect(row.tmdbRating, isNull);
    expect(row.titleSnapshot, 'Fight Club');
    expect(row.posterPathSnapshot, '/poster.jpg');
    expect(row.barcode, '5051892002172');
    expect(row.localDirty, isFalse);
  });

  test('appears in TmdbBridgeBucket.saved', () async {
    await useCase(
      tmdbId: 550,
      mediaType: 'movie',
      title: 'Fight Club',
      posterPath: null,
      barcode: null,
    );
    final saved = await dao.listByBucket(TmdbBridgeBucket.saved);
    expect(saved.length, 1);
    expect(saved.first.tmdbId, 550);
  });

  test('idempotent: re-saving same tmdbId merges into the existing row',
      () async {
    await useCase(
      tmdbId: 550,
      mediaType: 'movie',
      title: 'Fight Club',
      posterPath: '/p1.jpg',
      barcode: null,
    );
    await useCase(
      tmdbId: 550,
      mediaType: 'movie',
      title: 'Fight Club',
      posterPath: '/p2.jpg',
      barcode: null,
    );

    final all = await (db.select(db.tmdbAccountSyncItemsTable)).get();
    expect(all.length, 1);
    expect(all.first.posterPathSnapshot, '/p2.jpg',
        reason: 'second call updates the snapshot');
  });

  test('throws on unsupported media type', () async {
    expect(
      () => useCase(
        tmdbId: 1,
        mediaType: 'music',
        title: 't',
        posterPath: null,
        barcode: null,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
```

- [ ] **Step 2: Run tests (will fail)**

Run: `flutter test test/unit/domain/usecases/save_tmdb_only_usecase_test.dart`
Expected: FAIL — `SaveTmdbOnlyUseCase` does not exist.

- [ ] **Step 3: Implement the use case**

Create `lib/domain/usecases/save_tmdb_only_usecase.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

/// Saves a movie or TV title as a TMDB-only bridge row, with no
/// `media_items` entry. The bridge row has no flags set and no rating;
/// the user can later toggle watchlist / favourite / rate via the
/// existing slice-2 use cases, or convert to a local item via
/// `ConvertBridgeToLocalItemUseCase`.
///
/// Throws `ArgumentError` for media types other than `'movie'` or `'tv'`.
class SaveTmdbOnlyUseCase {
  SaveTmdbOnlyUseCase(this.repo);

  final ITmdbAccountSyncRepository repo;

  Future<void> call({
    required int tmdbId,
    required String mediaType,
    required String title,
    required String? posterPath,
    required String? barcode,
  }) async {
    if (mediaType != 'movie' && mediaType != 'tv') {
      throw ArgumentError.value(mediaType, 'mediaType',
          'Remote-first save only supports movie or tv');
    }
    await repo.upsertBridge(
      TmdbAccountSyncItemsTableCompanion(
        tmdbId: Value(tmdbId),
        tmdbMediaType: Value(mediaType),
        titleSnapshot: Value(title),
        posterPathSnapshot:
            posterPath == null ? const Value.absent() : Value(posterPath),
        barcode: barcode == null ? const Value.absent() : Value(barcode),
      ),
    );
  }
}
```

The use case calls `repo.upsertBridge(...)` — a thin pass-through that the repository will expose for direct bridge-row writes (no API call, no push). We need to add this method.

- [ ] **Step 4: Add `upsertBridge` to the repository interface and implementation**

In `lib/domain/repositories/i_tmdb_account_sync_repository.dart`, add a new section under "Slice 3a — remote-first save":

```dart
// ── Slice 3a — remote-first save ───────────────────────────────

/// Direct-write bridge upsert without any API call. Used by
/// `SaveTmdbOnlyUseCase` for remote-first saves where the bridge row
/// is the persisted state.
Future<void> upsertBridge(TmdbAccountSyncItemsTableCompanion companion);
```

Add the import for `TmdbAccountSyncItemsTableCompanion` at top:

```dart
import 'package:mymediascanner/data/local/database/app_database.dart';
```

In `lib/data/repositories/tmdb_account_sync_repository_impl.dart`, add the implementation:

```dart
@override
Future<void> upsertBridge(
    TmdbAccountSyncItemsTableCompanion companion) async {
  await dao.upsertByTmdbId(companion);
}
```

- [ ] **Step 5: Run tests**

Run: `flutter test test/unit/domain/usecases/save_tmdb_only_usecase_test.dart`
Expected: 4/4 pass.

- [ ] **Step 6: Run repository tests to make sure no regression**

Run: `flutter test test/unit/data/repositories/tmdb_account_sync_repository_impl_test.dart`
Expected: 11/11 still pass.

- [ ] **Step 7: Run analyzer**

Run: `flutter analyze lib/domain/ lib/data/repositories/`
Expected: zero issues.

- [ ] **Step 8: Commit**

```bash
git add lib/domain/usecases/save_tmdb_only_usecase.dart \
        lib/domain/repositories/i_tmdb_account_sync_repository.dart \
        lib/data/repositories/tmdb_account_sync_repository_impl.dart \
        test/unit/domain/usecases/save_tmdb_only_usecase_test.dart
git commit -m "feat(tmdb-sync): add SaveTmdbOnlyUseCase + repo upsertBridge"
```

---

## Task 4: Settings — `remoteFirstSaveEnabled` field + setter

**Files:**
- Modify: `lib/presentation/providers/settings_provider.dart`

- [ ] **Step 1: Extend `TmdbAccountSyncSettings`**

In `lib/presentation/providers/settings_provider.dart`, find the `TmdbAccountSyncSettings` class. Add a new field `remoteFirstSaveEnabled` (default false) and update the constructor + `copyWith`.

The full class should look like:

```dart
class TmdbAccountSyncSettings {
  const TmdbAccountSyncSettings({
    this.enabled = false,
    this.enrichScans = true,
    this.twoWaySync = true,
    this.mirrorOwnership = false,
    this.remoteFirstSaveEnabled = false,
    this.conflictPolicy = TmdbConflictPolicy.preferLatestTimestamp,
    this.lastSyncAt,
    this.lastSyncPulled = 0,
    this.lastSyncFailed = 0,
    this.lastError,
  });

  final bool enabled;
  final bool enrichScans;
  final bool twoWaySync;
  final bool mirrorOwnership;
  final bool remoteFirstSaveEnabled;
  final TmdbConflictPolicy conflictPolicy;
  final DateTime? lastSyncAt;
  final int lastSyncPulled;
  final int lastSyncFailed;
  final String? lastError;

  TmdbAccountSyncSettings copyWith({
    bool? enabled,
    bool? enrichScans,
    bool? twoWaySync,
    bool? mirrorOwnership,
    bool? remoteFirstSaveEnabled,
    TmdbConflictPolicy? conflictPolicy,
    DateTime? lastSyncAt,
    int? lastSyncPulled,
    int? lastSyncFailed,
    String? lastError,
    bool clearLastError = false,
  }) =>
      TmdbAccountSyncSettings(
        enabled: enabled ?? this.enabled,
        enrichScans: enrichScans ?? this.enrichScans,
        twoWaySync: twoWaySync ?? this.twoWaySync,
        mirrorOwnership: mirrorOwnership ?? this.mirrorOwnership,
        remoteFirstSaveEnabled:
            remoteFirstSaveEnabled ?? this.remoteFirstSaveEnabled,
        conflictPolicy: conflictPolicy ?? this.conflictPolicy,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        lastSyncPulled: lastSyncPulled ?? this.lastSyncPulled,
        lastSyncFailed: lastSyncFailed ?? this.lastSyncFailed,
        lastError: clearLastError ? null : (lastError ?? this.lastError),
      );
}
```

- [ ] **Step 2: Add the SharedPreferences key + setter on the notifier**

In the `TmdbAccountSyncSettingsNotifier` class, add a new constant near the existing ones:

```dart
static const _kRemoteFirst = 'tmdb.account_sync.remote_first_save_enabled';
```

Update `_load` to read the new key:

```dart
state = TmdbAccountSyncSettings(
  enabled: p.getBool(_kEnabled) ?? false,
  enrichScans: p.getBool(_kEnrichScans) ?? true,
  twoWaySync: p.getBool(_kTwoWay) ?? true,
  mirrorOwnership: p.getBool(_kMirror) ?? false,
  remoteFirstSaveEnabled: p.getBool(_kRemoteFirst) ?? false,
  conflictPolicy: TmdbConflictPolicy.fromName(p.getString(_kConflictPolicy)),
  // ... existing fields ...
);
```

Add the setter method:

```dart
Future<void> setRemoteFirstSaveEnabled(bool v) async {
  state = state.copyWith(remoteFirstSaveEnabled: v);
  final p = await SharedPreferences.getInstance();
  await p.setBool(_kRemoteFirst, v);
}
```

- [ ] **Step 3: Run analyzer**

Run: `flutter analyze lib/presentation/providers/settings_provider.dart`
Expected: zero issues.

- [ ] **Step 4: Run the full test suite to catch any unintended regression**

Run: `flutter test test/`
Expected: all tests pass. (Existing tests should not break since the new field has a default.)

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/providers/settings_provider.dart
git commit -m "feat(tmdb-sync): add remoteFirstSaveEnabled setting"
```

---

## Task 5: RemoteFirstWarningDialog

**Files:**
- Create: `lib/presentation/screens/settings/widgets/remote_first_warning_dialog.dart`
- Create: `test/widget/screens/settings/widgets/remote_first_warning_dialog_test.dart`

- [ ] **Step 1: Write failing widget tests**

Create `test/widget/screens/settings/widgets/remote_first_warning_dialog_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/remote_first_warning_dialog.dart';

void main() {
  Future<bool?> _show(WidgetTester tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (_) => const RemoteFirstWarningDialog(),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('Confirm returns true', (tester) async {
    final getResult = _show(tester);
    await tester.tap(find.text('Enable anyway'));
    await tester.pumpAndSettle();
    expect(await getResult, isTrue);
  });

  testWidgets('Cancel returns false', (tester) async {
    final getResult = _show(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await getResult, isFalse);
  });

  testWidgets('Renders the PRD warning text', (tester) async {
    await _show(tester);
    expect(
        find.textContaining('TMDB can store your ratings'),
        findsOneWidget);
    expect(
        find.textContaining('barcode, shelf, location'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run tests (will fail)**

Run: `flutter test test/widget/screens/settings/widgets/remote_first_warning_dialog_test.dart`
Expected: FAIL — `RemoteFirstWarningDialog` does not exist.

- [ ] **Step 3: Implement the dialog**

Create `lib/presentation/screens/settings/widgets/remote_first_warning_dialog.dart`:

```dart
import 'package:flutter/material.dart';

/// First-flip-on confirmation dialog for the "Allow remote-first save"
/// settings toggle. Returns `true` when the user confirms, `false` on
/// cancel.
class RemoteFirstWarningDialog extends StatelessWidget {
  const RemoteFirstWarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enable remote-first save?'),
      content: const Text(
        'TMDB can store your ratings, favourites, watchlist and list '
        'memberships, but it cannot store MyMediaScanner collection '
        'details such as barcode, shelf, location, purchase details, '
        'lending, tags, reviews, or scan history. In remote-first '
        'mode these details are not kept locally and may be '
        'unavailable offline.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Enable anyway'),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/widget/screens/settings/widgets/remote_first_warning_dialog_test.dart`
Expected: 3/3 pass.

- [ ] **Step 5: Run analyzer**

Run: `flutter analyze lib/presentation/screens/settings/widgets/remote_first_warning_dialog.dart test/widget/screens/settings/widgets/remote_first_warning_dialog_test.dart`
Expected: zero issues.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/screens/settings/widgets/remote_first_warning_dialog.dart \
        test/widget/screens/settings/widgets/remote_first_warning_dialog_test.dart
git commit -m "feat(tmdb-sync): add RemoteFirstWarningDialog"
```

---

## Task 6: Wire the toggle into the settings card

**Files:**
- Modify: `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart`

- [ ] **Step 1: Add the import**

At the top of the file, add (alongside other widget imports):

```dart
import 'package:mymediascanner/presentation/screens/settings/widgets/remote_first_warning_dialog.dart';
```

- [ ] **Step 2: Add the toggle row**

Find the existing slice-2 toggles in the section's build method (after "Mirror ownership to TMDB list" SwitchListTile). Insert a third toggle directly after it:

```dart
SwitchListTile(
  title: const Text('Allow remote-first save (film/TV)'),
  subtitle: const Text(
      'Save scanned or added titles to TMDB only — no local collection record.'),
  value: settings.remoteFirstSaveEnabled,
  onChanged: connectionAsync.value is TmdbConnected
      ? (v) => _toggleRemoteFirst(context, ref, v, settings.remoteFirstSaveEnabled)
      : null,
),
```

- [ ] **Step 3: Add the `_toggleRemoteFirst` helper**

At the bottom of the file (alongside any existing top-level helpers like `_disconnectWithCheck`), add:

```dart
Future<void> _toggleRemoteFirst(
  BuildContext context,
  WidgetRef ref,
  bool requested,
  bool currentValue,
) async {
  // First flip-on shows the warning dialog; flip-off is unconditional.
  if (requested && !currentValue) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const RemoteFirstWarningDialog(),
    );
    if (confirmed != true) return;
  }
  await ref
      .read(tmdbAccountSyncSettingsProvider.notifier)
      .setRemoteFirstSaveEnabled(requested);
}
```

The `currentValue` parameter avoids re-prompting the user when they flip OFF then back ON — only the first-flip-on shows the dialog. (The user already saw it once.)

Actually correction: the spec says "First flip-on shows the warning dialog. Cancel keeps it off." Re-prompting on each flip-off-then-flip-on is acceptable and arguably clearer — the user is opting in again. Simpler logic: prompt every time `requested == true && currentValue == false`. That's exactly what the code above does. Keep it.

- [ ] **Step 4: Run analyzer**

Run: `flutter analyze lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart`
Expected: zero issues.

- [ ] **Step 5: Run any settings widget tests to confirm no regression**

Run: `flutter test test/widget/screens/settings/`
Expected: all pass.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart
git commit -m "feat(tmdb-sync): wire remote-first toggle in settings card"
```

---

## Task 7: RemoteFirstSaveModeSelector

**Files:**
- Create: `lib/presentation/screens/metadata_confirm/widgets/remote_first_save_mode_selector.dart`
- Create: `test/widget/screens/metadata_confirm/widgets/remote_first_save_mode_selector_test.dart`

- [ ] **Step 1: Write failing widget tests**

Create `test/widget/screens/metadata_confirm/widgets/remote_first_save_mode_selector_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/remote_first_save_mode_selector.dart';

void main() {
  testWidgets('renders three radio options', (tester) async {
    SaveMode? captured;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RemoteFirstSaveModeSelector(
          value: SaveMode.saveLocally,
          onChanged: (v) => captured = v,
        ),
      ),
    ));
    expect(find.text('Save locally'), findsOneWidget);
    expect(find.text('Save locally and sync to TMDB'), findsOneWidget);
    expect(find.text('TMDB only'), findsOneWidget);
  });

  testWidgets('tapping a radio invokes onChanged with the new value',
      (tester) async {
    SaveMode? captured;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RemoteFirstSaveModeSelector(
          value: SaveMode.saveLocally,
          onChanged: (v) => captured = v,
        ),
      ),
    ));
    await tester.tap(find.text('TMDB only'));
    await tester.pumpAndSettle();
    expect(captured, SaveMode.tmdbOnly);
  });
}
```

- [ ] **Step 2: Run tests (will fail)**

Run: `flutter test test/widget/screens/metadata_confirm/widgets/remote_first_save_mode_selector_test.dart`
Expected: FAIL — class does not exist.

- [ ] **Step 3: Implement the widget**

Create `lib/presentation/screens/metadata_confirm/widgets/remote_first_save_mode_selector.dart`:

```dart
import 'package:flutter/material.dart';

/// Three-option save mode for remote-first-enabled film/TV saves.
enum SaveMode {
  saveLocally,
  saveLocallyAndSync,
  tmdbOnly,
}

/// Radio group letting the user choose between local save, local-and-push,
/// or TMDB-only save when remote-first save mode is enabled.
///
/// Callers must gate this widget on:
///   - account sync is enabled
///   - remote-first toggle is on
///   - the item has a tmdb_id and movie/tv media type
class RemoteFirstSaveModeSelector extends StatelessWidget {
  const RemoteFirstSaveModeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final SaveMode value;
  final ValueChanged<SaveMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<SaveMode>(
      groupValue: value,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where to save:',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          const RadioListTile<SaveMode>(
            value: SaveMode.saveLocally,
            title: Text('Save locally'),
            subtitle: Text('Adds to your collection. No TMDB push.'),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
          const RadioListTile<SaveMode>(
            value: SaveMode.saveLocallyAndSync,
            title: Text('Save locally and sync to TMDB'),
            subtitle:
                Text('Adds to your collection and pushes to TMDB.'),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
          const RadioListTile<SaveMode>(
            value: SaveMode.tmdbOnly,
            title: Text('TMDB only'),
            subtitle: Text('Stored on TMDB only — no local collection entry.'),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
        ],
      ),
    );
  }
}
```

The `RadioGroup<T>` ancestor pattern matches the slice-2 `ConflictPolicySelector` (Flutter 3.41+ deprecated `RadioListTile.groupValue`/`onChanged`).

- [ ] **Step 4: Run tests**

Run: `flutter test test/widget/screens/metadata_confirm/widgets/remote_first_save_mode_selector_test.dart`
Expected: 2/2 pass.

- [ ] **Step 5: Run analyzer**

Run: `flutter analyze lib/presentation/screens/metadata_confirm/widgets/remote_first_save_mode_selector.dart test/widget/screens/metadata_confirm/widgets/remote_first_save_mode_selector_test.dart`
Expected: zero issues.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/screens/metadata_confirm/widgets/remote_first_save_mode_selector.dart \
        test/widget/screens/metadata_confirm/widgets/remote_first_save_mode_selector_test.dart
git commit -m "feat(tmdb-sync): add RemoteFirstSaveModeSelector widget"
```

---

## Task 8: Wire selector + dispatch into metadata-confirm

**Files:**
- Modify: `lib/presentation/screens/metadata_confirm/metadata_confirm_screen.dart`
- Modify: `lib/presentation/providers/repository_providers.dart`

### Step 1 — Register the new use-case provider

In `lib/presentation/providers/repository_providers.dart`, add the import:

```dart
import 'package:mymediascanner/domain/usecases/save_tmdb_only_usecase.dart';
```

Add the provider near the slice-2 use-case providers:

```dart
final saveTmdbOnlyUseCaseProvider = Provider<SaveTmdbOnlyUseCase>((ref) {
  return SaveTmdbOnlyUseCase(ref.watch(tmdbAccountSyncRepositoryProvider));
});
```

### Step 2 — Investigate the metadata-confirm screen

Read `lib/presentation/screens/metadata_confirm/metadata_confirm_screen.dart`. Identify:
- The save call site (`useCase.execute(...)` or similar around line 292).
- The state-tracked fields (slice-2 added `_userRating`).
- The build method's section list.
- Where `tmdbId` and `mediaType` (the `'movie'`/`'tv'` API string) are resolved (slice 2 added helpers; verify they still exist and are accessible).

### Step 3 — Add `_saveMode` state field

The screen is already a `ConsumerStatefulWidget` (slice 2 conversion). Add to `_MetadataConfirmScreenState`:

```dart
SaveMode _saveMode = SaveMode.saveLocally;
```

Add the import at the top:

```dart
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/remote_first_save_mode_selector.dart';
```

### Step 4 — Render the selector conditionally

In the build method's column children list, find the `TmdbAccountPanel` insertion site (slice 2). Add the `RemoteFirstSaveModeSelector` near it, conditioned on:
- `accountSyncEnabled == true`
- `remoteFirstSaveEnabled == true`
- TMDB ID is non-null
- Media type is `'movie'` or `'tv'`

The existing helpers `_resolveTmdbId()` and `_resolveApiMediaType()` (or whatever they're named — slice 2 renamed) provide the values. If the helpers were renamed in the slice-2 fix, use the current names. If they don't exist (different slice 2 outcome), inline:

```dart
int? _resolveTmdbId() {
  // Slice 2 (commit fc3fad4) wrote 'movie'/'tv' directly to media_type
  // via TmdbMapper; reading extraMetadata['tmdb_id'] should be int.
  final id = /* the in-progress edited metadata */.extraMetadata['tmdb_id'];
  return id is int ? id : null;
}

String? _resolveApiMediaType() {
  final v = /* edited */.extraMetadata['media_type'];
  return (v == 'movie' || v == 'tv') ? v as String : null;
}
```

Render the selector:

```dart
final settings = ref.watch(tmdbAccountSyncSettingsProvider);
final tmdbId = _resolveTmdbId();
final mediaType = _resolveApiMediaType();
final showSelector = settings.enabled &&
    settings.remoteFirstSaveEnabled &&
    tmdbId != null &&
    (mediaType == 'movie' || mediaType == 'tv');

// Add to children list:
if (showSelector)
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: RemoteFirstSaveModeSelector(
      value: _saveMode,
      onChanged: (v) => setState(() => _saveMode = v),
    ),
  ),
```

### Step 5 — Branch on save mode at the existing save call site

Find the existing save call (`useCase.execute(...)` around line 292 in slice 2's snapshot). Wrap it in a switch on `_saveMode`:

```dart
switch (_saveMode) {
  case SaveMode.saveLocally:
  case SaveMode.saveLocallyAndSync:
    // Existing slice-A save path, unchanged. Slice 2's mirror trigger
    // and rating-apply post-save flow continue to fire.
    final saved = await useCase.execute(/* existing args */);
    // ... existing post-save handling for slice 2's rating apply ...
    break;
  case SaveMode.tmdbOnly:
    final tmdbId = _resolveTmdbId();
    final mediaType = _resolveApiMediaType();
    if (tmdbId == null || mediaType == null) {
      // Should not happen — selector is gated on these. Defensive:
      messenger.showSnackBar(const SnackBar(
          content: Text('Cannot save TMDB only — no TMDB ID resolved')));
      break;
    }
    final scannedBarcode = /* existing barcode-state field */;
    await ref.read(saveTmdbOnlyUseCaseProvider).call(
          tmdbId: tmdbId,
          mediaType: mediaType,
          title: edited.title,
          posterPath: edited.coverPath, // already a TMDB path or null
          barcode: scannedBarcode,
        );
    messenger.showSnackBar(
        const SnackBar(content: Text('Saved to TMDB')));
    break;
}
```

(Adapt to actual variable names in the screen.)

The slice-2 rating-apply flow (`repository.update(savedItem.copyWith(userRating: ...))`) only runs in the `saveLocally` / `saveLocallyAndSync` branches because TMDB-only saves don't produce a `savedItem`.

### Step 6 — Run analyzer

Run: `flutter analyze lib/presentation/screens/metadata_confirm/metadata_confirm_screen.dart lib/presentation/providers/repository_providers.dart`
Expected: zero issues.

### Step 7 — Run any existing metadata-confirm tests

Run: `flutter test test/widget/screens/metadata_confirm/`
Expected: all pass (existing tests should not break — the new path is gated on remote-first toggle being on).

### Step 8 — Commit

```bash
git add lib/presentation/screens/metadata_confirm/metadata_confirm_screen.dart \
        lib/presentation/providers/repository_providers.dart
git commit -m "feat(tmdb-sync): wire remote-first selector into metadata-confirm"
```

---

## Task 9: Wire selector + dispatch into manual-add

**Files:**
- Modify: `lib/presentation/screens/manual_add/manual_add_screen.dart`

### Step 1 — Investigate the manual-add screen

Read `lib/presentation/screens/manual_add/manual_add_screen.dart`. Identify the save call site (around line 41) and how `tmdbId` / `mediaType` are determined. Manual-add typically lets the user pick metadata; check whether that path can resolve to a TMDB-backed entity (it should — `MetadataResult` from TMDB lookup carries `extraMetadata['tmdb_id']`).

### Step 2 — Add `_saveMode` state and the selector

Manual-add is shorter than metadata-confirm (77 lines vs 361). Same pattern:

1. Convert to `ConsumerStatefulWidget` if it's not already (slice 2 may have done this).
2. Add `SaveMode _saveMode = SaveMode.saveLocally;` field.
3. Add the import:

```dart
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/remote_first_save_mode_selector.dart';
```

4. Render the selector in the build method, gated identically to metadata-confirm:

```dart
final settings = ref.watch(tmdbAccountSyncSettingsProvider);
final tmdbId = _resolveTmdbId();
final mediaType = _resolveApiMediaType();
final showSelector = settings.enabled &&
    settings.remoteFirstSaveEnabled &&
    tmdbId != null &&
    (mediaType == 'movie' || mediaType == 'tv');

if (showSelector)
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: RemoteFirstSaveModeSelector(
      value: _saveMode,
      onChanged: (v) => setState(() => _saveMode = v),
    ),
  ),
```

5. Branch the save call (same shape as Task 8, Step 5).

### Step 3 — Run analyzer

Run: `flutter analyze lib/presentation/screens/manual_add/manual_add_screen.dart`
Expected: zero issues.

### Step 4 — Run tests

Run: `flutter test test/widget/screens/manual_add/` (if any) and `flutter test`
Expected: all pass.

### Step 5 — Commit

```bash
git add lib/presentation/screens/manual_add/manual_add_screen.dart
git commit -m "feat(tmdb-sync): wire remote-first selector into manual-add"
```

---

## Task 10: Extend TmdbBucketScreen for the saved bucket

**Files:**
- Modify: `lib/presentation/screens/tmdb/tmdb_bucket_screen.dart`

- [ ] **Step 1: Add `saved` cases to title and empty-message switches**

In `lib/presentation/screens/tmdb/tmdb_bucket_screen.dart`, find the two `switch (bucket)` expressions (`_title` getter and `_emptyMessage` getter). Add the `saved` case to each:

For `_title`:

```dart
String get _title => switch (bucket) {
  TmdbBridgeBucket.watchlist => 'TMDB Watchlist',
  TmdbBridgeBucket.rated => 'TMDB Rated',
  TmdbBridgeBucket.favourite => 'TMDB Favourites',
  TmdbBridgeBucket.saved => 'TMDB Saved',
};
```

For `_emptyMessage`:

```dart
String get _emptyMessage => switch (bucket) {
  TmdbBridgeBucket.watchlist =>
    'Nothing on your TMDB watchlist yet. Add titles on themoviedb.org '
        'and they will appear here after the next sync.',
  TmdbBridgeBucket.rated =>
    'No TMDB ratings yet. Rate titles on themoviedb.org and run a '
        'sync.',
  TmdbBridgeBucket.favourite =>
    'No TMDB favourites yet. Mark some on themoviedb.org and run a '
        'sync.',
  TmdbBridgeBucket.saved =>
    'No remote-first saves yet. When you save a movie or TV title as '
        'TMDB only, it will appear here.',
};
```

The slice-2 watchlist-only actions (Mark as owned, Remove from TMDB watchlist) are gated on `bucket == TmdbBridgeBucket.watchlist` — unchanged. The standard "Open on TMDB" and "Convert to local item" actions work for all buckets.

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze lib/presentation/screens/tmdb/tmdb_bucket_screen.dart`
Expected: zero issues.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/screens/tmdb/tmdb_bucket_screen.dart
git commit -m "feat(tmdb-sync): add saved-bucket title and empty message"
```

---

## Task 11: Add `/tmdb/saved` route

**Files:**
- Modify: `lib/app/router.dart`

- [ ] **Step 1: Add the new branch**

In `lib/app/router.dart`, find the slice-2 resolve-conflicts branch:

```dart
StatefulShellBranch(routes: [
  GoRoute(
    path: '/tmdb/conflicts',
    pageBuilder: (_, _) => const NoTransitionPage(
        child: TmdbResolveConflictsScreen()),
  ),
]),
```

Add a new branch immediately **before** it (so TMDB Saved is branch 15 and Resolve Conflicts moves to branch 16):

```dart
StatefulShellBranch(routes: [
  GoRoute(
    path: '/tmdb/saved',
    pageBuilder: (_, _) => const NoTransitionPage(
        child: TmdbBucketScreen(bucket: TmdbBridgeBucket.saved)),
  ),
]),
```

`TmdbBucketScreen` and `TmdbBridgeBucket` are already imported (slice A).

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze lib/app/router.dart`
Expected: zero issues.

- [ ] **Step 3: Commit**

```bash
git add lib/app/router.dart
git commit -m "feat(tmdb-sync): add /tmdb/saved route"
```

---

## Task 12: Add 4th sidebar entry (TMDB Saved)

**Files:**
- Modify: `lib/presentation/widgets/app_scaffold.dart`

- [ ] **Step 1: Investigate the existing TMDB sidebar block**

Read `lib/presentation/widgets/app_scaffold.dart`. Slice A added three TMDB sidebar entries; slice 2 added a conditional Resolve Conflicts entry. The TMDB Saved entry follows the same conditional pattern (count > 0).

- [ ] **Step 2: Add the 4th conditional entry**

Find the slice-A TMDB sidebar block (the three Watchlist/Rated/Favourites entries). Add a fourth entry **before** the slice-2 Resolve Conflicts entry. Match the existing destination shape (icon + label + optional count). Pseudocode (adapt to the actual `_SidebarDestination` constructor — slice A's review described positional `IconData icon, IconData selectedIcon, String label`):

```dart
final savedAsync = ref.watch(tmdbBridgeBucketProvider(TmdbBridgeBucket.saved));
final savedCount = savedAsync.maybeWhen(
  data: (rows) => rows.length,
  orElse: () => 0,
);
if (showTmdb && savedCount > 0)
  _SidebarDestination(
    Icons.cloud_outlined,
    Icons.cloud,
    'TMDB Saved ($savedCount)',
  ),
```

Place this **after** the three static TMDB entries and **before** the Resolve Conflicts conditional. The order matters — sidebar position 12/13/14 = slice-A entries, position 15 = TMDB Saved (matches branch 15), position 16 = Resolve Conflicts (matches branch 16).

If the codebase uses a different conditional-append idiom (e.g., a list builder), match it.

- [ ] **Step 3: Update the branch-index mapping comment**

Find the slice-A comment about the identity-mapping fragility (around lines 297–309 from slice 2's review). Extend it to mention the new TMDB Saved entry. Pseudocode:

```dart
// Sidebar list positions map 1:1 to StatefulShellBranch indices in
// router.dart. Order matters:
//   0–11: static (Home, Library, Scan, ..., Settings, Rips, Wishlist, ...)
//   12–14: static TMDB (Watchlist, Rated, Favourites) — always present
//                       when isTmdbConnected
//   15: conditional TMDB Saved — only when savedCount > 0
//   16: conditional Resolve Conflicts — only when policy=askUser AND
//       conflictsCount > 0
// This identity mapping holds today only because the static entries
// are gated on `isDesktop`. If any feature flag becomes user-configurable,
// the conditional entries will drift from their branch indices and
// navigation will break — replace this mapping with an explicit
// lookup table at that point.
```

- [ ] **Step 4: Run analyzer**

Run: `flutter analyze lib/presentation/widgets/app_scaffold.dart`
Expected: zero issues.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/app_scaffold.dart
git commit -m "feat(tmdb-sync): add TMDB Saved conditional sidebar entry"
```

---

## Task 13: Add 4th tile to TmdbListsSection (Settings)

**Files:**
- Modify: `lib/presentation/screens/settings/widgets/tmdb_lists_section.dart`

- [ ] **Step 1: Investigate the slice-3b section**

Read `lib/presentation/screens/settings/widgets/tmdb_lists_section.dart`. Slice 3b added three static tiles (Watchlist/Rated/Favourites) plus a conditional Resolve Conflicts tile.

- [ ] **Step 2: Insert the 4th tile**

Add a 4th tile between the three static tiles and the conditional Resolve Conflicts tile. Like the sidebar entry, gated on count > 0:

```dart
ref.watch(tmdbBridgeBucketProvider(TmdbBridgeBucket.saved)).maybeWhen(
  data: (rows) => rows.isEmpty
      ? const SizedBox.shrink()
      : ListTile(
          leading: const Icon(Icons.cloud_outlined),
          title: Text('TMDB Saved (${rows.length})'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => GoRouter.of(context).go('/tmdb/saved'),
        ),
  orElse: () => const SizedBox.shrink(),
),
```

- [ ] **Step 3: Update the slice-3b tests for the new tile**

In `test/widget/screens/settings/widgets/tmdb_lists_section_test.dart`, add a new test:

```dart
testWidgets('shows TMDB Saved tile when there are saved bucket rows',
    (tester) async {
  final saved = TmdbBridgeItem(
    id: 'br-saved',
    tmdbId: 200,
    mediaType: 'movie',
  );
  // The harness already overrides `tmdbConflictedRowsProvider`; we need
  // to also override `tmdbBridgeBucketProvider(TmdbBridgeBucket.saved)`.
  // Existing harness uses `tmdbConflictedRowsProvider.overrideWith((ref) =>
  //   Stream<List<TmdbBridgeItem>>.value(conflicts))`. Add a similar
  // override for the saved bucket.
  await tester.pumpWidget(/* harness with savedRows: [saved] */);
  await tester.pumpAndSettle();
  expect(find.text('TMDB Saved (1)'), findsOneWidget);
});
```

The implementer adapts the existing harness to also accept a `savedRows` parameter and override `tmdbBridgeBucketProvider(TmdbBridgeBucket.saved)` accordingly. The harness signature changes; update the existing four tests to pass `savedRows: const []` (or the harness defaults this).

- [ ] **Step 4: Run analyzer + tests**

Run: `flutter analyze lib/presentation/screens/settings/widgets/tmdb_lists_section.dart test/widget/screens/settings/widgets/tmdb_lists_section_test.dart`
Run: `flutter test test/widget/screens/settings/widgets/tmdb_lists_section_test.dart`
Expected: zero issues, 5/5 pass.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/screens/settings/widgets/tmdb_lists_section.dart \
        test/widget/screens/settings/widgets/tmdb_lists_section_test.dart
git commit -m "feat(tmdb-sync): add TMDB Saved tile to TmdbListsSection"
```

---

## Task 14: Integration test — save TMDB only round-trip

**Files:**
- Modify: `integration_test/tmdb_account_sync_test.dart`

- [ ] **Step 1: Append the new test**

In `integration_test/tmdb_account_sync_test.dart`, after the existing slice-2 `push rating end-to-end` test, add:

```dart
testWidgets('save tmdb only creates an orphan bridge row', (tester) async {
  final api = _MockApi();
  final storage = _MockStorage();
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(() async => db.close());

  // Storage stub.
  final stored = <String, String>{
    'tmdb.session_id': 'sess-1',
    'tmdb.account_id': '1',
    'tmdb.account_username': 'paul',
  };
  when(() => storage.read(key: any(named: 'key')))
      .thenAnswer((inv) async => stored[inv.namedArguments[#key]]);
  when(() => storage.write(
          key: any(named: 'key'), value: any(named: 'value')))
      .thenAnswer((inv) async {
    stored[inv.namedArguments[#key] as String] =
        inv.namedArguments[#value] as String;
  });
  when(() => storage.delete(key: any(named: 'key')))
      .thenAnswer((inv) async {
    stored.remove(inv.namedArguments[#key]);
  });

  final repo = TmdbAccountSyncRepositoryImpl(
    api: api,
    dao: db.tmdbAccountSyncDao,
    mediaItemsDao: db.mediaItemsDao,
    storage: storage,
  );
  final useCase = SaveTmdbOnlyUseCase(repo);

  await useCase(
    tmdbId: 550,
    mediaType: 'movie',
    title: 'Fight Club',
    posterPath: '/p.jpg',
    barcode: '5051892002172',
  );

  final saved = await db.tmdbAccountSyncDao
      .listByBucket(TmdbBridgeBucket.saved);
  expect(saved.length, 1);
  expect(saved.first.tmdbId, 550);
  expect(saved.first.mediaItemId, isNull);
  expect(saved.first.barcode, '5051892002172');
});
```

Add the import:

```dart
import 'package:mymediascanner/domain/usecases/save_tmdb_only_usecase.dart';
```

- [ ] **Step 2: Run the integration test**

Run: `flutter test integration_test/tmdb_account_sync_test.dart -d linux`
Expected: 5/5 pass (slice-A's 3 + slice-2's 1 + slice 3a's 1).

- [ ] **Step 3: Commit**

```bash
git add integration_test/tmdb_account_sync_test.dart
git commit -m "test(tmdb-sync): integration test for save tmdb only"
```

---

## Task 15: Final verification

**Files:** none

- [ ] **Step 1: Run analyzer**

Run: `flutter analyze`
Expected: zero issues.

- [ ] **Step 2: Run full test suite**

Run: `flutter test`
Expected: 1372+ passing (slice 3b baseline 1372 + Tasks 2/3/5/7 added ~10 unit + widget tests + Task 13 added 1 test).

- [ ] **Step 3: Linux build**

Run: `flutter build linux --debug`
Expected: build succeeds.

- [ ] **Step 4: Android build**

Run: `flutter build apk --debug --flavor dev`
Expected: build succeeds.

- [ ] **Step 5: Manual inspection**

Confirm via reading source:

1. `lib/domain/entities/tmdb_bridge_bucket.dart` — has 4 enum values.
2. `lib/data/local/dao/tmdb_account_sync_dao.dart` — `listByBucket` and `watchByBucket` switches have a `saved` case filtering on `watchlist=false & favorite=false & tmdb_rating IS NULL`.
3. `lib/domain/usecases/save_tmdb_only_usecase.dart` — exists and validates media type.
4. `lib/data/repositories/tmdb_account_sync_repository_impl.dart` — has `upsertBridge`.
5. `lib/presentation/providers/settings_provider.dart` — `TmdbAccountSyncSettings` has `remoteFirstSaveEnabled`; notifier has `setRemoteFirstSaveEnabled`.
6. `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart` — has the 3rd toggle "Allow remote-first save (film/TV)" with warning-dialog wrapping.
7. `lib/presentation/screens/metadata_confirm/metadata_confirm_screen.dart` and `manual_add_screen.dart` — both render `RemoteFirstSaveModeSelector` when gated and dispatch on `_saveMode` at save time.
8. `lib/presentation/screens/tmdb/tmdb_bucket_screen.dart` — `_title` and `_emptyMessage` switches handle `saved`.
9. `lib/app/router.dart` — `/tmdb/saved` route exists at branch index 15.
10. `lib/presentation/widgets/app_scaffold.dart` — 4th conditional TMDB sidebar entry; mapping comment updated.
11. `lib/presentation/screens/settings/widgets/tmdb_lists_section.dart` — 4th tile gated on count > 0.

- [ ] **Step 6: Final report**

Branch: `feat/tmdb-account-sync-slice-3a-remote-first`
HEAD: `<SHA>`
Total commits since main: `<count via git log --oneline main..HEAD | wc -l>`
Test results: `<summary>`
Linux build: `<PASS/FAIL>`
Android build: `<PASS/FAIL>`
Manual inspection: `<PASS/FAIL with notes>`

Any concerns to flag for the user before merge.

If something fails, status is DONE_WITH_CONCERNS and the failures are listed.

---

## Self-review

- **Spec coverage:** All in-scope items mapped to tasks. Settings toggle (Tasks 4, 6), warning dialog (Task 5), three-radio selector (Task 7), use case + interface + repo (Task 3), DAO bucket extension (Tasks 1+2), screen wiring (Tasks 8+9), bucket screen extension (Task 10), router + sidebar + list-section (Tasks 11+12+13), integration test (Task 14), final verification (Task 15).
- **Placeholder scan:** Tasks 8 and 9 contain a small amount of "adapt to actual variable names in the screen" guidance because the slice-2 metadata-confirm screen's exact structure (variable names for `edited`, the barcode field, etc.) requires the implementer to read the existing code. This is intentional — the same pattern appeared in slice-2 plans for the same screens.
- **Type consistency:** `SaveMode`, `SaveTmdbOnlyUseCase`, `RemoteFirstSaveModeSelector`, `RemoteFirstWarningDialog`, `TmdbBridgeBucket.saved`, `upsertBridge`, `setRemoteFirstSaveEnabled`, `remoteFirstSaveEnabled` are all used consistently across tasks.
- **Branch-index alignment:** The plan locks down router order (TMDB Saved at branch 15, Resolve Conflicts at 16) and sidebar order (matching). The slice-2 review's identity-mapping concern is documented and updated.
- **No schema migration:** Confirmed — bridge table already supports orphan rows; the new `saved` enum value uses existing columns only.
