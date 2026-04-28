# TMDB Account Sync — Slice 3b (Mobile UI) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the TMDB Account Sync feature usable from Android and iOS by un-gating the settings card and adding a Settings-screen tile group that routes to the existing bucket views and the resolve-conflicts screen.

**Architecture:** Reuse all existing widgets (TmdbAccountSyncSection, TmdbConnectDialog, TmdbImportDialog, TmdbDisconnectWarningDialog, TmdbBucketScreen, TmdbResolveConflictsScreen) by removing the desktop early-return on the settings card and adding a new `TmdbListsSection` widget that exposes the bucket-view routes via `ListTile` entries. No new providers, no platform code, no new packages.

**Tech Stack:** Flutter, Riverpod 3 (existing providers), GoRouter (existing routes).

**Source spec:** `docs/superpowers/specs/2026-04-28-tmdb-account-sync-slice-3b-mobile-design.md`

---

## File Layout

### Create

| Path | Responsibility |
|---|---|
| `lib/presentation/screens/settings/widgets/tmdb_lists_section.dart` | Section with three bucket-view tiles + conditional Resolve-Conflicts tile, gated on `isConnected`. |
| `test/widget/screens/settings/widgets/tmdb_lists_section_test.dart` | Widget tests for the four states (disconnected / connected / conflicts-with-ask-user / conflicts-without-ask-user). |

### Modify

| Path | Change |
|---|---|
| `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart` | Remove the `if (!PlatformCapability.isDesktop) return SizedBox.shrink()` early-return at the top of `build`. The API-key gate stays. |
| `lib/presentation/screens/settings/settings_screen.dart` | Append `TmdbListsSection()` to the API Integrations group children list, after `TmdbAccountSyncSection()`. |
| `test/widget/screens/settings/widgets/tmdb_account_sync_section_test.dart` (if exists) | Remove any test setup that forced desktop-mode for rendering — render now happens cross-platform. If no such test exists, no change. |

---

## Convention notes

- Widget tests use `ProviderScope(overrides: [...])` to inject mock providers, following the slice-A `TmdbConnectDialog` test pattern.
- Routes are `/tmdb/watchlist`, `/tmdb/rated`, `/tmdb/favourites`, `/tmdb/conflicts` — registered in slice A and slice 2.
- Tile labels use British English (`Favourites`, `TMDB Favourites`).

---

## Task 1: Create `TmdbListsSection` with widget test

**Files:**
- Create: `lib/presentation/screens/settings/widgets/tmdb_lists_section.dart`
- Create: `test/widget/screens/settings/widgets/tmdb_lists_section_test.dart`

- [ ] **Step 1: Write the failing widget test**

