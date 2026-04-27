# Design: TMDB Account Sync — Slice A (pull-only)

**Status:** Approved (brainstorm 2026-04-28)
**Author:** Paul Snow
**Created:** 2026-04-28
**Implements:** First slice of `docs/superpowers/plans/2026-04-28-tmdb-account-sync.md`
**Target platforms:** Desktop (Linux, macOS, Windows) for the connection-management UI; all platforms for the underlying data layer.

---

## Scope

This slice delivers a one-way pull from TMDB into MyMediaScanner. A user connects their TMDB account once, and their TMDB ratings, watchlist, and favourites are read into a local bridge table. Scanning a movie or TV item also pulls live account state for that title. **No data is written back to TMDB in this slice.**

### In scope

- TMDB v3 user-authentication flow (request token → browser approval → session ID), with a manual "I've approved it" continue button on desktop.
- New `tmdb_account_sync_items` Drift table holding bridge rows, schema bump 19 → 20.
- Pull import on first connection: rated movies, rated TV, watchlist movies, watchlist TV, favourite movies, favourite TV.
- Manual "Sync TMDB now" full-pull refresh.
- On-scan enrichment: when the metadata-confirm screen has a resolved TMDB ID and account sync is enabled, fetch and display account state.
- Three new desktop-only sidebar bucket views: TMDB Watchlist, TMDB Rated, TMDB Favourites — listing bridge rows that have no matching local item.
- Account-state badges on collection grid covers and the item-detail screen (cross-platform, ungated by desktop).
- "Convert to local item" action that promotes a bridge-only row to a real `media_items` row using the latest TMDB metadata.

### Out of scope (deferred to slice 2 or later)

- Pushing rating, watchlist, or favourite changes back to TMDB.
- The "Mirror ownership to a private TMDB list called MyMediaScanner" feature.
- Conflict-policy controls (no writes ⇒ no conflicts in this slice).
- Remote-first save mode for film/TV.
- Custom-list management beyond reading list IDs into `list_ids_json` for forward compatibility.
- Mobile-skinned settings UI and bucket-view UI.
- Background or scheduled sync.

---

## Open questions resolved during brainstorm

