# Architecture: MyMediaScanner

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** 2026-03-15  

---

## 1. Technology Stack

| Layer | Technology | Rationale |
|---|---|---|
| UI Framework | Flutter (Dart) | Single codebase for Android, iOS, macOS, Windows, Linux |
| State Management | Riverpod | Compile-safe, testable, aligns with existing RepFoundry patterns |
| Local Database | Drift (SQLite) | Type-safe Dart ORM, familiar API, works on all Flutter platforms |
| Remote Database | PostgreSQL (self-hosted) | User-controlled, full relational capability, reliable sync target |
| Networking | Dio + Retrofit | Type-safe HTTP clients with interceptor support for auth + caching |
| Barcode Scanning | mobile_scanner (ML Kit) | Camera-based scanning on Android and iOS |
| Secure Storage | flutter_secure_storage | Platform keychain/keystore for Postgres credentials and API keys |
| Navigation | GoRouter | Declarative routing, deep-link support, consistent across platforms |
| Image Caching | cached_network_image | Efficient cover art loading and offline caching |
| Code Generation | build_runner, Drift codegen, Riverpod generator, Freezed | Reduces boilerplate, enforces type safety |

---

## 2. Repository Directory Layout

```
mymediascanner/
│
├── docs/                               # Project documentation (you are here)
│   ├── PRD.md
│   └── ARCHITECTURE.md
│
├── lib/
│   ├── main.dart                       # Entry point; initialises Drift, Riverpod, GoRouter
│   │
│   ├── app/
│   │   ├── app.dart                    # Root MaterialApp.router widget
│   │   ├── router.dart                 # GoRouter route definitions
│   │   └── theme/
│   │       ├── app_theme.dart          # Light / dark ThemeData
│   │       └── app_colors.dart         # Design tokens
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart      # Base URLs, endpoint paths
│   │   │   └── app_constants.dart      # App-wide magic values
│   │   ├── errors/
│   │   │   ├── app_exception.dart      # Sealed exception hierarchy
│   │   │   └── failure.dart            # Domain-layer failure types
│   │   ├── extensions/
│   │   │   ├── string_extensions.dart
│   │   │   └── datetime_extensions.dart
│   │   └── utils/
│   │       ├── barcode_utils.dart      # Barcode type detection (EAN vs ISBN etc.)
│   │       └── platform_utils.dart     # Desktop vs mobile capability flags
│   │
│   ├── data/
│   │   │
│   │   ├── local/                      # Drift SQLite layer
│   │   │   ├── database/
│   │   │   │   ├── app_database.dart   # @DriftDatabase root; registers all tables and DAOs
│   │   │   │   ├── app_database.g.dart # Generated (do not edit)
│   │   │   │   └── tables/
│   │   │   │       ├── media_items_table.dart
│   │   │   │       ├── tags_table.dart
│   │   │   │       ├── media_item_tags_table.dart   # join table
│   │   │   │       ├── shelves_table.dart
│   │   │   │       ├── shelf_items_table.dart       # join table
│   │   │   │       ├── barcode_cache_table.dart     # raw API responses keyed by barcode
│   │   │   │       └── sync_log_table.dart          # pending changes awaiting sync
│   │   │   └── dao/
│   │   │       ├── media_items_dao.dart
│   │   │       ├── tags_dao.dart
│   │   │       ├── shelves_dao.dart
│   │   │       ├── barcode_cache_dao.dart
│   │   │       └── sync_log_dao.dart
│   │   │
│   │   ├── remote/
│   │   │   │
│   │   │   ├── api/                    # External metadata API clients
│   │   │   │   ├── tmdb/
│   │   │   │   │   ├── tmdb_api.dart           # Retrofit interface
│   │   │   │   │   ├── tmdb_api.g.dart         # Generated
│   │   │   │   │   └── models/
│   │   │   │   │       ├── tmdb_movie_dto.dart
│   │   │   │   │       └── tmdb_tv_dto.dart
│   │   │   │   ├── discogs/
│   │   │   │   │   ├── discogs_api.dart
│   │   │   │   │   ├── discogs_api.g.dart
│   │   │   │   │   └── models/
│   │   │   │   │       └── discogs_release_dto.dart
│   │   │   │   ├── google_books/
│   │   │   │   │   ├── google_books_api.dart
│   │   │   │   │   ├── google_books_api.g.dart
│   │   │   │   │   └── models/
│   │   │   │   │       └── google_books_volume_dto.dart
│   │   │   │   ├── open_library/
│   │   │   │   │   ├── open_library_api.dart
│   │   │   │   │   └── models/
│   │   │   │   │       └── open_library_work_dto.dart
│   │   │   │   └── upc/
│   │   │   │       ├── upcitemdb_api.dart      # General UPC fallback
│   │   │   │       ├── upcitemdb_api.g.dart
│   │   │   │       └── models/
│   │   │   │           └── upc_item_dto.dart
│   │   │   │
│   │   │   └── sync/                   # PostgreSQL sync layer
│   │   │       ├── postgres_sync_client.dart   # Direct postgres connection (postgres package)
│   │   │       ├── sync_strategy.dart          # Last-write-wins conflict resolution
│   │   │       └── sync_models/
│   │   │           └── sync_record.dart        # Serialisable representation of a change
│   │   │
│   │   ├── mappers/                    # DTO → Domain entity converters
│   │   │   ├── tmdb_mapper.dart
│   │   │   ├── discogs_mapper.dart
│   │   │   ├── google_books_mapper.dart
│   │   │   └── upc_mapper.dart
│   │   │
│   │   └── repositories/              # Concrete implementations of domain interfaces
│   │       ├── media_item_repository_impl.dart
│   │       ├── metadata_repository_impl.dart   # Orchestrates tiered API lookup
│   │       ├── tag_repository_impl.dart
│   │       ├── shelf_repository_impl.dart
│   │       └── sync_repository_impl.dart
│   │
│   ├── domain/
│   │   ├── entities/                  # Pure Dart; no Flutter / no Drift dependencies
│   │   │   ├── media_item.dart        # @freezed
│   │   │   ├── media_type.dart        # enum: film, tv, music, book, game, unknown
│   │   │   ├── metadata_result.dart   # @freezed; result of a lookup (may be partial)
│   │   │   ├── tag.dart
│   │   │   └── shelf.dart
│   │   ├── repositories/             # Abstract interfaces
│   │   │   ├── i_media_item_repository.dart
│   │   │   ├── i_metadata_repository.dart
│   │   │   ├── i_tag_repository.dart
│   │   │   ├── i_shelf_repository.dart
│   │   │   └── i_sync_repository.dart
│   │   └── usecases/
│   │       ├── scan_barcode_usecase.dart       # Detect type → tiered lookup → return result
│   │       ├── save_media_item_usecase.dart
│   │       ├── delete_media_item_usecase.dart
│   │       ├── get_collection_usecase.dart
│   │       ├── search_collection_usecase.dart
│   │       ├── update_rating_usecase.dart
│   │       ├── manage_tags_usecase.dart
│   │       ├── manage_shelves_usecase.dart
│   │       └── sync_collection_usecase.dart
│   │
│   └── presentation/
│       │
│       ├── providers/                 # Riverpod providers
│       │   ├── database_provider.dart         # AppDatabase singleton
│       │   ├── repository_providers.dart      # Binds interfaces to impls
│       │   ├── settings_provider.dart         # Postgres config, API keys, prefs
│       │   ├── collection_provider.dart       # Filtered/sorted collection stream
│       │   ├── scanner_provider.dart          # Scan state machine
│       │   ├── metadata_provider.dart         # Lookup result + loading state
│       │   └── sync_provider.dart             # Sync status stream
│       │
│       ├── screens/
│       │   ├── collection/
│       │   │   ├── collection_screen.dart
│       │   │   ├── collection_screen_controller.dart
│       │   │   └── widgets/
│       │   │       ├── media_item_card.dart
│       │   │       ├── filter_bar.dart
│       │   │       └── sort_selector.dart
│       │   ├── scanner/
│       │   │   ├── scanner_screen.dart        # Mobile camera view
│       │   │   ├── desktop_scan_screen.dart   # Desktop keyboard-wedge input
│       │   │   ├── scanner_controller.dart
│       │   │   └── widgets/
│       │   │       ├── scan_overlay.dart
│       │   │       └── batch_scan_counter.dart
│       │   ├── metadata_confirm/
│       │   │   ├── metadata_confirm_screen.dart   # Review/edit before save
│       │   │   └── widgets/
│       │   │       └── editable_metadata_form.dart
│       │   ├── item_detail/
│       │   │   ├── item_detail_screen.dart
│       │   │   ├── item_detail_controller.dart
│       │   │   └── widgets/
│       │   │       ├── cover_art_hero.dart
│       │   │       ├── star_rating_widget.dart
│       │   │       ├── tag_chips.dart
│       │   │       └── metadata_section.dart
│       │   ├── shelves/
│       │   │   ├── shelves_screen.dart
│       │   │   └── shelf_detail_screen.dart
│       │   └── settings/
│       │       ├── settings_screen.dart
│       │       ├── settings_controller.dart
│       │       └── widgets/
│       │           ├── postgres_config_form.dart
│       │           ├── api_key_form.dart
│       │           └── sync_status_tile.dart
│       │
│       └── widgets/                   # Shared widgets used across multiple screens
│           ├── app_scaffold.dart       # Adaptive scaffold (nav rail on desktop, bottom nav on mobile)
│           ├── empty_state.dart
│           ├── error_state.dart
│           └── loading_indicator.dart
│
├── test/
│   ├── unit/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── widget/
│   └── integration/
│
├── android/
├── ios/
├── macos/
├── windows/
├── linux/
│
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── CLAUDE.md                          # Instructions for Claude Code sessions
└── .gitignore
```

