# Design: TMDB Account Sync — Slice 3b (mobile UI)

**Status:** Approved (brainstorm 2026-04-28)
**Author:** Paul Snow
**Created:** 2026-04-28
**Implements:** Mobile UI surfaces for the TMDB Account Sync feature originally scoped in `docs/superpowers/plans/2026-04-28-tmdb-account-sync.md`. Builds on slice A (PR #70) and slice 2 (PR #71).
**Target platforms:** Android, iOS — same widget code as desktop, with new mobile entry points.

---

## Scope

Most TMDB account-sync UI surfaces are already cross-platform: `TmdbBridgeBadge` on collection grid covers, `TmdbBridgeBadge` strip on item-detail, `TmdbAccountControlsSection` on item-detail, and `TmdbAccountPanel` on metadata-confirm all render on iOS/Android because they're gated only on `accountSyncEnabled`, never on `PlatformCapability.isDesktop`.

The remaining gap is **how a mobile user reaches the connection-management UI and the bucket views**. Slice A/2 routed those through:
- `TmdbAccountSyncSection` (settings card) — desktop early-returned via `if (!PlatformCapability.isDesktop) return SizedBox.shrink()`.
- Three bucket views accessed via desktop sidebar entries.
- Resolve-conflicts screen accessed via conditional desktop sidebar entry.

Slice 3b ungates the settings card and adds Settings-screen entry points for the bucket views and resolve-conflicts screen. Sidebar entries on desktop remain — they coexist with the settings tiles.

### In scope

1. Remove the desktop-only early-return from `TmdbAccountSyncSection`. The card now renders on all platforms when a TMDB API key is configured (the existing API-key gate stays).
2. New `TmdbListsSection` widget — three tiles routing to existing bucket screens (`/tmdb/watchlist`, `/tmdb/rated`, `/tmdb/favourites`) + a conditional fourth tile for the resolve-conflicts route when `policy == askUser && conflicts > 0`.
3. Embed `TmdbListsSection` in `settings_screen.dart`'s API Integrations group, immediately below the existing `TmdbAccountSyncSection`.
4. Verify the existing `TmdbConnectDialog`, `TmdbImportDialog`, and `TmdbDisconnectWarningDialog` (all `AlertDialog` widgets) render correctly on small mobile screens. Material 3 dialogs are responsive — no widget changes expected.
5. Update any widget tests that previously assumed desktop-only rendering of `TmdbAccountSyncSection`.
6. Add a widget test for `TmdbListsSection` covering: empty (not connected), connected (three tiles), and conflicts-with-ask-user (four tiles).

### Out of scope (deferred)

- Custom URL scheme / Universal Links / App Links for post-approval auto-return on mobile. The slice-A/2 manual continue button still works.
- Mobile-specific reskins of the dialogs.
- Reorganising the bottom navigation bar.
- Mobile-specific TMDB account icon set or branding.

---

## Architecture

No new platform code, no new packages, no new providers. The full set of changes:

```
┌──────────────────────────────────────────────────────────────────┐
│                     Settings screen                              │
│                                                                  │
│   API Integrations                                               │
│   ├─ ApiKeyForm (existing)                                       │
│   ├─ TmdbAccountSyncSection (existing — desktop gate REMOVED)    │
│   └─ TmdbListsSection (NEW) — bucket entry tiles                 │
└──────────────────────────────────────────────────────────────────┘
            │                                          │
            ▼                                          ▼
┌────────────────────────┐                  ┌────────────────────────┐
│ TmdbConnectDialog      │                  │ TmdbBucketScreen       │
│ TmdbImportDialog       │                  │ TmdbResolveConflicts   │
│ TmdbDisconnectWarning  │                  │   Screen               │
│ (existing AlertDialog) │                  │ (existing — already    │
│ — render on mobile     │                  │   mobile-aware via     │
│ via Material 3)        │                  │   conditional AppBar)  │
└────────────────────────┘                  └────────────────────────┘
```

The existing slice-A `TmdbBucketScreen` already conditionally renders `ScreenHeader` on desktop and `AppBar` on mobile (slice-A Task 16 fix). The slice-2 `TmdbResolveConflictsScreen` does the same. Both work on mobile out of the box once a mobile entry point exists.

### TmdbListsSection layout

Visible only when `connectionAsync.value is TmdbConnected`. Title row "TMDB Lists" + three `ListTile`s (icon + label + arrow), each tapping to `GoRouter.of(context).go(...)`:

| Tile | Icon | Route |
|---|---|---|
| TMDB Watchlist | `Icons.bookmark_border` | `/tmdb/watchlist` |
| TMDB Rated | `Icons.star_border` | `/tmdb/rated` |
| TMDB Favourites | `Icons.favorite_border` | `/tmdb/favourites` |
| Resolve Conflicts (N) | `Icons.warning_amber` | `/tmdb/conflicts` |

The fourth tile renders only when:
- `settings.conflictPolicy == TmdbConflictPolicy.askUser`
- AND `tmdbConflictedRowsProvider` data list is non-empty

The label includes the count parenthetical, mirroring the desktop sidebar pattern.

### Settings card un-gate

In `TmdbAccountSyncSection.build`, the first line is currently:

```dart
if (!PlatformCapability.isDesktop) return const SizedBox.shrink();
```

Remove this. The card now renders on any platform where the next gate (API key configured) is satisfied:

```dart
final tmdbKey = (ref.watch(apiKeysProvider).value ?? {})['tmdb'] ?? '';
if (tmdbKey.trim().isEmpty) return const SizedBox.shrink();
```

The remainder of the build method is platform-agnostic Material widgets — no further changes needed.

### Desktop coexistence

On desktop, the Settings card AND the desktop sidebar TMDB group both surface the bucket views. Tapping either route reaches the same `TmdbBucketScreen` instance via the shell branch. The sidebar gives quick top-level navigation; the settings tiles give a self-contained entry point that doesn't depend on the sidebar being expanded. Both useful on desktop; only the settings tiles work on mobile.

### Mobile UX flow

```
Open app on mobile (e.g. Android)
  ↓
Bottom-nav: Library / Scan / Insights / etc.
  ↓
(Settings is reached via Library → AppBar overflow → "Settings", or via the existing settings route — same as today)
  ↓
Settings screen
  ↓
Scroll to "API Integrations" section
  ↓
TMDB Account Sync card (now renders on mobile)
  ├─ Status: Disconnected → Connect button
  ├─ Connect dialog opens (AlertDialog), user approves in browser, taps Continue
  ├─ Status: Connected as @user
  ├─ Toggles, conflict-policy radio, last-sync, etc.
  ├─ Buttons: Import account contents, Sync TMDB now
  ↓
TMDB Lists section
  ├─ TMDB Watchlist → tap → /tmdb/watchlist (TmdbBucketScreen with mobile AppBar)
  ├─ TMDB Rated → tap → /tmdb/rated
  ├─ TMDB Favourites → tap → /tmdb/favourites
  └─ Resolve Conflicts (3) → tap → /tmdb/conflicts (only when ask-user policy + conflicts)
```

---

## Test changes

### Updated tests

- Any existing widget test for `TmdbAccountSyncSection` that wrapped the test in a desktop-mode override now needs to be replaced with a generic test (no platform override needed) OR have the override kept for the desktop-specific behaviour.
- Search the test tree for `TmdbAccountSyncSection` to find any.

### New widget test

`test/widget/screens/settings/widgets/tmdb_lists_section_test.dart` covering:

- **Disconnected state** — section renders nothing (or a minimal "Connect TMDB to see lists" hint, matching the empty-state pattern of other settings sub-sections).
- **Connected state** — three tiles visible (Watchlist / Rated / Favourites). Tapping each invokes router with the right route.
- **Conflicts-with-ask-user** — fourth tile visible with the count.
- **Conflicts-but-no-ask-user-policy** — fourth tile NOT visible.

---

## Files

### Create (2)

- `lib/presentation/screens/settings/widgets/tmdb_lists_section.dart` — the new section widget.
- `test/widget/screens/settings/widgets/tmdb_lists_section_test.dart` — widget test.

### Modify (~2)

- `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart` — remove the `if (!PlatformCapability.isDesktop) return SizedBox.shrink()` line. No other changes; the rest of the card is already responsive.
- `lib/presentation/screens/settings/settings_screen.dart` — append `TmdbListsSection()` to the API Integrations group children list, after `TmdbAccountSyncSection()`.

That's it. Slice 3b is genuinely small — most of the work was done by enforcing cross-platform discipline in slices A and 2.

---

## Mobile readiness — verification checklist

After implementation:

- `flutter build apk --debug --flavor dev` succeeds.
- `flutter build ios --no-codesign` succeeds (or pending if Linux-only host).
- Manual on-device run of Android emulator: settings card renders, connect dialog opens, after manual approval the user reaches Connected state.
- Manual on-device run of Android: TMDB Lists tiles route to bucket screens. The bucket screens' AppBar shows on mobile (slice-A behaviour).
- `TmdbAccountControlsSection` on item-detail still works (cross-platform from slice 2).
- `TmdbAccountPanel` on metadata-confirm still works (cross-platform from slice A).
- `TmdbBridgeBadge` overlays on collection grid still work (cross-platform from slice A).

---

## Acceptance criteria

- An Android user with the TMDB API key configured can:
  - See the TMDB Account Sync card in Settings.
  - Connect a TMDB account via the manual continue dialog.
  - Run the import and sync flows.
  - Navigate to the three bucket views via the new TMDB Lists tiles.
  - Disconnect (with the warning dialog if dirty rows exist).
- All existing tests still pass.
- New widget test for `TmdbListsSection` covers the four states.
- `flutter analyze` clean.
- iOS and Android compile builds succeed.
- No new platform plugins, no manifest changes, no new packages.

---

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| Settings card looks cramped on a narrow (360dp) phone screen | Standard Material 3 widgets are responsive. If specific overflow shows up during manual testing, address with `Wrap` for action button rows or single-column SwitchListTile arrangement. The existing card already uses `Wrap` for action buttons. |
| Mobile users find the manual continue dialog clunky | Documented as out of scope. Future polish slice can add custom URL scheme / app links if friction becomes a complaint. |
| Bucket-view branch routing fails when navigated from Settings on mobile (vs sidebar on desktop) | `GoRouter.go('/tmdb/watchlist')` is a top-level route call — works the same regardless of source. Will verify in widget test. |
| Widget tests over-mock and miss the platform-conditional rendering | New widget test for `TmdbListsSection` runs without any platform override and verifies behaviour by provider state, not platform. |

---

## Implementation order (high level — detailed plan in writing-plans output)

1. Create `TmdbListsSection` widget.
2. Write its widget test (TDD).
3. Remove the desktop early-return in `TmdbAccountSyncSection`.
4. Embed `TmdbListsSection` in `settings_screen.dart`.
5. Update any existing widget tests that assumed desktop-only `TmdbAccountSyncSection` rendering.
6. Final verification: `flutter analyze`, full test suite, Android + Linux builds.
