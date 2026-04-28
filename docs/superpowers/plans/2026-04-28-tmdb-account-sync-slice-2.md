# TMDB Account Sync — Slice 2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add two-way TMDB account sync — push local rating / watchlist / favourite changes immediately to TMDB, mirror local ownership to a private "MyMediaScanner" TMDB list, surface cross-reference write actions on the TMDB Watchlist view, and provide user-selectable conflict policy.

**Architecture:** Build on slice A's bridge table (no schema migration). Per-row push pipeline keyed off `localDirty`. Lazy-create-or-find pattern for the MyMediaScanner v3 list. Conflict resolver consulted during pulls. New domain entities for policy + push action enums. Item-detail gets a cross-platform `TmdbAccountControlsSection`. Settings extends the slice-A card with live toggles, conflict-policy radio, and a "X pending changes" affordance.

**Tech Stack:** Flutter, Drift (SQLite), Riverpod 3, Retrofit + Dio (slice A's `TmdbAccountApi` extended with 9 new endpoints), flutter_secure_storage, SharedPreferences, mocktail.

**Source spec:** `docs/superpowers/specs/2026-04-28-tmdb-account-sync-slice-2-design.md`

**GitHub issue:** #69

---

## File Layout

### Create

| Path | Responsibility |
|---|---|
| `lib/domain/entities/tmdb_conflict_policy.dart` | Enum: `preferLatestTimestamp / preferLocal / preferTmdb / askUser` plus serialise helpers. |
| `lib/domain/entities/tmdb_push_action.dart` | Sealed value: `PushRating / PushWatchlist / PushFavorite / PushOwnership / RemoveRating`. |
| `lib/data/remote/api/tmdb/models/tmdb_list_create_response_dto.dart` | DTO for `POST /list` response. |
| `lib/data/remote/api/tmdb/models/tmdb_account_lists_page_dto.dart` | DTO for `GET /account/{id}/lists`. |
| `lib/data/remote/api/tmdb/models/tmdb_status_response_dto.dart` | DTO for TMDB success-style responses (`{success, status_code, status_message}`). |
| `lib/domain/usecases/push_tmdb_change_usecase.dart` | Per-row push orchestration. |
| `lib/domain/usecases/toggle_tmdb_watchlist_usecase.dart` | Mark dirty + push for watchlist. |
| `lib/domain/usecases/toggle_tmdb_favorite_usecase.dart` | Mark dirty + push for favourite. |
| `lib/domain/usecases/mirror_ownership_change_usecase.dart` | Add/remove from MyMediaScanner list on ownership transition. |
| `lib/domain/usecases/mark_tmdb_watchlist_owned_usecase.dart` | Three-step: convert + remove-from-watchlist + add-to-mirror-list. |
| `lib/domain/usecases/resolve_tmdb_conflict_usecase.dart` | User-applied "Keep mine" / "Use TMDB" decisions. |
| `lib/presentation/screens/item_detail/widgets/tmdb_account_controls_section.dart` | Cross-platform item-detail TMDB account section. |
| `lib/presentation/screens/settings/widgets/conflict_policy_selector.dart` | Radio group widget. |
| `lib/presentation/screens/settings/widgets/tmdb_disconnect_warning_dialog.dart` | 3-button dialog when dirty rows exist. |
| `lib/presentation/screens/tmdb/tmdb_resolve_conflicts_screen.dart` | List of conflicted rows for ask-user policy. |

### Modify

| Path | Change |
|---|---|
| `lib/data/remote/api/tmdb/tmdb_account_api.dart` | Add 9 endpoints (5 push, 4 list). |
| `lib/data/local/dao/tmdb_account_sync_dao.dart` | Add `countDirtyRows`, `watchDirtyCount`, `listDirty`, `listConflicts`, `markDirty`, `clearDirty`. |
| `lib/data/repositories/tmdb_account_sync_repository_impl.dart` | Push pipeline, list manager, conflict resolver, disconnect-with-dirty hook, dirty-row APIs. |
| `lib/domain/repositories/i_tmdb_account_sync_repository.dart` | Add new methods. |
| `lib/presentation/providers/repository_providers.dart` | Register new use-case providers. |
| `lib/presentation/providers/settings_provider.dart` | Add `conflictPolicy`, make `mirrorOwnership` and `twoWaySync` live in `TmdbAccountSyncSettings`. |
| `lib/presentation/providers/tmdb_account_sync_provider.dart` | Add `tmdbDirtyCountProvider`, `tmdbConflictedRowsProvider`. |
| `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart` | Wire live toggles, embed `ConflictPolicySelector`, dirty-count display, retry-all button, disconnect-with-warning route. |
| `lib/presentation/screens/item_detail/item_detail_screen.dart` | Embed `TmdbAccountControlsSection` (replacing the slice-A read-only `TmdbBridgeBadge` strip when account sync is enabled). |
| `lib/presentation/screens/tmdb/tmdb_bucket_screen.dart` | Add "Mark as owned" + "Remove from TMDB watchlist" actions. |
| `lib/app/router.dart` | Add `/tmdb/conflicts` route (branch 15). |
| `lib/presentation/widgets/app_scaffold.dart` | Conditional sidebar entry for resolve-conflicts when policy=askUser AND conflicts exist. |
| `lib/domain/usecases/save_media_item_usecase.dart` | Hook ownership-mirror trigger on save (when mirror enabled and item is movie). |

---

## Convention notes

- All new flag/state writes use `Value.absent()` for unspecified columns so the slice-A pass-through `_dropPresent` upsert preserves cross-bucket state.
- `BoolColumn` → use `Value(true)` / `Value(false)` / `Value.absent()` — never `Value(1)` / `Value(0)`.
- Generated files (`*.g.dart`) are committed alongside their source files.
- After every Retrofit / DTO / Drift change, run `dart run build_runner build --delete-conflicting-outputs` before tests.
- TMDB v3 list endpoints accept `session_id` via query string. List CRUD is movies-only — TV ownership is local-only by design.
- Push pipeline never fails silently — every error path stores `last_error` on the row.

---

## Task 1: Domain entities — TmdbConflictPolicy + TmdbPushAction

**Files:**
- Create: `lib/domain/entities/tmdb_conflict_policy.dart`
- Create: `lib/domain/entities/tmdb_push_action.dart`

- [ ] **Step 1: Write `TmdbConflictPolicy`**

Create `lib/domain/entities/tmdb_conflict_policy.dart`:

```dart
/// User-selectable conflict resolution policy for TMDB account sync.
enum TmdbConflictPolicy {
  preferLatestTimestamp,
  preferLocal,
  preferTmdb,
  askUser;

  static TmdbConflictPolicy fromName(String? name) {
    return TmdbConflictPolicy.values.firstWhere(
      (p) => p.name == name,
      orElse: () => TmdbConflictPolicy.preferLatestTimestamp,
    );
  }
}
```

- [ ] **Step 2: Write `TmdbPushAction`**

Create `lib/domain/entities/tmdb_push_action.dart`:

```dart
/// Discrete TMDB push operations. The repository's push pipeline derives
/// the list of pending actions from the bridge row's delta against its
/// last-pushed snapshot.
sealed class TmdbPushAction {
  const TmdbPushAction();
}

class PushRating extends TmdbPushAction {
  const PushRating(this.value);
  final double value; // 0.5–10
}

class RemoveRating extends TmdbPushAction {
  const RemoveRating();
}

class PushWatchlist extends TmdbPushAction {
  const PushWatchlist(this.value);
  final bool value;
}

class PushFavorite extends TmdbPushAction {
  const PushFavorite(this.value);
  final bool value;
}

class PushOwnership extends TmdbPushAction {
  const PushOwnership(this.add);
  /// `true` to add the item to the MyMediaScanner list, `false` to remove.
  final bool add;
}
```

- [ ] **Step 3: Smoke compile**

Run: `flutter analyze lib/domain/entities/`
Expected: zero issues.

- [ ] **Step 4: Commit**

```bash
git add lib/domain/entities/tmdb_conflict_policy.dart \
        lib/domain/entities/tmdb_push_action.dart
git commit -m "feat(tmdb-sync): add slice 2 domain entities"
```

---

## Task 2: New TMDB DTOs (list + status)

**Files:**
- Create: `lib/data/remote/api/tmdb/models/tmdb_status_response_dto.dart`
- Create: `lib/data/remote/api/tmdb/models/tmdb_list_create_response_dto.dart`
- Create: `lib/data/remote/api/tmdb/models/tmdb_account_lists_page_dto.dart`

- [ ] **Step 1: Write `TmdbStatusResponseDto`**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'tmdb_status_response_dto.g.dart';

/// Generic TMDB success/status payload returned by mutation endpoints.
@JsonSerializable()
class TmdbStatusResponseDto {
  const TmdbStatusResponseDto({
    required this.statusCode,
    this.statusMessage,
    this.success,
  });

  factory TmdbStatusResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbStatusResponseDtoFromJson(json);

  @JsonKey(name: 'status_code')
  final int statusCode;
  @JsonKey(name: 'status_message')
  final String? statusMessage;
  final bool? success;

  Map<String, dynamic> toJson() => _$TmdbStatusResponseDtoToJson(this);
}
```

- [ ] **Step 2: Write `TmdbListCreateResponseDto`**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'tmdb_list_create_response_dto.g.dart';

/// Response from `POST /list` (v3). The new list ID is returned as `list_id`.
@JsonSerializable()
class TmdbListCreateResponseDto {
  const TmdbListCreateResponseDto({
    required this.success,
    required this.listId,
    this.statusCode,
    this.statusMessage,
  });

  factory TmdbListCreateResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbListCreateResponseDtoFromJson(json);

  final bool success;
  @JsonKey(name: 'list_id')
  final int listId;
  @JsonKey(name: 'status_code')
  final int? statusCode;
  @JsonKey(name: 'status_message')
  final String? statusMessage;

  Map<String, dynamic> toJson() => _$TmdbListCreateResponseDtoToJson(this);
}
```

- [ ] **Step 3: Write `TmdbAccountListsPageDto`**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'tmdb_account_lists_page_dto.g.dart';

/// Response from `GET /account/{id}/lists` (v3).
@JsonSerializable()
class TmdbAccountListsPageDto {
  const TmdbAccountListsPageDto({
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required this.results,
  });

  factory TmdbAccountListsPageDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbAccountListsPageDtoFromJson(json);

  final int page;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'total_results')
  final int totalResults;
  final List<TmdbAccountListSummaryDto> results;

  Map<String, dynamic> toJson() => _$TmdbAccountListsPageDtoToJson(this);
}

@JsonSerializable()
class TmdbAccountListSummaryDto {
  const TmdbAccountListSummaryDto({
    required this.id,
    required this.name,
    this.description,
    this.itemCount,
  });

  factory TmdbAccountListSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbAccountListSummaryDtoFromJson(json);

  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'item_count')
  final int? itemCount;

  Map<String, dynamic> toJson() => _$TmdbAccountListSummaryDtoToJson(this);
}
```

- [ ] **Step 4: Regenerate**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: 3 new `.g.dart` files generated.

- [ ] **Step 5: Smoke compile**

Run: `flutter analyze lib/data/remote/api/tmdb/models/`
Expected: zero issues.

- [ ] **Step 6: Commit**

```bash
git add lib/data/remote/api/tmdb/models/tmdb_status_response_dto.dart \
        lib/data/remote/api/tmdb/models/tmdb_status_response_dto.g.dart \
        lib/data/remote/api/tmdb/models/tmdb_list_create_response_dto.dart \
        lib/data/remote/api/tmdb/models/tmdb_list_create_response_dto.g.dart \
        lib/data/remote/api/tmdb/models/tmdb_account_lists_page_dto.dart \
        lib/data/remote/api/tmdb/models/tmdb_account_lists_page_dto.g.dart
