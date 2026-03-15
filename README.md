# MyMediaScanner

Cross-platform app for scanning barcodes on physical media (CDs, DVDs, Blu-rays, books, video games) and building a personal collection catalogue. Scan with your phone camera or a desktop USB barcode scanner, automatically enrich records with metadata from specialist APIs, and sync your collection across devices via self-hosted PostgreSQL.

**Author:** Paul Snow

## Features

- **Barcode scanning** — camera on Android/iOS, keyboard-wedge USB scanner on desktop
- **Automatic metadata lookup** — tiered strategy across TMDB (film/TV), Discogs (music), Google Books, Open Library (books), and UPCitemdb (fallback)
- **Critic scores** — community/critic ratings from TMDB, Discogs, and Google Books displayed alongside your own rating
- **Collection management** — browse, search, filter by type/genre/tag/year, sort by title/date/year/rating
- **Star ratings and reviews** — personal 1-5 star rating and free-text review per item
- **Tags** — create custom tags, assign to items, filter by tag
- **Shelves** — organise items into named, ordered collections
- **Lending tracker** — track who you've lent items to, manage borrowers, view lending history
- **Batch scanning** — scan multiple items in sequence without returning to the home screen
- **Statistics dashboard** — collection totals, breakdown by type/year/genre, average rating
- **Export** — export your collection as CSV or JSON
- **Sync** — push/pull to self-hosted PostgreSQL with last-write-wins conflict resolution
- **Offline-first** — all data stored locally in SQLite, fully functional without network

## Platforms

| Platform | Status | Scanning Method |
|---|---|---|
| Android | Supported | Device camera (ML Kit) |
| iOS | Supported | Device camera (ML Kit) |
| macOS | Supported | USB barcode scanner + manual entry |

## Tech Stack

- **UI:** Flutter, Material 3, adaptive layout (nav rail on desktop, bottom nav on mobile)
- **State:** Riverpod (hand-written providers)
- **Local DB:** Drift (SQLite) with type-safe DAOs
- **Remote DB:** PostgreSQL via `postgres` Dart package (direct connection)
- **HTTP:** Dio + Retrofit for metadata API clients
- **Models:** Freezed for immutable entities
- **Scanning:** mobile_scanner (ML Kit) on Android/iOS
- **Secrets:** flutter_secure_storage for credentials and API keys

## Getting Started

### Prerequisites

- Flutter 3.41+ / Dart 3.11+
- Android SDK 36+ (for Android builds)
- Xcode 26+ (for iOS/macOS builds)

### Run

```bash
# Get dependencies
flutter pub get

# Run code generation (after any schema/annotation changes)
dart run build_runner build --delete-conflicting-outputs

# Run on macOS
flutter run -d macos

# Run on Android
flutter run -d <device>

# Run tests
flutter test

# Analyse
flutter analyze
```

### API Keys

The app requires user-supplied API keys for metadata lookup. Configure these in **Settings > API Keys**:

| Service | Purpose | Free Tier |
|---|---|---|
| [TMDB](https://www.themoviedb.org/settings/api) | Film/TV metadata + scores | Yes (generous) |
| [Discogs](https://www.discogs.com/settings/developers) | Music metadata + scores | Yes (rate-limited) |
| [UPCitemdb](https://www.upcitemdb.com/wp/docs/main/development/getting-started/) | General UPC fallback | Yes (limited) |

Google Books and Open Library require no API keys.

### PostgreSQL Sync (Optional)

To sync across devices, set up a PostgreSQL instance and configure the connection in **Settings > PostgreSQL Configuration**:

1. Create the database and schema:
   ```bash
   createdb mymediascanner
   psql mymediascanner -f lib/data/remote/sync/migrations/001_initial_schema.sql
   psql mymediascanner -f lib/data/remote/sync/migrations/002_lending_tables.sql
   psql mymediascanner -f lib/data/remote/sync/migrations/003_critic_scores.sql
   ```

2. In the app, go to **Settings > PostgreSQL Configuration**, enter your connection details, and tap **Test Connection**.

TLS is required by default. For local development, you can disable it in settings.

## Architecture

Clean architecture with strict dependency rules: `domain/` has zero dependencies on `data/` or `presentation/`.

```
lib/
  app/          — MaterialApp.router, GoRouter routes, theme
  core/         — Constants, error types, extensions, utilities
  data/
    local/      — Drift database, tables, DAOs
    remote/
      api/      — Retrofit API clients (TMDB, Discogs, Google Books, Open Library, UPC)
      sync/     — PostgreSQL sync client, conflict resolution, migrations
    mappers/    — DTO to domain entity converters
    repositories/ — Concrete implementations of domain interfaces
  domain/
    entities/   — Pure Dart models (Freezed)
    repositories/ — Abstract interfaces (prefixed with I)
    usecases/   — Business logic orchestrators
  presentation/
    providers/  — Riverpod providers
    screens/    — Feature screens with widgets
    widgets/    — Shared widgets
```

## Metadata Lookup Order

1. Check barcode cache (SQLite) — return if less than 7 days old
2. Detect barcode type (EAN-13, UPC-A, ISBN-10/13)
3. Route by type: ISBN goes to Google Books then Open Library; EAN/UPC goes to specialist API by type hint (TMDB for film/TV, Discogs for music)
4. Fallback to UPCitemdb if specialist returns nothing
5. Cache raw response, map to domain entity, return

## Licence

Private project. All rights reserved.