| PRD question | Resolution for slice A |
|---|---|
| 1 — TMDB watchlist representation | Bridge-table rows only. New TMDB Watchlist view shows them. When the user scans a disc that matches a watchlist row, the local item gains a "★ on TMDB watchlist" badge. |
| 2 — Auto-create local items from rated/favourite imports? | No. All TMDB-only entities (watchlist, rated, favourite) live as bridge rows. Conversion to a local item is an explicit user action. Review wizard noted as a future enhancement. |
| 3 — Where do remote-first rows appear? | Deferred (no remote-first in slice A). Bridge views answer the analogous question for slice A: separate views, not the main collection grid. |
| 4 — Custom lists in v1? | No general custom-list support in slice A. The bridge schema records `list_ids_json` for forward compatibility. The "MyMediaScanner private list" idea is a slice-2 push feature. |
| 5 — Rating conflict default | N/A in slice A (no writes). |
| 6 — Two-way sync push timing | N/A in slice A. |
| 7 — Remote-first row depth | Deferred. |
| Auth UX (extra) | Manual "I've approved it" continue button. No localhost callback handler in this slice. |

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                       Presentation                              │
│                                                                  │
│  TmdbAccountSyncSection (settings, desktop)                      │
│  TmdbConnectDialog (desktop)                                     │
│  TmdbBucketScreen × 3 (desktop sidebar)                          │
│  TmdbAccountPanel (metadata_confirm, all platforms)              │
│  TmdbAccountBadgeStrip (item_detail, all platforms)              │
│  TmdbBridgeBadge (collection grid covers, all platforms)         │
│        │                                                         │
│        ▼                                                         │
│  TmdbAccountSyncProvider  (AsyncNotifier, connection state)      │
│  TmdbAccountSyncSettingsProvider (Notifier, prefs-backed)        │
│  TmdbAccountSyncStatusProvider (Notifier, last-sync summary)     │
│  TmdbBridgeProvider.family<TmdbBridgeBucket> (AsyncNotifier)     │
└──────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────────┐
│                          Domain                                  │
│                                                                  │
│  ITmdbAccountSyncRepository (interface)                          │
│  Use cases:                                                      │
│    ConnectTmdbAccountUseCase                                     │
│    DisconnectTmdbAccountUseCase                                  │
│    ImportTmdbAccountUseCase                                      │
│    SyncTmdbAccountUseCase                                        │
│    EnrichScanWithTmdbAccountUseCase                              │
│    ConvertBridgeToLocalItemUseCase                               │
│  Entities: TmdbAccountState, TmdbBridgeItem, TmdbBridgeBucket    │
└──────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────────┐
│                           Data                                   │
│                                                                  │
│  TmdbAccountSyncRepositoryImpl                                   │
│        │                                                         │
│   ┌────┴─────────────────────────────────────────────────┐      │
│   ▼                                                       ▼      │
│  TmdbAccountApi (Retrofit)               TmdbAccountSyncDao      │
│   │                                            │                │
│   ▼                                            ▼                │
│  Dio (rate-limit interceptor)            tmdb_account_sync_items │
│  flutter_secure_storage                  (Drift, schema 20)      │
└──────────────────────────────────────────────────────────────────┘
```

### Why a separate `TmdbAccountApi`

The existing `TmdbApi` is a read-only metadata client. A second class isolates account-write operations (slice 2) so write paths cannot leak into metadata lookups. Slice A still benefits from the separation: account-state endpoints take a `session_id` query parameter that metadata endpoints must never carry.

### Why a bridge table separate from `media_items`

- A user with a long TMDB history may have hundreds of rated/favourite/watchlist entries that are not in their physical collection. They should not pollute the main collection grid.
- Bridge rows are per-device account state derived from TMDB and are intentionally **not** replicated by PostgreSQL sync.
- Slice 2 needs `local_dirty` / `last_pushed_at` per provider; folding these into `media_items.extraMetadata` would re-implement the bridge table inside JSON columns.

---

## Data model

### Schema migration 19 → 20

Add Drift table `tmdb_account_sync_items`:

| Column | Type | Notes |
|---|---|---|
| `id` | text primary key | Local UUID. |
| `media_item_id` | text nullable | Links to `media_items.id` once a local item exists. NULL for TMDB-only rows. |
| `tmdb_id` | int not null | TMDB movie or TV ID. |
| `tmdb_media_type` | text not null | `movie` or `tv`. |
| `barcode` | text nullable | Recorded for future barcode-based matching. |
| `title_snapshot` | text nullable | Last-known title for bucket-view display. |
| `poster_path_snapshot` | text nullable | Last-known poster path for bucket-view display. |
| `tmdb_rating` | real nullable | Raw TMDB rating, 0.5–10. |
| `local_rating_snapshot` | real nullable | Slice 2 only — last local rating pushed to TMDB. |
| `watchlist` | int not null default 0 | 1 if on TMDB watchlist. |
| `favorite` | int not null default 0 | 1 if marked TMDB favourite. |
| `list_ids_json` | text not null default `[]` | TMDB custom-list IDs containing this item. |
| `account_state_json` | text not null default `{}` | Raw `/account_states` payload for forward compatibility. |
| `local_dirty` | int not null default 0 | Slice 2 only. |
| `remote_dirty` | int not null default 0 | Slice 2 only. |
| `last_pulled_at` | int nullable | Unix ms. |
| `last_pushed_at` | int nullable | Slice 2 only — Unix ms. |
| `last_error` | text nullable | Last per-row sync error. |
| `created_at` | int not null | Unix ms. |
| `updated_at` | int not null | Unix ms. |

Indexes:

- `UNIQUE(tmdb_id, tmdb_media_type)` — primary lookup.
- `INDEX(media_item_id)` — for joining bridge state into local-item queries.
- `INDEX(barcode)` — for future barcode reconciliation.
- `INDEX(local_dirty, remote_dirty)` — prepares slice 2 dirty-row scans; cheap to add now.

The migration step is `_from19To20`; Drift's generated migrator wraps it. Run `dart run build_runner build --delete-conflicting-outputs` after the table is added.

### PostgreSQL sync

`tmdb_account_sync_items` is **not** included in the PostgreSQL sync table set in `lib/data/local/database/tables/sync_log_table.dart` and friends. Bridge rows are per-device and re-derivable by re-running an import on a new device. This separation is intentional and must be documented in `lib/data/local/database/app_database.dart` near the table list.

### Secure storage keys

- `tmdb.session_id` — TMDB session token.
- `tmdb.account_id` — integer account ID.
- `tmdb.account_username` — TMDB display username, used for "Connected as @x" labels.

### SharedPreferences keys

- `tmdb.account_sync.enabled` — bool master switch.
- `tmdb.account_sync.enrich_scans` — bool, default true once connected.
- `tmdb.account_sync.last_sync_at` — int ms.
- `tmdb.account_sync.last_sync_pulled` — int.
- `tmdb.account_sync.last_sync_failed` — int.
- `tmdb.account_sync.last_error` — string.
- `tmdb.account_sync.session_started_at` — int ms (diagnostics only).

---

## Authentication flow

1. User clicks **Connect TMDB Account** in `TmdbAccountSyncSection`.
2. `ConnectTmdbAccountUseCase.requestToken()` calls `GET /3/authentication/token/new` using the existing TMDB bearer token. The returned `request_token` is held in memory; not persisted.
3. App calls `launchUrl('https://www.themoviedb.org/authenticate/$requestToken', mode: LaunchMode.externalApplication)`.
4. `TmdbConnectDialog` is shown modally with three buttons: **Re-open page**, **I've approved it — continue**, **Cancel**.
5. On Continue, `ConnectTmdbAccountUseCase.exchangeForSession(requestToken)` calls `POST /3/authentication/session/new` with `{request_token}`. On success it returns a `session_id`.
6. App calls `GET /3/account` with `?session_id=...` to read `account_id` and `username`.
7. App writes `tmdb.session_id`, `tmdb.account_id`, `tmdb.account_username` into `flutter_secure_storage`. Connection state transitions `connecting → connected`.
8. The first-import dialog is offered immediately.

Failure paths:

- `request_token` exchange returns 401 → message "Approval not detected. Re-open the approval page and try again." `request_token` retained in memory so user can retry without re-fetching.
- Network failure during any step → toast + state stays `connecting`, user can retry.
- Cancel → in-memory `request_token` cleared; connection state returns to `disconnected`.

The `request_token` is never written to disk and is redacted from any debug log output.

### Token expiry / 401 handling

Any TMDB call that returns 401 in this slice clears all stored credentials, transitions connection state to `expired`, and posts a `Reconnect required` banner in the settings card.

---

## Sync engine (pull only)

### First-import wizard

Triggered immediately after a successful connect (and re-runnable from the **Import account contents** button). Modal with six checkboxes (default all on):

- Rated movies
- Rated TV
- Watchlist movies
- Watchlist TV
- Favourite movies
- Favourite TV

Confirm runs `ImportTmdbAccountUseCase`. The use case paginates through each selected bucket using TMDB's standard 20-per-page response and upserts bridge rows by `(tmdb_id, tmdb_media_type)`. A progress dialog reports `<bucket>: page n of m`.

Each bucket maps fields:

- `tmdb_id`, `tmdb_media_type` from the response object's `id` and the bucket's media type.
- `tmdb_rating` from the rated-bucket `rating` field (raw 0.5–10). `null` for non-rating buckets.
- `watchlist = 1` for watchlist buckets, `favorite = 1` for favourite buckets.
- `title_snapshot` from `title` (movie) or `name` (tv).
- `poster_path_snapshot` from `poster_path`.
- `last_pulled_at = now`.

Where the same `(tmdb_id, tmdb_media_type)` is returned by multiple buckets (a movie can be rated, watchlisted, and favourited simultaneously), all flags merge into the same bridge row.

Per-row failures are caught and recorded in `last_error`; the import does not abort. The summary screen reports `<n> imported`, `<m> failed`.

### Manual "Sync TMDB now"

Reruns the same six pulls. After all upserts complete, a **prune step** deletes bridge rows where:

- `media_item_id IS NULL`, AND
- The `(tmdb_id, tmdb_media_type)` combination did not appear in any bucket on this run, AND
- `local_dirty = 0` (will always be true in slice A, kept for slice-2 safety).

This is intentionally simpler than per-row delta tracking. A removed-from-watchlist movie disappears from the bridge on the next sync.

### On-scan enrichment

When `MetadataConfirmScreen` mounts:

1. If `accountSyncEnabled == false` → no-op.
2. If the resolved metadata has a TMDB ID and `media_type ∈ {movie, tv}` → call `EnrichScanWithTmdbAccountUseCase`.
3. The use case calls `GET /movie/{id}/account_states` or `/tv/{id}/account_states` with the stored `session_id`.
4. Response is upserted into the bridge row for `(tmdb_id, tmdb_media_type)`. `account_state_json` stores the raw payload.
5. The screen reads the bridge row via `tmdbBridgeProvider.family((tmdbId, mediaType))` and renders `TmdbAccountPanel` if a row exists.

A network failure during enrichment is non-blocking — the confirm screen renders without the panel and a small "TMDB account state unavailable" hint.

### Rate limiting

A new Dio interceptor `TmdbAccountRateLimitInterceptor`:

- On any response with status 429, reads the `Retry-After` header (seconds). If absent, falls back to exponential backoff: 1s → 2s → 4s. Maximum 3 retries per request.
- Caps concurrent in-flight requests at 5 via a simple `Semaphore` wrapper.

The interceptor is attached only to the `TmdbAccountApi` Dio instance, not to the existing metadata `TmdbApi` — slice A keeps blast radius localised.

---

## UX

### Settings → API Integrations → TMDB Account Sync (desktop only)

A new card directly below the existing TMDB API key card, gated `if (PlatformCapability.isDesktop)`. Layout top-to-bottom:

1. Heading "TMDB Account Sync" + subtitle line "Sign in to TMDB to import your ratings, watchlist, and favourites."
2. Status row: one of
   - "Disconnected" (with Connect button to the right).
   - "Connected as @username" (with Disconnect button).
   - "Reconnect required — your TMDB session expired" (red, with Connect button).
   - "Connecting…" (with spinner).
3. Toggles:
   - "Enable TMDB account sync" — master switch. Disabled until connected.
   - "Enrich scans with TMDB account state" — default on after connect.
   - "Two-way sync (coming soon)" — visible but disabled, tooltip "Available in the next release."
   - "Mirror ownership to TMDB list (coming soon)" — visible but disabled.
4. Buttons row:
   - **Import account contents** — re-opens the import wizard.
   - **Sync TMDB now** — triggers `SyncTmdbAccountUseCase`.
5. Last-sync summary: "Last sync 5 minutes ago — pulled 142, failed 0" or "Never synced". Includes last-error line in red when set.

### TMDB Connect dialog (desktop only)

Modal with title "Connect to TMDB", body "We've opened TMDB in your browser. Sign in and approve MyMediaScanner, then come back and click Continue.", and three buttons: **Re-open page** / **I've approved it — continue** / **Cancel**.

### Sidebar: TMDB group (desktop only)

When `connection.isConnected`, the desktop sidebar shows a TMDB group with three children:

- TMDB Watchlist → `/tmdb/watchlist`
- TMDB Rated → `/tmdb/rated`
- TMDB Favourites → `/tmdb/favourites`

Each route renders `TmdbBucketScreen` parameterised by the bucket. Each list row shows a poster snapshot + title + year + media-type chip + actions: **Open on TMDB** (launches TMDB URL via `url_launcher`) and **Convert to local item** (calls `ConvertBridgeToLocalItemUseCase`, which fetches full TMDB metadata and creates a `media_items` row with `OwnershipStatus.owned`).

Empty state per bucket: "Nothing on your TMDB watchlist yet. Add titles on themoviedb.org and they'll appear here after the next sync."

### MetadataConfirmScreen — `TmdbAccountPanel` (all platforms)

Shown when a bridge row exists for the resolved TMDB ID. Layout:

- Heading "Your TMDB account state".
- Rating display "Your TMDB rating: 4.5 / 5" (converted from 9/10) — with "Apply to local rating" button when local rating is empty. Pressing it sets `userRating` on the form.
- Two badges: "★ Watchlist" if `watchlist == 1`, "♥ Favourite" if `favorite == 1`.

The panel is gated by `accountSyncEnabled`, **not** by `PlatformCapability.isDesktop`, so it will render on iOS / Android once a future mobile slice adds the connect entry point.

### Item detail screen — account-state strip (all platforms)

Below the cover hero, a small horizontal strip shows TMDB icons when a bridge row exists for the item: rating chip + watchlist / favourite icons. Tapping the strip opens TMDB in the browser.

### Collection grid — bridge badge (all platforms)

A small TMDB-icon badge in the top-right of the cover when a bridge row exists, mirroring the existing media-type badge pattern.

---

## Mobile readiness

This slice introduces no platform-specific dependencies. All cross-cutting code is mobile-ready:

- `url_launcher`, `flutter_secure_storage`, Dio, Drift all support iOS and Android.
- All `domain/` and `data/` code is pure Dart.
- Account-state badges, the metadata-confirm panel, the item-detail strip, and the collection-grid badge are gated only by `accountSyncEnabled` and **not** by `PlatformCapability.isDesktop`.

The only desktop-gated surfaces in this slice are:

- The Settings card (`TmdbAccountSyncSection`).
- The Connect dialog (`TmdbConnectDialog`).
- The three sidebar bucket entries and their `TmdbBucketScreen` routes.

A future mobile slice will:

- Add a mobile-skinned settings entry point.
- Replace the dialog with a mobile-appropriate flow (likely the same dialog re-laid-out, or a native-feeling full-screen wizard).
- Surface bucket views via the mobile drawer or a new bottom-nav entry.
- Optionally adopt platform-specific deep-linking (custom URL scheme on iOS, Android intent filter) to skip the manual continue button. Not required — the manual flow works on mobile too.

---

## Testing

### Unit tests

- `tmdb_account_mapper_test.dart` — TMDB-rating ↔ local-rating conversion both directions, including 0.5 and 10.0 boundaries.
- `tmdb_account_sync_dao_test.dart` — upsert merging across buckets, getByTmdbId, listByBucket filters, deleteByIds, prune-stale.
- `tmdb_account_sync_settings_test.dart` — settings persistence and clearing.
- `connect_tmdb_account_usecase_test.dart` — happy path; 401 on token exchange; cancel clears in-memory token.
- `import_tmdb_account_usecase_test.dart` — six-bucket merge, partial-failure handling.
- `sync_tmdb_account_usecase_test.dart` — prune logic.
- `enrich_scan_with_tmdb_account_usecase_test.dart` — enrichment writes bridge row.
- `convert_bridge_to_local_item_usecase_test.dart` — produces correct `media_items` row.

### Repository tests

- Importer happy path against a mocked Dio adapter.
- 401 on `/account` clears creds and transitions state to `expired`.
- 429 on a paginated bucket triggers backoff and recovers.
- Prune deletes only orphan TMDB-only rows.

### Widget tests

- Settings card states: disconnected, connecting, connected, expired.
- Connect dialog: launch URL, continue success, continue 401 message.
- `TmdbAccountPanel` rendering on metadata-confirm.
- `TmdbBucketScreen` empty state, populated rows, "Convert to local item" action.

### Integration tests

- Full connect flow against a `MockHttpServer` impersonating TMDB.
- First-import populates bridge rows.
- Scan → metadata confirm screen shows account panel.

---

## Files

### Create (28)

- `lib/data/local/database/tables/tmdb_account_sync_items_table.dart`
- `lib/data/local/dao/tmdb_account_sync_dao.dart`
- `lib/data/remote/api/tmdb/tmdb_account_api.dart`
- `lib/data/remote/api/tmdb/models/tmdb_request_token_dto.dart`
- `lib/data/remote/api/tmdb/models/tmdb_session_dto.dart`
- `lib/data/remote/api/tmdb/models/tmdb_account_dto.dart`
- `lib/data/remote/api/tmdb/models/tmdb_account_state_dto.dart`
- `lib/data/remote/api/tmdb/models/tmdb_account_list_page_dto.dart`
- `lib/data/remote/api/tmdb/tmdb_account_rate_limit_interceptor.dart`
- `lib/data/repositories/tmdb_account_sync_repository_impl.dart`
- `lib/data/mappers/tmdb_account_mapper.dart`
- `lib/domain/repositories/i_tmdb_account_sync_repository.dart`
- `lib/domain/entities/tmdb_account_state.dart`
- `lib/domain/entities/tmdb_bridge_item.dart`
- `lib/domain/entities/tmdb_bridge_bucket.dart`
- `lib/domain/usecases/connect_tmdb_account_usecase.dart`
- `lib/domain/usecases/disconnect_tmdb_account_usecase.dart`
- `lib/domain/usecases/import_tmdb_account_usecase.dart`
- `lib/domain/usecases/sync_tmdb_account_usecase.dart`
- `lib/domain/usecases/enrich_scan_with_tmdb_account_usecase.dart`
- `lib/domain/usecases/convert_bridge_to_local_item_usecase.dart`
- `lib/presentation/providers/tmdb_account_sync_provider.dart` (hosts the four Riverpod providers shown in the architecture diagram)
- `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart`
- `lib/presentation/screens/settings/widgets/tmdb_connect_dialog.dart`
- `lib/presentation/screens/settings/widgets/tmdb_import_dialog.dart`
- `lib/presentation/screens/tmdb/tmdb_bucket_screen.dart`
- `lib/presentation/screens/metadata_confirm/widgets/tmdb_account_panel.dart`
- `lib/presentation/widgets/tmdb_bridge_badge.dart`

### Modify (~10)

- `lib/data/local/database/app_database.dart` — register table, add `_from19To20`, bump `schemaVersion` to 20.
- `lib/data/local/database/app_database.g.dart` — regenerated.
- `lib/presentation/screens/settings/settings_screen.dart` — embed `TmdbAccountSyncSection` after the existing API key form.
- `lib/presentation/providers/repository_providers.dart` — register the new repository and use-case providers.
- `lib/presentation/providers/settings_provider.dart` — extend secure-storage / prefs keys.
- `lib/app/router.dart` — add `/tmdb/watchlist`, `/tmdb/rated`, `/tmdb/favourites` routes.
- `lib/presentation/screens/metadata_confirm/metadata_confirm_screen.dart` — render `TmdbAccountPanel` when applicable; offer "Apply TMDB rating".
- `lib/presentation/widgets/app_scaffold.dart` — add the desktop sidebar TMDB group.
- `lib/presentation/screens/item_detail/item_detail_screen.dart` — render the account-state strip when bridge row exists.
- `lib/presentation/screens/collection/widgets/library_grid_card.dart` (or equivalent) — add the bridge badge overlay.

---

## Acceptance criteria

- A desktop user can navigate to Settings → API Integrations and see the TMDB Account Sync card.
- The card is hidden until both a TMDB metadata bearer token and the desktop platform check are satisfied.
- The user can connect a TMDB account using the manual continue dialog and disconnect it again.
- TMDB session credentials live in `flutter_secure_storage`, never in SQLite.
- After a successful connect, the import wizard offers six buckets and the user can choose any subset.
- A scanned movie or TV item with a known TMDB ID and account sync enabled triggers an `/account_states` call, the result is stored in the bridge row, and the metadata-confirm screen shows the account panel.
- The local rating field on the metadata-confirm screen can be filled by clicking "Apply TMDB rating", which converts 0.5–10 to 0–5 by halving.
- TMDB-only entries are visible in the three desktop bucket screens and absent from the main collection grid.
- Items in the main collection grid that have a bridge row show the small TMDB badge on their cover.
- 429 responses do not crash and do not spin in a tight retry loop.
- 401 responses clear stored credentials and transition the connection state to `expired`.
- Disconnecting clears stored credentials. Bridge rows remain so existing local items keep their badges; the user can re-connect later without re-importing.
- The `tmdb_account_sync_items` table is not pushed to PostgreSQL during a sync run.
- iOS and Android builds compile and pass tests; no platform plugin is added that lacks iOS/Android support.

---

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| TMDB v3 user-auth flow is poorly documented in places. | Manual continue dialog tolerates the worst case (browser eats the redirect). All logging redacts the request token. |
| Large account histories (thousands of rated items) make first import slow. | Pagination is sequential per bucket but buckets run concurrently behind the semaphore (max 5). Per-row failures are non-fatal. |
| 401 mid-sync leaves bridge rows half-updated. | `last_pulled_at` is per-row; the next "Sync now" simply refreshes them. |
| Mobile readiness slips because the slice never runs on mobile in CI. | All gating uses `accountSyncEnabled`, not `isDesktop`, except the three named surfaces. CI builds iOS/Android targets to catch any plugin regressions. |
| Bridge table grows unbounded over many devices and re-imports. | Manual "Sync now" prunes orphan rows. Slice A does not yet implement automatic pruning on disconnect. |

---

## Implementation order (high level — detailed plan in writing-plans output)

1. Schema, table, DAO, migration, generated code.
2. API client, DTOs, mappers, rate-limit interceptor.
3. Repository, use cases.
4. Providers and secure-storage / prefs wiring.
5. Settings card and connect dialog (desktop-only).
6. Import wizard and "Sync now".
7. On-scan enrichment + metadata-confirm panel.
8. Bucket screens and sidebar entries.
9. Item-detail strip and collection-grid badge (cross-platform).
10. Tests at every layer; iOS/Android compile check at the end.