git commit -m "feat(tmdb-sync): add slice 2 list+status DTOs"
```

---

## Task 3: Extend TmdbAccountApi with push + list endpoints

**Files:**
- Modify: `lib/data/remote/api/tmdb/tmdb_account_api.dart`

- [ ] **Step 1: Add the 9 new endpoints**

Add these methods to the existing `TmdbAccountApi` abstract class. Place them in clear sections; keep existing methods untouched. The full file should look like the slice-A version with these additions appended:

```dart
// ── Rating push (slice 2) ─────────────────────────────────────

@POST('/movie/{id}/rating')
Future<TmdbStatusResponseDto> addMovieRating(
  @Path('id') int id,
  @Query('session_id') String sessionId,
  @Body() Map<String, dynamic> body, // {'value': <0.5..10>}
);

@POST('/tv/{id}/rating')
Future<TmdbStatusResponseDto> addTvRating(
  @Path('id') int id,
  @Query('session_id') String sessionId,
  @Body() Map<String, dynamic> body,
);

@DELETE('/movie/{id}/rating')
Future<TmdbStatusResponseDto> removeMovieRating(
  @Path('id') int id,
  @Query('session_id') String sessionId,
);

@DELETE('/tv/{id}/rating')
Future<TmdbStatusResponseDto> removeTvRating(
  @Path('id') int id,
  @Query('session_id') String sessionId,
);

// ── Watchlist / Favourite push (slice 2) ──────────────────────

@POST('/account/{accountId}/watchlist')
Future<TmdbStatusResponseDto> setWatchlist(
  @Path('accountId') int accountId,
  @Query('session_id') String sessionId,
  @Body() Map<String, dynamic> body,
  // body: {'media_type': 'movie'|'tv', 'media_id': <int>, 'watchlist': bool}
);

@POST('/account/{accountId}/favorite')
Future<TmdbStatusResponseDto> setFavorite(
  @Path('accountId') int accountId,
  @Query('session_id') String sessionId,
  @Body() Map<String, dynamic> body,
  // body: {'media_type': 'movie'|'tv', 'media_id': <int>, 'favorite': bool}
);

// ── List management (slice 2 — movies only) ───────────────────

@GET('/account/{accountId}/lists')
Future<TmdbAccountListsPageDto> getAccountLists(
  @Path('accountId') int accountId,
  @Query('session_id') String sessionId, {
  @Query('page') int page = 1,
});

@POST('/list')
Future<TmdbListCreateResponseDto> createList(
  @Query('session_id') String sessionId,
  @Body() Map<String, dynamic> body,
  // body: {'name': '...', 'description': '...', 'language': 'en'}
);

@POST('/list/{id}/add_item')
Future<TmdbStatusResponseDto> addItemToList(
  @Path('id') int id,
  @Query('session_id') String sessionId,
  @Body() Map<String, dynamic> body, // {'media_id': <tmdb_id>}
);

@POST('/list/{id}/remove_item')
Future<TmdbStatusResponseDto> removeItemFromList(
  @Path('id') int id,
  @Query('session_id') String sessionId,
  @Body() Map<String, dynamic> body, // {'media_id': <tmdb_id>}
);
```

Add the necessary imports at the top of the file:

```dart
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_account_lists_page_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_list_create_response_dto.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_status_response_dto.dart';
```

- [ ] **Step 2: Regenerate Retrofit code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `tmdb_account_api.g.dart` updated.

- [ ] **Step 3: Smoke compile**

Run: `flutter analyze lib/data/remote/api/tmdb/tmdb_account_api.dart`
Expected: zero issues.

- [ ] **Step 4: Commit**

```bash
git add lib/data/remote/api/tmdb/tmdb_account_api.dart \
        lib/data/remote/api/tmdb/tmdb_account_api.g.dart
git commit -m "feat(tmdb-sync): extend TmdbAccountApi with push + list endpoints"
```

---

## Task 4: Extend TmdbAccountSyncDao — dirty-row queries

**Files:**
- Modify: `lib/data/local/dao/tmdb_account_sync_dao.dart`
- Modify: `test/unit/data/local/dao/tmdb_account_sync_dao_test.dart` (extend)

- [ ] **Step 1: Write the failing tests**

Append to `test/unit/data/local/dao/tmdb_account_sync_dao_test.dart`:

```dart
test('countDirtyRows counts only localDirty rows', () async {
  await db.tmdbAccountSyncDao.upsertByTmdbId(row(id: 'a', tmdbId: 1));
  await db.tmdbAccountSyncDao.upsertByTmdbId(
    TmdbAccountSyncItemsTableCompanion(
      id: const Value('b'),
      tmdbId: const Value(2),
      tmdbMediaType: const Value('movie'),
      localDirty: const Value(true),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );
  await db.tmdbAccountSyncDao.upsertByTmdbId(
    TmdbAccountSyncItemsTableCompanion(
      id: const Value('c'),
      tmdbId: const Value(3),
      tmdbMediaType: const Value('movie'),
      localDirty: const Value(true),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );

  expect(await db.tmdbAccountSyncDao.countDirtyRows(), 2);
});

test('listDirty returns only localDirty rows', () async {
  await db.tmdbAccountSyncDao.upsertByTmdbId(row(id: 'a', tmdbId: 1));
  await db.tmdbAccountSyncDao.upsertByTmdbId(
    TmdbAccountSyncItemsTableCompanion(
      id: const Value('b'),
      tmdbId: const Value(2),
      tmdbMediaType: const Value('movie'),
      localDirty: const Value(true),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );

  final dirty = await db.tmdbAccountSyncDao.listDirty();
  expect(dirty.map((r) => r.tmdbId), [2]);
});

test('markDirty sets localDirty=true and bumps updatedAt', () async {
  await db.tmdbAccountSyncDao.upsertByTmdbId(row(id: 'a', tmdbId: 5));
  final before = (await db.tmdbAccountSyncDao.getByTmdbId(5, 'movie'))!;
  await Future<void>.delayed(const Duration(milliseconds: 5));

  await db.tmdbAccountSyncDao.markDirty(tmdbId: 5, mediaType: 'movie');
  final after = (await db.tmdbAccountSyncDao.getByTmdbId(5, 'movie'))!;
  expect(after.localDirty, isTrue);
  expect(after.updatedAt, greaterThan(before.updatedAt));
});

test('clearDirty sets localDirty=false, lastPushedAt=now, lastError=null',
    () async {
  await db.tmdbAccountSyncDao.upsertByTmdbId(
    TmdbAccountSyncItemsTableCompanion(
      id: const Value('a'),
      tmdbId: const Value(7),
      tmdbMediaType: const Value('movie'),
      localDirty: const Value(true),
      lastError: const Value('previous error'),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );

  await db.tmdbAccountSyncDao.clearDirty(
    tmdbId: 7,
    mediaType: 'movie',
    pushedRating: 4.0,
  );

  final row = (await db.tmdbAccountSyncDao.getByTmdbId(7, 'movie'))!;
  expect(row.localDirty, isFalse);
  expect(row.lastError, isNull);
  expect(row.lastPushedAt, isNotNull);
  expect(row.localRatingSnapshot, 4.0);
});
```

- [ ] **Step 2: Run the tests (will fail)**

Run: `flutter test test/unit/data/local/dao/tmdb_account_sync_dao_test.dart`
Expected: FAIL — methods undefined.

- [ ] **Step 3: Add the methods to the DAO**

In `lib/data/local/dao/tmdb_account_sync_dao.dart`, add these methods to the existing `TmdbAccountSyncDao` class:

```dart
/// Count rows with `localDirty == true`.
Future<int> countDirtyRows() async {
  final res = await (selectOnly(tmdbAccountSyncItemsTable)
        ..addColumns([tmdbAccountSyncItemsTable.id.count()])
        ..where(tmdbAccountSyncItemsTable.localDirty.equals(true)))
      .map((row) => row.read(tmdbAccountSyncItemsTable.id.count()) ?? 0)
      .getSingle();
  return res;
}

/// Watch the dirty count for the settings card's "X pending changes".
Stream<int> watchDirtyCount() {
  return (selectOnly(tmdbAccountSyncItemsTable)
        ..addColumns([tmdbAccountSyncItemsTable.id.count()])
        ..where(tmdbAccountSyncItemsTable.localDirty.equals(true)))
      .map((row) => row.read(tmdbAccountSyncItemsTable.id.count()) ?? 0)
      .watchSingle();
}

/// All dirty rows, ordered oldest-first by updatedAt.
Future<List<TmdbAccountSyncItemsTableData>> listDirty() {
  return (select(tmdbAccountSyncItemsTable)
        ..where((t) => t.localDirty.equals(true))
        ..orderBy([(t) => OrderingTerm.asc(t.updatedAt)]))
      .get();
}

/// Stream conflicted rows for the resolve-conflicts screen.
/// A conflict is a dirty row whose `last_error` matches the conflict marker.
Stream<List<TmdbAccountSyncItemsTableData>> watchConflicts() {
  return (select(tmdbAccountSyncItemsTable)
        ..where((t) =>
            t.localDirty.equals(true) &
            t.lastError.equals('conflict:user-resolution-required'))
        ..orderBy([(t) => OrderingTerm.asc(t.updatedAt)]))
      .watch();
}

/// Mark a row dirty without changing other fields. Bumps updatedAt.
Future<void> markDirty({
  required int tmdbId,
  required String mediaType,
}) async {
  await (update(tmdbAccountSyncItemsTable)
        ..where((t) =>
            t.tmdbId.equals(tmdbId) & t.tmdbMediaType.equals(mediaType)))
      .write(TmdbAccountSyncItemsTableCompanion(
    localDirty: const Value(true),
    updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
  ));
}

/// Clear dirty flag after a successful push. Stores the pushed rating
/// in `localRatingSnapshot` so the next dirty-detect compares against it.
Future<void> clearDirty({
  required int tmdbId,
  required String mediaType,
  double? pushedRating,
}) async {
  final now = DateTime.now().millisecondsSinceEpoch;
  await (update(tmdbAccountSyncItemsTable)
        ..where((t) =>
            t.tmdbId.equals(tmdbId) & t.tmdbMediaType.equals(mediaType)))
      .write(TmdbAccountSyncItemsTableCompanion(
    localDirty: const Value(false),
    lastError: const Value(null),
    lastPushedAt: Value(now),
    localRatingSnapshot: pushedRating == null
        ? const Value.absent()
        : Value(pushedRating),
    updatedAt: Value(now),
  ));
}

/// Record a per-row push error and keep the row dirty.
Future<void> recordPushError({
  required int tmdbId,
  required String mediaType,
  required String error,
}) async {
  await (update(tmdbAccountSyncItemsTable)
        ..where((t) =>
            t.tmdbId.equals(tmdbId) & t.tmdbMediaType.equals(mediaType)))
      .write(TmdbAccountSyncItemsTableCompanion(
    lastError: Value(error),
    updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
  ));
}
```

The `localRatingSnapshot: pushedRating == null ? const Value.absent() : Value(pushedRating)` pattern preserves the previous snapshot when the push didn't include a rating change.

- [ ] **Step 4: Regenerate Drift code**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: Run the tests**

Run: `flutter test test/unit/data/local/dao/tmdb_account_sync_dao_test.dart`
Expected: all tests pass (slice A's 7 + slice 2's 4 = 11).

- [ ] **Step 6: Commit**

```bash
git add lib/data/local/dao/tmdb_account_sync_dao.dart \
        lib/data/local/dao/tmdb_account_sync_dao.g.dart \
        test/unit/data/local/dao/tmdb_account_sync_dao_test.dart
git commit -m "feat(tmdb-sync): add dirty-row queries and conflict watch on DAO"
```

---

## Task 5: Settings provider — conflict policy + live toggles

**Files:**
- Modify: `lib/presentation/providers/settings_provider.dart`

- [ ] **Step 1: Extend `TmdbAccountSyncSettings`**

In `lib/presentation/providers/settings_provider.dart`, find the `TmdbAccountSyncSettings` class (added in slice A's Task 12). Replace it with:

```dart
class TmdbAccountSyncSettings {
  const TmdbAccountSyncSettings({
    this.enabled = false,
    this.enrichScans = true,
    this.twoWaySync = true,
    this.mirrorOwnership = false,
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
        conflictPolicy: conflictPolicy ?? this.conflictPolicy,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        lastSyncPulled: lastSyncPulled ?? this.lastSyncPulled,
        lastSyncFailed: lastSyncFailed ?? this.lastSyncFailed,
        lastError: clearLastError ? null : (lastError ?? this.lastError),
      );
}
```

Add the import at the top of the file:

```dart
import 'package:mymediascanner/domain/entities/tmdb_conflict_policy.dart';
```

- [ ] **Step 2: Extend `TmdbAccountSyncSettingsNotifier`**

Replace the slice-A notifier body with:

```dart
class TmdbAccountSyncSettingsNotifier
    extends Notifier<TmdbAccountSyncSettings> {
  static const _kEnabled = 'tmdb.account_sync.enabled';
  static const _kEnrichScans = 'tmdb.account_sync.enrich_scans';
  static const _kTwoWay = 'tmdb.account_sync.two_way_sync';
  static const _kMirror = 'tmdb.account_sync.mirror_ownership';
  static const _kConflictPolicy = 'tmdb.account_sync.conflict_policy';
  static const _kLastSyncAt = 'tmdb.account_sync.last_sync_at';
  static const _kLastPulled = 'tmdb.account_sync.last_sync_pulled';
  static const _kLastFailed = 'tmdb.account_sync.last_sync_failed';
  static const _kLastError = 'tmdb.account_sync.last_error';

  @override
  TmdbAccountSyncSettings build() {
    _load();
    return const TmdbAccountSyncSettings();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!ref.mounted) return;
    final lastSyncMs = p.getInt(_kLastSyncAt);
    state = TmdbAccountSyncSettings(
      enabled: p.getBool(_kEnabled) ?? false,
      enrichScans: p.getBool(_kEnrichScans) ?? true,
      twoWaySync: p.getBool(_kTwoWay) ?? true,
      mirrorOwnership: p.getBool(_kMirror) ?? false,
      conflictPolicy: TmdbConflictPolicy.fromName(p.getString(_kConflictPolicy)),
      lastSyncAt: lastSyncMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastSyncMs),
      lastSyncPulled: p.getInt(_kLastPulled) ?? 0,
      lastSyncFailed: p.getInt(_kLastFailed) ?? 0,
      lastError: p.getString(_kLastError),
    );
  }

  Future<void> setEnabled(bool v) async {
    state = state.copyWith(enabled: v);
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kEnabled, v);
  }

  Future<void> setEnrichScans(bool v) async {
    state = state.copyWith(enrichScans: v);
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kEnrichScans, v);
  }

  Future<void> setTwoWaySync(bool v) async {
    state = state.copyWith(twoWaySync: v);
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kTwoWay, v);
  }

  Future<void> setMirrorOwnership(bool v) async {
    state = state.copyWith(mirrorOwnership: v);
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kMirror, v);
  }

  Future<void> setConflictPolicy(TmdbConflictPolicy policy) async {
    state = state.copyWith(conflictPolicy: policy);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kConflictPolicy, policy.name);
  }

  Future<void> recordSyncResult({
    required int pulled,
    required int failed,
    String? error,
  }) async {
    final now = DateTime.now();
    state = state.copyWith(
      lastSyncAt: now,
      lastSyncPulled: pulled,
      lastSyncFailed: failed,
      lastError: error,
      clearLastError: error == null,
    );
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kLastSyncAt, now.millisecondsSinceEpoch);
    await p.setInt(_kLastPulled, pulled);
    await p.setInt(_kLastFailed, failed);
    if (error == null) {
      await p.remove(_kLastError);
    } else {
      await p.setString(_kLastError, error);
    }
  }
}
```

- [ ] **Step 3: Smoke compile**

Run: `flutter analyze lib/presentation/providers/settings_provider.dart`
Expected: zero issues.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/providers/settings_provider.dart
git commit -m "feat(tmdb-sync): make slice 2 toggles + conflict policy live in settings"
```

