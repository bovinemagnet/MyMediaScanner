# MyMediaScanner Implementation Design

**Date:** 2026-03-15
**Status:** Approved
**Target Platforms:** Android (P0) + macOS (P1), structured for both, tested on macOS locally

---

## 1. Implementation Strategy

**Approach: Vertical Slices with Platform Parity**

Build one feature at a time as a complete vertical slice (domain → data → UI), including both Android and macOS paths in each slice. Five slices in order:

1. Scaffold + Core Infrastructure
2. Scan + Metadata Lookup
3. Collection CRUD
4. Tags & Shelves
5. Settings + Sync

This gives a runnable app after slice 2, ensures both platforms stay in lockstep, and each slice is independently testable.

**Android SDK not available locally** — all code structured for both platforms but only testable on macOS during development. Android builds require a separate machine or CI.

---

## 2. Project Scaffold & Dependencies

- Flutter 3.41.4 / Dart 3.11.1
- `flutter create` targeting Android + macOS
- Strict analysis options with `flutter_lints`

### Key Dependencies

| Package | Version | Purpose |
|---|---|---|
| flutter_riverpod | ^2.x | State management |
| riverpod_annotation | ^2.x | Provider codegen |
| go_router | ^14.x | Declarative routing |
| drift | ^2.x | Local SQLite ORM |
| sqlite3_flutter_libs | ^0.5.x | SQLite for mobile |
| postgres | ^3.x | Remote sync |
| dio | ^5.x | HTTP client |
| retrofit | ^4.x | Type-safe API clients |
| mobile_scanner | ^6.x | Camera scanning (Android/iOS) |
| flutter_secure_storage | ^9.x | Credentials storage |
| cached_network_image | ^3.x | Cover art caching |
| freezed_annotation | ^2.x | Immutable entities |
| json_annotation | ^4.x | JSON serialisation |
| uuid | ^4.x | UUID v7 generation |
| intl | ^0.19.x | Formatting |

### Dev Dependencies

| Package | Purpose |
|---|---|
| build_runner | Code generation |
| drift_dev | Drift codegen |
| riverpod_generator | Provider codegen |
| freezed | Entity codegen |
| json_serializable | JSON codegen |
| retrofit_generator | API client codegen |
| mocktail | Test mocking |

---

## 3. Core Infrastructure

### Theme
- Material 3 with `useMaterial3: true`
- Seed colour-based `ColorScheme`, light and dark variants
- `app_colors.dart` for design tokens, `app_theme.dart` builds `ThemeData`

### Navigation (GoRouter)
All routes registered upfront:

| Route | Screen |
|---|---|
| `/` | CollectionScreen |
| `/scan` | ScannerScreen (platform-adaptive) |
| `/scan/confirm` | MetadataConfirmScreen |
| `/item/:id` | ItemDetailScreen |
| `/item/:id/edit` | EditMetadataScreen |
| `/shelves` | ShelvesScreen |
| `/shelves/:id` | ShelfDetailScreen |
| `/settings` | SettingsScreen |
| `/settings/postgres` | PostgresConfigForm |

Routes without implemented screens show a placeholder widget until their slice is built.

### Platform Utils
`PlatformCapability` class exposing:
- `canUseCamera` → true on Android/iOS
- `isDesktop` → true on macOS/Windows/Linux
- `usesKeyboardScanner` → true on desktop

Uses `defaultTargetPlatform` from Flutter foundation — never imports `dart:io` directly.

### AppScaffold (Adaptive)
- `< 600px` or mobile platform: bottom navigation bar + FAB
- `600–1200px`: two-column grid, nav rail or bottom nav
- `> 1200px` or desktop platform: navigation rail + content pane

Destinations: Collection, Scan, Shelves, Settings.

### Shared Widgets
`EmptyState`, `ErrorState`, `LoadingIndicator` — simple, reusable across all screens.

### Error Handling
Sealed `AppException` hierarchy: `NetworkException`, `DatabaseException`, `ApiException`, `SyncException`. Providers catch these into Riverpod `AsyncError`. No `Either`/`dartz` — idiomatic `AsyncValue` throughout.

---

## 4. Database Layer (Drift)

### Schema
7 tables exactly as specified in the Architecture doc:
- `media_items`, `tags`, `media_item_tags`, `shelves`, `shelf_items`, `barcode_cache`, `sync_log`

### Implementation Decisions
- **UUIDs:** `TextColumn`, generated client-side via `uuid` package's `Uuid().v7()` (time-ordered)
- **JSON columns** (`genres`, `extra_metadata`, `source_apis`): stored as `TEXT`, serialised/deserialised in DAOs
- **Timestamps:** `IntColumn` with Unix milliseconds
- **Soft deletes:** All queries filter `deleted = 0` by default. `includeDeleted` parameter for sync methods.
- **Migration:** Version 1 in `onCreate`. Future migrations via `onUpgrade`.
- **Singleton:** Provided via `@riverpod` `databaseProvider`, initialised in `main.dart`.

### DAOs
One per logical group: `MediaItemsDao`, `TagsDao`, `ShelvesDao`, `BarcodeCacheDao`, `SyncLogDao`. Each exposes `Stream`-based watch methods for reactive UI and `Future`-based methods for writes.

---

## 5. Domain Layer

### Entities (all `@freezed`)
- `MediaItem` — typed `MediaType` enum, `List<String>` for genres/source APIs
- `MediaType` enum — `film`, `tv`, `music`, `book`, `game`, `unknown`
- `MetadataResult` — partial (nullable fields), includes `sourceApis` list
- `Tag` — id, name, colour
- `Shelf` — id, name, description, sortOrder