Create `test/widget/screens/settings/widgets/tmdb_lists_section_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_item.dart';
import 'package:mymediascanner/domain/entities/tmdb_conflict_policy.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_lists_section.dart';

void main() {
  Widget _harness({
    required TmdbConnectionState connection,
    required TmdbAccountSyncSettings settings,
    List<TmdbBridgeItem> conflicts = const [],
  }) {
    return ProviderScope(
      overrides: [
        tmdbAccountConnectionProvider.overrideWith(
            () => _StubConnectionNotifier(connection)),
        tmdbAccountSyncSettingsProvider.overrideWith(
            () => _StubSettingsNotifier(settings)),
        tmdbConflictedRowsProvider.overrideWith((ref) =>
            Stream<List<TmdbBridgeItem>>.value(conflicts)),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const Scaffold(
                  body: SafeArea(child: TmdbListsSection())),
            ),
            GoRoute(
                path: '/tmdb/watchlist',
                builder: (_, _) => const Scaffold(body: Text('Watchlist'))),
            GoRoute(
                path: '/tmdb/rated',
                builder: (_, _) => const Scaffold(body: Text('Rated'))),
            GoRoute(
                path: '/tmdb/favourites',
                builder: (_, _) => const Scaffold(body: Text('Favourites'))),
            GoRoute(
                path: '/tmdb/conflicts',
                builder: (_, _) => const Scaffold(body: Text('Conflicts'))),
          ],
        ),
      ),
    );
  }

  testWidgets('renders nothing when disconnected', (tester) async {
    await tester.pumpWidget(_harness(
      connection: const TmdbDisconnected(),
      settings: const TmdbAccountSyncSettings(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('TMDB Watchlist'), findsNothing);
    expect(find.text('TMDB Rated'), findsNothing);
    expect(find.text('TMDB Favourites'), findsNothing);
  });

  testWidgets('renders three tiles when connected', (tester) async {
    await tester.pumpWidget(_harness(
      connection: const TmdbConnected(accountId: 1, username: 'p'),
      settings: const TmdbAccountSyncSettings(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('TMDB Watchlist'), findsOneWidget);
    expect(find.text('TMDB Rated'), findsOneWidget);
    expect(find.text('TMDB Favourites'), findsOneWidget);
    expect(find.textContaining('Resolve Conflicts'), findsNothing);
  });

  testWidgets('shows Resolve Conflicts tile under ask-user policy with conflicts',
      (tester) async {
    final conflict = TmdbBridgeItem(
      id: 'br-1',
      tmdbId: 100,
      mediaType: 'movie',
    );
    await tester.pumpWidget(_harness(
      connection: const TmdbConnected(accountId: 1, username: 'p'),
      settings: const TmdbAccountSyncSettings(
        conflictPolicy: TmdbConflictPolicy.askUser,
      ),
      conflicts: [conflict],
    ));
    await tester.pumpAndSettle();
    expect(find.text('Resolve Conflicts (1)'), findsOneWidget);
  });

  testWidgets(
      'hides Resolve Conflicts tile when policy is not askUser even if conflicts exist',
      (tester) async {
    final conflict = TmdbBridgeItem(
      id: 'br-1',
      tmdbId: 100,
      mediaType: 'movie',
    );
    await tester.pumpWidget(_harness(
      connection: const TmdbConnected(accountId: 1, username: 'p'),
      settings: const TmdbAccountSyncSettings(
        conflictPolicy: TmdbConflictPolicy.preferLatestTimestamp,
      ),
      conflicts: [conflict],
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('Resolve Conflicts'), findsNothing);
  });
}

class _StubConnectionNotifier extends TmdbAccountConnectionNotifier {
  _StubConnectionNotifier(this._initial);
  final TmdbConnectionState _initial;
  @override
  Future<TmdbConnectionState> build() async => _initial;
}

class _StubSettingsNotifier extends TmdbAccountSyncSettingsNotifier {
  _StubSettingsNotifier(this._initial);
  final TmdbAccountSyncSettings _initial;
  @override
  TmdbAccountSyncSettings build() => _initial;
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/widget/screens/settings/widgets/tmdb_lists_section_test.dart`
Expected: FAIL — `TmdbListsSection` does not exist.

- [ ] **Step 3: Implement `TmdbListsSection`**

Create `lib/presentation/screens/settings/widgets/tmdb_lists_section.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/tmdb_conflict_policy.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';

/// TMDB-account list entries surfaced in the Settings screen.
///
/// Renders three route tiles (Watchlist / Rated / Favourites) when
/// connected, plus a fourth Resolve-Conflicts tile when the user has
/// chosen the ask-user conflict policy and there are conflicts pending.
///
/// Cross-platform: this is the mobile entry point for the bucket views,
/// and on desktop it complements the existing sidebar entries.
class TmdbListsSection extends ConsumerWidget {
  const TmdbListsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionAsync = ref.watch(tmdbAccountConnectionProvider);
    final isConnected = connectionAsync.value is TmdbConnected;
    if (!isConnected) return const SizedBox.shrink();

    final settings = ref.watch(tmdbAccountSyncSettingsProvider);
    final conflictsCount = ref.watch(tmdbConflictedRowsProvider).maybeWhen(
          data: (rows) => rows.length,
          orElse: () => 0,
        );
    final showConflicts =
        settings.conflictPolicy == TmdbConflictPolicy.askUser &&
            conflictsCount > 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('TMDB Lists',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_border),
            title: const Text('TMDB Watchlist'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                GoRouter.of(context).go('/tmdb/watchlist'),
          ),
          ListTile(
            leading: const Icon(Icons.star_border),
            title: const Text('TMDB Rated'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                GoRouter.of(context).go('/tmdb/rated'),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('TMDB Favourites'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                GoRouter.of(context).go('/tmdb/favourites'),
          ),
          if (showConflicts)
            ListTile(
              leading: Icon(Icons.warning_amber,
                  color: Theme.of(context).colorScheme.error),
              title: Text('Resolve Conflicts ($conflictsCount)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  GoRouter.of(context).go('/tmdb/conflicts'),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/widget/screens/settings/widgets/tmdb_lists_section_test.dart`