---

## 3. Data Architecture

### 3.1 Local Schema (Drift / SQLite)

```
media_items
───────────────────────────────────────────────────────
  id                UUID PK
  barcode           TEXT NOT NULL
  barcode_type      TEXT NOT NULL           -- EAN13, UPC_A, ISBN13, etc.
  media_type        TEXT NOT NULL           -- film | tv | music | book | game | unknown
  title             TEXT NOT NULL
  subtitle          TEXT
  description       TEXT
  cover_url         TEXT
  year              INTEGER
  publisher         TEXT                   -- studio / label / publisher
  format            TEXT                   -- Blu-ray | CD | Hardcover | etc.
  genres            TEXT                   -- JSON array of strings
  extra_metadata    TEXT                   -- JSON blob for type-specific fields
  source_apis       TEXT                   -- JSON array: which APIs contributed
  user_rating       REAL                   -- 1.0–5.0
  user_review       TEXT
  date_added        INTEGER NOT NULL        -- Unix ms
  date_scanned      INTEGER NOT NULL        -- Unix ms
  updated_at        INTEGER NOT NULL        -- Unix ms; used for sync conflict resolution
  synced_at         INTEGER                 -- Unix ms; NULL = not yet synced
  deleted           INTEGER NOT NULL DEFAULT 0  -- soft delete

tags
───────────────────────────────────────────────────────
  id                UUID PK
  name              TEXT NOT NULL UNIQUE
  colour            TEXT                   -- hex string
  updated_at        INTEGER NOT NULL
  deleted           INTEGER NOT NULL DEFAULT 0

media_item_tags                            -- join table
───────────────────────────────────────────────────────
  media_item_id     UUID FK → media_items.id
  tag_id            UUID FK → tags.id
  PRIMARY KEY (media_item_id, tag_id)

shelves
───────────────────────────────────────────────────────
  id                UUID PK
  name              TEXT NOT NULL
  description       TEXT
  sort_order        INTEGER NOT NULL DEFAULT 0
  updated_at        INTEGER NOT NULL
  deleted           INTEGER NOT NULL DEFAULT 0

shelf_items                                -- join table (ordered)
───────────────────────────────────────────────────────
  shelf_id          UUID FK → shelves.id
  media_item_id     UUID FK → media_items.id
  position          INTEGER NOT NULL DEFAULT 0
  PRIMARY KEY (shelf_id, media_item_id)

barcode_cache                              -- raw API response cache
───────────────────────────────────────────────────────
  barcode           TEXT PK
  media_type_hint   TEXT
  response_json     TEXT NOT NULL           -- raw API response
  source_api        TEXT NOT NULL
  cached_at         INTEGER NOT NULL

sync_log                                   -- outbound change queue
───────────────────────────────────────────────────────
  id                UUID PK
  entity_type       TEXT NOT NULL           -- media_item | tag | shelf | shelf_item | etc.
  entity_id         UUID NOT NULL
  operation         TEXT NOT NULL           -- insert | update | delete
  payload_json      TEXT NOT NULL
  created_at        INTEGER NOT NULL
  attempted_at      INTEGER
  synced            INTEGER NOT NULL DEFAULT 0
```

