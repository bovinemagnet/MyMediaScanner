# TMDB Account Sync — Slice 4a (Auto-Remove from Mirror) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Hook `MediaItemRepositoryImpl.update()` and `softDelete()` to fire `MirrorOwnershipChangeUseCase.add` / `.remove` whenever a movie's ownership crosses the `owned` boundary, so the MyMediaScanner private TMDB list stays in sync with local ownership across all transition paths (not just initial saves).

**Architecture:** Inject optional `MirrorOwnershipChangeUseCase` and a `bool Function() readMirrorEnabled` callback into `MediaItemRepositoryImpl` using the same nullable-DI pattern slice 2 used in `SaveMediaItemUseCase`. Pre-write read of the previous row, compare ownership, fire-and-forget mirror op when the gate passes. No new domain types, no schema migration, no UI.

**Tech Stack:** Flutter, Riverpod 3, Drift (no schema changes), mocktail.

**Source spec:** `docs/superpowers/specs/2026-04-29-tmdb-account-sync-slice-4a-auto-remove-mirror-design.md`

---

## File Layout

### Modify

| Path | Change |
|---|---|
| `lib/data/repositories/media_item_repository_impl.dart` | Add optional ctor params (`mirror`, `readMirrorEnabled`); add private `_maybeMirrorOnTransition` and `_maybeMirrorOnSoftDelete` helpers; hook `update()` and `softDelete()`. |
| `lib/presentation/providers/repository_providers.dart` | Wire optional mirror + `readMirrorEnabled` into `mediaItemRepositoryProvider`, with try/catch for the case where TMDB API key isn't configured (matches slice-2 pattern). |
| `test/unit/data/repositories/media_item_repository_impl_test.dart` | Add 9 test cases covering both hooks (transition detection, gates, no-ops). |
| `src/docs/modules/ROOT/pages/tmdb-account-sync.adoc` | One-paragraph note in the *Mirror Ownership* section that ownership transitions on existing items now mirror automatically. |

No new files. No schema migration.

---

## Convention notes

- Mirror calls are fire-and-forget via `unawaited(...).catchError(...)`. The local write always completes regardless of mirror outcome. Errors land on the bridge row's `last_error` (slice 2 already implements this in `_mirrorMutate`).
- The new ctor params are optional/nullable so existing test setups continue to work without changes — only tests that exercise the new hook supply them.
- `extraMetadata['tmdb_id']` is stored as `int`. `extraMetadata['media_type']` was switched to `'movie'`/`'tv'` directly during slice 2 (commit `fc3fad4`); no normalisation needed.

---

## Task 1: Add optional ctor params + private helpers (no behaviour change)

**Files:**
- Modify: `lib/data/repositories/media_item_repository_impl.dart`

This task adds the dependencies and helper methods without yet calling them from `update()` or `softDelete()`. Subsequent tasks wire the call sites with TDD per behaviour.

- [ ] **Step 1: Add the imports**

In `lib/data/repositories/media_item_repository_impl.dart`, add at the top alongside the existing imports:

```dart
import 'dart:async';

import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/mirror_ownership_change_usecase.dart';
```

The `dart:async` import is for `unawaited`. The other two cover `MirrorOwnershipChangeUseCase` and the `TmdbPushResult` type used by its return signature.

- [ ] **Step 2: Add the optional ctor params**

Change the constructor from:

```dart
class MediaItemRepositoryImpl implements IMediaItemRepository {
  MediaItemRepositoryImpl({
    required MediaItemsDao mediaItemsDao,
    required SyncLogDao syncLogDao,
  })  : _mediaItemsDao = mediaItemsDao,
        _syncLogDao = syncLogDao;

  final MediaItemsDao _mediaItemsDao;
  final SyncLogDao _syncLogDao;
  // ...
}
```

to:

```dart
class MediaItemRepositoryImpl implements IMediaItemRepository {
  MediaItemRepositoryImpl({
    required MediaItemsDao mediaItemsDao,
    required SyncLogDao syncLogDao,
    MirrorOwnershipChangeUseCase? mirror,
    bool Function()? readMirrorEnabled,
  })  : _mediaItemsDao = mediaItemsDao,
        _syncLogDao = syncLogDao,
        _mirror = mirror,
        _readMirrorEnabled = readMirrorEnabled;

  final MediaItemsDao _mediaItemsDao;
  final SyncLogDao _syncLogDao;
  final MirrorOwnershipChangeUseCase? _mirror;
  final bool Function()? _readMirrorEnabled;
  // ...
}
```

- [ ] **Step 3: Add the private helper methods**

At the bottom of the class (before the closing brace), add:

```dart
/// Fires `mirror.add` or `mirror.remove` when the ownership state of
/// a `media_items` row crosses the `owned` boundary. Gated on the
/// mirror toggle, presence of a TMDB ID, and movie media type.
///
/// Fire-and-forget — failures land on the bridge row's `last_error`.
void _maybeMirrorOnTransition(MediaItem? previous, MediaItem next) {
  final mirror = _mirror;
  final readEnabled = _readMirrorEnabled;
  if (mirror == null || readEnabled == null) return;
  if (!readEnabled()) return;

  final wasOwned = previous?.ownershipStatus == OwnershipStatus.owned;
  final isOwned = next.ownershipStatus == OwnershipStatus.owned;
  if (wasOwned == isOwned) return; // no transition

  final tmdbId = next.extraMetadata['tmdb_id'];
  if (tmdbId is! int) return;
  final mediaType = next.extraMetadata['media_type'];
  if (mediaType != 'movie') return;

  if (isOwned) {
    unawaited(mirror.add(tmdbId: tmdbId).catchError((_) {
      return const TmdbPushResult(success: false);
    }));
  } else {
    unawaited(mirror.remove(tmdbId: tmdbId).catchError((_) {
      return const TmdbPushResult(success: false);
    }));
  }
}

/// Fires `mirror.remove` when an owned movie is soft-deleted.
void _maybeMirrorOnSoftDelete(MediaItem previous) {
  final mirror = _mirror;
  final readEnabled = _readMirrorEnabled;
  if (mirror == null || readEnabled == null) return;
  if (!readEnabled()) return;
  if (previous.ownershipStatus != OwnershipStatus.owned) return;

  final tmdbId = previous.extraMetadata['tmdb_id'];
  if (tmdbId is! int) return;
  final mediaType = previous.extraMetadata['media_type'];
  if (mediaType != 'movie') return;

  unawaited(mirror.remove(tmdbId: tmdbId).catchError((_) {
    return const TmdbPushResult(success: false);
  }));
}
```

- [ ] **Step 4: Run analyzer**

Run: `flutter analyze lib/data/repositories/media_item_repository_impl.dart`
Expected: zero issues. The helpers are unused right now (Tasks 2 and 3 will call them) — Dart's analyzer doesn't flag unused private methods, so this is fine.

If the analyzer flags `unused_element` for the helpers, that means a stricter lint is enabled. In that case add `// ignore: unused_element` above each helper for now; Tasks 2 and 3 will remove the suppression.

- [ ] **Step 5: Run the existing repository tests to confirm no regression**

Run: `flutter test test/unit/data/repositories/media_item_repository_impl_test.dart`
Expected: all existing tests pass. The optional ctor params are nullable; existing tests don't supply them and skip the helpers entirely.

- [ ] **Step 6: Commit**

Verify branch is `feat/tmdb-account-sync-slice-4a-auto-remove-mirror` via `git branch --show-current`.

```bash
git add lib/data/repositories/media_item_repository_impl.dart
git commit -m "feat(tmdb-sync): add optional mirror DI to MediaItemRepositoryImpl"
```

Verify `git rev-parse feat/tmdb-account-sync-slice-4a-auto-remove-mirror` == `git rev-parse HEAD`.

---

## Task 2: Hook `update()` with TDD

**Files:**
- Modify: `lib/data/repositories/media_item_repository_impl.dart`
- Modify: `test/unit/data/repositories/media_item_repository_impl_test.dart`

