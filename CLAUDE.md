# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project: MyMediaScanner

Cross-platform Flutter/Dart application for scanning barcodes on physical media (CDs, DVDs, Blu-rays, books, video games) and building a personal collection catalogue. Supports Android, iOS, macOS, Windows, and Linux. Data is stored locally in SQLite with optional sync to self-hosted PostgreSQL.

### Additional Features

- Lending tracker (borrowers and loans management)
- Critic scores from TMDB, Discogs, and Google Books
- FLAC rip library scanner with coverage comparison against physical collection
- Audio quality analysis (AccurateRip verification + click/pop detection)
- Statistics dashboard with CSV/JSON export
- Camera + Bluetooth/USB scanner support on mobile
- Media type filter on scan screen

## Technology Stack

- **UI:** Flutter (all platforms), Material 3 adaptive layout
- **State:** Riverpod 3.x with hand-written providers (Notifier and AsyncNotifier); `riverpod_generator` is not used due to incompatibility with `drift_dev`
- **Local DB:** Drift (SQLite) with type-safe DAOs
- **Remote DB:** PostgreSQL via `postgres` Dart package (direct connection, no intermediary API)
- **HTTP:** Dio + Retrofit for metadata API clients (TMDB, Discogs, Google Books, Open Library, UPCitemdb)
- **Navigation:** GoRouter with declarative routes
- **Models:** Freezed for immutable entities and sealed classes
- **Scanning:** mobile_scanner (ML Kit) on Android/iOS; keyboard-wedge USB scanner on desktop
- **Secrets:** flutter_secure_storage for Postgres credentials and API keys

## Build & Development Commands

```bash
# Run code generation after schema, annotation, or model changes
dart run build_runner build --delete-conflicting-outputs

# Run all tests
flutter test

# Run a single test file
flutter test test/unit/domain/scan_barcode_usecase_test.dart

# Run tests matching a name pattern
flutter test --name "should return metadata"

# Run the app
flutter run

# Analyse code
flutter analyze

# Build Android APK (debug)
flutter build apk --debug

# Build iOS (without codesigning)
flutter build ios --no-codesign
```

## Testing

The project has ~94 tests covering domain logic, data layer, and presentation. Run `flutter test` to execute the full suite.

## Architecture

Clean architecture with strict dependency rules: `domain/` has zero dependencies on `data/` or `presentation/`.

```
lib/
  app/          → MaterialApp.router, GoRouter routes, theme
  core/         → Constants, error types, extensions, utilities
  data/
    local/      → Drift database, tables, DAOs
    remote/
      api/      → Retrofit API clients (tmdb/, discogs/, google_books/, open_library/, upc/)
      sync/     → PostgreSQL sync client, conflict resolution
    mappers/    → DTO → domain entity converters
    repositories/ → Concrete implementations of domain interfaces
  domain/
    entities/   → Pure Dart models (@freezed), enums
    repositories/ → Abstract interfaces (prefixed with I)
    usecases/   → Business logic orchestrators
  presentation/
    providers/  → Riverpod providers (hand-written)
    screens/    → Feature screens with controllers and widgets
    widgets/    → Shared widgets (app_scaffold, empty/error/loading states)
```

## Key Conventions

- Repository interfaces live in `domain/repositories/` and are prefixed with `I` (e.g. `IMediaItemRepository`)
- All Riverpod providers are hand-written using Riverpod 3.x Notifier/AsyncNotifier classes (`riverpod_generator` is not used)
- Platform checks use `core/utils/platform_utils.dart` — never use `dart:io Platform` directly in presentation layer
- Soft deletes only: set `deleted = 1`, never hard-delete rows; deleted records are included in sync
- Metadata lookup follows a tiered strategy: cache check → barcode type detection → specialist API → UPCitemdb fallback
- Sync uses last-write-wins per-field conflict resolution based on `updated_at` timestamps
- Database schema changes require a new migration in `AppDatabase`
- Current schema version is 5 with 11 tables: `media_items`, `tags`, `media_item_tags`, `shelves`, `shelf_items`, `barcode_cache`, `sync_log`, `borrowers`, `loans`, `rip_albums`, `rip_tracks`

## External APIs

Users supply their own API keys (stored in secure storage) for TMDB, Discogs, and UPCitemdb. Google Books and Open Library require no keys.

## Metadata Lookup Order

1. Check `barcode_cache` (SQLite) — return if < 7 days old
2. Detect barcode type (EAN-13, UPC-A, ISBN-10/13)
3. Route by type: ISBN → Google Books → Open Library; EAN/UPC → specialist API by type hint (TMDB for film/TV, Discogs for music)
4. Fallback to UPCitemdb if specialist returns nothing
5. Cache raw response, map to `MetadataResult` domain entity
