# MyMediaScanner Implementation Design

**Date:** 2026-03-15
**Status:** Draft
**Target Platforms (this pass):** Android (P0) + macOS (P1), structured for both, tested on macOS locally

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

### Platform Scope

The PRD specifies all five platforms (Android P0, iOS P0, macOS P1, Windows P1, Linux P1). This implementation pass focuses on **Android + macOS** as representative mobile + desktop targets. iOS, Windows, and Linux are deferred to a follow-up pass — the architecture supports all five platforms, so adding them later requires only platform-specific build configuration, not code changes. iOS is deferred solely because Android SDK setup is the immediate mobile target; the Flutter codebase is shared.

### Deferred PRD Requirements

The following requirements are acknowledged but explicitly deferred beyond this implementation pass:

| Requirement | Priority | Reason |
|---|---|---|
| META-08 (re-fetch metadata) | P2 | Low priority, straightforward to add later |
| COLL-11 (statistics dashboard) | P2 | Low priority |
| COLL-12 (export CSV/JSON) | P2 | Low priority |

All P0 and P1 requirements are addressed in the slices below.

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
| mobile_scanner | ^5.x | Camera scanning (Android/iOS only) |
| flutter_secure_storage | ^9.x | Credentials storage |
| cached_network_image | ^3.x | Cover art caching |
| freezed_annotation | ^2.x | Immutable entities |
| json_annotation | ^4.x | JSON serialisation |
| uuid | ^4.x | UUID v7 generation |
| intl | ^0.19.x | Formatting |

### Dev Dependencies

| Package | Version | Purpose |
|---|---|---|
| build_runner | ^2.x | Code generation |
| drift_dev | ^2.x | Drift codegen |
| riverpod_generator | ^2.x | Provider codegen |
| freezed | ^2.x | Entity codegen |
| json_serializable | ^6.x | JSON codegen |
| retrofit_generator | ^8.x | API client codegen |
| mocktail | ^1.x | Test mocking |

**Note:** Dependency versions match the Architecture doc (Section 9). Exact minor versions will be resolved at `flutter pub get` time against Dart 3.11 compatibility.

---

## 3. Core Infrastructure

### Theme
- Material 3 with `useMaterial3: true`
- Seed colour-based `ColorScheme`, light and dark variants
- `app_colors.dart` for design tokens, `app_theme.dart` builds `ThemeData`
- Theme mode (system/light/dark) controlled via settings (SET-07)

### Navigation (GoRouter)
All routes registered upfront:

| Route | Screen |
|---|---|
| `/` | CollectionScreen |
| `/scan` | ScannerScreen (platform-adaptive) |
| `/scan/confirm` | MetadataConfirmScreen |
| `/item/:id` | ItemDetailScreen |
| `/item/:id/edit` | EditMetadataScreen (reuses `EditableMetadataForm` from confirm screen with pre-populated data) |
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
- **`AppException`** — sealed exception hierarchy: `NetworkException`, `DatabaseException`, `ApiException`, `SyncException`. Used in data layer.
- **`Failure`** — sealed class in `core/errors/failure.dart` representing domain-layer failures. Use cases return results; providers catch `AppException`s and surface them as Riverpod `AsyncError` with `Failure` payloads.
- No `Either`/`dartz` — idiomatic `AsyncValue` throughout.

### Accessibility & Localisation
- All interactive elements have semantic labels for screen readers (WCAG AA minimum)
- All user-facing strings extracted to a central location, ready for i18n (English only in v1)
- No telemetry or analytics (privacy requirement)

---

## 4. Database Layer (Drift)

### Schema
7 tables exactly as specified in the Architecture doc:
- `media_items`, `tags`, `media_item_tags`, `shelves`, `shelf_items`, `barcode_cache`, `sync_log`

### Implementation Decisions
- **UUIDs:** `TextColumn`, generated client-side via `uuid` package's `Uuid().v7()` (time-ordered for better indexing and sync ordering)
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

### Type-Specific Metadata Structure

The `extra_metadata` JSON blob in `MediaItem` follows a defined structure per `MediaType`:

- **Film/TV:** `{"director": "...", "cast": ["..."], "runtime_minutes": 120, "content_rating": "PG-13", "tmdb_id": 12345}`
- **Music:** `{"artists": ["..."], "track_listing": [{"number": 1, "title": "..."}], "label": "...", "catalogue_number": "...", "discogs_release_id": 67890}`
- **Books:** `{"authors": ["..."], "isbn10": "...", "isbn13": "...", "page_count": 300, "google_books_id": "..."}`
- **Game:** `{"platform": "...", "developer": "..."}` (minimal in v1)