- [ ] **Step 1: Read the existing test file structure**

Read `test/unit/data/repositories/media_item_repository_impl_test.dart` to understand its setup (in-memory `AppDatabase`, fixture builders for `MediaItem`, etc.). Mirror that style — don't re-invent setup helpers.

- [ ] **Step 2: Write the failing tests for `update()`**

Append these tests to the existing test file. They use `mocktail` (already a project dependency) for the mirror dep. If `mocktail` isn't already imported in this file, add the import.

Add these imports at the top of the test file alongside the existing imports:

```dart
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/mirror_ownership_change_usecase.dart';
```

Add a mock class near the top of the file (after the existing imports, before `void main()`):

```dart
class _MockMirror extends Mock implements MirrorOwnershipChangeUseCase {}
```

Append these tests inside the existing `void main()` block (in a new `group('mirror auto-remove hook', () { ... })`):

```dart
group('mirror auto-remove hook', () {
  late _MockMirror mirror;
  late bool mirrorEnabled;

  setUp(() {
    mirror = _MockMirror();
    mirrorEnabled = true;
    when(() => mirror.add(tmdbId: any(named: 'tmdbId'))).thenAnswer(
        (_) async => const TmdbPushResult(success: true));
    when(() => mirror.remove(tmdbId: any(named: 'tmdbId'))).thenAnswer(
        (_) async => const TmdbPushResult(success: true));
  });

  MediaItemRepositoryImpl makeRepo() => MediaItemRepositoryImpl(
        mediaItemsDao: db.mediaItemsDao,
        syncLogDao: db.syncLogDao,
        mirror: mirror,
        readMirrorEnabled: () => mirrorEnabled,
      );

  MediaItem movieItem({
    required String id,
    required OwnershipStatus ownership,
    int? tmdbId = 550,
    String mediaType = 'movie',
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return MediaItem(
      id: id,
      title: 'Fight Club',
      mediaType: MediaType.film,
      ownershipStatus: ownership,
      barcode: '',
      barcodeType: '',
      extraMetadata: {
        if (tmdbId != null) 'tmdb_id': tmdbId,
        'media_type': mediaType,
      },
      createdAt: now,
      updatedAt: now,
    );
  }

  test('update non-owned → owned fires mirror.add', () async {
    final repo = makeRepo();
    // Seed wishlist row.
    final wishlist =
        movieItem(id: 'a', ownership: OwnershipStatus.wishlist);
    await db.mediaItemsDao.insertMediaItem(/* see existing test pattern */
        // — adapt to whatever insertion helper the existing tests use.
        // If the existing tests insert via `repo.upsert` or `dao.insertItem`,
        // use that path here too.
        );
    // For a clean test surface, use the repository's own create path
    // (whatever the existing tests use) so the row matches what the
    // production code expects.

    await repo.update(
        movieItem(id: 'a', ownership: OwnershipStatus.owned));

    verify(() => mirror.add(tmdbId: 550)).called(1);
    verifyNever(() => mirror.remove(tmdbId: any(named: 'tmdbId')));
  });

  test('update owned → not-owned fires mirror.remove', () async {
    final repo = makeRepo();
    // Seed owned row first.
    await /* insert owned movieItem(id: 'b') via existing helper */;

    await repo.update(
        movieItem(id: 'b', ownership: OwnershipStatus.wishlist));

    verify(() => mirror.remove(tmdbId: 550)).called(1);
    verifyNever(() => mirror.add(tmdbId: any(named: 'tmdbId')));
  });

  test('update owned → owned (rating-only) does not fire mirror', () async {
    final repo = makeRepo();
    await /* insert owned movieItem(id: 'c') */;

    final updated = movieItem(id: 'c', ownership: OwnershipStatus.owned)
        .copyWith(userRating: 4.5);
    await repo.update(updated);

    verifyNever(() => mirror.add(tmdbId: any(named: 'tmdbId')));
    verifyNever(() => mirror.remove(tmdbId: any(named: 'tmdbId')));
  });

  test('update with mirror disabled does not fire mirror', () async {
    mirrorEnabled = false;
    final repo = makeRepo();
    await /* insert wishlist movieItem(id: 'd') */;

    await repo.update(
        movieItem(id: 'd', ownership: OwnershipStatus.owned));

    verifyNever(() => mirror.add(tmdbId: any(named: 'tmdbId')));
  });

  test('update non-owned → owned for TV does not fire mirror', () async {
    final repo = makeRepo();
    final tvItem = movieItem(
      id: 'e',
      ownership: OwnershipStatus.wishlist,
      mediaType: 'tv',
    );
    await /* insert tvItem */;

    await repo.update(tvItem.copyWith(
        ownershipStatus: OwnershipStatus.owned));

    verifyNever(() => mirror.add(tmdbId: any(named: 'tmdbId')));
  });

  test('update non-owned → owned without TMDB ID does not fire mirror',
      () async {
    final repo = makeRepo();
    final noTmdb = movieItem(
      id: 'f',
      ownership: OwnershipStatus.wishlist,
      tmdbId: null,
    );
    await /* insert noTmdb */;

    await repo.update(noTmdb.copyWith(
        ownershipStatus: OwnershipStatus.owned));

    verifyNever(() => mirror.add(tmdbId: any(named: 'tmdbId')));
  });
});
```

