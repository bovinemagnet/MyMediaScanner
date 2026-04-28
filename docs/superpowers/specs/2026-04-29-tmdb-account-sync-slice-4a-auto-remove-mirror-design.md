# Design: TMDB Account Sync — Slice 4a (auto-remove from mirror)

**Status:** Approved (brainstorm 2026-04-29)
**Author:** Paul Snow
**Created:** 2026-04-29
**Implements:** Polish task carried forward from slice 2 (#71). Slice 2 added `MirrorOwnershipChangeUseCase` but only wired the *add* path inside `SaveMediaItemUseCase` (initial save). Slice 4a closes the gap so that ownership transitions on existing rows — including soft-deletes — also reflect on the MyMediaScanner private TMDB list.
**Target platforms:** All — purely under-the-hood, no UI changes.

---

## Scope

When a movie's `ownershipStatus` transitions to or from `OwnershipStatus.owned`, OR when an owned movie is soft-deleted, fire the existing `MirrorOwnershipChangeUseCase.add` / `.remove` automatically. Hook lives in `MediaItemRepositoryImpl.update()` and `MediaItemRepositoryImpl.softDelete()` so all transition paths — current and future — are covered.

### In scope

1. Inject optional `MirrorOwnershipChangeUseCase` and `bool Function() readMirrorEnabled` into `MediaItemRepositoryImpl`. Both nullable; existing call sites (tests, etc.) that don't supply them skip the hook entirely.
2. `update(item)` — pre-write read of the previous row by id; if the ownership state crosses the `owned` boundary, fire the appropriate mirror call after the write.
3. `softDelete(id)` — pre-write read; if the row was previously owned, fire mirror-remove before (or in parallel with) the soft-delete write.
4. Both hooks gated on:
   - Mirror toggle enabled.
   - Item has `extraMetadata['tmdb_id']` as a non-null int.
   - `extraMetadata['media_type'] == 'movie'` (slice-2 movies-only constraint — TV requires v4 list access tokens).
5. Failure mode: fire-and-forget, errors land on the bridge row's `last_error` for retry via the existing settings card "Push pending now" workflow.

### Out of scope

- Hard-delete handling. The codebase enforces soft-deletes only.
- TV ownership mirror via TMDB v4 access tokens (separate slice 4b candidate).
- Background or scheduled mirror reconciliation.
- Any UI changes — purely under the hood.

---

## Architecture

```
ConvertWishlistToOwnedUsecase ─┐
ItemDetail save / future paths ┼──→ MediaItemRepositoryImpl.update(item)
                               ┘                                  │
SoftDelete from any UI ─────────────→ MediaItemRepositoryImpl.softDelete(id)
                                                                  │
                                                                  ▼
                              ┌──────────────────────────────────────┐
                              │ Compute transition:                  │
                              │  1. Read existing row by id.         │
                              │  2. Compare old.owned ↔ new.owned.   │
                              │  3. Gate on mirror toggle + TMDB ID  │
                              │     + mediaType == movie.            │
                              │  4. Fire mirror.add or .remove,      │
                              │     fire-and-forget.                 │
                              │  5. Proceed with the local write.    │
                              └──────────────────────────────────────┘
```

### Why hook the repository, not the use cases

The slice-2 hook fired inside `SaveMediaItemUseCase` (Option B-style — per-use-case wiring). For initial saves that's fine because `SaveMediaItemUseCase` is the only insertion path. But ownership *transitions* flow through `MediaItemRepositoryImpl.update()` from multiple callers:

- `ConvertWishlistToOwnedUsecase` (existing — wishlist → owned via `_repo.update(...)`).
- `MetadataConfirmScreen` post-save rating apply (`repo.update(savedItem.copyWith(userRating: ...))`) — touches `update()` but doesn't change ownership.
- Future ownership-edit UIs (none today, but plausible).

Hooking the repository instead of each use case means future transition paths inherit the behaviour automatically. The trade-off is one cross-cutting injection on the repository — the same pattern slice 2 used on `SaveMediaItemUseCase`, just one layer down.

### What does NOT change

- `SaveMediaItemUseCase`'s slice-2 mirror-add hook stays. It fires on the initial INSERT before the row exists in the repository. The new repository-level hook only sees `update()` and `softDelete()` calls, so there's no overlap on initial saves. (Even if there were overlap, mirror-add is idempotent on TMDB.)
- `MirrorOwnershipChangeUseCase` itself is unchanged.
- No new domain entities.
- No new UI.
- No schema migration.

---

## Behaviour

### `update(item)` decision table

| Old ownership | New ownership | Mirror toggle | TMDB ID | Media type | Action |
|---|---|---|---|---|---|
| owned | wishlist / soldOff / borrowed / lent / returned | on | int | movie | `mirror.remove(tmdbId)` |
| not-owned (any) | owned | on | int | movie | `mirror.add(tmdbId)` |
| owned | owned | — | — | — | no-op (no transition) |
| not-owned | not-owned | — | — | — | no-op (no transition) |
| any | any | off | — | — | no-op (gate fails) |
| any | any | on | null | — | no-op (gate fails) |
| any | any | on | int | tv / book / music / game / other | no-op (movies-only) |
| (row missing — first insert) | any | — | — | — | no-op (treat as no transition; SaveMediaItemUseCase covers initial saves) |

### `softDelete(id)` decision table

| Existing row's ownership | Mirror toggle | TMDB ID | Media type | Action |
|---|---|---|---|---|
| owned | on | int | movie | `mirror.remove(tmdbId)`, then standard soft-delete |
| not-owned | — | — | — | standard soft-delete only |
| any | off | — | — | standard soft-delete only |
| any | on | null | — | standard soft-delete only |
| any | on | int | tv / book / music / game / other | standard soft-delete only |
| (row missing) | — | — | — | standard soft-delete only (idempotent) |

### Failure handling

The mirror call is wrapped in `unawaited(...)` with a `.catchError` handler so a failed network or TMDB error never propagates to the local write. The error is stored on the bridge row's `last_error` (slice 2's `_mirrorMutate` already does this). The user can retry via the existing settings card "Push pending now" button.

