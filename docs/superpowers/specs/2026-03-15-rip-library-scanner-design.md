# Rip Library Scanner + Coverage Comparison — Design Spec

**Date:** 2026-03-15
**Status:** Approved
**Platforms:** Desktop only (macOS, Windows, Linux) for scanning; rip status visible on all platforms

---

## 1. Overview

Add the ability to scan a local directory of ripped FLAC files, extract metadata from Vorbis comment tags, match rip albums to physical CD entries in the collection, and display rip coverage (ripped/partially ripped/not ripped) on the item detail screen with a filter chip on the collection view.

---

## 2. Data Model

### New Tables (SQLite only — no Postgres sync)

**rip_albums**
- `id` TEXT PK (UUID v7)
- `library_path` TEXT NOT NULL — root-relative path to the album directory
- `artist` TEXT
- `album_title` TEXT
- `barcode` TEXT — from FLAC tags if present
- `track_count` INTEGER NOT NULL
- `disc_count` INTEGER NOT NULL DEFAULT 1
- `total_size_bytes` INTEGER NOT NULL
- `media_item_id` TEXT nullable FK → media_items.id — matched collection item
- `last_scanned_at` INTEGER NOT NULL — Unix ms
- `updated_at` INTEGER NOT NULL
- `deleted` INTEGER NOT NULL DEFAULT 0

**rip_tracks**
- `id` TEXT PK (UUID v7)
- `rip_album_id` TEXT NOT NULL FK → rip_albums.id
- `disc_number` INTEGER NOT NULL DEFAULT 1
- `track_number` INTEGER NOT NULL
- `title` TEXT
- `file_path` TEXT NOT NULL — full path to FLAC file
- `duration_ms` INTEGER — from FLAC streaminfo if available
- `file_size_bytes` INTEGER NOT NULL
- `updated_at` INTEGER NOT NULL

**Track deletion strategy:** Tracks have no `deleted` column. When a rip album is soft-deleted, its tracks are filtered out at query time (DAO joins on rip_album.deleted = 0). When re-scanning replaces an album, old tracks are hard-deleted and replaced with the new track list.

### Drift Migration

Increment `AppDatabase.schemaVersion` to 4. Add migration:

```dart
if (from < 4) {
  await m.createTable(ripAlbumsTable);
  await m.createTable(ripTracksTable);
}
```

---

## 3. FLAC Vorbis Comment Parser

Pure Dart implementation (~200 lines). Reads the FLAC file header to extract metadata blocks. No external dependencies.

**Location:** `lib/core/utils/flac_reader.dart`

**FLAC file structure:**
1. 4-byte magic: `fLaC`
2. One or more metadata blocks, each with a 4-byte header (1 bit last-block flag, 7 bits block type, 24 bits length)
3. Block type 0 = STREAMINFO, block type 4 = VORBIS_COMMENT

**STREAMINFO block (type 0) — bit layout:**
| Bits | Field |
|------|-------|
| 16 | Minimum block size (samples) |
| 16 | Maximum block size (samples) |
| 24 | Minimum frame size (bytes) |
| 24 | Maximum frame size (bytes) |
| 20 | Sample rate (Hz) |
| 3 | Number of channels - 1 |
| 5 | Bits per sample - 1 |
| 36 | Total samples |
| 128 | MD5 signature |

Duration = total samples / sample rate.

**VORBIS_COMMENT block (type 4):**
1. Vendor string (length-prefixed UTF-8, little-endian uint32)
2. Comment count (uint32 LE)
3. Each comment: length-prefixed UTF-8 string in `KEY=VALUE` format

**Tags to extract:**
- `ALBUMARTIST` → artist (preferred over `ARTIST` for album-level attribution)
- `ARTIST` → artist (fallback if no `ALBUMARTIST`)
- `ALBUM` → album title
- `TITLE` → track title
- `TRACKNUMBER` → track number
- `DISCNUMBER` → disc number
- `BARCODE` / `UPC` / `EAN` → barcode
- `TOTALTRACKS` / `TRACKTOTAL` → total track count

**Multi-artist handling:** `ALBUMARTIST` takes precedence. For compilations/various artists, `ALBUMARTIST` is typically "Various Artists". The matching logic uses this single artist string.

---

## 4. Rip Scanning

**ScanRipLibraryUseCase:**
1. Takes a root directory path
2. **Runs in a separate isolate** via `Isolate.run()` to avoid blocking the UI — file I/O and FLAC header parsing can be slow for large libraries
3. Recursively finds all `.flac` files
4. Groups files by parent directory (each directory = one album)
5. For each album directory:
   - Read FLAC tags from the first track to get artist, album title, barcode (using `ALBUMARTIST` if available, falling back to `ARTIST`)
   - Read STREAMINFO from the first track for sample rate, then read all tracks for total samples → duration
   - Read tags from all tracks to build track list
   - Compute total size from file sizes
6. Returns results to the main isolate
7. Main isolate upserts `RipAlbum` and `RipTrack` entries (keyed by directory path to handle re-scans; old tracks for an album are hard-deleted and replaced)

**Re-scan behaviour:** On re-scan, existing entries are updated (matched by `library_path`). Albums whose directories no longer exist are soft-deleted.

**Progress reporting:** The use case yields progress via a `Stream<RipScanProgress>` where `RipScanProgress` contains `albumsScanned`, `totalDirectories`, and `currentDirectory`. The settings UI subscribes to this stream.

