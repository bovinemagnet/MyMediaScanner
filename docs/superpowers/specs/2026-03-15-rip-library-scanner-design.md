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

---

## 3. FLAC Vorbis Comment Parser

Pure Dart implementation (~200 lines). Reads the FLAC file header to extract the VORBIS_COMMENT metadata block.

**FLAC file structure:**
1. 4-byte magic: `fLaC`
2. One or more metadata blocks, each with a 4-byte header (1 bit last-block flag, 7 bits block type, 24 bits length)
3. Block type 4 = VORBIS_COMMENT

**VORBIS_COMMENT format:**
1. Vendor string (length-prefixed UTF-8, little-endian uint32)
2. Comment count (uint32 LE)
3. Each comment: length-prefixed UTF-8 string in `KEY=VALUE` format

**Tags to extract:**
- `ARTIST` / `ALBUMARTIST` → artist
- `ALBUM` → album title
- `TITLE` → track title
- `TRACKNUMBER` → track number
- `DISCNUMBER` → disc number
- `BARCODE` / `UPC` / `EAN` → barcode
- `TOTALTRACKS` / `TRACKTOTAL` → total track count

**FLAC STREAMINFO block** (block type 0): Read total samples and sample rate to compute duration. First 4+4+3+3+20+36+128 bits = min/max block size, min/max frame size, sample rate (20 bits), channels, bits per sample, total samples (36 bits).

**Location:** `lib/core/utils/flac_reader.dart`

---

## 4. Rip Scanning

**ScanRipLibraryUseCase:**
1. Takes a root directory path
2. Recursively finds all `.flac` files
3. Groups files by parent directory (each directory = one album)
4. For each album directory:
   - Read FLAC tags from the first track to get artist, album title, barcode
   - Read tags from all tracks to build track list
   - Compute total size from file sizes
5. Upserts `RipAlbum` and `RipTrack` entries (keyed by file path to handle re-scans)
6. Returns scan summary (albums found, tracks found, new, updated)

**Re-scan behaviour:** On re-scan, existing entries are updated (matched by directory path). Albums whose directories no longer exist are soft-deleted.

---

## 5. Matching Strategy

**MatchRipsUseCase** runs after scanning:

1. For each unmatched `RipAlbum`:
   - If `barcode` is present: exact match against `media_items.barcode` where `media_type = 'music'`
   - If no barcode or no barcode match: normalised title match
2. **Normalised title match:** lowercase both strings, strip leading "the ", remove all punctuation, trim whitespace, then exact string compare on both artist and album title
3. If matched, set `rip_album.media_item_id` to the matching media item's ID
4. Users can manually link/unlink from the item detail screen

---

## 6. Domain Entities

**RipAlbum** (@freezed):
- id, libraryPath, artist, albumTitle, barcode, trackCount, discCount, totalSizeBytes, mediaItemId, lastScannedAt, updatedAt, deleted

**RipTrack** (@freezed):
- id, ripAlbumId, discNumber, trackNumber, title, filePath, durationMs, fileSizeBytes, updatedAt

---

## 7. Repository

**IRipLibraryRepository:**
- `Stream<List<RipAlbum>> watchAll()`
- `Future<RipAlbum?> getByMediaItemId(String mediaItemId)`
- `Stream<RipAlbum?> watchByMediaItemId(String mediaItemId)`
- `Future<List<RipTrack>> getTracksForAlbum(String ripAlbumId)`
- `Future<void> saveAlbum(RipAlbum album)`
- `Future<void> saveTracks(List<RipTrack> tracks)`
- `Future<void> linkToMediaItem(String ripAlbumId, String mediaItemId)`
- `Future<void> unlinkFromMediaItem(String ripAlbumId)`
- `Future<void> softDeleteAlbum(String ripAlbumId)`

---

## 8. Presentation

### Settings
- New "FLAC Library" section in settings screen (desktop only, hidden on mobile via `PlatformCapability.isDesktop`)
- Text field for library root path (with folder picker button)
- "Scan Now" button — shows progress indicator during scan, then summary (X albums, Y tracks found, Z matched)
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
- Small disc icon badge on MediaItemCard for music items with a linked rip album
- CollectionFilter extended with `rippedOnly` bool

### Providers
- `ripAlbumForItemProvider` — StreamProvider.family by mediaItemId
- `ripTracksProvider` — FutureProvider.family by ripAlbumId
- `rippedItemIdsProvider` — StreamProvider returning Set<String> of media item IDs with linked rips
- `ripLibraryPathProvider` — reads from secure storage
- All hand-written (no riverpod_generator)

---

## 9. Testing

- **FLAC parser:** Unit test with a fixture containing real FLAC header bytes (a minimal valid FLAC file with known tags). Test tag extraction, missing tags, malformed files.
- **Matching:** Unit test for barcode match, normalised title match (with articles, punctuation), no match case.
- **DAO:** In-memory Drift test for rip_albums and rip_tracks CRUD, query by mediaItemId.
- **Use case:** Mock repository tests for scan and match logic.

---

## 10. Out of Scope (Phase B)

- Click/pop detection in FLAC audio
- AccurateRip database verification
- Audio waveform visualisation
- Automatic re-scanning / file watching
- Postgres sync of rip data