The local write (update or softDelete) **always** completes regardless of mirror outcome.

---

## Implementation outline

### `MediaItemRepositoryImpl` constructor

Add two optional params:

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
  // ... existing body ...
}
```

### `update(item)` body

```dart
@override
Future<void> update(MediaItem item) async {
  final previous = await getById(item.id);
  await _mediaItemsDao.update(_toCompanion(item));
  await _logSync('media_item', item.id, 'update', item);
  _maybeMirrorOnTransition(previous, item);
}
```

`_maybeMirrorOnTransition` is a private helper that performs the gating + dispatch:

```dart
void _maybeMirrorOnTransition(MediaItem? previous, MediaItem next) {
  if (_mirror == null || _readMirrorEnabled == null) return;
  if (!_readMirrorEnabled!()) return;
  final wasOwned = previous?.ownershipStatus == OwnershipStatus.owned;
  final isOwned = next.ownershipStatus == OwnershipStatus.owned;
  if (wasOwned == isOwned) return; // no transition
  final tmdbId = next.extraMetadata['tmdb_id'];
  final mediaType = next.extraMetadata['media_type'];
  if (tmdbId is! int) return;
  if (mediaType != 'movie') return;
  if (isOwned) {
    unawaited(_mirror!.add(tmdbId: tmdbId).catchError((_) {
      // Silent — bridge row's last_error already set by _mirrorMutate.
      return const TmdbPushResult(success: false);
    }));
  } else {
    unawaited(_mirror!.remove(tmdbId: tmdbId).catchError((_) {
      return const TmdbPushResult(success: false);
    }));
  }
}
```

### `softDelete(id)` body

```dart
@override
Future<void> softDelete(String id) async {
  final previous = await getById(id);
  final now = DateTime.now().millisecondsSinceEpoch;
  await _mediaItemsDao.softDelete(id, now);
  await _logSync('media_item', id, 'soft_delete', previous);
  if (previous != null) {
    _maybeMirrorOnSoftDelete(previous);
  }
}