The `/* insert ... */` placeholders need to be filled in with whatever insertion helper the existing test setup uses. Read the existing tests in this file to identify the pattern — likely `repo.upsert(item)` or `dao.insertItem(...)` or a top-level helper. Use the same pattern in the new tests.

If the existing test file doesn't expose a clean way to insert a `MediaItem`, add a small private helper at the top of the new group:

```dart
Future<void> _seed(MediaItem item) async {
  // Insert via DAO directly to bypass the repo's update hook (which
  // is what we're testing). Adapt to the actual DAO insert method:
  await db.mediaItemsDao.insertItem(/* MediaItemsTableCompanion shape */);
}
```

- [ ] **Step 3: Run the new tests (will fail)**

Run: `flutter test test/unit/data/repositories/media_item_repository_impl_test.dart --name "mirror auto-remove hook"`
Expected: FAIL — `update()` doesn't yet call `_maybeMirrorOnTransition`.

- [ ] **Step 4: Hook `update()` to call the helper**

In `lib/data/repositories/media_item_repository_impl.dart`, find the `update()` method:

```dart
@override
Future<void> update(MediaItem item) async {
  await _mediaItemsDao.update(_toCompanion(item));
  await _logSync('media_item', item.id, 'update', item);
}
```

Wrap it with the previous-row read and the helper call:

```dart
@override
Future<void> update(MediaItem item) async {
  final previous = await getById(item.id);
  await _mediaItemsDao.update(_toCompanion(item));
  await _logSync('media_item', item.id, 'update', item);
  _maybeMirrorOnTransition(previous, item);
}
```

`getById` is the existing repository method (slice-A or earlier). Verify it returns `MediaItem?` (nullable when row missing).

- [ ] **Step 5: Run the new tests**

Run: `flutter test test/unit/data/repositories/media_item_repository_impl_test.dart --name "mirror auto-remove hook"`
Expected: 6/6 of the new tests pass.

- [ ] **Step 6: Run the full repository test file to confirm no regression**

Run: `flutter test test/unit/data/repositories/media_item_repository_impl_test.dart`
Expected: all tests pass (existing + new).

- [ ] **Step 7: Run analyzer**

Run: `flutter analyze lib/data/repositories/media_item_repository_impl.dart test/unit/data/repositories/media_item_repository_impl_test.dart`
Expected: zero issues.

- [ ] **Step 8: Commit**

```bash
git add lib/data/repositories/media_item_repository_impl.dart \
        test/unit/data/repositories/media_item_repository_impl_test.dart
git commit -m "feat(tmdb-sync): hook update() to mirror ownership transitions"
```