These are serialised/deserialised in the mapper layer. The UI renders type-specific sections on `ItemDetailScreen` based on `mediaType`.

### Repository Interfaces (prefixed `I`)
- `IMediaItemRepository` — CRUD + watch stream + search + filter/sort + check barcode exists (for duplicate detection)
- `IMetadataRepository` — `lookupBarcode(barcode, typeHint?)`
- `ITagRepository` — CRUD + assign/remove from items
- `IShelfRepository` — CRUD + manage ordered items
- `ISyncRepository` — push/pull sync, connection test, status stream, full reset

### Use Cases
- `ScanBarcodeUseCase` — detect type → check for duplicate barcode (SCAN-06) → tiered lookup → return result
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
- `OpenLibraryApi` — book fallback. **Hand-written Dio client** (simpler API, avoids extra codegen). Has its own mapper: `open_library_mapper.dart`.
- `UpcitemdbApi` — general UPC fallback. API key via interceptor.

### DTOs & Mappers
Each API has `@JsonSerializable` DTOs in `models/` subfolder. Stateless mapper functions in `data/mappers/` convert each DTO → `MetadataResult`. Five mappers total:
- `tmdb_mapper.dart`
- `discogs_mapper.dart`
- `google_books_mapper.dart`
- `open_library_mapper.dart`
- `upc_mapper.dart`

### Metadata Lookup Order

**Design decision:** The Architecture doc specifies specialist API first with UPCitemdb as fallback. The PRD (META-02) wording suggests "UPCitemdb → specialist", but the Architecture doc's ordering is more logical and efficient (specialist APIs have richer data). **We follow the Architecture doc ordering: specialist first, UPCitemdb fallback.**

### MetadataRepositoryImpl (Tiered Lookup)
1. Check `BarcodeCacheDao` — return if < 7 days old
2. Detect barcode type (ISBN: starts with 978/979; otherwise EAN/UPC)
3. Route by type + hint:
   - ISBN → GoogleBooks → OpenLibrary fallback
   - EAN/UPC + film/tv → TMDB
   - EAN/UPC + music → Discogs
   - EAN/UPC + unknown → UPCitemdb → reclassify → specialist
4. If specialist API returns no result → UPCitemdb fallback
5. Cache raw response in `barcode_cache`
6. Map to `MetadataResult` and return
7. If all tiers fail → minimal result with barcode only (user can save barcode-only record per META-07)

---

## 7. Presentation Layer

### Providers (all `@riverpod` codegen)
- `databaseProvider` — singleton, `keepAlive: true`
- Repository providers binding interfaces to implementations
- `settingsProvider` — secure storage for Postgres config + API keys + preferences (default media type hint SET-03, auto-sync toggle SET-05, haptic/sound toggle SET-06, theme mode SET-07)
- `collectionProvider` — `AsyncNotifier` watching DAO stream, holds filter/sort state
- `scannerProvider` — `AsyncNotifier` state machine: idle → scanning → lookingUp → found/notFound/duplicate/error
- `metadataLookupProvider` — family provider keyed by barcode
- `syncProvider` — sync status stream, pending count, last synced time

### Screens

- **CollectionScreen** — search bar, filter chips (type, genre, tag, year), sort selector (title, date added, year, rating), grid/list toggle, `MediaItemCard` with cover art, title, type badge, rating.
- **ScannerScreen** — platform-adaptive:
  - Android/iOS: `MobileScanner` camera viewfinder with `ScanOverlay` widget (crosshair/frame overlay) and scan confirmation animation (SCAN-02). Audible + haptic feedback on detection (SCAN-05), controlled by SET-06 toggle.
  - macOS/desktop: `DesktopScanScreen` with focused `TextField` for USB scanner keyboard-wedge input or manual entry (SCAN-03, SCAN-04). Enter key triggers lookup.
  - **Duplicate detection** (SCAN-06): after barcode captured, check `IMediaItemRepository.barcodeExists()`. If duplicate, show warning dialog with options: view existing item, scan again, or proceed anyway.
  - **Batch scan mode** (SCAN-07): toggle in scanner UI. When enabled, after saving a confirmed item, returns to scan view with `BatchScanCounter` widget showing count instead of navigating back to collection.