---

## 5. Matching Strategy

**MatchRipsUseCase** runs after scanning:

1. For each unmatched `RipAlbum`:
   - If `barcode` is present: exact match against `media_items.barcode` where `media_type = 'music'`
   - If no barcode or no barcode match: normalised title match
2. **Normalised title match:** lowercase both strings, strip leading "the ", remove all punctuation, trim whitespace, then exact string compare on both artist and album title. For the collection item, the artist is taken from `extraMetadata['artists']` (joined as a single string) or the `publisher` field as fallback.
3. If matched, set `rip_album.media_item_id` to the matching media item's ID
4. Users can manually link/unlink from the item detail screen

---

## 6. Domain Entities

**RipAlbum** (@freezed):
- id, libraryPath, artist, albumTitle, barcode, trackCount, discCount, totalSizeBytes, mediaItemId, lastScannedAt, updatedAt, deleted

**RipTrack** (@freezed):
- id, ripAlbumId, discNumber, trackNumber, title, filePath, durationMs, fileSizeBytes, updatedAt

**RipScanProgress** (plain Dart class):
- albumsScanned, totalDirectories, currentDirectory

---

## 7. Data Access

### DAOs

**RipLibraryDao** (`lib/data/local/dao/rip_library_dao.dart`):
- `@DriftAccessor(tables: [RipAlbumsTable, RipTracksTable])`
- `watchAll()` — stream of non-deleted rip albums
- `watchByMediaItemId(String mediaItemId)` — stream of single rip album for a collection item
- `getByLibraryPath(String path)` — for re-scan matching
- `insertAlbum(companion)` / `updateAlbum(companion)`
- `softDeleteAlbum(String id, int updatedAt)`
- `getTracksForAlbum(String ripAlbumId)` — filtered by album's non-deleted status
- `insertTracks(List<companion>)` / `deleteTracksForAlbum(String ripAlbumId)` — hard delete for re-scan replacement
- `watchRippedMediaItemIds()` — stream of `Set<String>` for collection badge/filter

Register in `AppDatabase` and add provider in `database_provider.dart`.

### Repository

**IRipLibraryRepository** (`lib/domain/repositories/i_rip_library_repository.dart`):
- Interface as defined in the original spec

**RipLibraryRepositoryImpl** (`lib/data/repositories/rip_library_repository_impl.dart`):
- Wraps RipLibraryDao, maps rows to domain entities

---

## 8. Presentation

### Providers
- `ripLibraryDaoProvider` — from database_provider.dart
- `ripLibraryRepositoryProvider` — hand-written Provider in repository_providers.dart
- `ripAlbumForItemProvider` — StreamProvider.family by mediaItemId
- `ripTracksProvider` — FutureProvider.family by ripAlbumId
- `rippedItemIdsProvider` — StreamProvider returning Set<String> of media item IDs with linked rips
- `ripLibraryPathProvider` — reads from secure storage
- `ripScanNotifierProvider` — Notifier managing scan state (idle/scanning/complete) with progress stream
- All hand-written (no riverpod_generator — matches existing codebase pattern)

### Settings
- New "FLAC Library" section in settings screen (desktop only, hidden on mobile via `PlatformCapability.isDesktop`)
- Text field for library root path (with folder picker button)
- "Scan Now" button — subscribes to `ripScanNotifierProvider` for progress (e.g. "Scanning... 42/156 albums"), then shows summary (X albums, Y tracks found, Z matched)
- Library path stored in secure storage

### Item Detail — Rip Status Section
For music items (`mediaType == MediaType.music`), add a section after metadata:

- **Ripped (12/12 tracks)** — green checkmark, all tracks present
- **Partially ripped (8/12 tracks)** — amber warning, lists missing tracks
- **Not ripped** — grey, no matching rip album
- **Unmatched rip exists** — if a rip album exists but isn't linked, show "Link rip" button

Track comparison: compares rip track count against the Discogs tracklist in `extraMetadata['track_listing']`. If track listing is available, shows per-track match status.

Manual link/unlink: "Link rip" button opens a picker showing unlinked rip albums. "Unlink" button on linked rips.

### Collection View
- "Ripped" filter chip in FilterBar (same pattern as "Lent out")
- Small disc icon badge on MediaItemCard — card receives `isRipped` bool parameter from parent (same pattern as `isLent`), passed from CollectionScreen using `rippedItemIdsProvider`
- `CollectionFilterState` record extended with `rippedOnly` bool — requires updating all setter methods in `CollectionFilter` that reconstruct the record

---

## 9. Testing

- **FLAC parser:** Unit test with a fixture containing real FLAC header bytes (a minimal valid FLAC file with known tags). Test tag extraction, ALBUMARTIST precedence, missing tags, malformed files.
- **Matching:** Unit test for barcode match, normalised title match (with articles, punctuation, multi-artist), no match case.
- **DAO:** In-memory Drift test for rip_albums and rip_tracks CRUD, query by mediaItemId, track hard-delete on re-scan.
- **Use case:** Mock repository tests for scan and match logic.

---

## 10. Out of Scope (Phase B)

- Click/pop detection in FLAC audio
- AccurateRip database verification
- Audio waveform visualisation
- Automatic re-scanning / file watching
- Postgres sync of rip data