Verify branch + HEAD match.

---

## Task 3: Hook `softDelete()` with TDD

**Files:**
- Modify: `lib/data/repositories/media_item_repository_impl.dart`
- Modify: `test/unit/data/repositories/media_item_repository_impl_test.dart`

- [ ] **Step 1: Append the soft-delete tests**

Add these tests to the existing `mirror auto-remove hook` group in the test file (or create a new group `softDelete mirror hook` if you prefer — either works, the existing group is fine):

```dart
test('softDelete on owned movie fires mirror.remove', () async {
  final repo = makeRepo();
  await /* insert owned movieItem(id: 'g') */;

  await repo.softDelete('g');

  verify(() => mirror.remove(tmdbId: 550)).called(1);
});

test('softDelete on non-owned item does not fire mirror', () async {
  final repo = makeRepo();
  await /* insert wishlist movieItem(id: 'h') */;

  await repo.softDelete('h');

  verifyNever(() => mirror.remove(tmdbId: any(named: 'tmdbId')));
});

test('softDelete on owned TV item does not fire mirror', () async {
  final repo = makeRepo();
  final tvOwned = movieItem(
    id: 'i',
    ownership: OwnershipStatus.owned,
    mediaType: 'tv',
  );
  await /* insert tvOwned */;

  await repo.softDelete('i');

  verifyNever(() => mirror.remove(tmdbId: any(named: 'tmdbId')));
});
```

- [ ] **Step 2: Run the new tests (will fail)**

Run: `flutter test test/unit/data/repositories/media_item_repository_impl_test.dart --name "softDelete"`
Expected: FAIL — `softDelete()` doesn't yet call `_maybeMirrorOnSoftDelete`.

- [ ] **Step 3: Hook `softDelete()` to call the helper**

In `lib/data/repositories/media_item_repository_impl.dart`, find `softDelete()`:

```dart
@override
Future<void> softDelete(String id) async {
  final now = DateTime.now().millisecondsSinceEpoch;
  await _mediaItemsDao.softDelete(id, now);
  // ... existing _logSync call ...
}
```

(The exact existing body may differ — check the file. The key is to add a pre-write `getById` and a post-write `_maybeMirrorOnSoftDelete` call.)

Wrap it:

```dart
@override
Future<void> softDelete(String id) async {
  final previous = await getById(id);
  final now = DateTime.now().millisecondsSinceEpoch;
  await _mediaItemsDao.softDelete(id, now);
  // ... existing _logSync call, unchanged ...
  if (previous != null) {
    _maybeMirrorOnSoftDelete(previous);
  }
}
```

The `if (previous != null)` guard handles the rare case where `softDelete` is called on a non-existent ID — the soft-delete itself is a no-op SQL update and we shouldn't try to mirror anything.

- [ ] **Step 4: Run the new tests**

Run: `flutter test test/unit/data/repositories/media_item_repository_impl_test.dart --name "softDelete"`
Expected: 3/3 new soft-delete tests pass.

- [ ] **Step 5: Run the full repository test file**

Run: `flutter test test/unit/data/repositories/media_item_repository_impl_test.dart`
Expected: all pass (existing + 6 from Task 2 + 3 new = 9 mirror-related tests plus pre-existing).

- [ ] **Step 6: Run analyzer**

Run: `flutter analyze lib/data/repositories/media_item_repository_impl.dart test/unit/data/repositories/media_item_repository_impl_test.dart`
Expected: zero issues.

- [ ] **Step 7: Commit**

```bash
git add lib/data/repositories/media_item_repository_impl.dart \
        test/unit/data/repositories/media_item_repository_impl_test.dart
git commit -m "feat(tmdb-sync): hook softDelete() to mirror ownership removal"
```

Verify branch + HEAD match.

---

## Task 4: Wire repository provider injection

**Files:**
- Modify: `lib/presentation/providers/repository_providers.dart`

- [ ] **Step 1: Investigate the existing `mediaItemRepositoryProvider`**

