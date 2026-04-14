# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project: MyMediaScanner

Cross-platform Flutter/Dart application for scanning barcodes on physical media (CDs, DVDs, Blu-rays, books, video games) and building a personal collection catalogue. Supports Android, iOS, macOS, Windows, and Linux. Data is stored locally in SQLite with optional sync to self-hosted PostgreSQL.

### Additional Features

- Lending tracker (borrowers and loans management)
- Critic scores from TMDB, Discogs, and Google Books
- FLAC/MP3 rip library scanner with CUE sheet support and coverage comparison against physical collection
- Audio quality analysis (AccurateRip verification + click/pop detection)
- Insights & analytics dashboard with CSV/JSON export
- Camera + Bluetooth/USB scanner support on mobile; webcam scanning on all desktop platforms
- Media type filter on scan screen
- Batch scanning mode with queue-based review and bulk save
- IMDb ID lookup (tt1234567) via TMDB find endpoint
- Cover OCR text recognition (ML Kit on Android/iOS, Vision framework on macOS, Tesseract on Windows/Linux)
- Theme mode selector (system/light/dark) persisted to SharedPreferences
- Resizable master-detail split with drag divider (persisted to SharedPreferences)
- Keyboard navigation in collection and rips tables (arrow keys, Enter, Delete, Escape)
- Auto-collapse sidebar to drawer on narrow desktop windows

## Technology Stack

- **UI:** Flutter (all platforms), custom "Obsidian Lens" (dark) / "Precision Editorial" (light) design system built on Material 3 with hand-crafted colour schemes, Manrope + Inter typography, glassmorphism, and tonal container architecture
- **State:** Riverpod 3.x with hand-written providers (Notifier and AsyncNotifier); `riverpod_generator` is not used due to incompatibility with `drift_dev`
- **Local DB:** Drift (SQLite) with type-safe DAOs
- **Remote DB:** PostgreSQL via `postgres` Dart package (direct connection, no intermediary API)
- **HTTP:** Dio + Retrofit for metadata API clients (TMDB, TVDB, Discogs, MusicBrainz, TheAudioDB, Fanart, Google Books, Open Library, UPCitemdb)
- **Navigation:** GoRouter with StatefulShellRoute; desktop sidebar + glassmorphism mobile bottom nav
- **Models:** Freezed for immutable entities and sealed classes
- **Scanning:** mobile_scanner (ML Kit) on Android/iOS/macOS; camera_desktop + flutter_zxing on Windows/Linux; keyboard-wedge USB scanner on all desktop platforms
- **OCR:** Google ML Kit text recognition (Android/iOS); macOS Vision framework via method channel (`com.mymediascanner/vision_ocr`); Tesseract via flutter_tesseract_ocr on Windows/Linux
- **Secrets:** flutter_secure_storage for Postgres credentials and API keys
- **Fonts:** Manrope and Inter bundled in `assets/fonts/` (no google_fonts runtime dependency)

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

# Build Android APK (debug, dev flavour)
flutter build apk --debug --flavor dev

# Build Android APK (release, prod flavour)
flutter build apk --release --flavor prod

# Build iOS (without codesigning)
flutter build ios --no-codesign

# Build macOS
flutter build macos --debug
```

## Testing

The project has ~729 tests: ~683 unit/widget tests covering domain logic, data layer, presentation providers, and widget tests, plus ~46 integration tests covering full-app user flows. Run `flutter test` to execute the unit/widget suite. Integration tests run individually per file: `flutter test integration_test/<file>.dart -d linux`. Tests use `mocktail` for mocking and `ProviderContainer` with overrides for provider testing.

## Architecture

Clean architecture with strict dependency rules: `domain/` has zero dependencies on `data/` or `presentation/`.

```
lib/
  app/
    theme/      → Custom design system (app_colors, app_typography, app_theme, app_theme_extensions)
    app.dart    → MaterialApp.router with theme mode provider
    router.dart → GoRouter with 8 StatefulShellBranch routes
  core/
    constants/  → App constants, breakpoints, window dimensions
    services/
      camera/   → CameraService abstraction, MobileScannerCameraService, NativeCameraService, BarcodeDetector
    utils/      → Platform utils, barcode utils, cover OCR helper, Vision OCR channel, Tesseract OCR service
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
    providers/  → Riverpod providers (hand-written), including batch_editor_provider, split_ratio_provider
    screens/
      dashboard/      → Landing page with hero text, quick scan CTA, recent additions
      collection/     → Library grid/table view with master-detail, statistics/insights
      scanner/        → Mobile camera scanner + desktop keyboard/webcam scanner
      shelves/        → Shelf management with drag-reorder
      batch/          → Batch editor with queue review, conflict resolution, bulk save
      item_detail/    → Item detail with cover art hero, metadata sections, lending, rip status
      metadata_confirm/ → Post-scan metadata review and editing
      disambiguation/   → Multi-match candidate selection
      settings/       → API keys, sync config, theme mode toggle, FLAC library config
      rips/           → Rip library browser with coverage and quality analysis
      about/          → App info, features list, licences
    widgets/    → Shared widgets (app_scaffold with sidebar/drawer/glassmorphism nav, glass_container, gradient_button, screen_header, master_detail_layout with resizable split, table_keyboard_navigation, empty/error/loading states)