---

## Task 6: Repository — push pipeline foundation

**Files:**
- Modify: `lib/domain/repositories/i_tmdb_account_sync_repository.dart`
- Modify: `lib/data/repositories/tmdb_account_sync_repository_impl.dart`
- Modify: `test/unit/data/repositories/tmdb_account_sync_repository_impl_test.dart` (extend)

- [ ] **Step 1: Extend the interface**

In `lib/domain/repositories/i_tmdb_account_sync_repository.dart`, add new methods to the abstract class (place them in a clearly commented "Slice 2 — push" section):

```dart
// ── Slice 2 — push pipeline ────────────────────────────────────

/// Push any pending changes for the title `(tmdbId, mediaType)`.
/// Reads the bridge row, derives the action list from the delta
/// against last-pushed snapshot, and POSTs each action. Returns
/// [TmdbPushResult] describing success or failure.
Future<TmdbPushResult> pushOne({
  required int tmdbId,
  required String mediaType,
});

/// Push every dirty row sequentially. Used by "Push pending now".
Future<TmdbPushSummary> pushAllDirty();

/// Watch the count of dirty rows for UI badging.
Stream<int> watchDirtyCount();

/// Stream conflicted rows (those needing user resolution).
Stream<List<TmdbBridgeItem>> watchConflicts();

// ── Slice 2 — toggle helpers ───────────────────────────────────

/// Toggle the watchlist flag locally + push (if two-way enabled).
Future<TmdbPushResult> toggleWatchlist({
  required int tmdbId,
  required String mediaType,
  required bool value,
});

/// Toggle the favourite flag locally + push (if two-way enabled).
Future<TmdbPushResult> toggleFavorite({
  required int tmdbId,
  required String mediaType,
  required bool value,
});

/// Set local rating + push.
Future<TmdbPushResult> updateRating({
  required int tmdbId,
  required String mediaType,
  required double? localRating, // null clears the rating on TMDB.
});

// ── Slice 2 — list mirror ──────────────────────────────────────

/// Lazy-resolve the MyMediaScanner private list ID. Looks up by name,
/// creates if missing, caches in secure storage.
Future<int> ensureMyMediaScannerListId();

/// Add a movie to the MyMediaScanner list. No-op for TV (v3 list
/// limitation). Failure stored on the bridge row's last_error.
Future<TmdbPushResult> mirrorAddOwnership({required int tmdbId});

/// Remove a movie from the MyMediaScanner list. No-op for TV.
Future<TmdbPushResult> mirrorRemoveOwnership({required int tmdbId});

/// True when disconnect should warn — i.e. there are dirty rows.
Future<int> countDirtyRows();
```

Add `TmdbPushResult` and `TmdbPushSummary` value classes near the bottom of the file:

```dart
class TmdbPushResult {
  const TmdbPushResult({required this.success, this.error});
  final bool success;
  final String? error;
}

class TmdbPushSummary {
  const TmdbPushSummary({
    required this.attempted,
    required this.succeeded,
    required this.failed,
    this.lastError,
  });
  final int attempted;
  final int succeeded;
  final int failed;
  final String? lastError;
}
```

Add the necessary import at top:

```dart
import 'package:mymediascanner/domain/entities/tmdb_push_action.dart';
```

- [ ] **Step 2: Write failing tests for `pushOne` happy path**

Append to `test/unit/data/repositories/tmdb_account_sync_repository_impl_test.dart`:

```dart
test('pushOne with dirty rating emits POST /movie/{id}/rating then clears dirty',
    () async {
  // Seed dirty bridge row with a new local rating.
  await db.tmdbAccountSyncDao.upsertByTmdbId(
    TmdbAccountSyncItemsTableCompanion(
      id: const Value('br-1'),
      tmdbId: const Value(550),
      tmdbMediaType: const Value('movie'),
      tmdbRating: const Value(8.0), // last known TMDB rating
      localRatingSnapshot: const Value(8.0), // last pushed = same as known
      localDirty: const Value(true),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );
  // User has set local userRating to 4.5 (= TMDB 9.0). The repository
  // figures out the delta from the bridge row plus the linked
  // media_items row OR via an explicit updateRating call earlier.
  // For pushOne we mock the api response.
  when(() => api.addMovieRating(550, 'sess-123', any()))
      .thenAnswer((_) async =>
          const TmdbStatusResponseDto(statusCode: 1, success: true));

  // For this minimal pushOne test we set the bridge's tmdbRating to the
  // new desired value first, simulating what updateRating would do.
  await db.tmdbAccountSyncDao.upsertByTmdbId(
    const TmdbAccountSyncItemsTableCompanion(
      tmdbId: Value(550),
      tmdbMediaType: Value('movie'),
      tmdbRating: Value(9.0), // new desired rating
      localDirty: Value(true),
    ),
  );

  final result = await repo.pushOne(tmdbId: 550, mediaType: 'movie');
  expect(result.success, isTrue);

  final after = await db.tmdbAccountSyncDao.getByTmdbId(550, 'movie');
  expect(after?.localDirty, isFalse);
  expect(after?.lastPushedAt, isNotNull);
  expect(after?.localRatingSnapshot, 9.0);
  verify(() => api.addMovieRating(550, 'sess-123', {'value': 9.0})).called(1);
});

test('pushOne with API error keeps row dirty and stores last_error',
    () async {
  await db.tmdbAccountSyncDao.upsertByTmdbId(
    TmdbAccountSyncItemsTableCompanion(
      id: const Value('br-1'),
      tmdbId: const Value(550),
      tmdbMediaType: const Value('movie'),
      tmdbRating: const Value(7.0),
      localRatingSnapshot: const Value(8.0), // diff → push needed
      localDirty: const Value(true),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );
  when(() => api.addMovieRating(550, 'sess-123', any()))
      .thenThrow(DioException(
    requestOptions: RequestOptions(path: ''),
    response: Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: 500,
    ),
  ));

  final result = await repo.pushOne(tmdbId: 550, mediaType: 'movie');
  expect(result.success, isFalse);
  expect(result.error, isNotNull);

  final after = await db.tmdbAccountSyncDao.getByTmdbId(550, 'movie');
  expect(after?.localDirty, isTrue, reason: 'stays dirty for retry');
  expect(after?.lastError, isNotNull);
});
```

- [ ] **Step 3: Run the tests (will fail)**

Run: `flutter test test/unit/data/repositories/tmdb_account_sync_repository_impl_test.dart`
Expected: FAIL — `pushOne` does not exist.

- [ ] **Step 4: Implement `pushOne` and helpers**

In `lib/data/repositories/tmdb_account_sync_repository_impl.dart`, add the following imports:

```dart
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_status_response_dto.dart';
import 'package:mymediascanner/domain/entities/tmdb_push_action.dart';
```

Add the secure-storage key constant near the existing ones at the top of the class:

```dart
static const _kListId = 'tmdb.mymediascanner_list_id';
```

Add these methods to `TmdbAccountSyncRepositoryImpl`:

```dart
@override
Future<int> countDirtyRows() => dao.countDirtyRows();

@override
Stream<int> watchDirtyCount() => dao.watchDirtyCount();

@override
Stream<List<TmdbBridgeItem>> watchConflicts() {
  return dao.watchConflicts().map(
      (rows) => rows.map(TmdbAccountMapper.rowToBridgeItem).toList());
}

@override
Future<TmdbPushResult> pushOne({
  required int tmdbId,
  required String mediaType,
}) async {
  final state = await currentState();
  if (state is! TmdbConnected) {
    return const TmdbPushResult(
        success: false, error: 'Not connected to TMDB');
  }
  final session = (await storage.read(key: _kSession))!;

  final row = await dao.getByTmdbId(tmdbId, mediaType);
  if (row == null) {
    return const TmdbPushResult(
        success: false, error: 'No bridge row');
  }

  // Derive push actions from the delta. Slice 2 supports rating + watchlist
  // + favourite per row. Ownership-mirror is invoked separately.
  final actions = <TmdbPushAction>[];

  // Rating delta: tmdbRating (current desired) vs localRatingSnapshot (last pushed).
  final desiredRating = row.tmdbRating;
  final lastPushedRating = row.localRatingSnapshot;
  if (desiredRating != lastPushedRating) {
    if (desiredRating == null) {
      actions.add(const RemoveRating());
    } else {
      actions.add(PushRating(desiredRating));
    }
  }

  // Watchlist / favourite are written via updateRating-equivalent — the
  // toggle helpers update the bridge first, mark dirty, then call pushOne.
  // We always re-push their current values when dirty (TMDB POSTs are
  // idempotent for these endpoints).
  // Detect a watchlist/favourite delta as: dirty AND value differs from
  // a server-known baseline. Since we don't track per-flag baselines,
  // we always push the current state when dirty. TMDB accepts no-op writes.
  // To keep the action list minimal, only push these when explicitly
  // requested — the toggle helpers set a marker via JSON in account_state_json
  // before calling pushOne. Slice 2 simplifies: always push current
  // watchlist/favourite when dirty.
  if (row.localDirty && desiredRating == lastPushedRating) {
    // Pure flag dirty — push both flags as their current state.
    actions.add(PushWatchlist(row.watchlist));
    actions.add(PushFavorite(row.favorite));
  } else if (row.localDirty) {
    // Mixed — also push flags so TMDB matches local state.
    actions.add(PushWatchlist(row.watchlist));
    actions.add(PushFavorite(row.favorite));
  }

  if (actions.isEmpty) {
    // Nothing to do — clear dirty flag.
    await dao.clearDirty(
      tmdbId: tmdbId,
      mediaType: mediaType,
      pushedRating: desiredRating,
    );
    return const TmdbPushResult(success: true);
  }

  for (final action in actions) {
    try {
      await _executeAction(
        action: action,
        accountId: state.accountId,
        sessionId: session,
        tmdbId: tmdbId,
        mediaType: mediaType,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _handle401();
        await dao.recordPushError(
          tmdbId: tmdbId,
          mediaType: mediaType,
          error: 'Session expired',
        );
        return const TmdbPushResult(
            success: false, error: 'Session expired');
      }
      final msg = e.message ?? 'Network error';
      await dao.recordPushError(
          tmdbId: tmdbId, mediaType: mediaType, error: msg);
      return TmdbPushResult(success: false, error: msg);
    } catch (e) {
      await dao.recordPushError(
          tmdbId: tmdbId, mediaType: mediaType, error: e.toString());
      return TmdbPushResult(success: false, error: e.toString());
    }
  }

  await dao.clearDirty(
    tmdbId: tmdbId,
    mediaType: mediaType,
    pushedRating: desiredRating,
  );
  return const TmdbPushResult(success: true);
}

Future<void> _executeAction({
  required TmdbPushAction action,
  required int accountId,
  required String sessionId,
  required int tmdbId,
  required String mediaType,
}) async {
  switch (action) {
    case PushRating(value: final v):
      if (mediaType == 'tv') {
        await api.addTvRating(tmdbId, sessionId, {'value': v});
      } else {
        await api.addMovieRating(tmdbId, sessionId, {'value': v});
      }
    case RemoveRating():
      if (mediaType == 'tv') {
        await api.removeTvRating(tmdbId, sessionId);
      } else {
        await api.removeMovieRating(tmdbId, sessionId);
      }
    case PushWatchlist(value: final v):
      await api.setWatchlist(accountId, sessionId, {
        'media_type': mediaType,
        'media_id': tmdbId,
        'watchlist': v,
      });
    case PushFavorite(value: final v):
      await api.setFavorite(accountId, sessionId, {
        'media_type': mediaType,
        'media_id': tmdbId,
        'favorite': v,
      });
    case PushOwnership():
      // Ownership is invoked via mirrorAddOwnership/mirrorRemoveOwnership,
      // not via pushOne. Throw to make the misuse loud.
      throw StateError('PushOwnership not handled in pushOne');
  }
}

@override
Future<TmdbPushSummary> pushAllDirty() async {
  final dirty = await dao.listDirty();
  int succeeded = 0;
  int failed = 0;
  String? lastError;
  for (final row in dirty) {
    final result = await pushOne(
        tmdbId: row.tmdbId, mediaType: row.tmdbMediaType);
    if (result.success) {
      succeeded++;
    } else {
      failed++;
      lastError = result.error;
    }
  }
  return TmdbPushSummary(
    attempted: dirty.length,
    succeeded: succeeded,
    failed: failed,
    lastError: lastError,
  );
}
```

- [ ] **Step 5: Run the tests**

Run: `flutter test test/unit/data/repositories/tmdb_account_sync_repository_impl_test.dart`
Expected: PASS (all slice-A tests + 2 new).

- [ ] **Step 6: Commit**

```bash
git add lib/domain/repositories/i_tmdb_account_sync_repository.dart \
        lib/data/repositories/tmdb_account_sync_repository_impl.dart \
        test/unit/data/repositories/tmdb_account_sync_repository_impl_test.dart
git commit -m "feat(tmdb-sync): add push pipeline foundation"
```

---

## Task 7: Repository — toggle/update helpers

**Files:**
- Modify: `lib/data/repositories/tmdb_account_sync_repository_impl.dart`
- Modify: `test/unit/data/repositories/tmdb_account_sync_repository_impl_test.dart`

- [ ] **Step 1: Write the failing tests**

```dart
test('toggleWatchlist updates bridge + pushes', () async {
  await db.tmdbAccountSyncDao.upsertByTmdbId(
    TmdbAccountSyncItemsTableCompanion(
      id: const Value('br-1'),
      tmdbId: const Value(100),
      tmdbMediaType: const Value('movie'),
      watchlist: const Value(false),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );
  when(() => api.setWatchlist(42, 'sess-123', any()))
      .thenAnswer((_) async =>
          const TmdbStatusResponseDto(statusCode: 1, success: true));
  when(() => api.setFavorite(42, 'sess-123', any()))
      .thenAnswer((_) async =>
          const TmdbStatusResponseDto(statusCode: 1, success: true));

  final result =
      await repo.toggleWatchlist(tmdbId: 100, mediaType: 'movie', value: true);
  expect(result.success, isTrue);

  final after = await db.tmdbAccountSyncDao.getByTmdbId(100, 'movie');
  expect(after?.watchlist, isTrue);
  expect(after?.localDirty, isFalse);
});

test('updateRating with null clears the TMDB rating', () async {
  await db.tmdbAccountSyncDao.upsertByTmdbId(
    TmdbAccountSyncItemsTableCompanion(
      id: const Value('br-1'),
      tmdbId: const Value(100),
      tmdbMediaType: const Value('movie'),
      tmdbRating: const Value(8.0),
      localRatingSnapshot: const Value(8.0),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );
  when(() => api.removeMovieRating(100, 'sess-123'))
      .thenAnswer((_) async =>
          const TmdbStatusResponseDto(statusCode: 13, success: true));
  when(() => api.setWatchlist(42, 'sess-123', any()))
      .thenAnswer((_) async =>
          const TmdbStatusResponseDto(statusCode: 1, success: true));
  when(() => api.setFavorite(42, 'sess-123', any()))
      .thenAnswer((_) async =>
          const TmdbStatusResponseDto(statusCode: 1, success: true));

  final result = await repo.updateRating(
      tmdbId: 100, mediaType: 'movie', localRating: null);
  expect(result.success, isTrue);
  verify(() => api.removeMovieRating(100, 'sess-123')).called(1);
});
```

- [ ] **Step 2: Implement the helpers**

Add to `TmdbAccountSyncRepositoryImpl`:

```dart
@override
Future<TmdbPushResult> toggleWatchlist({
  required int tmdbId,
  required String mediaType,
  required bool value,
}) async {
  await dao.upsertByTmdbId(
    TmdbAccountSyncItemsTableCompanion(
      tmdbId: Value(tmdbId),
      tmdbMediaType: Value(mediaType),
      watchlist: Value(value),
      localDirty: const Value(true),
    ),
  );
  return pushOne(tmdbId: tmdbId, mediaType: mediaType);
}

@override
Future<TmdbPushResult> toggleFavorite({
  required int tmdbId,
  required String mediaType,
  required bool value,
}) async {
  await dao.upsertByTmdbId(
    TmdbAccountSyncItemsTableCompanion(
      tmdbId: Value(tmdbId),
      tmdbMediaType: Value(mediaType),
      favorite: Value(value),
      localDirty: const Value(true),
    ),
  );
  return pushOne(tmdbId: tmdbId, mediaType: mediaType);
}

@override
Future<TmdbPushResult> updateRating({
  required int tmdbId,
  required String mediaType,
  required double? localRating,
}) async {
  // Convert local 0–5 to TMDB 0.5–10. Null clears.
  final tmdb = localRating == null
      ? null
      : TmdbAccountMapper.localToTmdbRating(localRating);

  await dao.upsertByTmdbId(
    TmdbAccountSyncItemsTableCompanion(
      tmdbId: Value(tmdbId),
      tmdbMediaType: Value(mediaType),
      tmdbRating: Value(tmdb),
      localDirty: const Value(true),
    ),
  );
  return pushOne(tmdbId: tmdbId, mediaType: mediaType);
}
```

- [ ] **Step 3: Run the tests**

Run: `flutter test test/unit/data/repositories/tmdb_account_sync_repository_impl_test.dart`
Expected: all pass.

- [ ] **Step 4: Commit**

```bash
git add lib/data/repositories/tmdb_account_sync_repository_impl.dart \
        test/unit/data/repositories/tmdb_account_sync_repository_impl_test.dart
git commit -m "feat(tmdb-sync): add toggle/update helpers on repository"
```

---

## Task 8: Repository — list manager (lazy create-or-find)

**Files:**
- Modify: `lib/data/repositories/tmdb_account_sync_repository_impl.dart`
- Modify: `test/unit/data/repositories/tmdb_account_sync_repository_impl_test.dart`

- [ ] **Step 1: Write the failing tests**

```dart
test('ensureMyMediaScannerListId reuses existing list found by name',
    () async {
  // No cached list ID.
  when(() => storage.read(key: 'tmdb.mymediascanner_list_id'))
      .thenAnswer((_) async => null);
  when(() => storage.write(
          key: 'tmdb.mymediascanner_list_id', value: any(named: 'value')))
      .thenAnswer((_) async {});
  when(() => api.getAccountLists(42, 'sess-123', page: any(named: 'page')))
      .thenAnswer((_) async => const TmdbAccountListsPageDto(
            page: 1,
            totalPages: 1,
            totalResults: 1,
            results: [
              TmdbAccountListSummaryDto(id: 999, name: 'MyMediaScanner'),
            ],
          ));

  final id = await repo.ensureMyMediaScannerListId();
  expect(id, 999);
  verifyNever(() => api.createList(any(), any()));
});

test('ensureMyMediaScannerListId creates list when none exists', () async {
  when(() => storage.read(key: 'tmdb.mymediascanner_list_id'))
      .thenAnswer((_) async => null);
  when(() => storage.write(
          key: 'tmdb.mymediascanner_list_id', value: any(named: 'value')))
      .thenAnswer((_) async {});
  when(() => api.getAccountLists(42, 'sess-123', page: any(named: 'page')))
      .thenAnswer((_) async => const TmdbAccountListsPageDto(
            page: 1, totalPages: 1, totalResults: 0, results: [],
          ));
  when(() => api.createList('sess-123', any())).thenAnswer((_) async =>
      const TmdbListCreateResponseDto(success: true, listId: 1234));

  final id = await repo.ensureMyMediaScannerListId();
  expect(id, 1234);
  verify(() => api.createList('sess-123', any())).called(1);
});

test('ensureMyMediaScannerListId returns cached id without API calls',
    () async {
  when(() => storage.read(key: 'tmdb.mymediascanner_list_id'))
      .thenAnswer((_) async => '777');

  final id = await repo.ensureMyMediaScannerListId();
  expect(id, 777);
  verifyNever(() => api.getAccountLists(any(), any(), page: any(named: 'page')));
  verifyNever(() => api.createList(any(), any()));
});
```

- [ ] **Step 2: Implement `ensureMyMediaScannerListId` and the mirror helpers**