Expected: 4/4 pass.

- [ ] **Step 5: Run analyzer**

Run: `flutter analyze lib/presentation/screens/settings/widgets/tmdb_lists_section.dart test/widget/screens/settings/widgets/tmdb_lists_section_test.dart`
Expected: zero issues.

- [ ] **Step 6: Commit**

Verify branch is `feat/tmdb-account-sync-slice-3b-mobile` via `git branch --show-current`.

```bash
git add lib/presentation/screens/settings/widgets/tmdb_lists_section.dart \
        test/widget/screens/settings/widgets/tmdb_lists_section_test.dart
git commit -m "feat(tmdb-sync): add TmdbListsSection with route tiles for buckets and conflicts"
```

Verify `git rev-parse feat/tmdb-account-sync-slice-3b-mobile` == `git rev-parse HEAD`.

---

## Task 2: Remove desktop early-return from TmdbAccountSyncSection

**Files:**
- Modify: `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart`
- Modify (if exists): existing widget test for `TmdbAccountSyncSection`

- [ ] **Step 1: Investigate the existing card**

Read `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart`. The first lines of `TmdbAccountSyncSection.build` should look like:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  if (!PlatformCapability.isDesktop) return const SizedBox.shrink();

  final tmdbKey = (ref.watch(apiKeysProvider).value ?? {})['tmdb'] ?? '';
  if (tmdbKey.trim().isEmpty) return const SizedBox.shrink();
  // ...
```

The first guard is the desktop early-return. The second is the API-key gate (we keep this).

Also check whether `PlatformCapability` is still used elsewhere in the file. If the only use site is the line we're removing, remove the import too.

- [ ] **Step 2: Remove the desktop early-return**

Edit `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart`:

Find:
```dart
if (!PlatformCapability.isDesktop) return const SizedBox.shrink();
```

Delete this line (and any trailing blank line that becomes orphaned).

If `PlatformCapability` is no longer referenced anywhere in the file, also delete its import:

```dart
import 'package:mymediascanner/core/utils/platform_utils.dart';
```

If `PlatformCapability` is still used elsewhere in the file (e.g., to gate something else), keep the import.

- [ ] **Step 3: Check for an existing widget test that assumes desktop-only rendering**

Run: `find test/widget -name "tmdb_account_sync_section*" -print`

If no such test exists, no further test-file changes are needed.

If a test exists, read it. If it forces desktop mode (e.g., via a `PlatformCapability` override or by skipping non-desktop runs), either:
- Remove the platform override so the test exercises the now-cross-platform behaviour, OR
- Replace the desktop-specific assertion with a generic one.

Apply whichever change keeps the test meaningful. If the existing test is hostile to the removal (e.g. tightly coupled to `SizedBox.shrink()` on mobile), update the assertion to verify the card now renders on mobile too:

```dart
testWidgets('renders the card regardless of platform', (tester) async {
  // ... existing harness setup with provider overrides ...
  await tester.pumpWidget(harness);
  await tester.pumpAndSettle();
  expect(find.text('TMDB Account Sync'), findsOneWidget);
});
```

- [ ] **Step 4: Run analyzer**

Run: `flutter analyze lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart`
Expected: zero issues.

If the analyzer flags `unused_import` for `platform_utils.dart`, delete the import (this means `PlatformCapability` was only used in the line we removed).

- [ ] **Step 5: Run the section's tests (if any)**

Run: `flutter test test/widget/screens/settings/widgets/tmdb_account_sync_section_test.dart`
Expected: PASS (if such a test exists). If the file doesn't exist, skip.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart
# Only add the test file if it was modified.
git commit -m "feat(tmdb-sync): un-gate TmdbAccountSyncSection for mobile"
```