```

## Navigation Structure

Routes are organised as 8 `StatefulShellBranch` entries:

| Branch | Route | Screen | Desktop Sidebar | Mobile Bottom Nav |
|--------|-------|--------|-----------------|-------------------|
| 0 | `/` | Dashboard | Yes | Yes (Home) |
| 1 | `/collection` | Collection/Library | Yes | Yes (Library) |
| 2 | `/scan` | Scanner | Yes | Yes |
| 3 | `/shelves` | Shelves | Yes | No (accessible from Library AppBar) |
| 4 | `/batch` | Batch Editor | Yes | No |
| 5 | `/insights` | Insights/Statistics | Yes | Yes |
| 6 | `/settings` | Settings | Yes | No |
| 7 | `/rips` | Rips (desktop only) | Yes | No |

Item detail routes are nested under collection: `/collection/item/:id`

## Design System

The app uses a custom design system with two themes:

- **Dark ("Obsidian Lens"):** Deep obsidian surfaces (#0e0e0e), electric cyan primary (#6dddff), Inter body text
- **Light ("Precision Editorial"):** Off-white surfaces (#f5f6f7), deep teal primary (#00647a), Manrope throughout

Design principles: "no-line" rule (tonal shifts instead of borders), glassmorphism for navigation, gradient CTAs, ghost borders (outline-variant at 15% opacity), ambient shadows. Theme extension (`AppDesignExtension`) carries glassmorphism, gradient, and shadow tokens.

## Key Conventions

- Repository interfaces live in `domain/repositories/` and are prefixed with `I` (e.g. `IMediaItemRepository`)
- All Riverpod providers are hand-written using Riverpod 3.x Notifier/AsyncNotifier classes (`riverpod_generator` is not used)
- Platform checks use `core/utils/platform_utils.dart` — never use `dart:io Platform` directly in presentation layer
- Soft deletes only: set `deleted = 1`, never hard-delete rows; deleted records are included in sync
- Metadata lookup follows a tiered strategy: cache check → barcode type detection → specialist API → UPCitemdb fallback
- Sync uses last-write-wins per-field conflict resolution based on `updated_at` timestamps, with user-facing conflict resolution UI for concurrent edits within a configurable threshold
- Database schema changes require a new migration in `AppDatabase`
- Current schema version is 12 with 13 tables: `media_items`, `tags`, `media_item_tags`, `shelves`, `shelf_items`, `barcode_cache`, `sync_log`, `borrowers`, `loans`, `rip_albums`, `rip_tracks`, `batch_sessions`, `batch_queue_items`
- Desktop screens use inline `ScreenHeader` widget instead of AppBar; mobile screens keep AppBar for back navigation
- Sections use tonal containers (`surfaceContainerHigh`) with uppercase label headers, not dividers

## External APIs

Users supply their own API keys (stored in secure storage) for TMDB, Discogs, UPCitemdb, TVDB, and Fanart. Google Books, Open Library, MusicBrainz, and TheAudioDB require no keys.

## Metadata Lookup Order

1. Check `barcode_cache` (SQLite) — return if < 7 days old
2. Detect barcode type (EAN-13, UPC-A, ISBN-10/13, IMDb ID)
3. Route by type:
   - IMDb ID (tt*) → TMDB `/find/{external_id}` endpoint
   - ISBN → Google Books → Open Library
   - EAN/UPC → specialist API by type hint (TMDB for film/TV, Discogs for music, MusicBrainz as music fallback)
4. Fallback to UPCitemdb if specialist returns nothing
4b. Enrich with artwork from Fanart and metadata from TheAudioDB where available
5. Cache raw response, map to `MetadataResult` domain entity

## Known Constraints

- `file_picker` pinned to `>=10.3.10 <11.0.0` — v11 has a broken Android Gradle config (missing kotlin-android plugin)
- iOS deployment target is 15.5 (required by google_mlkit_commons)
- Google ML Kit text recognition not available on desktop — macOS uses Vision framework via method channel; Windows/Linux use Tesseract
- Cover OCR on desktop uses gallery file picker (not camera capture) since `ImagePicker.camera` is unreliable on desktop
- `flutter_zxing` uses native FFI — its barcode detection cannot be unit-tested; requires integration tests
- `camera_desktop` image streaming not available on Windows — uses periodic still-frame capture for barcode detection instead
