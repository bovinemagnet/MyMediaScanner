# Design: TMDB Account Sync — Slice 2 (push + ownership mirror)

**Status:** Approved (brainstorm 2026-04-28)
**Author:** Paul Snow
**Created:** 2026-04-28
**Implements:** Second slice of `docs/superpowers/plans/2026-04-28-tmdb-account-sync.md`. Builds on slice A (`2026-04-28-tmdb-account-sync-slice-a-design.md`, merged in PR #70).
**Target platforms:** Desktop for connection-management UI; cross-platform for item-detail toggles and bridge controls.
**GitHub issue:** #69

---

## Scope

Slice 2 introduces **two-way sync**: local edits to ratings, watchlist, favourites, and ownership flow back to TMDB. Foundations from slice A (bridge table with `localDirty`/`lastPushedAt`/`listIdsJson`, the rate-limit interceptor, the auth flow, the settings card, the bucket screens) are reused. Schema 20 is unchanged.

### In scope

1. **Push pipeline foundation.** Per-row `_pushOne` writes pending changes (rating / watchlist / favourite / ownership-list membership) to TMDB. Triggered by an `enqueuePush` call after each local edit. Per-row error stored in `last_error`; dirty flag clears on success. Failure paths (401, 429, 5xx, network) keep the row dirty for retry.
2. **Push rating** — `POST /movie/{id}/rating` and `POST /tv/{id}/rating` when local rating changes. `DELETE /…/rating` when the user clears a rating.
3. **Push watchlist / favourite** — `POST /account/{id}/watchlist` and `POST /account/{id}/favorite` when user toggles those flags locally on movies/TV with bridge rows.
4. **MyMediaScanner-list ownership mirror.** Lazy-create or reuse-by-name a private TMDB list called "MyMediaScanner". Add owned items / remove disowned items. Toggleable per-account (default OFF — opt-in).
5. **Cross-reference write actions on TMDB Watchlist view.** "Mark as owned" combines convert-to-local + remove-from-TMDB-watchlist + add-to-mirror-list (if mirror enabled). "Remove from TMDB watchlist" is a stand-alone action.
6. **Conflict policy.** User-selectable: prefer latest timestamp (default) / prefer local / prefer TMDB / ask user. Settings radio + a new "Resolve conflicts" screen for the ask-user path.

### Out of scope (slice 3+)

- Remote-first save mode for film/TV.
- Custom-list management beyond the single MyMediaScanner list.
- Mobile-skinned settings UI (cross-platform UI surfaces from this slice still render correctly on mobile, but settings stays desktop-only).
- Background or scheduled sync.
- Bulk push-retry UI beyond a single "retry all pending" button.

---

## Open questions resolved during brainstorm

| Question | Resolution |
|---|---|
| PRD Q5 — Rating conflict default | User-selectable (E), default `preferLatestTimestamp` (A). Settings radio with four options. |
| PRD Q6 — Push timing | Immediate push with retry on failure (A). No debounce. Failure handling via `last_error` + retry-all button. |
| MyMediaScanner list creation | Lazy creation on first ownership change (A). Always reuse-by-name when an existing "MyMediaScanner" list is found on TMDB. |
| Cross-reference watchlist actions | "Mark as owned" performs convert-to-local + remove-from-TMDB-watchlist + add-to-mirror-list. "Remove from TMDB watchlist" is a separate stand-alone action. |
| Rating-edit trigger | Wired into the existing item-detail rating commit point (slider release / save). Marks `localDirty=true` and fires immediate push. |
| Watchlist / favourite toggle UI | New `TmdbAccountControlsSection` on item-detail screen — toggle chips for movies / TV with bridge rows. |
| Disconnect with pending dirty rows | Pre-disconnect dialog warns: "Push and disconnect" / "Disconnect anyway" / "Cancel". |
| Push pipeline shape | Per-row independent — each push is its own future. No queue ordering. |

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                       Presentation                              │
│                                                                  │
│  TmdbAccountSyncSection (settings)                               │
│    + ConflictPolicySelector                                      │
│    + Pending-push count + retry button                           │
│  TmdbDisconnectWarningDialog                                     │
│  TmdbResolveConflictsScreen (only when policy = askUser)         │
│  TmdbAccountControlsSection (item-detail, cross-platform)        │
│  TmdbBucketScreen (slice A, with new actions)                    │
│        │                                                         │
│        ▼                                                         │
│  Existing slice-A providers + new:                               │
│  tmdbDirtyCountProvider (Stream<int>)                            │
│  tmdbConflictPolicyProvider (NotifierProvider)                   │
└──────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────────┐
│                          Domain                                  │
│                                                                  │
│  ITmdbAccountSyncRepository (extended interface)                 │
│  Use cases (new):                                                │
│    PushTmdbChangeUseCase                                         │
│    ToggleTmdbWatchlistUseCase                                    │
│    ToggleTmdbFavoriteUseCase                                     │
│    MirrorOwnershipChangeUseCase                                  │
│    MarkTmdbWatchlistOwnedUseCase                                 │
│    ResolveTmdbConflictUseCase                                    │
│  Entities (new): TmdbConflictPolicy, TmdbPushAction              │
└──────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────────┐
│                           Data                                   │
│                                                                  │
│  TmdbAccountSyncRepositoryImpl (extended)                        │
│    + _pushOne(row): per-row push                                 │
│    + _ensureMyMediaScannerListId(): lazy create-or-find          │
│    + _resolveConflict(local, remote, policy): conflict logic     │
│        │                                                         │
│        ▼                                                         │
│  TmdbAccountApi (extended)                                       │
│    + POST /movie/{id}/rating, /tv/{id}/rating, DELETE …          │
│    + POST /account/{id}/watchlist, /favorite                     │
│    + POST /list, GET /account/{id}/lists,                        │
│      POST /list/{id}/add_item, /remove_item                      │
└──────────────────────────────────────────────────────────────────┘
```

### TMDB v3 list endpoints (chosen over v4)

V4 list endpoints exist but require a v4 access token (a separate auth flow). V3 list endpoints — `POST /list`, `GET /list/{id}`, `POST /list/{id}/add_item`, `POST /list/{id}/remove_item`, `GET /account/{id}/lists` — all accept the existing `session_id` query parameter. Slice 2 stays on v3 to keep the auth surface uniform. The trade-off is that v3 list responses use a slightly different shape than v4 (mainly `list_id` returned as `int` for v3 vs `string` for v4); we model v3 directly.

### Push pipeline

The pipeline is intentionally minimal — each push is a single API call, gated on the bridge row being dirty. There is no batch optimisation:

```
enqueuePush(tmdbId, mediaType):
  1. Read bridge row.
  2. If !connected → mark error "Not connected", return.
  3. Determine push actions from delta between bridge state and last-pushed snapshot:
     - If localRatingSnapshot != lastPushedRating → POST rating
     - If watchlist != lastPushedWatchlist → POST watchlist
     - If favorite != lastPushedFavorite → POST favorite
     - If MyMediaScanner-mirror enabled and mediaItem is owned/disowned-since-last-push → list add/remove
  4. For each action:
     - Call API; on 4xx/5xx, store error in last_error and stop (other actions for this row are deferred).
  5. On all-success: localDirty=false, lastPushedAt=now, lastError=null.
  6. On any failure: localDirty stays true, lastError populated.
```

Slice A's existing `localRatingSnapshot` column repurposes as the "last pushed rating" — set after a successful rating push. A subsequent rating change re-marks dirty so the next push re-runs.

The "delta from last push" approach means a row can have multiple pending actions but pushes them as one logical commit. We do **not** track per-action dirty flags — the flag is per-row.

### Conflict resolution

Conflicts arise during **pull** operations (sync-now full pull and scan-time enrichment), not during pushes. When a pull fetches state for a title:

```
1. Read bridge row.
2. If localDirty == false → standard pull (overwrite bridge state).
3. If localDirty == true:
   a. Compare bridge.updatedAt against the implied remote freshness.
      Remote freshness is approximated as "now" because TMDB doesn't return updated_at.
   b. Apply policy:
      - preferLatestTimestamp: if bridge.updatedAt < (now - threshold of 5min) → pull wins
                                else → keep dirty.
      - preferLocal: keep dirty, don't overwrite.
      - preferTmdb: clear dirty, accept remote.
      - askUser: keep dirty + last_error="Conflict — resolve in settings".
```

The 5-minute "fresh local edit" threshold for `preferLatestTimestamp` is conservative. In practice the push-immediate model from PRD Q6=A means most local edits push within seconds, so the conflict window is tiny.

### MyMediaScanner-list lifecycle

```
_ensureMyMediaScannerListId():
  cached = secureStorage.read(tmdb.mymediascanner_list_id)
  if cached != null → return cached
  lists = await api.getAccountLists(accountId, sessionId)
  match = lists.firstWhere(l => l.name == 'MyMediaScanner', orElse: null)
  if match != null:
    secureStorage.write(tmdb.mymediascanner_list_id, match.id.toString())
    return match.id
  created = await api.createList(sessionId, {
    name: 'MyMediaScanner',
    description: 'Mirrored from MyMediaScanner — owned items in your collection.',
  })  // v3 lists are private by default? Need to verify; if not we add iso_639_1: 'en'
  secureStorage.write(tmdb.mymediascanner_list_id, created.list_id.toString())
  return created.list_id
```

Triggers for write — wired into the existing `SaveMediaItemUseCase` and `UpdateOwnershipUseCase`:

- Item transitions `ownershipStatus` to `owned` AND has a `tmdb_id` AND mirror-toggle is on → add to MyMediaScanner list.
- Item transitions to any non-`owned` status (or is hard-deleted, though slice A established soft-deletes only) → remove from MyMediaScanner list.

Disconnect: clears the cached list ID. The list itself stays on TMDB. Reconnect → reuse-by-name finds it again.

Toggle flip-off: stops triggering writes; existing list membership unchanged.

### Disconnect warning flow

`DisconnectTmdbAccountUseCase` (slice A) gets a precondition check:

```
disconnect():
  dirty = await dao.countDirtyRows()
  if dirty > 0:
    return DisconnectResult.requiresConfirmation(dirtyCount: dirty)
  // proceed with normal disconnect
```

The settings card's Disconnect button now goes through `TmdbDisconnectWarningDialog` which presents three options:
- **Push and disconnect:** runs the push pipeline for all dirty rows, then disconnects.
- **Disconnect anyway:** discards pending changes, disconnects.
- **Cancel:** no-op.

If the push-and-disconnect path encounters errors, the dialog shows "X failed — disconnect anyway?" and stays open.

### Resolve-conflicts screen

Only relevant when `conflictPolicy == askUser`. Lists rows where `last_error` matches the conflict marker. Each row has "Keep mine" (clears last_error, keeps dirty for next push) or "Use TMDB" (clears dirty + last_error, applies remote state).

### Item-detail TMDB controls section

A new widget below the existing slice-A `TmdbBridgeBadge` strip. Cross-platform — gated only on `accountSyncEnabled`, not on `PlatformCapability.isDesktop`.

Contents:
- Rating row: shows local rating side-by-side with TMDB rating (when both differ); single value when they agree. Changes to local rating fire push via `PushTmdbChangeUseCase`.
- Watchlist chip (toggle): tap toggles state, marks dirty, fires push.
- Favourite chip (toggle): same.
- Pending indicator: small "↻ Syncing…" or "⚠ Push failed (retry)" affordance when `localDirty` or `lastError` is set on the bridge row.

This section replaces the slice-A read-only strip; the same screen anchor.

---

## Data model

**No schema migration.** Slice A bridge table has all columns we need:
- `localDirty` (BoolColumn) — set true after each local edit.
- `lastPushedAt` (IntColumn nullable) — set on successful push.
- `localRatingSnapshot` (RealColumn nullable) — repurposed: "last value pushed to TMDB".
- `lastError` (TextColumn nullable) — per-row error message.
- `listIdsJson` (TextColumn) — slice A reads, slice 2 also writes.

New secure-storage key:
- `tmdb.mymediascanner_list_id` — string-encoded TMDB list ID.

New SharedPreferences keys:
- `tmdb.account_sync.conflict_policy` — string enum value (`preferLatestTimestamp` / `preferLocal` / `preferTmdb` / `askUser`).
- `tmdb.account_sync.mirror_ownership` — bool (slice 2 makes this live; default false).
- `tmdb.account_sync.two_way_sync` — bool (slice 2 makes this live; default true once connected).

---

## TMDB API surface — additions

Added to `TmdbAccountApi`:

| Method | Endpoint | Body / Query | Purpose |
|---|---|---|---|
| `addMovieRating` | POST `/movie/{id}/rating` | `{value: <0.5–10>}`, `?session_id=` | Push rating |
| `addTvRating` | POST `/tv/{id}/rating` | same | Push TV rating |
| `removeMovieRating` | DELETE `/movie/{id}/rating` | `?session_id=` | Clear rating |
| `removeTvRating` | DELETE `/tv/{id}/rating` | same | Clear TV rating |
| `setWatchlist` | POST `/account/{id}/watchlist` | `{media_type, media_id, watchlist: bool}`, `?session_id=` | Toggle watchlist |
| `setFavorite` | POST `/account/{id}/favorite` | `{media_type, media_id, favorite: bool}`, `?session_id=` | Toggle favourite |
| `getAccountLists` | GET `/account/{id}/lists` | `?session_id=`, `&page=` | Lookup-by-name during list bootstrap |
| `createList` | POST `/list` | `{name, description, language: 'en'}`, `?session_id=` | Create MyMediaScanner list |
| `addItemToList` | POST `/list/{id}/add_item` | `{media_id: <tmdb_id>}`, `?session_id=` | Add owned item to mirror list |
| `removeItemFromList` | POST `/list/{id}/remove_item` | `{media_id: <tmdb_id>}`, `?session_id=` | Remove disowned item |

V3 list `add_item` / `remove_item` operate on movies only by default; for TV items the mirror is restricted to movies in slice 2 (TMDB v3 lists are movie-only — adding TV requires v4 lists). This is a documented limitation: the MyMediaScanner mirror covers movies; TV ownership is tracked locally only.

If TV mirror support is needed later, it requires the v4 access-token flow which is a slice-3 concern.

---

## UX

### Settings — TMDB Account Sync card (desktop only)

The slice-A card gets the following changes:

- "Two-way sync" toggle becomes live. Default ON when connected. Off → still pulls but never pushes.
- "Mirror ownership to TMDB list" toggle becomes live. Default OFF. On flip-on, no immediate API call (lazy creation on first owned save).
- New section "Conflict resolution" with a radio group:
  - Prefer latest timestamp (default)
  - Prefer local
  - Prefer TMDB
  - Ask me each time
- Last-sync summary now includes "**X pending changes**" line when dirty rows exist + a "Push pending now" button (calls `_pushAllDirty`).
- "Resolve conflicts (X)" link appears only when policy is "Ask me" AND the conflict-error count is non-zero.

### Item-detail screen — TmdbAccountControlsSection (cross-platform)

Replaces (extends) the slice-A read-only `TmdbBridgeBadge` strip. Visible when:
1. `accountSyncEnabled == true`
2. Item has a TMDB ID and media type ∈ {movie, tv}

Layout:
- Header: "TMDB Account"
- Rating row: a small star widget showing the local rating (editable). Below: "TMDB has 3.5 / 5" (only if different from local). On change, fires push.
- Watchlist chip: toggleable. Tap fires push.
- Favourite chip: toggleable. Tap fires push.
- Pending indicator: small spinner "Syncing…" or red "⚠ Push failed (tap to retry)" when `localDirty` or `lastError` is set.

If two-way sync is disabled, the chips are read-only; rating shows but doesn't push.

### TMDB Watchlist bucket (slice A screen — extended)

New row actions:
- **Mark as owned** (icon `Icons.check_circle_outline`) — runs `MarkTmdbWatchlistOwnedUseCase`:
  1. `ConvertBridgeToLocalItemUseCase` (existing) creates the local `media_items` row with `ownershipStatus: owned`.
  2. `setWatchlist(false)` push removes from TMDB watchlist.
  3. If mirror toggle on, `addItemToList` adds to MyMediaScanner list.
  4. Single SnackBar reports the combined result.
- **Remove from TMDB watchlist** (icon `Icons.bookmark_remove`) — calls `setWatchlist(false)` only. Bridge row updates: `watchlist=false`, `localDirty=true`, push fires.

Existing actions ("Open on TMDB", "Convert to local item") remain.

### Disconnect dialog

When the user clicks Disconnect in the settings card AND `dao.countDirtyRows() > 0`:

```
┌────────────────────────────────────────────────┐
│ Disconnect TMDB Account                        │
│                                                │
│ You have N unsaved changes that haven't been   │
│ pushed to TMDB yet. What would you like to do? │
│                                                │
│  [ Push and disconnect ]                       │
│  [ Disconnect anyway   ]                       │
│  [ Cancel              ]                       │
└────────────────────────────────────────────────┘
```

- **Push and disconnect:** runs `_pushAllDirty()` then `disconnect()`. Shows progress.
- **Disconnect anyway:** discards pending — bridge rows stay marked dirty but session creds are cleared. On reconnect the dirty rows resume pushing.
- **Cancel:** no-op.

### Resolve-conflicts screen (new, only when ask-user policy is set)

Route: `/tmdb/conflicts`. Sidebar entry only appears when:
- Conflict policy == askUser
- AND there are conflicted rows (`last_error` matches conflict marker)

Layout: list of bridge rows with conflicts. Each row shows:
- Title + poster
- Local state (e.g., "Local rating: 4 / 5, watchlist: yes")
- TMDB state (e.g., "TMDB rating: 5 / 5, watchlist: no")
- Two buttons: "Keep mine" / "Use TMDB"

---

## Mobile readiness

This slice continues slice A's discipline: domain + data layers are pure Dart, no platform-specific dependencies. The desktop-gated surfaces are:
- The settings card (extends slice A's existing desktop-only card)
- `TmdbDisconnectWarningDialog` (desktop only — disconnect is desktop-only)
- `TmdbResolveConflictsScreen` (desktop only for now — surfaced via desktop sidebar)

Cross-platform surfaces:
- `TmdbAccountControlsSection` on item-detail — gated only on `accountSyncEnabled`, renders on mobile.
- The bucket-screen new actions are reachable on mobile when (future) mobile sidebar adds the entries.

A future mobile slice will need:
- Mobile-skinned settings card (with conflict-policy selector).
- Mobile-skinned disconnect dialog (or replace with bottom-sheet).
- Mobile entry-point to resolve-conflicts screen.

No platform plugins added; iOS / Android compile builds remain green.

---

## Testing

### Unit tests

- `tmdb_account_mapper_test.dart` (slice A — extend) — push payload shape (rating value bounds, watchlist body shape).
- `push_tmdb_change_usecase_test.dart` — happy path; partial failure across multiple actions; 401 marks error.
- `toggle_tmdb_watchlist_usecase_test.dart` / favourite — mark dirty, fire push, verify bridge row state.
- `mirror_ownership_change_usecase_test.dart` — verify add when transitioning to owned, remove when transitioning away. Skip-if-mirror-disabled.
- `mark_tmdb_watchlist_owned_usecase_test.dart` — three-step combo verified end-to-end against a mock repository.
- `resolve_tmdb_conflict_usecase_test.dart` — each policy branch returns the right action.
- `tmdb_account_sync_repository_impl_test.dart` (slice A — extend) — push pipeline, list-bootstrap (lookup-by-name + create), conflict resolution.

### Repository tests

- Push rating against a mocked Dio adapter — happy path + 401 + 429 retry.
- List bootstrap — list exists by name → reuse; list missing → create; both paths verified.
- Disconnect-with-dirty-rows precondition check.

### Widget tests

- Conflict-policy radio in settings reflects + persists state.
- TmdbAccountControlsSection: tap watchlist → bridge state mocked to flip → SnackBar shown on push success/failure.
- TmdbDisconnectWarningDialog: each of the three buttons calls the right path.
- TmdbResolveConflictsScreen: empty state vs populated.

### Integration tests

- Extend `integration_test/tmdb_account_sync_test.dart` — connect → push rating round-trip; toggle watchlist; mirror ownership.

---

## Files

### Create (12)

- `lib/domain/entities/tmdb_conflict_policy.dart`
- `lib/domain/entities/tmdb_push_action.dart`
- `lib/domain/usecases/push_tmdb_change_usecase.dart`
- `lib/domain/usecases/toggle_tmdb_watchlist_usecase.dart`
- `lib/domain/usecases/toggle_tmdb_favorite_usecase.dart`
- `lib/domain/usecases/mirror_ownership_change_usecase.dart`
- `lib/domain/usecases/mark_tmdb_watchlist_owned_usecase.dart`
- `lib/domain/usecases/resolve_tmdb_conflict_usecase.dart`
- `lib/presentation/screens/item_detail/widgets/tmdb_account_controls_section.dart`
- `lib/presentation/screens/settings/widgets/conflict_policy_selector.dart`
- `lib/presentation/screens/settings/widgets/tmdb_disconnect_warning_dialog.dart`
- `lib/presentation/screens/tmdb/tmdb_resolve_conflicts_screen.dart`

### Modify (~10)

- `lib/data/remote/api/tmdb/tmdb_account_api.dart` — 9 new endpoints.
- `lib/data/repositories/tmdb_account_sync_repository_impl.dart` — push pipeline, list manager, conflict resolver, dirty-row count, disconnect-with-dirty handling.
- `lib/domain/repositories/i_tmdb_account_sync_repository.dart` — new methods.
- `lib/data/local/dao/tmdb_account_sync_dao.dart` — `countDirtyRows`, `watchDirtyCount`, `listConflicts`.
- `lib/presentation/providers/repository_providers.dart` — register new use-case providers.
- `lib/presentation/providers/settings_provider.dart` — add `conflictPolicy` notifier; make `mirrorOwnership` and `twoWaySync` live.
- `lib/presentation/providers/tmdb_account_sync_provider.dart` — add `tmdbDirtyCountProvider` (Stream<int>), `tmdbConflictedRowsProvider`.
- `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart` — wire live toggles, add conflict-policy selector, dirty-count display, retry-all button, disconnect-with-warning.
- `lib/presentation/screens/item_detail/item_detail_screen.dart` — embed `TmdbAccountControlsSection`.
- `lib/presentation/screens/tmdb/tmdb_bucket_screen.dart` — add new "Mark as owned" + "Remove from TMDB watchlist" actions.
- `lib/app/router.dart` — add `/tmdb/conflicts` route.
- `lib/presentation/widgets/app_scaffold.dart` — add conditional sidebar entry for resolve-conflicts when policy=askUser AND conflicts exist.

---

## Acceptance criteria

- A user with two-way sync enabled who edits a local rating → TMDB account-state for that title shows the new rating after the next refresh.
- Toggling watchlist or favourite on item-detail → TMDB state matches within a few seconds (push-immediate).
- Marking an item as owned with mirror enabled → MyMediaScanner private list (lazy-created or reused) gains the item.
- "Mark as owned" on a TMDB-watchlist row → local item created, removed from TMDB watchlist, added to MyMediaScanner list (if mirror on).
- Disconnecting with dirty rows → warning dialog with three options behaves correctly.
- Conflict policy radio in settings persists across restarts.
- Pre-existing items rated locally before slice 2 → first edit marks dirty → first push catches them up.
- 401 during push → bridge row stays dirty, UI shows "Push failed", manual retry works.
- 429 during push → backoff via slice-A interceptor, retry succeeds within 30s.
- All slice-A tests still pass.
- iOS / Android compile builds succeed.
- `flutter analyze` clean.

---

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| TMDB v3 list endpoints have undocumented quirks (e.g., `iso_639_1` required field) | Lookup-by-name → create-on-miss flow tolerates partial errors. List-create payload validated against TMDB docs during implementation. |
| MyMediaScanner-list mirror inflates v3 list to thousands of items | TMDB v3 lists support up to ~500 items typically; for larger collections, a future slice may need v4 access tokens. Document the limit in settings. |
| Multiple devices with mirror enabled all writing to the same MyMediaScanner list | The lookup-by-name reuse pattern means all devices converge on the same list. Add/remove operations are idempotent on TMDB. Concurrent writes from two devices may briefly fight, but eventual consistency holds. |
| User toggles watchlist/favourite on a non-bridge item (no TMDB metadata yet) | The toggle UI is gated on `tmdbId != null`. Items without TMDB resolution don't show the section. |
| Pre-slice-2 dirty rows from slice A's accidentally-set fields cause spurious pushes on first run | Slice A never sets `localDirty=true`. Sanity-check during the first push pipeline call: `localRatingSnapshot == null && localDirty == true` is suspicious — log a warning rather than push. |
| TV ownership-mirror is impossible on v3 list endpoints | Document: MyMediaScanner mirror covers movies; TV ownership is tracked locally. UI surfaces a one-line note in settings. |
| Push-immediate model triggers a thundering herd on first connect after re-installation (every dirty row pushes at once) | The slice-A `_Semaphore(maxConcurrent=5)` rate-limit interceptor caps in-flight requests. The push pipeline calls one row at a time per `enqueuePush`; mass-push only happens via "Push pending now" which respects the semaphore. |

---

## Implementation order (high level — detailed plan in writing-plans output)

1. New domain entities (`TmdbConflictPolicy`, `TmdbPushAction`).
2. API client extensions — 9 new endpoints + DTOs for list-create response.
3. Repository extension — push pipeline, list manager, conflict resolver.
4. New use cases (Push, ToggleWatchlist, ToggleFavorite, MirrorOwnership, ResolveConflict, MarkAsOwned).
5. Provider wiring — dirty-count stream, conflict-policy notifier, mirror toggle, two-way toggle.
6. Item-detail TmdbAccountControlsSection.
7. Settings card extensions — live toggles, conflict-policy selector, dirty-count UI, retry-all, disconnect warning.
8. Bucket screen new actions ("Mark as owned", "Remove from TMDB watchlist").
9. Resolve-conflicts screen + router/sidebar wiring.
10. Save-media-item / update-ownership integrations (mirror trigger).
11. Tests at every layer; iOS / Android compile check at the end.
