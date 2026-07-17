# Rip Library Album Artwork — Design

**Date:** 2026-07-17
**Author:** Paul Snow
**Status:** Approved

## Problem

The Rip Library shows no album artwork. Rip album cards and the album
detail panel are text-only, even though 117 of 160 FLAC files in the
reference library carry an embedded `PICTURE` block, and folder cover
images (`cover.jpg` etc.) are a common library convention.

## Goals

- Show album artwork on rip album cards (grid) and, larger, in the
  album detail panel/dialog.
- Source artwork from a folder image file first, falling back to the
  first embedded FLAC `PICTURE` block.
- Artwork must remain visible when the library volume is unmounted or
  its sandbox grant is unavailable.

## Non-goals

- Table-view row thumbnails and now-playing artwork.
- Cache eviction for deleted albums.
- Online artwork lookup (Fanart etc.) for rips.

## Design

### Data model (schema v24)

- `rip_albums` gains `cover_path TEXT NULL` — absolute path of a
  locally cached cover image, or NULL when the album has no artwork.
- New `from < 24` branch in the `AppDatabase` migration chain (which
  now runs inside a transaction with guarded column adds).
- `RipAlbum` entity gains `String? coverPath`; Drift table, DAO
  mapping, and repository plumbing updated to match.

### Extraction (scan pipeline)

Extraction happens inside the existing `ScanRipLibraryUseCase` scan,
which already walks each album directory and fully reads the first
track of each album for metadata.

Source priority per album directory:

1. **Folder image**: the first of `cover`, `folder`, `album`, `front`
   with extension `.jpg`, `.jpeg`, or `.png` (case-insensitive match
   on both name and extension).
2. **Embedded picture**: the first `PICTURE` block of the first track
   whose metadata parses. `FlacMetadata` gains a `coverArt`
   (`Uint8List?`) field populated by `FlacReader` from
   `dart_metaflac`'s `doc.pictures` (first picture, any picture type).
3. Neither present → `coverPath` stays NULL.

Cache write:

- Destination: `<ApplicationSupport>/rip_covers/<hash>.<ext>` where
  `<hash>` is the lowercase hex MD5 of the album's relative
  `libraryPath` (stability matters, not cryptographic strength) and
  `<ext>` is `jpg` or `png` — taken from the folder image's filename,
  or from the embedded picture's MIME type (`image/png` → `png`,
  anything else → `jpg`). A stable name means rescans overwrite in
  place; the cache holds at most one file per album directory. When a
  rescan finds no artwork for an album that previously had some,
  `coverPath` is set back to NULL (the orphaned cache file may remain;
  eviction is out of scope).
- The Application Support directory is resolved on the main isolate
  (via `path_provider`) and passed into the scan isolate as a plain
  string, because platform channels are unavailable off the main
  isolate.
- The scan result struct carries `coverPath`; the album insert/update
  writes it to the database alongside the other album fields.

### Display

- **Album card** (`_RipAlbumCard`): a rounded-corner square thumbnail
  (~76 px) on the left of the existing card content. When `coverPath`
  is NULL or the file fails to load (`Image.file` `errorBuilder`), a
  subtle disc icon on a tonal background is shown instead. Card height
  and information density are otherwise unchanged.
- **Album detail panel/dialog**: the same image rendered larger at the
  top of the panel, with the same placeholder behaviour.

### Error handling

- Unreadable/corrupt folder image or picture block: extraction is
  skipped for that source and the next source is tried; failures never
  abort the scan.
- Cache write failures (disk full, permissions) are swallowed per
  album; `coverPath` stays NULL.
- A cached file deleted out-of-band degrades to the placeholder via
  `errorBuilder`.

### Testing

- Migration v24 test following the existing `migration_v*_test.dart`
  pattern.
- `FlacReader` test: `coverArt` populated from fixture bytes built
  with a `PictureBlock`, and NULL when no picture block exists.
- Scan use case tests: folder image beats embedded picture; embedded
  picture used when no folder image; cache file written with expected
  name; repository receives the `coverPath`; extraction failure leaves
  `coverPath` NULL without failing the scan.
- Widget test: card renders the disc-icon placeholder when
  `coverPath` is NULL.