### 3.2 PostgreSQL Schema (Sync Target)

The Postgres schema mirrors the SQLite schema exactly, with the following additions:

- `device_id TEXT NOT NULL` column on every table — identifies the originating device
- `created_at TIMESTAMPTZ` alongside `updated_at` for audit purposes
- `UNIQUE (barcode)` constraint on `media_items` relaxed to per-device uniqueness; deduplication handled in sync strategy
- Postgres-native `UUID` type instead of SQLite `TEXT` for primary keys

### 3.3 Sync Strategy

**Mechanism:** Direct PostgreSQL connection from the client using the `postgres` Dart package.

**Conflict resolution (v1): Last-Write-Wins per field**

Each record carries an `updated_at` Unix millisecond timestamp. During sync:

1. Client reads all local rows with `synced_at IS NULL` or `updated_at > synced_at`
2. For each changed row, client fetches the current Postgres version
3. Field-by-field comparison: if the local `updated_at` > remote `updated_at`, the local value wins
4. Result is upserted into Postgres; local `synced_at` is updated to current time
5. Client then pulls all Postgres rows updated after its last known `synced_at` for any device and merges into local SQLite

**Soft deletes:** Deleted items set `deleted = 1` and are included in sync. Postgres never hard-deletes in v1.

---

## 4. Metadata Lookup Architecture