Add to `TmdbAccountSyncRepositoryImpl`:

```dart
@override
Future<int> ensureMyMediaScannerListId() async {
  final cached = await storage.read(key: _kListId);
  if (cached != null) {
    final parsed = int.tryParse(cached);
    if (parsed != null) return parsed;
  }
  final state = await currentState();
  if (state is! TmdbConnected) {
    throw StateError('Not connected — cannot resolve TMDB list');
  }
  final session = (await storage.read(key: _kSession))!;

  // Look up by name across pages.
  var page = 1;
  while (true) {
    final pageDto = await api.getAccountLists(
        state.accountId, session, page: page);
    for (final list in pageDto.results) {
      if (list.name == 'MyMediaScanner') {
        await storage.write(key: _kListId, value: list.id.toString());
        return list.id;
      }
    }
    if (page >= pageDto.totalPages) break;
    page++;
  }

  // Not found → create.
  final created = await api.createList(session, {
    'name': 'MyMediaScanner',
    'description':
        'Mirrored from MyMediaScanner — owned items in your collection.',
    'language': 'en',
  });
  if (!created.success) {
    throw const TmdbConnectException(
        'TMDB rejected the MyMediaScanner list creation');
  }
  await storage.write(
      key: _kListId, value: created.listId.toString());
  return created.listId;
}

@override
Future<TmdbPushResult> mirrorAddOwnership({required int tmdbId}) async {
  return _mirrorMutate(tmdbId: tmdbId, add: true);
}

@override
Future<TmdbPushResult> mirrorRemoveOwnership({required int tmdbId}) async {
  return _mirrorMutate(tmdbId: tmdbId, add: false);
}

Future<TmdbPushResult> _mirrorMutate({
  required int tmdbId,
  required bool add,
}) async {
  try {
    final state = await currentState();
    if (state is! TmdbConnected) {
      return const TmdbPushResult(
          success: false, error: 'Not connected to TMDB');
    }
    final session = (await storage.read(key: _kSession))!;
    final listId = await ensureMyMediaScannerListId();
    final body = {'media_id': tmdbId};
    if (add) {
      await api.addItemToList(listId, session, body);
    } else {
      await api.removeItemFromList(listId, session, body);
    }
    return const TmdbPushResult(success: true);
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      await _handle401();
      return const TmdbPushResult(
          success: false, error: 'Session expired');
    }
    return TmdbPushResult(
        success: false, error: e.message ?? 'Network error');
  } catch (e) {
    return TmdbPushResult(success: false, error: e.toString());
  }
}
```

Also extend `disconnect()` to clear the list ID:

```dart
// In the existing disconnect() method, after the existing storage.delete calls:
await storage.delete(key: _kListId);
```

- [ ] **Step 3: Run the tests**

Run: `flutter test test/unit/data/repositories/tmdb_account_sync_repository_impl_test.dart`
Expected: all pass (3 new tests).

- [ ] **Step 4: Commit**

```bash
git add lib/data/repositories/tmdb_account_sync_repository_impl.dart \
        test/unit/data/repositories/tmdb_account_sync_repository_impl_test.dart
git commit -m "feat(tmdb-sync): add MyMediaScanner list manager (lookup-or-create)"
```

---

## Task 9: Use cases — Push, ToggleWatchlist, ToggleFavorite

**Files:**
- Create: `lib/domain/usecases/push_tmdb_change_usecase.dart`
- Create: `lib/domain/usecases/toggle_tmdb_watchlist_usecase.dart`
- Create: `lib/domain/usecases/toggle_tmdb_favorite_usecase.dart`
- Test: `test/unit/domain/usecases/push_tmdb_change_usecase_test.dart`

- [ ] **Step 1: Write `PushTmdbChangeUseCase`**

```dart
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

/// Push pending changes for a single bridge row.
class PushTmdbChangeUseCase {
  PushTmdbChangeUseCase(this.repo);
  final ITmdbAccountSyncRepository repo;

  Future<TmdbPushResult> call({
    required int tmdbId,
    required String mediaType,
  }) =>
      repo.pushOne(tmdbId: tmdbId, mediaType: mediaType);

  Future<TmdbPushSummary> all() => repo.pushAllDirty();
}
```

- [ ] **Step 2: Write `ToggleTmdbWatchlistUseCase`**

```dart
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

class ToggleTmdbWatchlistUseCase {
  ToggleTmdbWatchlistUseCase(this.repo);
  final ITmdbAccountSyncRepository repo;

  Future<TmdbPushResult> call({
    required int tmdbId,
    required String mediaType,
    required bool value,
  }) =>
      repo.toggleWatchlist(
          tmdbId: tmdbId, mediaType: mediaType, value: value);
}
```

- [ ] **Step 3: Write `ToggleTmdbFavoriteUseCase`**

```dart
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

class ToggleTmdbFavoriteUseCase {
  ToggleTmdbFavoriteUseCase(this.repo);
  final ITmdbAccountSyncRepository repo;

  Future<TmdbPushResult> call({
    required int tmdbId,
    required String mediaType,
    required bool value,
  }) =>
      repo.toggleFavorite(
          tmdbId: tmdbId, mediaType: mediaType, value: value);
}
```

- [ ] **Step 4: Write a smoke test for `PushTmdbChangeUseCase`**

Create `test/unit/domain/usecases/push_tmdb_change_usecase_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/push_tmdb_change_usecase.dart';

class _MockRepo extends Mock implements ITmdbAccountSyncRepository {}

void main() {
  test('forwards pushOne to repo', () async {
    final repo = _MockRepo();
    when(() => repo.pushOne(
            tmdbId: any(named: 'tmdbId'),
            mediaType: any(named: 'mediaType')))
        .thenAnswer((_) async => const TmdbPushResult(success: true));
    final useCase = PushTmdbChangeUseCase(repo);
    final r = await useCase(tmdbId: 1, mediaType: 'movie');
    expect(r.success, isTrue);
    verify(() => repo.pushOne(tmdbId: 1, mediaType: 'movie')).called(1);
  });

  test('all() forwards pushAllDirty to repo', () async {
    final repo = _MockRepo();
    when(() => repo.pushAllDirty()).thenAnswer((_) async =>
        const TmdbPushSummary(attempted: 0, succeeded: 0, failed: 0));
    final useCase = PushTmdbChangeUseCase(repo);
    final s = await useCase.all();
    expect(s.attempted, 0);
  });
}
```

- [ ] **Step 5: Run the test**

Run: `flutter test test/unit/domain/usecases/push_tmdb_change_usecase_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/domain/usecases/push_tmdb_change_usecase.dart \
        lib/domain/usecases/toggle_tmdb_watchlist_usecase.dart \
        lib/domain/usecases/toggle_tmdb_favorite_usecase.dart \
        test/unit/domain/usecases/push_tmdb_change_usecase_test.dart
git commit -m "feat(tmdb-sync): add Push/ToggleWatchlist/ToggleFavorite use cases"
```

---

## Task 10: Use case — MirrorOwnershipChange

**Files:**
- Create: `lib/domain/usecases/mirror_ownership_change_usecase.dart`

- [ ] **Step 1: Write the use case**

```dart
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

/// Adds or removes a movie from the MyMediaScanner private TMDB list
/// based on a local ownership transition. No-op for TV (v3 list limit).
/// No-op when mirror toggle is off (caller must check before calling).
class MirrorOwnershipChangeUseCase {
  MirrorOwnershipChangeUseCase(this.repo);
  final ITmdbAccountSyncRepository repo;

  Future<TmdbPushResult> add({required int tmdbId}) =>
      repo.mirrorAddOwnership(tmdbId: tmdbId);

  Future<TmdbPushResult> remove({required int tmdbId}) =>
      repo.mirrorRemoveOwnership(tmdbId: tmdbId);
}
```

- [ ] **Step 2: Smoke compile**

Run: `flutter analyze lib/domain/usecases/mirror_ownership_change_usecase.dart`
Expected: zero issues.

- [ ] **Step 3: Commit**

```bash
git add lib/domain/usecases/mirror_ownership_change_usecase.dart
git commit -m "feat(tmdb-sync): add MirrorOwnershipChange use case"
```

---

## Task 11: Use case — MarkTmdbWatchlistOwned

**Files:**
- Create: `lib/domain/usecases/mark_tmdb_watchlist_owned_usecase.dart`

- [ ] **Step 1: Write the use case**

```dart
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/convert_bridge_to_local_item_usecase.dart';
import 'package:mymediascanner/domain/usecases/toggle_tmdb_watchlist_usecase.dart';
import 'package:mymediascanner/domain/usecases/mirror_ownership_change_usecase.dart';

/// "Mark as owned" on the TMDB watchlist bucket view.
///
/// Three steps:
///  1. Convert the bridge row to a local `media_items` row (owned).
///  2. Remove the title from the TMDB watchlist (push).
///  3. If the mirror toggle is enabled, add the title to the
///     MyMediaScanner private TMDB list.
///
/// Returns a per-step result so the caller can show partial-success messages.
class MarkTmdbWatchlistOwnedUseCase {
  MarkTmdbWatchlistOwnedUseCase({
    required this.convert,
    required this.toggleWatchlist,
    required this.mirror,
  });

  final ConvertBridgeToLocalItemUseCase convert;
  final ToggleTmdbWatchlistUseCase toggleWatchlist;
  final MirrorOwnershipChangeUseCase mirror;

  Future<MarkOwnedResult> call({
    required String bridgeId,
    required int tmdbId,
    required String mediaType,
    required bool mirrorEnabled,
  }) async {
    String? convertError;
    String? watchlistError;
    String? mirrorError;
    String mediaItemId = '';
    try {
      mediaItemId = await convert(bridgeId);
    } catch (e) {
      convertError = e.toString();
    }
    final wl = await toggleWatchlist(
        tmdbId: tmdbId, mediaType: mediaType, value: false);
    if (!wl.success) watchlistError = wl.error;
    if (mirrorEnabled && mediaType == 'movie') {
      final m = await mirror.add(tmdbId: tmdbId);
      if (!m.success) mirrorError = m.error;
    }
    return MarkOwnedResult(
      mediaItemId: mediaItemId,
      convertError: convertError,
      watchlistError: watchlistError,
      mirrorError: mirrorError,
    );
  }
}

class MarkOwnedResult {
  const MarkOwnedResult({
    required this.mediaItemId,
    this.convertError,
    this.watchlistError,
    this.mirrorError,
  });
  final String mediaItemId;
  final String? convertError;
  final String? watchlistError;
  final String? mirrorError;

  bool get fullSuccess =>
      convertError == null &&
      watchlistError == null &&
      mirrorError == null;
}
```

- [ ] **Step 2: Smoke compile**

Run: `flutter analyze lib/domain/usecases/mark_tmdb_watchlist_owned_usecase.dart`
Expected: zero issues.

- [ ] **Step 3: Commit**

```bash
git add lib/domain/usecases/mark_tmdb_watchlist_owned_usecase.dart
git commit -m "feat(tmdb-sync): add MarkTmdbWatchlistOwned three-step use case"
```

---

## Task 12: Use case — ResolveTmdbConflict

**Files:**
- Create: `lib/domain/usecases/resolve_tmdb_conflict_usecase.dart`
- Modify: `lib/data/repositories/tmdb_account_sync_repository_impl.dart` (add `applyConflictResolution`)
- Modify: `lib/domain/repositories/i_tmdb_account_sync_repository.dart` (add interface method)

- [ ] **Step 1: Add interface method**

In `i_tmdb_account_sync_repository.dart`, add:

```dart
/// Apply a user resolution decision to a conflicted bridge row.
/// `keepLocal == true` clears the conflict marker but keeps the row dirty
/// (next push resolves). `keepLocal == false` clears dirty + last_error
/// and applies the remote state via a fresh enrichment call.
Future<void> applyConflictResolution({
  required int tmdbId,
  required String mediaType,
  required bool keepLocal,
});
```

- [ ] **Step 2: Implement on repository**

In `tmdb_account_sync_repository_impl.dart`:

```dart
@override
Future<void> applyConflictResolution({
  required int tmdbId,
  required String mediaType,
  required bool keepLocal,
}) async {
  if (keepLocal) {
    // Clear the conflict marker but keep dirty for next push.
    await dao.recordPushError(
        tmdbId: tmdbId, mediaType: mediaType, error: '');
    // Empty string overwrites; clear it explicitly via clearError-style call.
    await (dao.update(dao.tmdbAccountSyncItemsTable)
          ..where((t) =>
              t.tmdbId.equals(tmdbId) &
              t.tmdbMediaType.equals(mediaType)))
        .write(const TmdbAccountSyncItemsTableCompanion(
      lastError: Value(null),
    ));
  } else {
    // Take TMDB side: re-fetch account state and overwrite.
    await enrichOne(tmdbId: tmdbId, mediaType: mediaType);
    await dao.clearDirty(tmdbId: tmdbId, mediaType: mediaType);
  }
}
```

- [ ] **Step 3: Write the use case**

```dart
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';

class ResolveTmdbConflictUseCase {
  ResolveTmdbConflictUseCase(this.repo);
  final ITmdbAccountSyncRepository repo;

  Future<void> keepMine({
    required int tmdbId,
    required String mediaType,
  }) =>
      repo.applyConflictResolution(
          tmdbId: tmdbId, mediaType: mediaType, keepLocal: true);

  Future<void> useTmdb({
    required int tmdbId,
    required String mediaType,
  }) =>
      repo.applyConflictResolution(
          tmdbId: tmdbId, mediaType: mediaType, keepLocal: false);
}
```

- [ ] **Step 4: Smoke compile + run repository tests**

Run: `flutter analyze lib/domain/ lib/data/repositories/`
Run: `flutter test test/unit/data/repositories/tmdb_account_sync_repository_impl_test.dart`
Expected: zero issues, all tests still pass.

- [ ] **Step 5: Commit**

```bash
git add lib/domain/repositories/i_tmdb_account_sync_repository.dart \
        lib/data/repositories/tmdb_account_sync_repository_impl.dart \
        lib/domain/usecases/resolve_tmdb_conflict_usecase.dart
git commit -m "feat(tmdb-sync): add ResolveTmdbConflict use case"
```

---

## Task 13: Provider extensions — dirty count + use cases

**Files:**
- Modify: `lib/presentation/providers/repository_providers.dart`
- Modify: `lib/presentation/providers/tmdb_account_sync_provider.dart`

- [ ] **Step 1: Register the new use-case providers**

In `lib/presentation/providers/repository_providers.dart`, add imports:

```dart
import 'package:mymediascanner/domain/usecases/push_tmdb_change_usecase.dart';
import 'package:mymediascanner/domain/usecases/toggle_tmdb_watchlist_usecase.dart';
import 'package:mymediascanner/domain/usecases/toggle_tmdb_favorite_usecase.dart';
import 'package:mymediascanner/domain/usecases/mirror_ownership_change_usecase.dart';
import 'package:mymediascanner/domain/usecases/mark_tmdb_watchlist_owned_usecase.dart';
import 'package:mymediascanner/domain/usecases/resolve_tmdb_conflict_usecase.dart';
```

Add the providers near the other slice-A use-case providers:

```dart
final pushTmdbChangeUseCaseProvider =
    Provider<PushTmdbChangeUseCase>((ref) {
  return PushTmdbChangeUseCase(ref.watch(tmdbAccountSyncRepositoryProvider));
});

final toggleTmdbWatchlistUseCaseProvider =
    Provider<ToggleTmdbWatchlistUseCase>((ref) {
  return ToggleTmdbWatchlistUseCase(
      ref.watch(tmdbAccountSyncRepositoryProvider));
});

final toggleTmdbFavoriteUseCaseProvider =
    Provider<ToggleTmdbFavoriteUseCase>((ref) {
  return ToggleTmdbFavoriteUseCase(
      ref.watch(tmdbAccountSyncRepositoryProvider));
});

final mirrorOwnershipChangeUseCaseProvider =
    Provider<MirrorOwnershipChangeUseCase>((ref) {
  return MirrorOwnershipChangeUseCase(
      ref.watch(tmdbAccountSyncRepositoryProvider));
});

final markTmdbWatchlistOwnedUseCaseProvider =
    Provider<MarkTmdbWatchlistOwnedUseCase>((ref) {
  return MarkTmdbWatchlistOwnedUseCase(
    convert: ref.watch(convertBridgeToLocalItemUseCaseProvider),
    toggleWatchlist: ref.watch(toggleTmdbWatchlistUseCaseProvider),
    mirror: ref.watch(mirrorOwnershipChangeUseCaseProvider),
  );
});

final resolveTmdbConflictUseCaseProvider =
    Provider<ResolveTmdbConflictUseCase>((ref) {
  return ResolveTmdbConflictUseCase(
      ref.watch(tmdbAccountSyncRepositoryProvider));
});
```

- [ ] **Step 2: Add dirty-count and conflict providers**

In `lib/presentation/providers/tmdb_account_sync_provider.dart`, add:

```dart
/// Stream of dirty-row count for the settings card "X pending changes".
final tmdbDirtyCountProvider = StreamProvider<int>((ref) {
  return ref.watch(tmdbAccountSyncRepositoryProvider).watchDirtyCount();
});

/// Stream of conflicted bridge rows for the resolve-conflicts screen.
final tmdbConflictedRowsProvider =
    StreamProvider<List<TmdbBridgeItem>>((ref) {
  return ref.watch(tmdbAccountSyncRepositoryProvider).watchConflicts();
});
```

- [ ] **Step 3: Smoke compile**

Run: `flutter analyze lib/presentation/providers/`
Expected: zero issues.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/providers/repository_providers.dart \
        lib/presentation/providers/tmdb_account_sync_provider.dart
git commit -m "feat(tmdb-sync): register slice 2 use case + dirty-count providers"
```

---

## Task 14: ConflictPolicySelector widget

**Files:**
- Create: `lib/presentation/screens/settings/widgets/conflict_policy_selector.dart`

- [ ] **Step 1: Write the widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/tmdb_conflict_policy.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

/// Radio group for picking the TMDB conflict resolution policy.
class ConflictPolicySelector extends ConsumerWidget {
  const ConflictPolicySelector({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policy = ref.watch(tmdbAccountSyncSettingsProvider).conflictPolicy;
    final notifier =
        ref.read(tmdbAccountSyncSettingsProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('When local and TMDB both changed:',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        for (final p in TmdbConflictPolicy.values)
          RadioListTile<TmdbConflictPolicy>(
            value: p,
            groupValue: policy,
            onChanged: enabled ? (v) {
              if (v != null) notifier.setConflictPolicy(v);
            } : null,
            title: Text(_label(p)),
            subtitle: Text(_subtitle(p),
                style: Theme.of(context).textTheme.bodySmall),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
      ],
    );
  }

  String _label(TmdbConflictPolicy p) => switch (p) {
        TmdbConflictPolicy.preferLatestTimestamp => 'Prefer latest timestamp',
        TmdbConflictPolicy.preferLocal => 'Prefer local',
        TmdbConflictPolicy.preferTmdb => 'Prefer TMDB',
        TmdbConflictPolicy.askUser => 'Ask me each time',
      };

  String _subtitle(TmdbConflictPolicy p) => switch (p) {
        TmdbConflictPolicy.preferLatestTimestamp =>
          'Whichever side was edited most recently wins.',
        TmdbConflictPolicy.preferLocal =>
          'Local edits in MyMediaScanner always win.',
        TmdbConflictPolicy.preferTmdb =>
          'TMDB always wins; pulls overwrite local edits.',
        TmdbConflictPolicy.askUser =>
          'Conflicts surface in the Resolve Conflicts screen.',
      };
}
```

- [ ] **Step 2: Smoke compile**

Run: `flutter analyze lib/presentation/screens/settings/widgets/conflict_policy_selector.dart`
Expected: zero issues.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/screens/settings/widgets/conflict_policy_selector.dart
git commit -m "feat(tmdb-sync): add ConflictPolicySelector widget"
```

---

## Task 15: TmdbDisconnectWarningDialog

**Files:**
- Create: `lib/presentation/screens/settings/widgets/tmdb_disconnect_warning_dialog.dart`

- [ ] **Step 1: Write the dialog**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';

enum TmdbDisconnectChoice { pushAndDisconnect, disconnectAnyway, cancel }

/// Three-button dialog shown when the user clicks Disconnect AND there
/// are dirty (un-pushed) bridge rows.
class TmdbDisconnectWarningDialog extends ConsumerStatefulWidget {
  const TmdbDisconnectWarningDialog({super.key, required this.dirtyCount});

  final int dirtyCount;

  @override
  ConsumerState<TmdbDisconnectWarningDialog> createState() =>
      _TmdbDisconnectWarningDialogState();
}

class _TmdbDisconnectWarningDialogState
    extends ConsumerState<TmdbDisconnectWarningDialog> {
  bool _busy = false;
  String? _message;

  Future<void> _pushAndDisconnect() async {
    setState(() {
      _busy = true;
      _message = 'Pushing pending changes…';
    });
    final summary =
        await ref.read(pushTmdbChangeUseCaseProvider).all();
    if (!mounted) return;
    if (summary.failed > 0) {
      setState(() {
        _busy = false;
        _message =
            'Push completed with ${summary.failed} failures. '
                'Disconnect anyway?';
      });
    } else {
      await ref.read(disconnectTmdbAccountUseCaseProvider).call();
      if (!mounted) return;
      await ref
          .read(tmdbAccountConnectionProvider.notifier)
          .refresh();
      if (mounted) {
        Navigator.of(context).pop(TmdbDisconnectChoice.pushAndDisconnect);
      }
    }
  }

  Future<void> _disconnectAnyway() async {
    setState(() {
      _busy = true;
      _message = 'Disconnecting…';
    });
    await ref.read(disconnectTmdbAccountUseCaseProvider).call();
    if (!mounted) return;
    await ref.read(tmdbAccountConnectionProvider.notifier).refresh();
    if (mounted) {
      Navigator.of(context).pop(TmdbDisconnectChoice.disconnectAnyway);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Disconnect TMDB Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You have ${widget.dirtyCount} unsaved change'
              '${widget.dirtyCount == 1 ? '' : 's'} that '
              'have not been pushed to TMDB yet.'),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(_message!),
          ],
          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy
              ? null
              : () =>
                  Navigator.of(context).pop(TmdbDisconnectChoice.cancel),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _busy ? null : _disconnectAnyway,
          child: const Text('Disconnect anyway'),
        ),
        FilledButton(
          onPressed: _busy ? null : _pushAndDisconnect,
          child: const Text('Push and disconnect'),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Smoke compile**

Run: `flutter analyze lib/presentation/screens/settings/widgets/tmdb_disconnect_warning_dialog.dart`
Expected: zero issues.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/screens/settings/widgets/tmdb_disconnect_warning_dialog.dart
git commit -m "feat(tmdb-sync): add TmdbDisconnectWarningDialog"
```

---

## Task 16: Update settings card — wire live toggles + new sections

**Files:**
- Modify: `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart`

- [ ] **Step 1: Read the slice-A settings card**

The slice-A card has disabled "Two-way sync" and "Mirror ownership to TMDB list" toggles + an existing connection row, master/enrich toggles, action buttons, and last-sync summary. We need to:
1. Make the two slice-2 toggles live.
2. Embed a `ConflictPolicySelector` below them.
3. Add a "X pending changes" line + retry-all button.
4. Route the Disconnect button through `TmdbDisconnectWarningDialog` when dirty rows exist.

- [ ] **Step 2: Replace the slice-2 toggles + add new sections**

In `lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart`, find the two `const SwitchListTile(... onChanged: null, ...)` toggles for "Two-way sync" and "Mirror ownership to TMDB list". Replace them with:

```dart
SwitchListTile(
  title: const Text('Push local changes to TMDB'),
  subtitle: const Text('Two-way sync — your edits propagate.'),
  value: settings.twoWaySync,
  onChanged: connectionAsync.value is TmdbConnected
      ? (v) => ref
          .read(tmdbAccountSyncSettingsProvider.notifier)
          .setTwoWaySync(v)
      : null,
),
SwitchListTile(
  title: const Text('Mirror ownership to TMDB list (movies only)'),
  subtitle: const Text(
      'Owned movies are added to a private TMDB list called "MyMediaScanner".'),
  value: settings.mirrorOwnership,
  onChanged: connectionAsync.value is TmdbConnected
      ? (v) => ref
          .read(tmdbAccountSyncSettingsProvider.notifier)
          .setMirrorOwnership(v)
      : null,
),
```

Below the toggles section (before the action-buttons Wrap), add:

```dart
const SizedBox(height: 12),
ConflictPolicySelector(
    enabled: connectionAsync.value is TmdbConnected),
const SizedBox(height: 12),
ref.watch(tmdbDirtyCountProvider).when(
  loading: () => const SizedBox.shrink(),
  error: (_, __) => const SizedBox.shrink(),
  data: (count) {
    if (count == 0) return const SizedBox.shrink();
    return Row(children: [
      Icon(Icons.cloud_upload,
          size: 16, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 6),
      Expanded(child: Text('$count pending change'
          '${count == 1 ? '' : 's'} to push')),
      TextButton.icon(
        icon: const Icon(Icons.sync, size: 16),
        label: const Text('Push pending now'),
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final summary = await ref
              .read(pushTmdbChangeUseCaseProvider)
              .all();
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

Add the import for `ConflictPolicySelector` at top:

```dart
import 'package:mymediascanner/presentation/screens/settings/widgets/conflict_policy_selector.dart';
```

In the `_ConnectionRow` widget, replace the `Disconnect` `TextButton` `onPressed` with a function that checks dirty count first and routes through the warning dialog when needed:

```dart
TextButton(
  onPressed: () => _disconnectWithCheck(context, ref),
  child: const Text('Disconnect'),
),
```

Add this method (top-level or as a class method on `_ConnectionRow`):

```dart
Future<void> _disconnectWithCheck(
    BuildContext context, WidgetRef ref) async {
  final dirty = await ref
      .read(tmdbAccountSyncRepositoryProvider)
      .countDirtyRows();
  if (dirty > 0 && context.mounted) {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TmdbDisconnectWarningDialog(dirtyCount: dirty),
    );
  } else {
    await ref
        .read(disconnectTmdbAccountUseCaseProvider)
        .call();
    await ref
        .read(tmdbAccountConnectionProvider.notifier)
        .refresh();
  }
}
```

Add the import for `TmdbDisconnectWarningDialog`:

```dart
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_disconnect_warning_dialog.dart';
```

- [ ] **Step 3: Smoke compile**

Run: `flutter analyze lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart`
Expected: zero issues.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/screens/settings/widgets/tmdb_account_sync_section.dart
git commit -m "feat(tmdb-sync): wire slice 2 settings toggles + dirty-count + conflict policy"
```

---

## Task 17: TmdbAccountControlsSection (item-detail)

**Files:**
- Create: `lib/presentation/screens/item_detail/widgets/tmdb_account_controls_section.dart`
- Modify: `lib/presentation/screens/item_detail/item_detail_screen.dart`

- [ ] **Step 1: Write the section widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_item.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';

/// Item-detail section for TMDB account state. Cross-platform.
/// Visible when:
///   - accountSyncEnabled is true
///   - the item has a tmdb_id and movie/tv media type
class TmdbAccountControlsSection extends ConsumerWidget {
  const TmdbAccountControlsSection({
    super.key,
    required this.tmdbId,
    required this.mediaType,
  });

  final int tmdbId;
  final String mediaType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(tmdbAccountSyncSettingsProvider);
    if (!settings.enabled) return const SizedBox.shrink();

    final bridgeAsync = ref.watch(
        tmdbBridgeForIdProvider((tmdbId: tmdbId, mediaType: mediaType)));
    return bridgeAsync.maybeWhen(
      data: (bridge) {
        if (bridge == null) return const SizedBox.shrink();
        return _buildSection(context, ref, settings, bridge);
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildSection(
    BuildContext context,
    WidgetRef ref,
    TmdbAccountSyncSettings settings,
    TmdbBridgeItem bridge,
  ) {
    final pushEnabled = settings.twoWaySync;
    final pending = bridge.lastError != null
        ? '⚠ Push failed — tap to retry'
        : (bridge.lastError == null && _isDirty(bridge)
            ? '⏳ Syncing…'
            : null);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.cloud_done, size: 18),
              const SizedBox(width: 6),
              Text('TMDB Account',
                  style: Theme.of(context).textTheme.titleSmall),
            ]),
            const SizedBox(height: 8),
            if (bridge.localRating != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                    'TMDB rating: ${bridge.localRating!.toStringAsFixed(1)} / 5'),
              ),
            Wrap(spacing: 8, runSpacing: 4, children: [
              FilterChip(
                label: const Text('Watchlist'),
                avatar: Icon(
                    bridge.watchlist
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    size: 16),
                selected: bridge.watchlist,
                onSelected: pushEnabled
                    ? (v) async {
                        final messenger = ScaffoldMessenger.of(context);
                        final result = await ref
                            .read(toggleTmdbWatchlistUseCaseProvider)
                            .call(
                                tmdbId: tmdbId,
                                mediaType: mediaType,
                                value: v);
                        if (!result.success) {
                          messenger.showSnackBar(SnackBar(
                              content: Text(
                                  'Watchlist push failed: ${result.error}')));
                        }
                      }
                    : null,
              ),
              FilterChip(
                label: const Text('Favourite'),
                avatar: Icon(
                    bridge.favorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 16),
                selected: bridge.favorite,
                onSelected: pushEnabled
                    ? (v) async {
                        final messenger = ScaffoldMessenger.of(context);
                        final result = await ref
                            .read(toggleTmdbFavoriteUseCaseProvider)
                            .call(
                                tmdbId: tmdbId,
                                mediaType: mediaType,
                                value: v);
                        if (!result.success) {
                          messenger.showSnackBar(SnackBar(
                              content: Text(
                                  'Favourite push failed: ${result.error}')));
                        }
                      }
                    : null,
              ),
            ]),
            if (pending != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: bridge.lastError != null
                    ? () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final result = await ref
                            .read(pushTmdbChangeUseCaseProvider)
                            .call(tmdbId: tmdbId, mediaType: mediaType);
                        if (!result.success) {
                          messenger.showSnackBar(SnackBar(
                              content: Text(
                                  'Retry failed: ${result.error}')));
                        }
                      }
                    : null,
                child: Text(pending,
                    style: TextStyle(
                        color: bridge.lastError != null
                            ? Theme.of(context).colorScheme.error
                            : null)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isDirty(TmdbBridgeItem b) =>
      b.lastError == null && b.lastPulledAt == null;
}
```

- [ ] **Step 2: Embed in `item_detail_screen.dart`**

Read `lib/presentation/screens/item_detail/item_detail_screen.dart`. Find where the slice-A `TmdbBridgeBadge(... size: TmdbBridgeBadgeSize.detailStrip)` is rendered. Replace it with `TmdbAccountControlsSection` when `tmdbId` and `mediaType` are valid:

```dart
import 'package:mymediascanner/presentation/screens/item_detail/widgets/tmdb_account_controls_section.dart';
// ...
final tmdbId = item.extraMetadata['tmdb_id'];
final mediaType = item.extraMetadata['media_type'];
if (tmdbId is int && (mediaType == 'movie' || mediaType == 'tv'))
  TmdbAccountControlsSection(
    tmdbId: tmdbId,
    mediaType: mediaType as String,
  ),
```

If the slice-A badge usage has other call sites, leave them — the new controls section augments rather than removes. The slice-A `TmdbBridgeBadge` on the collection grid stays intact.

- [ ] **Step 3: Smoke compile**

Run: `flutter analyze lib/presentation/screens/item_detail/`
Expected: zero issues.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/screens/item_detail/widgets/tmdb_account_controls_section.dart \
        lib/presentation/screens/item_detail/item_detail_screen.dart
git commit -m "feat(tmdb-sync): add TmdbAccountControlsSection on item detail"
```

---

## Task 18: Bucket screen — Mark as owned + Remove from watchlist actions

**Files:**
- Modify: `lib/presentation/screens/tmdb/tmdb_bucket_screen.dart`

- [ ] **Step 1: Add the new actions on `_BridgeRowTile`**

In `lib/presentation/screens/tmdb/tmdb_bucket_screen.dart`, find the `_BridgeRowTile`'s `trailing` Row of IconButtons. Add two new actions before the existing "Convert to local item" button:

```dart
// Add at the top of the file:
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

// Inside _BridgeRowTile's trailing Row:
if (bucket == TmdbBridgeBucket.watchlist) ...[
  IconButton(
    tooltip: 'Mark as owned',
    icon: const Icon(Icons.check_circle_outline),
    onPressed: () async {
      final messenger = ScaffoldMessenger.of(context);
      final mirrorEnabled = ref
          .read(tmdbAccountSyncSettingsProvider)
          .mirrorOwnership;
      final result = await ref
          .read(markTmdbWatchlistOwnedUseCaseProvider)
          .call(
            bridgeId: item.id,
            tmdbId: item.tmdbId,
            mediaType: item.mediaType,
            mirrorEnabled: mirrorEnabled,
          );
      if (result.fullSuccess) {
        messenger.showSnackBar(const SnackBar(
            content: Text('Marked as owned and removed from watchlist')));
      } else {
        final issues = [
          if (result.convertError != null) 'convert: ${result.convertError}',
          if (result.watchlistError != null)
            'watchlist: ${result.watchlistError}',
          if (result.mirrorError != null) 'mirror: ${result.mirrorError}',
        ].join('; ');
        messenger.showSnackBar(SnackBar(
            content: Text('Partial success — $issues')));
      }
    },
  ),
  IconButton(
    tooltip: 'Remove from TMDB watchlist',
    icon: const Icon(Icons.bookmark_remove),
    onPressed: () async {
      final messenger = ScaffoldMessenger.of(context);
      final result = await ref
          .read(toggleTmdbWatchlistUseCaseProvider)
          .call(
            tmdbId: item.tmdbId,
            mediaType: item.mediaType,
            value: false,
          );
      messenger.showSnackBar(SnackBar(
        content: Text(result.success
            ? 'Removed from TMDB watchlist'
            : 'Remove failed: ${result.error}'),
      ));
    },
  ),
],
```

- [ ] **Step 2: Smoke compile**

Run: `flutter analyze lib/presentation/screens/tmdb/`
Expected: zero issues.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/screens/tmdb/tmdb_bucket_screen.dart
git commit -m "feat(tmdb-sync): add Mark-as-owned + Remove-from-watchlist row actions"
```

---

## Task 19: Resolve-conflicts screen + router/sidebar

**Files:**
- Create: `lib/presentation/screens/tmdb/tmdb_resolve_conflicts_screen.dart`
- Modify: `lib/app/router.dart`
- Modify: `lib/presentation/widgets/app_scaffold.dart`

- [ ] **Step 1: Write the resolve-conflicts screen**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_item.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';

class TmdbResolveConflictsScreen extends ConsumerWidget {
  const TmdbResolveConflictsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = PlatformCapability.isDesktop;
    final asyncRows = ref.watch(tmdbConflictedRowsProvider);

    Widget body = asyncRows.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (rows) {
        if (rows.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No conflicts to resolve.',
                  textAlign: TextAlign.center),
            ),
          );
        }
        return ListView.separated(
          itemCount: rows.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) =>
              _ConflictRow(item: rows[i]),
        );
      },
    );

    return Scaffold(
      appBar:
          isDesktop ? null : AppBar(title: const Text('Resolve Conflicts')),
      body: isDesktop
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ScreenHeader(title: 'Resolve Conflicts'),
                Expanded(child: body),
              ],
            )
          : body,
    );
  }
}

class _ConflictRow extends ConsumerWidget {
  const _ConflictRow({required this.item});
  final TmdbBridgeItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(item.title ?? '#${item.tmdbId}'),
      subtitle: Text('Media type: ${item.mediaType}'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        OutlinedButton(
          onPressed: () async {
            await ref
                .read(resolveTmdbConflictUseCaseProvider)
                .keepMine(
                    tmdbId: item.tmdbId, mediaType: item.mediaType);
          },
          child: const Text('Keep mine'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () async {
            await ref
                .read(resolveTmdbConflictUseCaseProvider)
                .useTmdb(
                    tmdbId: item.tmdbId, mediaType: item.mediaType);
          },
          child: const Text('Use TMDB'),
        ),
      ]),
    );
  }
}
```

