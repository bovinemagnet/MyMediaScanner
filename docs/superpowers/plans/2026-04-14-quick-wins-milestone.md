# Quick Wins Milestone Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the four features of the "Quick Wins" milestone (issues #32–#35): duplicate detection on scan, random picker, wishlist, and condition/purchase info — as one coherent slice sharing a single schema migration.

**Architecture:** Add a single Drift migration (v11 → v12) that introduces an `ownership_status` enum column plus four optional fields (`condition`, `price_paid`, `acquired_at`, `retailer`) to `media_items`. Wishlist is modelled as `ownership_status = 'wishlist'` on the existing entity (issue #34 answer A). Duplicate detection is a pure-domain usecase called from the save pipeline. Random picker is a standalone domain usecase + dashboard action + filter sheet. Condition/purchase are optional fields surfaced on item detail with a new insights tile.

**Tech Stack:** Drift (SQLite), Freezed, Riverpod 3.x, Flutter, mocktail, flutter_test.

---

## Feature ordering

1. **Section 0 — Shared schema migration to v12** (prerequisite for all features).
2. **Section 1 — Wishlist** (issue #34).
3. **Section 2 — Condition & purchase info** (issue #35).
4. **Section 3 — Duplicate detection on scan** (issue #32).
5. **Section 4 — Random picker** (issue #33).

Each section ends with a green `flutter test` + commit. Commit after each task unless explicitly grouped.

---

## File Structure

**New files:**
- `lib/domain/entities/ownership_status.dart` — enum (`owned`, `wishlist`).
- `lib/domain/entities/item_condition.dart` — enum (`mint`, `nearMint`, `good`, `fair`, `poor`).
- `lib/domain/usecases/detect_duplicate_usecase.dart` — exact-barcode + fuzzy title+year match.
- `lib/domain/usecases/random_pick_usecase.dart` — weighted random over filtered collection.
- `lib/domain/usecases/convert_wishlist_to_owned_usecase.dart` — flip status + set `acquired_at`.
- `lib/presentation/providers/wishlist_provider.dart` — watches wishlist-only items.
- `lib/presentation/providers/random_pick_provider.dart` — holds filter state + last pick.
- `lib/presentation/screens/wishlist/wishlist_screen.dart` — list surface.
- `lib/presentation/screens/dashboard/widgets/random_pick_tile.dart` — dashboard entry.
- `lib/presentation/screens/dashboard/widgets/random_pick_sheet.dart` — filter + result modal.
- `lib/presentation/screens/item_detail/widgets/purchase_info_section.dart` — condition/price/acquired/retailer editor.
- `lib/presentation/widgets/duplicate_warning_dialog.dart` — modal with "different edition" override.
- Tests for each of the above under `test/unit/` and `test/widget/`.

**Modified files:**
- `lib/data/local/database/tables/media_items_table.dart` — five new columns.
- `lib/data/local/database/app_database.dart` — bump `schemaVersion` to 12, add `if (from < 12)` migration branch.
- `lib/data/local/dao/media_items_dao.dart` — filter helpers for ownership status; `countByBarcode`; `findByTitleYear`.
- `lib/data/mappers/media_item_mapper.dart` — map new columns ↔ entity.
- `lib/domain/entities/media_item.dart` — add `ownershipStatus`, `condition`, `pricePaid`, `acquiredAt`, `retailer` (all optional with defaults).
- `lib/domain/repositories/i_media_item_repository.dart` — add `countByBarcode`, `findByTitleYear`, `watchByStatus`.
- `lib/data/repositories/media_item_repository.dart` — implement the new methods.
- `lib/domain/usecases/save_media_item_usecase.dart` — consult `DetectDuplicateUsecase` before save and surface the result.
- `lib/presentation/providers/collection_provider.dart` — default to `ownershipStatus == owned` filter; expose switch.
- `lib/presentation/screens/item_detail/item_detail_screen.dart` — embed `PurchaseInfoSection`.
- `lib/presentation/screens/statistics/statistics_screen.dart` — add "Collection Value" tile.
- `lib/presentation/screens/dashboard/dashboard_screen.dart` — add `RandomPickTile`.
- `lib/app/router.dart` — register `/wishlist` route.
- `lib/presentation/widgets/app_scaffold.dart` — wishlist nav entry (desktop sidebar only).
- `lib/data/remote/sync/*` — include new columns in sync payload (mirror existing pattern).

---

## Section 0 — Shared schema migration (v11 → v12)

**Goal:** Add five columns to `media_items` with safe defaults; all existing rows become `ownership_status = 'owned'` with null condition/price/retailer and `acquired_at = date_added`.

### Task 0.1: Extend `MediaItemsTable` with five columns

**Files:**
- Modify: `lib/data/local/database/tables/media_items_table.dart`

- [ ] **Step 1: Add columns**

Edit `media_items_table.dart` — add below `deleted`:

```dart
  TextColumn get ownershipStatus =>
      text().withDefault(const Constant('owned'))();
  TextColumn get condition => text().nullable()();
  RealColumn get pricePaid => real().nullable()();
  IntColumn get acquiredAt => integer().nullable()();
  TextColumn get retailer => text().nullable()();
```

- [ ] **Step 2: Regenerate Drift code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: exits 0; `app_database.g.dart` and `media_items_dao.g.dart` updated.

- [ ] **Step 3: Commit**

```bash
git add lib/data/local/database/tables/media_items_table.dart \
        lib/data/local/database/app_database.g.dart \
        lib/data/local/dao/media_items_dao.g.dart
git commit -m "feat(db): add ownership, condition and purchase columns to media_items"
```

### Task 0.2: Bump schema version and add migration

**Files:**
- Modify: `lib/data/local/database/app_database.dart:79` and migration block.

- [ ] **Step 1: Change schemaVersion**

Edit line 79: `int get schemaVersion => 12;`

- [ ] **Step 2: Append migration branch**

Inside the `onUpgrade` closure, after the `if (from < 11)` block, add:

```dart
          if (from < 12) {
            await m.addColumn(
                mediaItemsTable, mediaItemsTable.ownershipStatus);
            await m.addColumn(mediaItemsTable, mediaItemsTable.condition);
            await m.addColumn(mediaItemsTable, mediaItemsTable.pricePaid);
            await m.addColumn(mediaItemsTable, mediaItemsTable.acquiredAt);
            await m.addColumn(mediaItemsTable, mediaItemsTable.retailer);
            // Backfill acquiredAt from dateAdded where null (column defaults
            // apply to new rows; existing rows keep NULL without this).
            await customStatement(
                'UPDATE media_items '
                "SET acquired_at = date_added WHERE acquired_at IS NULL");
          }
```

- [ ] **Step 3: Write migration test**

Create `test/unit/data/local/database/migration_v12_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';

void main() {
  test('v12 schema exposes ownership and purchase columns', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    // Trigger creation via a no-op query
    await db.customSelect('SELECT 1').get();

    final rows = await db.customSelect(
      "SELECT name FROM pragma_table_info('media_items')",
    ).get();
    final names = rows.map((r) => r.data['name'] as String).toSet();
    expect(names, containsAll(
        ['ownership_status', 'condition', 'price_paid', 'acquired_at', 'retailer']));
  });
}
```

- [ ] **Step 4: Run test**

Run: `flutter test test/unit/data/local/database/migration_v12_test.dart`
Expected: 1 passed.

- [ ] **Step 5: Commit**

```bash
git add lib/data/local/database/app_database.dart test/unit/data/local/database/migration_v12_test.dart
git commit -m "feat(db): migrate media_items to schema v12"
```

### Task 0.3: Add domain enums

**Files:**
- Create: `lib/domain/entities/ownership_status.dart`
- Create: `lib/domain/entities/item_condition.dart`

- [ ] **Step 1: Write enums**

`ownership_status.dart`:

```dart
enum OwnershipStatus {
  owned,
  wishlist;

  static OwnershipStatus fromString(String value) =>
      OwnershipStatus.values.firstWhere(
        (v) => v.name == value,
        orElse: () => OwnershipStatus.owned,
      );
}
```

`item_condition.dart`:

```dart
enum ItemCondition {
  mint,
  nearMint,
  good,
  fair,
  poor;

  static ItemCondition? fromString(String? value) {
    if (value == null) return null;
    for (final c in ItemCondition.values) {
      if (c.name == value) return c;
    }
    return null;
  }

  String get label => switch (this) {
        mint => 'Mint',
        nearMint => 'Near Mint',
        good => 'Good',
        fair => 'Fair',
        poor => 'Poor',
      };
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/domain/entities/ownership_status.dart lib/domain/entities/item_condition.dart
git commit -m "feat(domain): add OwnershipStatus and ItemCondition enums"
```

### Task 0.4: Extend `MediaItem` entity

**Files:**
- Modify: `lib/domain/entities/media_item.dart`

- [ ] **Step 1: Add fields**

Add above `required int dateAdded`:

```dart
    @Default(OwnershipStatus.owned) OwnershipStatus ownershipStatus,
    ItemCondition? condition,
    double? pricePaid,
    int? acquiredAt,
    String? retailer,
```

Add imports:

```dart
import 'package:mymediascanner/domain/entities/item_condition.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
```

- [ ] **Step 2: Regenerate Freezed**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: exits 0.

- [ ] **Step 3: Update mapper**

Edit `lib/data/mappers/media_item_mapper.dart`. In `toEntity()` add:

```dart
      ownershipStatus: OwnershipStatus.fromString(row.ownershipStatus),
      condition: ItemCondition.fromString(row.condition),
      pricePaid: row.pricePaid,
      acquiredAt: row.acquiredAt,
      retailer: row.retailer,
```

In `toCompanion()` add:

```dart
      ownershipStatus: Value(item.ownershipStatus.name),
      condition: Value(item.condition?.name),
      pricePaid: Value(item.pricePaid),
      acquiredAt: Value(item.acquiredAt),
      retailer: Value(item.retailer),
```

- [ ] **Step 4: Verify existing tests still compile**

Run: `flutter test test/unit/data/mappers/ test/unit/domain/`
Expected: no regressions (may need to accept the generated `copyWith` / `==` changes).

- [ ] **Step 5: Commit**

```bash
git add lib/domain/entities/media_item.dart lib/domain/entities/media_item.freezed.dart \
        lib/data/mappers/media_item_mapper.dart
git commit -m "feat(domain): extend MediaItem with ownership and purchase fields"
```

### Task 0.5: Update sync payload

**Files:**
- Modify: sync client and conflict fields (follow existing pattern — grep for `'user_review'` in `lib/data/remote/sync/` and extend every list where that appears).

- [ ] **Step 1: Add new columns to sync**

For each file under `lib/data/remote/sync/` where `user_review` appears as a Postgres column or conflict field, add the five new columns in the same order: `ownership_status`, `condition`, `price_paid`, `acquired_at`, `retailer`.

- [ ] **Step 2: Run sync tests**

Run: `flutter test test/unit/data/remote/sync/`
Expected: pass. If conflict-resolution tests reference column counts, update them to match.

- [ ] **Step 3: Commit**

```bash
git add lib/data/remote/sync/
git commit -m "feat(sync): sync ownership and purchase fields"
```

---

## Section 1 — Wishlist (issue #34)

### Task 1.1: Repository — `watchByStatus`

**Files:**
- Modify: `lib/data/local/dao/media_items_dao.dart`, `lib/domain/repositories/i_media_item_repository.dart`, `lib/data/repositories/media_item_repository.dart`.
- Test: `test/unit/data/repositories/media_item_repository_test.dart`.

- [ ] **Step 1: Write failing test**

Append to the repository test:

```dart
  test('watchByStatus returns only wishlist items', () async {
    await repo.save(owned.copyWith(id: 'a'));
    await repo.save(owned.copyWith(
        id: 'b', ownershipStatus: OwnershipStatus.wishlist));
    final list = await repo.watchByStatus(OwnershipStatus.wishlist).first;
    expect(list.map((e) => e.id), ['b']);
  });
```

- [ ] **Step 2: Run — expect fail**

Run: `flutter test test/unit/data/repositories/media_item_repository_test.dart -n watchByStatus`
Expected: FAIL (method missing).

- [ ] **Step 3: Implement**

DAO — add:

```dart
  Stream<List<MediaItemsTableData>> watchByStatus(String status) {
    return (select(mediaItemsTable)
          ..where((t) =>
              t.ownershipStatus.equals(status) & t.deleted.equals(0))
          ..orderBy([(t) => OrderingTerm.desc(t.dateAdded)]))
        .watch();
  }
```

Repository interface — add:

```dart
  Stream<List<MediaItem>> watchByStatus(OwnershipStatus status);
```

Repository impl — add:

```dart
  @override
  Stream<List<MediaItem>> watchByStatus(OwnershipStatus status) =>
      _dao.watchByStatus(status.name).map((rows) =>
          rows.map(_mapper.toEntity).toList());
```

- [ ] **Step 4: Run — expect pass**

Run: `flutter test test/unit/data/repositories/media_item_repository_test.dart -n watchByStatus`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/data/local/dao/media_items_dao.dart \
        lib/domain/repositories/i_media_item_repository.dart \
        lib/data/repositories/media_item_repository.dart \
        test/unit/data/repositories/media_item_repository_test.dart
git commit -m "feat(repo): add watchByStatus for wishlist filtering"
```

### Task 1.2: Filter collection to `owned` by default

**Files:**
- Modify: `lib/presentation/providers/collection_provider.dart` — existing list provider currently returns all non-deleted items; scope it to `ownershipStatus == owned`.
- Test: matching provider test.

- [ ] **Step 1: Write failing test**

In `test/unit/presentation/providers/collection_provider_test.dart` add:

```dart
  test('collection excludes wishlist items', () async {
    await repo.save(ownedItem);
    await repo.save(wishlistItem);
    final container = makeContainer(repo);
    final items =
        await container.read(collectionProvider.future);
    expect(items.map((e) => e.id), [ownedItem.id]);
  });
```

- [ ] **Step 2: Run — expect fail**

Run: `flutter test test/unit/presentation/providers/collection_provider_test.dart -n "excludes wishlist"`
Expected: FAIL.

- [ ] **Step 3: Implement**

In `collection_provider.dart`, replace the current stream mapping with `repo.watchByStatus(OwnershipStatus.owned)`.

- [ ] **Step 4: Run — expect pass**

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/providers/collection_provider.dart \
        test/unit/presentation/providers/collection_provider_test.dart
git commit -m "feat(collection): scope default list to owned items"
```

### Task 1.3: Wishlist provider

**Files:**
- Create: `lib/presentation/providers/wishlist_provider.dart`.
- Test: `test/unit/presentation/providers/wishlist_provider_test.dart`.

- [ ] **Step 1: Write failing test**

```dart
void main() {
  test('wishlistProvider emits only wishlist items', () async {
    final repo = FakeRepo();
    await repo.save(owned);
    await repo.save(wish);
    final c = ProviderContainer(overrides: [
      mediaItemRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(c.dispose);
    final items = await c.read(wishlistProvider.future);
    expect(items.map((e) => e.id), [wish.id]);
  });
}
```

- [ ] **Step 2: Run — expect fail**

Expected: FAIL (provider missing).

- [ ] **Step 3: Implement**

```dart
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final wishlistProvider = StreamProvider<List<MediaItem>>((ref) {
  final repo = ref.watch(mediaItemRepositoryProvider);
  return repo.watchByStatus(OwnershipStatus.wishlist);
});
```

(Match whatever hand-written provider pattern the codebase uses — see `collection_provider.dart`.)

- [ ] **Step 4: Run — expect pass**

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/providers/wishlist_provider.dart \
        test/unit/presentation/providers/wishlist_provider_test.dart
git commit -m "feat(providers): add wishlistProvider"
```

### Task 1.4: Wishlist screen

**Files:**
- Create: `lib/presentation/screens/wishlist/wishlist_screen.dart`.
- Modify: `lib/app/router.dart`, `lib/presentation/widgets/app_scaffold.dart`.
- Test: `test/widget/presentation/screens/wishlist/wishlist_screen_test.dart`.

- [ ] **Step 1: Write widget test**

```dart
testWidgets('WishlistScreen shows items and convert button', (tester) async {
  final repo = FakeRepo()..addWishlist('A Book');
  await pumpWithRepo(tester, repo, const WishlistScreen());
  await tester.pumpAndSettle();
  expect(find.text('A Book'), findsOneWidget);
  expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
});
```

- [ ] **Step 2: Run — expect fail**

Expected: FAIL (screen missing).

- [ ] **Step 3: Implement**

Minimal screen: `ScreenHeader`, `ListView.builder` driven by `ref.watch(wishlistProvider)`, each tile has a "Mark owned" icon button invoking `ConvertWishlistToOwnedUsecase` (added in 1.5).

- [ ] **Step 4: Register route**

In `router.dart` add under the existing `StatefulShellBranch` list a new branch for `/wishlist` that hosts `WishlistScreen`. Add a `NavigationItem` in `app_scaffold.dart` for the sidebar (desktop only — mirror the Shelves pattern).

- [ ] **Step 5: Run — expect pass**

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/screens/wishlist/ lib/app/router.dart \
        lib/presentation/widgets/app_scaffold.dart \
        test/widget/presentation/screens/wishlist/
git commit -m "feat(wishlist): add wishlist screen and navigation"
```

### Task 1.5: Convert-to-owned usecase

**Files:**
- Create: `lib/domain/usecases/convert_wishlist_to_owned_usecase.dart`.
- Test: `test/unit/domain/convert_wishlist_to_owned_usecase_test.dart`.

- [ ] **Step 1: Write failing test**

```dart
test('converts item from wishlist to owned and stamps acquiredAt', () async {
  final repo = FakeRepo();
  final item = wish.copyWith(id: 'x');
  await repo.save(item);
  final uc = ConvertWishlistToOwnedUsecase(repo, clock: () => 1700);
  await uc(item.id);
  final stored = await repo.findById(item.id);
  expect(stored!.ownershipStatus, OwnershipStatus.owned);
  expect(stored.acquiredAt, 1700);
});
```

- [ ] **Step 2: Run — expect fail.**

- [ ] **Step 3: Implement**

```dart
class ConvertWishlistToOwnedUsecase {
  ConvertWishlistToOwnedUsecase(this._repo, {int Function()? clock})
      : _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch);
  final IMediaItemRepository _repo;
  final int Function() _clock;

  Future<void> call(String id) async {
    final item = await _repo.findById(id);
    if (item == null || item.ownershipStatus != OwnershipStatus.wishlist) {
      return;
    }
    await _repo.save(item.copyWith(
      ownershipStatus: OwnershipStatus.owned,
      acquiredAt: _clock(),
      updatedAt: _clock(),
    ));
  }
}
```

- [ ] **Step 4: Run — expect pass.**

- [ ] **Step 5: Wire the wishlist screen button to call the usecase (via a provider). Run the widget test again.**

- [ ] **Step 6: Commit**

```bash
git add lib/domain/usecases/convert_wishlist_to_owned_usecase.dart \
        lib/presentation/screens/wishlist/ \
        test/unit/domain/convert_wishlist_to_owned_usecase_test.dart
git commit -m "feat(wishlist): convert-to-owned usecase and UI action"
```

### Task 1.6: Scan flow — "Save to wishlist" alternative

**Files:**
- Modify: `lib/presentation/screens/metadata_confirm/metadata_confirm_screen.dart` — add secondary button "Save to Wishlist" which calls the save provider with `ownershipStatus: OwnershipStatus.wishlist`.
- Test: widget test asserting the button is present and saves with the wishlist flag.

- [ ] **Step 1: Write failing widget test**

Assert that after tapping the "Save to Wishlist" button, the fake save usecase was called with a `MediaItem` whose `ownershipStatus == wishlist`.

- [ ] **Step 2: Run — expect fail.**

- [ ] **Step 3: Implement** — add the button next to existing Save, passing the flag through to the save pipeline.

- [ ] **Step 4: Run — expect pass.**

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/screens/metadata_confirm/ \
        test/widget/presentation/screens/metadata_confirm/
git commit -m "feat(wishlist): save-to-wishlist option in metadata confirm"
```

### Task 1.7: Section checkpoint

- [ ] `flutter test` → all green.
- [ ] `flutter analyze` → no new warnings.

---

## Section 2 — Condition & purchase info (issue #35)

### Task 2.1: Purchase info editor widget

**Files:**
- Create: `lib/presentation/screens/item_detail/widgets/purchase_info_section.dart`.
- Test: `test/widget/presentation/screens/item_detail/widgets/purchase_info_section_test.dart`.

- [ ] **Step 1: Write widget test**

```dart
testWidgets('PurchaseInfoSection emits onChange on edit', (tester) async {
  MediaItem? captured;
  await tester.pumpWidget(MaterialApp(home: Scaffold(
    body: PurchaseInfoSection(
      item: baseItem,
      onChanged: (m) => captured = m,
    ),
  )));
  await tester.tap(find.byKey(const Key('condition-dropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Good').last);
  await tester.pumpAndSettle();
  expect(captured?.condition, ItemCondition.good);
});
```

- [ ] **Step 2: Run — expect fail.**

- [ ] **Step 3: Implement**

A `Column` using the existing tonal-container/uppercase-label convention, with:
- `DropdownButtonFormField<ItemCondition>` (key `condition-dropdown`) offering `ItemCondition.values`.
- `TextFormField` for price paid (numeric keyboard) — parse to double.
- `TextFormField` for retailer.
- Read-only tile for "Acquired" date with a `DatePicker` launcher that writes `acquiredAt`.

Call `onChanged(item.copyWith(...))` on each field change.

- [ ] **Step 4: Run — expect pass.**

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/screens/item_detail/widgets/purchase_info_section.dart \
        test/widget/presentation/screens/item_detail/widgets/purchase_info_section_test.dart
git commit -m "feat(detail): add purchase info section widget"
```

### Task 2.2: Embed in item detail screen

**Files:**
- Modify: `lib/presentation/screens/item_detail/item_detail_screen.dart` — insert `PurchaseInfoSection` between rating and lending sections. Wire `onChanged` to the existing save provider (debounced or save-on-blur, matching existing rating save pattern).
- Test: extend existing item_detail widget test.

- [ ] **Step 1: Add a widget test** asserting the section appears for an owned item and its edits persist via the fake repo.

- [ ] **Step 2: Implement.**

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/screens/item_detail/ \
        test/widget/presentation/screens/item_detail/
git commit -m "feat(detail): embed purchase info section"
```

### Task 2.3: Collection-value insight tile

**Files:**
- Modify: `lib/domain/usecases/get_insights_usecase.dart` (or equivalent — locate via grep `InsightsData`) to aggregate `sum(pricePaid)` over owned items.
- Modify: `lib/presentation/screens/statistics/statistics_screen.dart` — add a new `StatTile` labelled "Collection value".
- Test: unit test for the aggregation and widget test for the tile.

- [ ] **Step 1: Write failing unit test** for the aggregate returning the sum ignoring nulls.

- [ ] **Step 2: Run — expect fail.**

- [ ] **Step 3: Implement aggregation** — extend the insights entity with `totalValue` (nullable double) and populate it from the repo.

- [ ] **Step 4: Add tile** — use the existing `StatTile` component; format via `NumberFormat.simpleCurrency()` from `intl`.

- [ ] **Step 5: Run — expect pass.**

- [ ] **Step 6: Commit**

```bash
git add lib/domain/entities/insights_data.dart \
        lib/domain/entities/insights_data.freezed.dart \
        lib/domain/usecases/ \
        lib/presentation/screens/statistics/ \
        test/unit/domain/
git commit -m "feat(insights): add collection value tile"
```

### Task 2.4: Section checkpoint

- [ ] `flutter test` → green.
- [ ] `flutter analyze` → clean.

---

## Section 3 — Duplicate detection on scan (issue #32)

### Task 3.1: Repo lookups

**Files:**
- Modify: DAO + repo interface + impl to add `countByBarcode(String)` and `findByTitleYear(String title, int? year)`.
- Test: `test/unit/data/repositories/media_item_repository_test.dart`.

- [ ] **Step 1: Write failing tests**

```dart
test('countByBarcode counts non-deleted matches', () async {
  await repo.save(owned.copyWith(id: '1', barcode: '123'));
  await repo.save(owned.copyWith(
      id: '2', barcode: '123', deleted: true));
  expect(await repo.countByBarcode('123'), 1);
});

test('findByTitleYear returns candidates with same year', () async {
  await repo.save(owned.copyWith(id: '1', title: 'Dune', year: 1984));
  await repo.save(owned.copyWith(id: '2', title: 'Dune', year: 2021));
  final m = await repo.findByTitleYear('Dune', 2021);
  expect(m.map((e) => e.id), ['2']);
});
```

- [ ] **Step 2: Run — expect fail.**

- [ ] **Step 3: Implement**

DAO methods using simple `select` with `where` clauses (barcode equals and deleted = 0; title equalsIgnoreCase via `collate nocase` and year equals).

- [ ] **Step 4: Run — expect pass.**

- [ ] **Step 5: Commit**

```bash
git add lib/data/local/dao/media_items_dao.dart \
        lib/domain/repositories/i_media_item_repository.dart \
        lib/data/repositories/media_item_repository.dart \
        test/unit/data/repositories/media_item_repository_test.dart
git commit -m "feat(repo): countByBarcode and findByTitleYear"
```

### Task 3.2: `DetectDuplicateUsecase`

**Files:**
- Create: `lib/domain/usecases/detect_duplicate_usecase.dart`.
- Test: `test/unit/domain/detect_duplicate_usecase_test.dart`.

- [ ] **Step 1: Define result type in-file**

```dart
enum DuplicateKind { exactBarcode, fuzzyTitle, none }

class DuplicateMatch {
  const DuplicateMatch(this.kind, this.candidates);
  final DuplicateKind kind;
  final List<MediaItem> candidates;
}
```

- [ ] **Step 2: Write failing tests**

Three cases: exact barcode match (returns `exactBarcode`), title+year fuzzy match at ≥0.85 similarity (returns `fuzzyTitle`), and no match (returns `none`).

- [ ] **Step 3: Run — expect fail.**

- [ ] **Step 4: Implement**

```dart
class DetectDuplicateUsecase {
  DetectDuplicateUsecase(this._repo);
  final IMediaItemRepository _repo;

  static const double _fuzzyThreshold = 0.85;

  Future<DuplicateMatch> call({
    required String barcode,
    required String title,
    int? year,
    String? excludeId,
  }) async {
    final byBarcode = await _repo.findByBarcode(barcode);
    final exact = byBarcode.where((e) => e.id != excludeId).toList();
    if (exact.isNotEmpty) {
      return DuplicateMatch(DuplicateKind.exactBarcode, exact);
    }
    final candidates = await _repo.findByTitleYear(title, year);
    final fuzzy = candidates.where((c) {
      if (c.id == excludeId) return false;
      return _similarity(c.title, title) >= _fuzzyThreshold;
    }).toList();
    if (fuzzy.isNotEmpty) {
      return DuplicateMatch(DuplicateKind.fuzzyTitle, fuzzy);
    }
    return const DuplicateMatch(DuplicateKind.none, []);
  }

  double _similarity(String a, String b) {
    final s1 = a.toLowerCase();
    final s2 = b.toLowerCase();
    final d = _levenshtein(s1, s2);
    final maxLen = s1.length > s2.length ? s1.length : s2.length;
    if (maxLen == 0) return 1.0;
    return 1.0 - d / maxLen;
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    final prev = List<int>.generate(b.length + 1, (i) => i);
    final cur = List<int>.filled(b.length + 1, 0);
    for (var i = 0; i < a.length; i++) {
      cur[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final cost = a[i] == b[j] ? 0 : 1;
        cur[j + 1] = [
          cur[j] + 1,
          prev[j + 1] + 1,
          prev[j] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
      for (var k = 0; k < cur.length; k++) prev[k] = cur[k];
    }
    return prev[b.length];
  }
}
```

Also add `findByBarcode(String)` (returning list of non-deleted) to the repo if missing — mirror `countByBarcode` pattern.

- [ ] **Step 5: Run — expect pass.**

- [ ] **Step 6: Commit**

```bash
git add lib/domain/usecases/detect_duplicate_usecase.dart \
        lib/data/local/dao/media_items_dao.dart \
        lib/domain/repositories/i_media_item_repository.dart \
        lib/data/repositories/media_item_repository.dart \
        test/unit/domain/detect_duplicate_usecase_test.dart
git commit -m "feat(domain): detect duplicate usecase (exact + fuzzy)"
```

### Task 3.3: Duplicate warning dialog

**Files:**
- Create: `lib/presentation/widgets/duplicate_warning_dialog.dart`.
- Test: `test/widget/presentation/widgets/duplicate_warning_dialog_test.dart`.

- [ ] **Step 1: Write widget test** — pumping a dialog with one candidate, tapping "Different edition — save anyway" resolves the future with `true`; tapping "Cancel" resolves `false`.

- [ ] **Step 2: Run — expect fail.**

- [ ] **Step 3: Implement**

Stateless dialog showing candidate covers/titles/years in a small list. Two actions: "Cancel" (returns `false`) and "Different edition — save anyway" (returns `true`). Include a text hint distinguishing exact-barcode vs fuzzy-title cases.

- [ ] **Step 4: Run — expect pass.**

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/duplicate_warning_dialog.dart \
        test/widget/presentation/widgets/duplicate_warning_dialog_test.dart
git commit -m "feat(scan): duplicate warning dialog"
```

### Task 3.4: Integrate into save pipeline

**Files:**
- Modify: `lib/domain/usecases/save_media_item_usecase.dart` — accept an optional pre-save duplicate check outcome; OR keep it purely as a callable from the presentation layer before invoking save.
- Modify: `lib/presentation/screens/metadata_confirm/metadata_confirm_screen.dart` — call `DetectDuplicateUsecase` on save; on non-`none` result, show `DuplicateWarningDialog` and only proceed if the user confirms "different edition".
- Modify: `lib/presentation/screens/batch/…` — same integration at the bulk-save entry point.
- Test: widget tests for both flows.

- [ ] **Step 1: Write widget tests** for the metadata confirm screen covering (a) no duplicate → saves directly, (b) duplicate → dialog shown, cancel aborts save, (c) duplicate → confirm proceeds.

- [ ] **Step 2: Run — expect fail.**

- [ ] **Step 3: Implement** the pre-save check in the screen's save handler.

- [ ] **Step 4: Replicate** in the batch save entry point.

- [ ] **Step 5: Run — expect pass.**

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/screens/metadata_confirm/ \
        lib/presentation/screens/batch/ \
        test/widget/presentation/screens/
git commit -m "feat(scan): warn on duplicate before save"
```

### Task 3.5: Section checkpoint

- [ ] `flutter test` → green.

---

## Section 4 — Random picker (issue #33)

### Task 4.1: Filter entity

**Files:**
- Create: `lib/domain/entities/random_pick_filter.dart`.

- [ ] **Step 1: Write the entity**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

part 'random_pick_filter.freezed.dart';

@freezed
sealed class RandomPickFilter with _$RandomPickFilter {
  const factory RandomPickFilter({
    String? shelfId,
    MediaType? mediaType,
    String? genre,
    int? maxRuntimeMinutes,
    int? maxPageCount,
    @Default(false) bool unratedOnly,
  }) = _RandomPickFilter;
}
```

- [ ] **Step 2: Regenerate**

Run: `dart run build_runner build --delete-conflicting-outputs`.

- [ ] **Step 3: Commit**

```bash
git add lib/domain/entities/random_pick_filter.dart \
        lib/domain/entities/random_pick_filter.freezed.dart
git commit -m "feat(domain): RandomPickFilter entity"
```

### Task 4.2: `RandomPickUsecase`

**Files:**
- Create: `lib/domain/usecases/random_pick_usecase.dart`.
- Test: `test/unit/domain/random_pick_usecase_test.dart`.

- [ ] **Step 1: Write failing tests**

Cover: returns null when no items match; returns an item from the filtered subset; excludes wishlist items; honours `unratedOnly` and `mediaType` filters; uses injected `Random` for deterministic testing.

- [ ] **Step 2: Run — expect fail.**

- [ ] **Step 3: Implement**

```dart
class RandomPickUsecase {
  RandomPickUsecase(this._repo, {Random? rng}) : _rng = rng ?? Random();
  final IMediaItemRepository _repo;
  final Random _rng;

  Future<MediaItem?> call(RandomPickFilter f) async {
    final owned = await _repo.watchByStatus(OwnershipStatus.owned).first;
    final filtered = owned.where((i) {
      if (f.mediaType != null && i.mediaType != f.mediaType) return false;
      if (f.genre != null && !i.genres.contains(f.genre)) return false;
      if (f.unratedOnly && i.userRating != null) return false;
      final runtime = i.extraMetadata['runtimeMinutes'];
      if (f.maxRuntimeMinutes != null && runtime is int &&
          runtime > f.maxRuntimeMinutes!) return false;
      final pages = i.extraMetadata['pageCount'];
      if (f.maxPageCount != null && pages is int &&
          pages > f.maxPageCount!) return false;
      // shelfId handled via a repo join if needed; YAGNI for v1.
      return true;
    }).toList();
    if (filtered.isEmpty) return null;
    return filtered[_rng.nextInt(filtered.length)];
  }
}
```

(Shelf filter: deferred — implement only if trivially available in the repo. Otherwise leave `shelfId` field in the entity for later wiring and omit it from the filter predicate.)

- [ ] **Step 4: Run — expect pass.**

- [ ] **Step 5: Commit**

```bash
git add lib/domain/usecases/random_pick_usecase.dart \
        test/unit/domain/random_pick_usecase_test.dart
git commit -m "feat(domain): random pick usecase"
```

### Task 4.3: Provider

**Files:**
- Create: `lib/presentation/providers/random_pick_provider.dart`.
- Test: `test/unit/presentation/providers/random_pick_provider_test.dart`.

- [ ] **Step 1: Write failing test** — invoking `roll()` updates state with a picked item.

- [ ] **Step 2: Run — expect fail.**

- [ ] **Step 3: Implement** a hand-written `AsyncNotifier<MediaItem?>` that holds the current `RandomPickFilter` and exposes `updateFilter(...)` and `roll()`.

- [ ] **Step 4: Run — expect pass.**

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/providers/random_pick_provider.dart \
        test/unit/presentation/providers/random_pick_provider_test.dart
git commit -m "feat(providers): random pick notifier"
```

### Task 4.4: Dashboard tile + filter sheet

**Files:**
- Create: `lib/presentation/screens/dashboard/widgets/random_pick_tile.dart`.
- Create: `lib/presentation/screens/dashboard/widgets/random_pick_sheet.dart`.
- Modify: `lib/presentation/screens/dashboard/dashboard_screen.dart`.
- Test: widget test for the sheet and tile.

- [ ] **Step 1: Write widget test**

Asserts: tapping the tile opens the sheet; applying a filter and tapping "Roll" shows a result card with the item title; "Re-roll" picks again.

- [ ] **Step 2: Run — expect fail.**

- [ ] **Step 3: Implement**

`RandomPickTile` — a `GestureDetector` wrapping a glass container with the title "Pick something for me"; on tap shows `showModalBottomSheet` with `RandomPickSheet`.

`RandomPickSheet` — `ConsumerStatefulWidget` with form controls for shelf/media type/genre/runtime/pages/unrated-only. A primary "Roll" button calls `randomPickProvider.notifier.roll()`. Result area shows item card with a "Re-roll" and "Open" button. "Open" routes to `/collection/item/:id`.

Add the tile to the dashboard grid.

- [ ] **Step 4: Run — expect pass.**

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/screens/dashboard/ \
        test/widget/presentation/screens/dashboard/
git commit -m "feat(dashboard): random pick tile and filter sheet"
```

### Task 4.5: Section checkpoint

- [ ] `flutter test` → green.
- [ ] `flutter analyze` → clean.

---

## Milestone verification

- [ ] Full suite: `flutter test` → all tests pass (existing + ~15–20 new).
- [ ] `flutter analyze` → no new warnings.
- [ ] Manual smoke test (desktop):
  1. Launch app; add two items with the same barcode — second save surfaces duplicate dialog; override works.
  2. Convert one item to a wishlist item via a new scan → wishlist screen shows it; "Mark owned" flips it back.
  3. Edit condition/price/retailer/acquired on an owned item; reload; insights shows collection value sum.
  4. From dashboard, open "Pick something for me"; apply a filter; verify result is within filter; re-roll.
- [ ] `git log --oneline` shows one commit per task (≈30 commits for the milestone).
- [ ] Close issues #32, #33, #34, #35 referencing the final merge commit.

## Out of scope (explicit)

- Shelf filter in random picker (depends on shelf-join query not yet exposed). Tracked as a follow-up note on #33.
- Backfill of acquiredAt beyond `date_added` copy.
- Value tracking beyond summed `pricePaid` (no estimated-market-value API).
- Sync schema updates to PostgreSQL server-side — application side is updated; the DBA-side migration is the user's call out of scope for this plan.