Read `lib/presentation/providers/repository_providers.dart`. The slice-A version of `mediaItemRepositoryProvider` looks like:

```dart
final mediaItemRepositoryProvider = Provider<IMediaItemRepository>((ref) {
  return MediaItemRepositoryImpl(
    mediaItemsDao: ref.watch(mediaItemsDaoProvider),
    syncLogDao: ref.watch(syncLogDaoProvider),
  );
});
```

Slice 2 added a `mirrorOwnershipChangeUseCaseProvider` that itself depends on `tmdbAccountSyncRepositoryProvider` — and `tmdbAccountSyncRepositoryProvider` THROWS a `StateError` if no TMDB API key is configured. So we need to wrap the read of the mirror in a try/catch (slice 2 used the same pattern in `series_provider.dart` — verify by reading that file briefly if you need a reference).

- [ ] **Step 2: Update `mediaItemRepositoryProvider`**

Replace the existing provider with:

```dart
final mediaItemRepositoryProvider = Provider<IMediaItemRepository>((ref) {
  // Optional mirror dep — null when TMDB API key isn't configured. The
  // repository tolerates a null mirror and skips the auto-remove hook.
  MirrorOwnershipChangeUseCase? mirror;
  try {
    mirror = ref.watch(mirrorOwnershipChangeUseCaseProvider);
  } on StateError {
    mirror = null;
  }
  return MediaItemRepositoryImpl(
    mediaItemsDao: ref.watch(mediaItemsDaoProvider),
    syncLogDao: ref.watch(syncLogDaoProvider),
    mirror: mirror,
    readMirrorEnabled: () =>
        ref.read(tmdbAccountSyncSettingsProvider).mirrorOwnership,
  );
});
```

If `mirrorOwnershipChangeUseCaseProvider` and `tmdbAccountSyncSettingsProvider` aren't already imported in this file, add them. They were registered by slice 2.

The `try` / `on StateError` covers the "TMDB API key not configured" case. If the underlying error type is different in this codebase, change to `catch (_)` — read the slice-2 `series_provider.dart` precedent if unsure. The intent is the same: the mirror dep is optional, and if its provider can't be resolved cleanly we pass null.

- [ ] **Step 3: Run analyzer**

Run: `flutter analyze lib/presentation/providers/repository_providers.dart`
Expected: zero issues.

- [ ] **Step 4: Run the full test suite to confirm no regression**

Run: `flutter test`
Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/providers/repository_providers.dart
git commit -m "feat(tmdb-sync): wire mirror dep into mediaItemRepositoryProvider"
```

Verify branch + HEAD match.

---

## Task 5: Update the user docs

**Files:**
- Modify: `src/docs/modules/ROOT/pages/tmdb-account-sync.adoc`

- [ ] **Step 1: Find the *Mirror Ownership* section**

Open `src/docs/modules/ROOT/pages/tmdb-account-sync.adoc` and find the section titled `== Mirror Ownership to a TMDB List`.

- [ ] **Step 2: Add a paragraph noting auto-mirror on transitions**

Add a paragraph at the end of the *Mirror Ownership to a TMDB List* section (just before the next `==` heading), describing the new behaviour:

```adoc
=== Automatic mirroring on ownership changes

Mirror updates fire automatically whenever a movie's ownership status changes:

* Marking an owned movie as wishlist, sold, lent, borrowed, or returned removes it from the MyMediaScanner TMDB list.
* Promoting a wishlist movie to owned (for example via the *Convert to owned* action on a wishlist row) adds it to the MyMediaScanner TMDB list.
* Soft-deleting an owned movie removes it from the MyMediaScanner TMDB list.