- [ ] **Step 2: Add the route in `router.dart`**

Add a 16th `StatefulShellBranch` (after the existing 15) for the resolve-conflicts screen. The route is `/tmdb/conflicts`. Import:

```dart
import 'package:mymediascanner/presentation/screens/tmdb/tmdb_resolve_conflicts_screen.dart';
```

Branch:

```dart
StatefulShellBranch(routes: [
  GoRoute(
    path: '/tmdb/conflicts',
    pageBuilder: (_, __) => const NoTransitionPage(
        child: TmdbResolveConflictsScreen()),
  ),
]),
```

- [ ] **Step 3: Add conditional sidebar entry**

In `lib/presentation/widgets/app_scaffold.dart`, find the `_DesktopSidebar` items list. Add a conditional entry for the resolve-conflicts screen after the existing TMDB entries. Gate on:
- `isTmdbConnected == true`
- `settings.conflictPolicy == TmdbConflictPolicy.askUser`
- conflicted rows count > 0 (use `ref.watch(tmdbConflictedRowsProvider)`)

```dart
// Read the count of conflicts.
final conflicts = ref.watch(tmdbConflictedRowsProvider).maybeWhen(
      data: (rows) => rows.length,
      orElse: () => 0,
    );
final settings = ref.watch(tmdbAccountSyncSettingsProvider);
final showConflicts = isTmdbConnected &&
    settings.conflictPolicy == TmdbConflictPolicy.askUser &&
    conflicts > 0;

// Inside the conditional block where TMDB items are appended:
if (showConflicts)
  _SidebarDestination(
    label: 'Resolve Conflicts ($conflicts)',
    icon: Icons.warning_amber,
    route: '/tmdb/conflicts',
  ),
```

Adapt the exact destination shape to whatever pattern slice-A established for the TMDB sidebar entries. Note: this adds a 16th sidebar position; ensure the router branch index matches.

Update the comment about the identity mapping (slice-A) if needed to reflect the conditional.

Add the imports if missing:

```dart
import 'package:mymediascanner/domain/entities/tmdb_conflict_policy.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
```

- [ ] **Step 4: Smoke compile**

Run: `flutter analyze lib/presentation/screens/tmdb/ lib/app/router.dart lib/presentation/widgets/app_scaffold.dart`
Expected: zero issues.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/screens/tmdb/tmdb_resolve_conflicts_screen.dart \
        lib/app/router.dart \
        lib/presentation/widgets/app_scaffold.dart
git commit -m "feat(tmdb-sync): add resolve-conflicts screen + sidebar entry"
```

---

## Task 20: Wire ownership-mirror trigger into save path

**Files:**
- Modify: `lib/domain/usecases/save_media_item_usecase.dart`

- [ ] **Step 1: Investigate the save path**

Read `lib/domain/usecases/save_media_item_usecase.dart`. Identify where ownership transitions to `owned` are detected (likely on save when `OwnershipStatus == owned`). Find the existing return type and how downstream UI consumes the result.

The mirror trigger should fire **after** the local save succeeds. We need to:
1. Detect when ownership is set to `owned` AND mirror toggle is on AND item has a `tmdb_id` AND media type is movie.
2. Call `MirrorOwnershipChangeUseCase.add(tmdbId: ...)`.
3. Don't fail the save if the mirror call fails — log and continue.

For ownership transitioning AWAY from `owned`, we'd need the previous state. If `SaveMediaItemUseCase` doesn't surface that, dispatch as DONE_WITH_CONCERNS noting the limitation.

- [ ] **Step 2: Add the mirror hook**

Inject `MirrorOwnershipChangeUseCase` and `TmdbAccountSyncSettings` access (via a callback or settings reader) into `SaveMediaItemUseCase`. Add the post-save trigger:

```dart
// After the local save returns the saved item:
if (savedItem.ownershipStatus == OwnershipStatus.owned) {
  final tmdbId = savedItem.extraMetadata['tmdb_id'];
  final mediaType = savedItem.extraMetadata['media_type'];
  if (tmdbId is int && mediaType == 'movie' && _settings.mirrorOwnership) {
    // Best-effort fire-and-forget.
    unawaited(_mirror.add(tmdbId: tmdbId).catchError((_) {
      // Silent — UI will surface via lastError on the bridge row when push pipeline next runs.
    }));
  }
}
```

Inject the dependencies via the use case constructor and update `repository_providers.dart` to wire them.

If integrating into `SaveMediaItemUseCase` is too invasive, an alternative is to add a separate "`MirrorOnSaveHook`" that the screen calls after save. Pick whichever has lower blast radius.

- [ ] **Step 3: Smoke compile + run tests**

Run: `flutter analyze lib/domain/usecases/save_media_item_usecase.dart`
Run: `flutter test test/unit/domain/usecases/`
Expected: zero issues, all tests pass (existing save-media tests should not regress).

- [ ] **Step 4: Commit**

```bash
git add lib/domain/usecases/save_media_item_usecase.dart \
        lib/presentation/providers/repository_providers.dart
git commit -m "feat(tmdb-sync): hook ownership-mirror trigger into save path"
```

---

## Task 21: Integration test — push round-trip

**Files:**
- Modify: `integration_test/tmdb_account_sync_test.dart` (extend)

- [ ] **Step 1: Add a push-rating-roundtrip test**

Append to the existing integration test file:

```dart
testWidgets('push rating end-to-end', (tester) async {
  final api = _MockApi();
  final storage = _MockStorage();
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(() async => db.close());

  // Seed connected state.
  final stored = <String, String>{};
  stored['tmdb.session_id'] = 'sess-1';
  stored['tmdb.account_id'] = '1';
  stored['tmdb.account_username'] = 'paul';
  when(() => storage.read(key: any(named: 'key')))
      .thenAnswer((inv) async => stored[inv.namedArguments[#key]]);
  when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
      .thenAnswer((inv) async {
    stored[inv.namedArguments[#key] as String] =
        inv.namedArguments[#value] as String;
  });
  when(() => storage.delete(key: any(named: 'key')))
      .thenAnswer((inv) async => stored.remove(inv.namedArguments[#key]));

  // Mock the rating push endpoint.
  when(() => api.addMovieRating(550, 'sess-1', any())).thenAnswer((_) async =>
      const TmdbStatusResponseDto(statusCode: 1, success: true));
  when(() => api.setWatchlist(1, 'sess-1', any())).thenAnswer((_) async =>
      const TmdbStatusResponseDto(statusCode: 1, success: true));
  when(() => api.setFavorite(1, 'sess-1', any())).thenAnswer((_) async =>
      const TmdbStatusResponseDto(statusCode: 1, success: true));

  final repo = TmdbAccountSyncRepositoryImpl(
    api: api,
    dao: db.tmdbAccountSyncDao,
    mediaItemsDao: db.mediaItemsDao,
    storage: storage,
  );

  // Update local rating to 4.0 (= TMDB 8.0). Expect a push to fire.
  final result = await repo.updateRating(
      tmdbId: 550, mediaType: 'movie', localRating: 4.0);

  expect(result.success, isTrue);
  verify(() => api.addMovieRating(550, 'sess-1', {'value': 8.0})).called(1);

  final after = await db.tmdbAccountSyncDao.getByTmdbId(550, 'movie');
  expect(after?.localDirty, isFalse);
  expect(after?.localRatingSnapshot, 8.0);
});
```

You may need to add additional imports and fallback registrations.

- [ ] **Step 2: Run the integration test**

Run: `flutter test integration_test/tmdb_account_sync_test.dart -d linux`
Expected: all tests pass (slice-A's 3 + slice-2's 1 = 4).

- [ ] **Step 3: Commit**

```bash
git add integration_test/tmdb_account_sync_test.dart
git commit -m "test(tmdb-sync): integration test for push rating round-trip"
```

---

## Task 22: Final verification

**Files:** none

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: all 1346+ tests pass (slice-A baseline + new slice-2 tests).

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze`
Expected: zero issues.

- [ ] **Step 3: Linux build**

Run: `flutter build linux --debug`
Expected: build succeeds.

- [ ] **Step 4: Android build**

Run: `flutter build apk --debug --flavor dev`
Expected: build succeeds.

- [ ] **Step 5: iOS / macOS** (only on macOS host — skip on Linux with a note)

- [ ] **Step 6: Manual inspection**

1. `lib/data/local/database/app_database.dart` — `schemaVersion` is still 20 (no migration).
2. `lib/data/remote/api/tmdb/tmdb_account_api.dart` — has 9 new endpoints.
3. `lib/data/repositories/tmdb_account_sync_repository_impl.dart` — has `pushOne`, `pushAllDirty`, `ensureMyMediaScannerListId`, `mirrorAddOwnership`, `mirrorRemoveOwnership`, `applyConflictResolution`, `toggleWatchlist`, `toggleFavorite`, `updateRating`, `countDirtyRows`, `watchDirtyCount`, `watchConflicts`.
4. Settings card has live "Push local changes to TMDB" + "Mirror ownership" toggles + ConflictPolicySelector + dirty-count line + Push pending button.
5. Disconnect button routes through `TmdbDisconnectWarningDialog` when dirty rows exist.
6. Item-detail screen renders `TmdbAccountControlsSection` for movies/TV with a TMDB ID.
7. TMDB Watchlist bucket has "Mark as owned" + "Remove from TMDB watchlist" actions.
8. Resolve-conflicts screen route exists at `/tmdb/conflicts`.

- [ ] **Step 7: Final report**

Branch: `feat/tmdb-account-sync-slice-2`
HEAD: <SHA>
Total commits since main: <count>
Test results: <summary>
Linux build: <PASS/FAIL>
Android build: <PASS/FAIL>
iOS build: <PASS/SKIPPED/FAIL>
macOS build: <PASS/SKIPPED/FAIL>
Manual inspection: <PASS/FAIL with notes>

If anything fails, status is DONE_WITH_CONCERNS and the failures are listed.

---

## Self-review

- **Spec coverage:** All six in-scope features have tasks. Push pipeline in T6, push rating in T7, watchlist/favourite in T7+T9, conflict policy default+selector in T1+T5+T14, MyMediaScanner list in T8+T10, cross-reference watchlist actions in T11+T18, resolve-conflicts screen in T12+T19, disconnect-with-warning in T15+T16, ownership-mirror save hook in T20.
- **Placeholder scan:** Some tasks explicitly delegate codebase-discovery work to the implementer (Task 16 for the settings card structure, Task 17 for finding the existing slice-A badge use site, Task 19 for the sidebar item shape, Task 20 for the save use case shape). These are intentional — the slice-A patterns established the surrounding code, and the implementer adapts. No "TBD" or "implement later" markers.
- **Type consistency:** `TmdbConflictPolicy`, `TmdbPushAction`, `TmdbPushResult`, `TmdbPushSummary` are defined once and used consistently. `pushOne` / `pushAllDirty` / `toggleWatchlist` / `toggleFavorite` / `updateRating` / `mirrorAddOwnership` / `mirrorRemoveOwnership` / `ensureMyMediaScannerListId` / `applyConflictResolution` are all on `ITmdbAccountSyncRepository` and used consistently in use cases.
- **Test patterns:** All DAO/repository tests use the existing slice-A fixtures (`AppDatabase.forTesting`, `_MockApi`, `_MockStorage`, mocktail). New use-case tests follow slice-A patterns.