- **MetadataConfirmScreen** — displays `MetadataResult` fields in `EditableMetadataForm`. User reviews, edits, then confirms. "Save as barcode only" option if lookup failed. Media type hint selector for ambiguous results.
- **ItemDetailScreen** — hero cover art (`CoverArtHero`), type-specific metadata sections (`MetadataSection`), star rating widget (`StarRatingWidget`), tag chips (`TagChips`), review/notes area. Edit and delete actions.
- **EditMetadataScreen** (`/item/:id/edit`) — reuses `EditableMetadataForm` from MetadataConfirmScreen, pre-populated with existing item data.
- **ShelvesScreen** / **ShelfDetailScreen** — shelf list, ordered items, drag-to-reorder.
- **SettingsScreen** — subsections:
  - Postgres connection config (host, port, db, user, password) with **test connection button** showing clear success/error feedback (SET-01, SET-02)
  - API key management for TMDB, Discogs, UPCitemdb (SET-04)
  - Default media type hint for scanner (SET-03)
  - Auto-sync on launch toggle (SET-05)
  - Haptic/sound feedback toggle (SET-06)
  - Theme selector: system/light/dark (SET-07)
  - Sync status tile: last synced time, pending changes count (SYNC-04)
  - Full re-sync / reset local database option (SYNC-09)

---

## 8. Sync & Security

### PostgreSQL Sync
- Direct connection via `postgres` Dart package
- **TLS required by default** — app rejects non-TLS connections unless user explicitly opts out in settings (Architecture doc Section 8)
- Last-write-wins per-field conflict resolution based on `updated_at` timestamps
- Sync flow as specified in Architecture doc Section 3.3
- `ISyncRepository` exposes: `pushChanges()`, `pullChanges()`, `testConnection()`, `resetLocalDatabase()`, `watchSyncStatus()`

### Security
- Postgres credentials and API keys stored in `flutter_secure_storage` (platform keychain/keystore)
- No credentials in code or environment files
- No telemetry or analytics

---

## 9. Testing Strategy

### Unit Tests
- All use cases with mock repositories (`mocktail`)
- Barcode type detection with known EAN/ISBN/UPC patterns
- Each mapper (all five) with real sample JSON fixtures
- DAO tests with in-memory Drift database (no mocking)
- Duplicate barcode detection logic

### Widget Tests
- CollectionScreen, ItemDetailScreen, MetadataConfirmScreen, SettingsScreen
- `ProviderScope` overrides with mock repositories
- Test duplicate barcode warning dialog
- Test connection button feedback

### Integration Tests
- Scan → lookup → confirm → save flow (mock API responses)
- Collection CRUD cycle: add, view, edit, soft-delete
- Batch scan flow

### TDD Approach
Tests written alongside implementation for this greenfield project. Domain/use case tests come before moving to the next slice.

### Not Tested in v1
Platform-specific camera scanning (requires device), actual PostgreSQL sync (requires running Postgres).

---

## 10. Build Order

### Slice 1 — Scaffold + Core Infrastructure
- `flutter create`, pubspec, analysis options
- Full directory structure
- Core: constants, errors (AppException + Failure), extensions, platform utils, barcode utils
- Theme (light/dark/system), AppScaffold (adaptive nav), shared widgets
- GoRouter with all routes (placeholders)
- Drift database: all 7 tables, DAOs
- Domain entities (Freezed), repository interfaces
- Riverpod providers (database, repositories)

### Slice 2 — Scan + Metadata Lookup
- API clients (TMDB, Discogs, Google Books, Open Library, UPCitemdb)
- DTOs, all five mappers, MetadataRepositoryImpl with tiered lookup
- ScanBarcodeUseCase (with duplicate check), SaveMediaItemUseCase
- Scanner providers (state machine including duplicate state)
- ScannerScreen: camera with ScanOverlay + haptic/sound on Android, keyboard-wedge on macOS
- MetadataConfirmScreen with EditableMetadataForm
- Duplicate barcode warning (SCAN-06)
- Batch scan mode with BatchScanCounter (SCAN-07)
- Barcode cache integration

### Slice 3 — Collection CRUD
- GetCollectionUseCase, SearchCollectionUseCase, DeleteMediaItemUseCase, UpdateRatingUseCase
- CollectionScreen with search, filter, sort
- ItemDetailScreen with CoverArtHero, type-specific MetadataSection, StarRatingWidget, review
- EditMetadataScreen (reusing EditableMetadataForm)

### Slice 4 — Tags & Shelves
- ManageTagsUseCase, ManageShelvesUseCase
- Tag CRUD, assignment to items, TagChips widget, filter by tag
- Shelf CRUD, ordered items, detail screen

### Slice 5 — Settings + Sync
- SettingsScreen: Postgres config with test connection button (SET-01, SET-02), API keys (SET-04), default media type hint (SET-03), auto-sync toggle (SET-05), haptic/sound toggle (SET-06), theme selector (SET-07)
- Secure storage integration
- PostgresSyncClient with TLS requirement, SyncStrategy, SyncRepositoryImpl
- SyncCollectionUseCase
- Sync status tile (SYNC-04), manual + auto-sync
- Full re-sync / reset local database (SYNC-09)