The `MetadataRepositoryImpl` implements a tiered lookup strategy that is transparent to the domain layer:

```
ScanBarcodeUseCase
    │
    ▼
MetadataRepository.lookupBarcode(barcode, typeHint?)
    │
    ├─ 1. Check barcode_cache (SQLite) → return cached result if < 7 days old
    │
    ├─ 2. Detect barcode type (EAN-13, UPC-A, ISBN-10/13)
    │
    ├─ 3. Apply type-specific strategy:
    │       ISBN → Google Books → (fallback) Open Library
    │       EAN/UPC + typeHint=film/tv → TMDB search by barcode/title
    │       EAN/UPC + typeHint=music → Discogs release search
    │       EAN/UPC + typeHint=unknown → UPCitemdb → reclassify → specialist API
    │
    ├─ 4. If specialist API returns no result → UPCitemdb fallback
    │
    ├─ 5. Map DTO(s) → MetadataResult domain entity
    │
    ├─ 6. Store raw response in barcode_cache
    │
    └─ 7. Return MetadataResult to use case
```

Each API client is a separate class with its own Dio instance, interceptors, and error handling. API keys are read from `SecureStorageService` at client construction time via Riverpod provider.

---

## 5. State Management (Riverpod)

All providers are `@riverpod` annotated (code-generated). The key provider graph:

```
databaseProvider (AppDatabase)
    └─ mediaItemsDao, tagsDao, shelvesDDao, syncLogDao

settingsProvider (SecureStorage + SharedPreferences)
    └─ postgresConfigProvider
    └─ apiKeysProvider

repositoryProviders
    ├─ mediaItemRepositoryProvider  ← databaseProvider
    ├─ metadataRepositoryProvider   ← apiKeysProvider, databaseProvider (cache)
    ├─ tagRepositoryProvider        ← databaseProvider
    ├─ shelfRepositoryProvider      ← databaseProvider
    └─ syncRepositoryProvider       ← postgresConfigProvider, databaseProvider

Feature providers (watch DAOs / call repositories)
    ├─ collectionProvider           → Stream<List<MediaItem>> (filtered, sorted)
    ├─ scannerProvider              → AsyncNotifier (state machine)
    ├─ metadataLookupProvider       → FutureProvider per barcode
    └─ syncStatusProvider           → Stream<SyncStatus>
```

---

## 6. Navigation (GoRouter)

| Route | Screen | Notes |
|---|---|---|
| `/` | Collection screen | Default route |
| `/scan` | Scanner screen (platform-adaptive) | |
| `/scan/confirm` | Metadata confirm screen | Receives `MetadataResult` as extra |
| `/item/:id` | Item detail screen | |
| `/item/:id/edit` | Edit metadata screen | |
| `/shelves` | Shelves list | |
| `/shelves/:id` | Shelf detail | |
| `/settings` | Settings screen | |
| `/settings/postgres` | Postgres config form | |