Mirror calls run in the background and do not block the local save.
A failed call surfaces under the settings card's *Push pending now* affordance for retry.
The behaviour is gated on the *Mirror ownership to TMDB list (movies only)* toggle and only applies to titles that have a TMDB ID.
TV titles are not mirrored — TMDB v3 lists support movies only.
```

The exact wording can be polished — match the existing prose style of the page.

- [ ] **Step 3: Validate the Antora build**

Run from the repository root: `npx antora local-antora-playbook-search.yml`
Expected: clean exit (no new warnings or errors). If the playbook file isn't named exactly that, search for `*.yml` files at the repo root that mention `antora` to find the right one.

(The global instruction `gradle21w antora` doesn't apply to this Flutter project — the repo uses npx-based Antora invocation.)

- [ ] **Step 4: Commit**

```bash
git add src/docs/modules/ROOT/pages/tmdb-account-sync.adoc
git commit -m "docs: note auto-mirror on ownership transitions"
```

Verify branch + HEAD match.

---

## Task 6: Final verification

**Files:** none (read-only checks)

- [ ] **Step 1: Run analyzer**

Run: `flutter analyze`
Expected: zero issues across the entire codebase.

- [ ] **Step 2: Run full test suite**

Run: `flutter test`
Expected: all tests pass. The slice 4 baseline (after slice 3a + docs slice 3a merged) was 1385 passing; this slice adds 9 new mirror-hook tests, so total should be ~1394.

- [ ] **Step 3: Linux build**

Run: `flutter build linux --debug`
Expected: build succeeds.

- [ ] **Step 4: Android build**

Run: `flutter build apk --debug --flavor dev`
Expected: build succeeds.

- [ ] **Step 5: iOS / macOS**

Skip on Linux host. Document as pending.

- [ ] **Step 6: Manual inspection**

Confirm via reading source:

1. `lib/data/repositories/media_item_repository_impl.dart` — has optional `mirror` and `readMirrorEnabled` ctor params; `_maybeMirrorOnTransition` and `_maybeMirrorOnSoftDelete` private helpers exist; `update()` calls `_maybeMirrorOnTransition`; `softDelete()` calls `_maybeMirrorOnSoftDelete`.
2. `lib/presentation/providers/repository_providers.dart` — `mediaItemRepositoryProvider` injects the new deps with the try/catch fallback.
3. `test/unit/data/repositories/media_item_repository_impl_test.dart` — has 9 new mirror-related tests.
4. `src/docs/modules/ROOT/pages/tmdb-account-sync.adoc` — has the new paragraph in the *Mirror Ownership* section.
5. No new files created. No schema migration. No UI changes.

- [ ] **Step 7: Final report**

Branch: `feat/tmdb-account-sync-slice-4a-auto-remove-mirror`
HEAD: `<SHA>`
Total commits since main: `<count via git log --oneline main..HEAD | wc -l>`
Test results: `<summary>`
Linux build: `<PASS/FAIL>`
Android build: `<PASS/FAIL>`
iOS build: `<PASS/SKIPPED/FAIL>`
macOS build: `<PASS/SKIPPED/FAIL>`
Manual inspection: `<PASS/FAIL with notes>`

Any concerns to flag for the user before merge.

If something fails, status is DONE_WITH_CONCERNS and the failures are listed.

---

## Self-review

- **Spec coverage:** Each spec section maps to a task. Optional ctor params + helpers (Task 1), `update()` hook (Task 2), `softDelete()` hook (Task 3), provider wiring (Task 4), docs note (Task 5), final verification (Task 6). The 9 test cases listed in the spec are split between Tasks 2 (6 cases for `update`) and Task 3 (3 cases for `softDelete`).
- **Placeholder scan:** Test seeding pseudocode uses `/* insert ... */` because the existing repository test file's seeding helper isn't visible to me from this writing. The implementer reads the existing tests once and wires the same helper. This is a deliberate context-discovery prompt, not a placeholder for missing logic.
- **Type consistency:** `MirrorOwnershipChangeUseCase`, `TmdbPushResult`, `MediaItem`, `OwnershipStatus`, `MediaType`, `_maybeMirrorOnTransition`, `_maybeMirrorOnSoftDelete` are all named consistently across tasks and match the slice-2 baseline.
- **No new domain types:** Confirmed. No new files in `lib/domain/`.
- **No schema migration:** Confirmed. The hooks read existing rows via `getById` and don't add columns.