void _maybeMirrorOnSoftDelete(MediaItem previous) {
  if (_mirror == null || _readMirrorEnabled == null) return;
  if (!_readMirrorEnabled!()) return;
  if (previous.ownershipStatus != OwnershipStatus.owned) return;
  final tmdbId = previous.extraMetadata['tmdb_id'];
  final mediaType = previous.extraMetadata['media_type'];
  if (tmdbId is! int) return;
  if (mediaType != 'movie') return;
  unawaited(_mirror!.remove(tmdbId: tmdbId).catchError((_) {
    return const TmdbPushResult(success: false);
  }));
}
```

### `repository_providers.dart` wiring

Update the existing `mediaItemRepositoryProvider` to optionally pass the mirror dep. Same pattern slice 2 used for `saveMediaItemUseCaseProvider`:

```dart
final mediaItemRepositoryProvider = Provider<IMediaItemRepository>((ref) {
  // Read the mirror use case; null if TMDB API key not configured.
  MirrorOwnershipChangeUseCase? mirror;
  try {
    mirror = ref.watch(mirrorOwnershipChangeUseCaseProvider);
  } catch (_) {
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

The try/catch covers the case where `mirrorOwnershipChangeUseCaseProvider` itself throws because the TMDB API key isn't configured (slice 2's repository provider gates on `tmdbKey != null`). When TMDB sync isn't set up, mirror is null and the hook is a no-op.

---

## Tests

Extend the existing repository tests (`test/unit/data/repositories/media_item_repository_impl_test.dart` if it exists, or wherever the slice-A/slice-2 repository tests live) with these cases:

1. **`update` non-owned → owned with mirror enabled, movie** — verifies `mirror.add(tmdbId)` is called once.
2. **`update` owned → non-owned with mirror enabled, movie** — verifies `mirror.remove(tmdbId)`.
3. **`update` owned → owned (rating-only change) with mirror enabled** — verifies no mirror call.
4. **`update` non-owned → non-owned (e.g., wishlist → soldOff) with mirror enabled** — verifies no mirror call.
5. **`update` non-owned → owned with mirror DISABLED** — verifies no mirror call.
6. **`update` non-owned → owned, mirror enabled, but TV item** — verifies no mirror call.
7. **`update` non-owned → owned, mirror enabled, but no TMDB ID** — verifies no mirror call.
8. **`softDelete` on owned movie with mirror enabled** — verifies `mirror.remove(tmdbId)`.
9. **`softDelete` on non-owned item with mirror enabled** — verifies no mirror call.

Use `mocktail` for the mirror dependency. The `readMirrorEnabled` callback is supplied as `() => true` or `() => false` per test.

Existing tests that construct `MediaItemRepositoryImpl` without the new deps continue to work — both deps are optional/nullable.

---

## Files

### Modify (3)

- `lib/data/repositories/media_item_repository_impl.dart` — add optional ctor params, `_maybeMirrorOnTransition` and `_maybeMirrorOnSoftDelete` helpers, hook into `update()` and `softDelete()`.
- `lib/presentation/providers/repository_providers.dart` — wire optional mirror + `readMirrorEnabled` into `mediaItemRepositoryProvider` with the same try/catch pattern slice 2 used.
- `test/unit/data/repositories/media_item_repository_impl_test.dart` (or current location) — add the 9 test cases above.

### No new files. No new domain types. No UI changes. No schema migration.

---

## Acceptance criteria

- A user with mirror enabled + an owned movie + a TMDB ID who runs `ConvertWishlistToOwnedUsecase` (the existing wishlist-to-owned path) sees the movie added to the MyMediaScanner TMDB list.
- A user who soft-deletes an owned movie sees it removed from the TMDB list.
- A user with mirror disabled sees no TMDB calls fire from these hooks.
- TV items, items without TMDB IDs, items already in their target ownership state — no TMDB calls fire.
- All existing repository / domain / integration tests still pass.
- `flutter analyze` clean.
- iOS / Android / Linux compile builds succeed.
- TMDB Account Sync user guide page (`src/docs/modules/ROOT/pages/tmdb-account-sync.adoc`) gets a small update noting that ownership transitions on existing items now mirror automatically (one paragraph in the *Mirror Ownership* section).

---

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| Existing test setup constructs `MediaItemRepositoryImpl` without the new deps and breaks compilation | New deps are optional/nullable. Existing tests pass `null` (or omit) and skip the hook. Verified by leaving the constructor's required-param shape unchanged. |
| Pre-write `getById` on every `update()` adds a DB roundtrip | Acceptable. `update()` already does a sync-log write per call. The extra read is one indexed query and only matters in hot loops (bulk import). If profiling shows it dominates, the optimisation is to read just the ownership column — defer until measured. |
| Race with the slice-2 `SaveMediaItemUseCase` mirror-add | Mirror-add is idempotent on TMDB. No correctness risk. The new hook only fires on `update()` / `softDelete()`, not on initial INSERT, so there's no double-fire for the common case. |
| Failed mirror call crashes the local write | `unawaited(...).catchError(...)` ensures the local write always completes. The error lands on the bridge row's `last_error`. |
| Convert-bridge-to-local-item (slice A) creates a new `media_items` row via insert + bridge link — does that fire the hook? | The insert path goes through `SaveMediaItemUseCase` (slice 2's hook fires). The bridge `linkToMediaItem` is a DAO write that doesn't touch `update()`. No double-fire. |
| `MetadataConfirmScreen` post-save rating apply (`repo.update(savedItem.copyWith(userRating: ...))`) is owned → owned and triggers a no-op on the new hook | Yes — the wasOwned == isOwned branch returns early. No work, no TMDB call. |

---

## Implementation order (high level — detailed plan in writing-plans output)

1. Add the optional ctor params + private helpers in `MediaItemRepositoryImpl`.
2. Wire `update()` and `softDelete()` to call the helpers.
3. Update `mediaItemRepositoryProvider` to inject the new deps.
4. Add the 9 test cases.
5. Update the user guide with the new behaviour note.
6. Final verification: `flutter analyze`, `flutter test`, Linux + Android builds.