### Repository Interfaces (prefixed `I`)
- `IMediaItemRepository` — CRUD + watch stream + search + filter/sort
- `IMetadataRepository` — `lookupBarcode(barcode, typeHint?)`
- `ITagRepository` — CRUD + assign/remove from items
- `IShelfRepository` — CRUD + manage ordered items
- `ISyncRepository` — push/pull sync, connection test, status stream

### Use Cases
- `ScanBarcodeUseCase` — detect type → tiered lookup → return result
- `SaveMediaItemUseCase` — validate, generate UUID v7, set timestamps, persist, log to sync
- `DeleteMediaItemUseCase` — soft delete, update `updated_at`
- `GetCollectionUseCase` / `SearchCollectionUseCase` — filter/sort delegation
- `UpdateRatingUseCase`, `ManageTagsUseCase`, `ManageShelvesUseCase`
- `SyncCollectionUseCase` — full push/pull cycle

---

## 6. API Clients & Metadata Lookup

### Dio Setup
One base factory with common config (timeouts, logging in debug). Each API gets its own `Dio` instance with service-specific base URL and auth interceptor.

### Retrofit Clients
- `TmdbApi` — search by barcode/title, movie/TV details. API key via interceptor.
- `DiscogsApi` — search releases by barcode. User-agent required. API key via interceptor.
- `GoogleBooksApi` — search by ISBN. No key needed.
- `OpenLibraryApi` — book fallback. **Hand-written Dio client** (simpler API, avoids extra codegen).
- `UpcitemdbApi` — general UPC fallback. API key via interceptor.

### DTOs & Mappers
Each API has `@JsonSerializable` DTOs in `models/` subfolder. Stateless mapper functions in `data/mappers/` convert each DTO → `MetadataResult`.

### MetadataRepositoryImpl (Tiered Lookup)
1. Check `BarcodeCacheDao` — return if < 7 days old
2. Detect barcode type (ISBN: starts with 978/979; otherwise EAN/UPC)
3. Route by type + hint:
   - ISBN → GoogleBooks → OpenLibrary fallback
   - EAN/UPC + film/tv → TMDB
   - EAN/UPC + music → Discogs
   - EAN/UPC + unknown → UPCitemdb → reclassify → specialist
4. Cache raw response in `barcode_cache`
5. Map to `MetadataResult` and return
6. If all tiers fail → minimal result with barcode only (user can save barcode-only record)

---

## 7. Presentation Layer

### Providers (all `@riverpod` codegen)
- `databaseProvider` — singleton, `keepAlive: true`
- Repository providers binding interfaces to implementations
- `settingsProvider` — secure storage for Postgres config + API keys
- `collectionProvider` — `AsyncNotifier` watching DAO stream, holds filter/sort state
- `scannerProvider` — `AsyncNotifier` state machine: idle → scanning → lookingUp → found/notFound/error
- `metadataLookupProvider` — family provider keyed by barcode
- `syncProvider` — sync status stream

### Screens
- **CollectionScreen** — search bar, filter chips, sort selector, grid/list toggle, `MediaItemCard`
- **ScannerScreen** — platform-adaptive (camera on Android, `TextField` + Enter on macOS)
- **MetadataConfirmScreen** — editable form, confirm to save, "barcode only" fallback
- **ItemDetailScreen** — hero cover art, metadata, star rating, tag chips, review
- **ShelvesScreen** / **ShelfDetailScreen** — shelf list, ordered items
- **SettingsScreen** — Postgres config, API keys, sync status, theme toggle

---

## 8. Testing Strategy

### Unit Tests
- All use cases with mock repositories (`mocktail`)
- Barcode type detection with known patterns
- Each mapper with real sample JSON fixtures
- DAO tests with in-memory Drift database (no mocking)

### Widget Tests
- CollectionScreen, ItemDetailScreen, MetadataConfirmScreen
- `ProviderScope` overrides with mock repositories

### Integration Tests
- Scan → lookup → confirm → save flow (mock API responses)
- Collection CRUD cycle: add, view, edit, soft-delete

### TDD Approach
Tests written alongside implementation for this greenfield project. Domain/use case tests come before moving to the next slice.

### Not Tested in v1
Platform-specific camera scanning (requires device), actual PostgreSQL sync (requires running Postgres).

---

## 9. Build Order

### Slice 1 — Scaffold + Core Infrastructure
- `flutter create`, pubspec, analysis options
- Full directory structure
- Core: constants, errors, extensions, platform utils, barcode utils
- Theme, AppScaffold, shared widgets
- GoRouter with all routes (placeholders)
- Drift database: all 7 tables, DAOs
- Domain entities (Freezed), repository interfaces
- Riverpod providers (database, repositories)

### Slice 2 — Scan + Metadata Lookup
- API clients (TMDB, Discogs, Google Books, Open Library, UPCitemdb)
- DTOs, mappers, MetadataRepositoryImpl
- ScanBarcodeUseCase, SaveMediaItemUseCase
- Scanner providers
- ScannerScreen (camera + keyboard-wedge)
- MetadataConfirmScreen
- Barcode cache integration

### Slice 3 — Collection CRUD
- GetCollectionUseCase, SearchCollectionUseCase, DeleteMediaItemUseCase, UpdateRatingUseCase
- CollectionScreen with search, filter, sort
- ItemDetailScreen with cover art, metadata, ratings, review
- Edit metadata flow

### Slice 4 — Tags & Shelves
- ManageTagsUseCase, ManageShelvesUseCase
- Tag CRUD, assignment, filtering
- Shelf CRUD, ordered items, detail screen

### Slice 5 — Settings + Sync
- SettingsScreen (Postgres config, API keys, theme)
- Secure storage integration
- PostgresSyncClient, SyncStrategy, SyncRepositoryImpl
- SyncCollectionUseCase
- Sync status UI, manual + auto-sync