---

## 7. Platform-Adaptive UI

Flutter's `adaptive_scaffold` pattern is used via `AppScaffold`:

| Platform | Navigation Pattern | Scan Entry |
|---|---|---|
| Android / iOS | Bottom navigation bar + FAB (scan) | Full-screen camera overlay |
| macOS / Windows / Linux | Navigation rail (left sidebar) + toolbar button | Focused text field + Enter key |

Breakpoints mirror Material 3 compact / medium / expanded:

- **< 600px** (phones): bottom nav, single-column list
- **600–1200px** (tablets): bottom nav or rail, two-column grid
- **> 1200px** (desktop): nav rail + content pane, three-column grid or master-detail

---

## 8. Security

| Concern | Approach |
|---|---|
| Postgres credentials | `flutter_secure_storage` (Keychain on iOS/macOS, Keystore on Android, Secret Service on Linux, Windows Credential Manager on Windows) |
| API keys | Same as above |
| Postgres connection | TLS required; app rejects connections to Postgres without TLS unless the user explicitly opts out in settings |
| No backend API | The app connects directly to Postgres; there is no intermediate API service in v1 |

---

## 9. Key Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x

  # Navigation
  go_router: ^14.x

  # Local database
  drift: ^2.x
  sqlite3_flutter_libs: ^0.5.x

  # Remote database (sync)
  postgres: ^3.x

  # Networking
  dio: ^5.x
  retrofit: ^4.x

  # Barcode scanning
  mobile_scanner: ^5.x          # Android + iOS only

  # Secure storage
  flutter_secure_storage: ^9.x

  # Image loading
  cached_network_image: ^3.x

  # Code generation helpers
  freezed_annotation: ^2.x
  json_annotation: ^4.x

  # Utilities
  uuid: ^4.x
  intl: ^0.19.x

dev_dependencies:
  build_runner: ^2.x
  drift_dev: ^2.x
  riverpod_generator: ^2.x
  freezed: ^2.x
  json_serializable: ^6.x
  retrofit_generator: ^8.x
  flutter_test:
    sdk: flutter
  mocktail: ^1.x
```

---

## 10. CLAUDE.md Guidance for This Repository

The `CLAUDE.md` at the repository root should include the following for AI-assisted development sessions:

```markdown
## Project: MyMediaScanner
Flutter/Dart cross-platform media barcode scanning app.

## Stack
- Flutter + Dart (all platforms)
- Riverpod (riverpod_annotation / @riverpod codegen style)
- Drift for local SQLite; postgres package for remote sync
- GoRouter for navigation
- Dio + Retrofit for HTTP clients
- Freezed for immutable entities and sealed classes

## Conventions
- Clean architecture: domain/ has no dependencies on data/ or presentation/
- All repository interfaces live in domain/repositories/ and are prefixed with I
- Providers are always code-generated with @riverpod annotation
- Run `dart run build_runner build --delete-conflicting-outputs` after any schema or annotation change
- Use AsyncNotifier for stateful controllers, not StateNotifier
- Platform checks for desktop vs mobile via `core/utils/platform_utils.dart`; never use dart:io Platform directly in presentation/

## Database
- Local: Drift (SQLite). Schema changes require a new database migration in AppDatabase.
- Remote: PostgreSQL (self-hosted). Connection config stored in secure storage, not in code or env files.
- Soft deletes only. Never hard-delete a row; set deleted = 1 and include in sync.

## Testing
- Unit tests for all use cases and repository implementations
- Widget tests for key screens (collection, item detail, scanner confirm)
- Integration tests for the full scan → save → sync flow
```

---

## 11. Future Architecture Considerations

| Topic | Notes |
|---|---|
| **Sync service** | Consider a lightweight intermediary sync service (e.g. self-hosted with `shelf` Dart package) in v2 to decouple clients from direct Postgres access and enable multi-user scenarios |
| **Cover art storage** | v2 could store cover images as binary files in a self-hosted object store (e.g. MinIO), syncing file paths rather than external API URLs |
| **Video game metadata** | IGDB integration fits naturally into the tiered lookup architecture as a new API client + mapper |
| **Full-text search** | SQLite FTS5 extension via Drift for fast in-collection search without loading all rows |
| **Background sync** | `workmanager` package for periodic background sync on Android/iOS when app is not in foreground |