Verify branch + HEAD match.

---

## Task 3: Embed TmdbListsSection in the settings screen

**Files:**
- Modify: `lib/presentation/screens/settings/settings_screen.dart`

- [ ] **Step 1: Add the import**

At the top of `lib/presentation/screens/settings/settings_screen.dart`, alongside the existing `tmdb_account_sync_section.dart` import, add:

```dart
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_lists_section.dart';
```

- [ ] **Step 2: Add the section to the API Integrations children list**

Find the API Integrations group's `children:` list. Slice A landed it as:

```dart
children: const [ApiKeyForm(), TmdbAccountSyncSection()],
```

Change to:

```dart
children: const [
  ApiKeyForm(),
  TmdbAccountSyncSection(),
  TmdbListsSection(),
],
```

The `const` qualifier may need to drop if any of the children become non-const through future edits — for now they're all const-constructible so the literal stays.

- [ ] **Step 3: Run analyzer**

Run: `flutter analyze lib/presentation/screens/settings/settings_screen.dart`
Expected: zero issues.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/screens/settings/settings_screen.dart
git commit -m "feat(tmdb-sync): embed TmdbListsSection in settings screen"
```

Verify branch + HEAD match.

---

## Task 4: Final verification

**Files:** none

- [ ] **Step 1: Run analyzer on the entire codebase**

Run: `flutter analyze`
Expected: zero issues.

- [ ] **Step 2: Run the full test suite**

Run: `flutter test`
Expected: 1368+ tests pass (slice 2 baseline + 4 new from `TmdbListsSection`).

- [ ] **Step 3: Linux build**

Run: `flutter build linux --debug`
Expected: build succeeds.

- [ ] **Step 4: Android build**

Run: `flutter build apk --debug --flavor dev`
Expected: build succeeds.

- [ ] **Step 5: iOS / macOS** (skip on Linux host with a note)

- [ ] **Step 6: Manual inspection**

1. `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart` no longer has the `if (!PlatformCapability.isDesktop) return ...` line.
2. `lib/presentation/screens/settings/widgets/tmdb_lists_section.dart` exists with three route tiles + conditional fourth.
3. `lib/presentation/screens/settings/settings_screen.dart` includes `TmdbListsSection()` after `TmdbAccountSyncSection()` in the API Integrations children list.
4. The desktop sidebar TMDB group from slice A still renders (sanity — `app_scaffold.dart` unchanged in this slice).

- [ ] **Step 7: Final report**

Branch: `feat/tmdb-account-sync-slice-3b-mobile`
HEAD: `<SHA>`
Total commits since main: `<git rev-list --count main..HEAD>`
Test results: `<count> passing`
Linux build: `<PASS/FAIL>`
Android build: `<PASS/FAIL>`
Manual inspection: `<PASS/FAIL>`

---

## Self-review

- **Spec coverage:** Each in-scope item from the spec maps to a task. Card un-gating (Task 2), `TmdbListsSection` (Task 1), settings embedding (Task 3), final verification (Task 4). The dialog-rendering verification in the spec is covered by Task 4's manual inspection step (the dialogs don't change code-wise; they just inherit from Material 3's adaptive rendering once the card is reachable).
- **Placeholder scan:** No "TBD"/"TODO" markers. Task 2 has a conditional path for the existing widget test depending on whether one exists — this is intentional; the implementer needs to inspect first. The instructions are concrete in both branches.
- **Type consistency:** `TmdbConnectionState`, `TmdbAccountSyncSettings`, `TmdbConflictPolicy`, `TmdbBridgeItem`, `tmdbAccountConnectionProvider`, `tmdbAccountSyncSettingsProvider`, `tmdbConflictedRowsProvider` are all used consistently with the names established in slices A and 2.
- **Routing:** `/tmdb/watchlist`, `/tmdb/rated`, `/tmdb/favourites`, `/tmdb/conflicts` — all four routes are registered (slice A added the first three, slice 2 added the fourth). No router changes needed in slice 3b.
