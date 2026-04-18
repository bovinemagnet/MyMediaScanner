# Product Plan: `dart_cue` — Pure Dart CUE Sheet Parser

## Problem

There is no CUE sheet parser available on [pub.dev](https://pub.dev) for the Dart ecosystem. CUE sheets are widely used in CD ripping, audio archival, and media library management to describe track layouts within a single audio file. Any Dart/Flutter application working with ripped audio needs to parse these files.

## Product Vision

A pure Dart library that parses CUE sheet files into structured data, covering the full CUE sheet specification. Zero dependencies beyond the Dart SDK. Usable in Flutter, server-side Dart, and CLI tools.

## Target Users

- Developers building media library/collection apps
- Audio archival and CD ripping tool developers
- Music player app developers (gapless playback from single-file rips)
- Anyone working with CD images or split audio files

## Package Details

- **Name:** `dart_cue`
- **Repository:** `github.com/bovinemagnet/dart_cue`
- **Licence:** GPL v3 (consistent with `dart_accuraterip` and `audio_defect_detector`)
- **SDK constraint:** `>=3.5.0 <4.0.0`
- **Dependencies:** None (pure Dart, `dart:io` for file reading only)
- **Author:** Paul Snow
- **Version:** 0.0.1

## CUE Sheet Specification Coverage

Reference: [Hydrogenaudio CUE Sheet](https://wiki.hydrogenaudio.org/index.php?title=Cue_sheet), [wyday CUE Specification](https://wyday.com/cuesharp/specification.php)

### Commands to Support

#### Album-Level (Global)
| Command | Status in current code | Priority |
|---------|----------------------|----------|
| `CATALOG` (barcode/EAN) | Implemented | Must have |
| `PERFORMER` | Implemented | Must have |
| `TITLE` | Implemented | Must have |
| `FILE` (filename + type) | Implemented (filename only) | Must have — also parse file type (WAVE, MP3, AIFF, BINARY, MOTOROLA) |
| `SONGWRITER` | Not implemented | Should have |
| `CDTEXTFILE` | Not implemented | Could have |
| `REM` (comments/extensions) | Partial (UPC, BARCODE, DISCNUMBER) | Must have — also support GENRE, DATE, DISCID, COMMENT |

#### Track-Level
| Command | Status in current code | Priority |
|---------|----------------------|----------|
| `TRACK` (number + type) | Implemented (AUDIO only) | Must have — also parse CDG, MODE1/2048, MODE1/2352, MODE2/2336, MODE2/2352, CDI/2336, CDI/2352 |
| `TITLE` | Implemented | Must have |
| `PERFORMER` | Implemented | Must have |
| `INDEX` (00 pregap, 01 start, 02+ subindices) | Partial (01 only) | Must have — parse all indices, not just 01 |
| `SONGWRITER` | Not implemented | Should have |
| `ISRC` | Not implemented | Should have |
| `PREGAP` | Not implemented | Should have |
| `POSTGAP` | Not implemented | Should have |
| `FLAGS` (DCP, 4CH, PRE, SCMS) | Not implemented | Should have |

### REM Extensions to Support
| Extension | Status | Priority |
|-----------|--------|----------|
| `REM UPC` | Implemented | Must have |
| `REM BARCODE` | Implemented | Must have |
| `REM DISCNUMBER` | Implemented | Must have |
| `REM GENRE` | Not implemented | Should have |
| `REM DATE` / `REM YEAR` | Not implemented | Should have |
| `REM DISCID` | Not implemented | Should have |
| `REM COMMENT` | Not implemented | Could have |
| `REM REPLAYGAIN_*` | Not implemented | Could have |
| Custom `REM` fields | Not implemented | Should have — expose as `Map<String, String>` |

## Data Models

### `CueSheet`
```
- performer: String?
- title: String?
- songwriter: String?
- catalog: String? (barcode/EAN-13)
- cdTextFile: String?
- files: List<CueFile>
- remComments: Map<String, String> (all REM key-value pairs)
- genre: String? (convenience getter from remComments)
- date: String? (convenience getter from remComments)
- discNumber: int? (convenience getter from remComments)
- discId: String? (convenience getter from remComments)
```

### `CueFile`
```
- filename: String
- fileType: CueFileType (wave, mp3, aiff, binary, motorola)
- tracks: List<CueTrack>
```

Note: The CUE spec allows multiple FILE commands. The current implementation only captures the first. The library must handle multi-FILE CUE sheets correctly, grouping tracks under their respective FILE entries.

### `CueTrack`
```
- trackNumber: int
- trackType: CueTrackType (audio, cdg, mode1_2048, etc.)
- title: String?
- performer: String?
- songwriter: String?
- isrc: String?
- pregap: Duration?
- postgap: Duration?
- flags: Set<CueFlag> (dcp, fourChannel, preEmphasis, scms)
- indices: Map<int, Duration> (index number → timestamp)
- startTime: Duration? (convenience: indices[1])
- endTime: Duration? (derived from next track's index 01, or null for last)
- duration: Duration? (endTime - startTime, or null)
```

### Enums
```
CueFileType { wave, mp3, aiff, binary, motorola }
CueTrackType { audio, cdg, mode1_2048, mode1_2352, mode2_2336, mode2_2352, cdi_2336, cdi_2352 }
CueFlag { dcp, fourChannel, preEmphasis, scms }
```

## Public API

### Parsing
```dart
/// Parse CUE sheet from a string.
CueSheet? parseCueSheet(String content);

/// Parse CUE sheet from a file path.
/// Tries UTF-8 first, falls back to Latin-1.
Future<CueSheet?> parseCueFile(String filePath);

/// Parse CUE sheet from bytes with explicit encoding.
CueSheet? parseCueBytes(Uint8List bytes, {Encoding encoding = utf8});
```

### Time Utilities
```dart
/// Parse MSF timestamp (mm:ss:ff where ff = frames at 75fps) to Duration.
Duration? parseMsf(String msf);

/// Format Duration as MSF string.
String formatMsf(Duration duration);
```

### Serialisation
```dart
/// Convert CueSheet back to CUE format string.
String toCueString(CueSheet sheet);
```

This enables round-trip parsing: read → modify → write.

## Architecture

```
lib/
  dart_cue.dart              → Public API exports
  src/
    models.dart              → CueSheet, CueFile, CueTrack, enums
    parser.dart              → Core parsing logic (from string)
    file_reader.dart         → File I/O with encoding fallback
    msf.dart                 → MSF time format utilities
    writer.dart              → CUE sheet serialisation
bin/
  cueinfo.dart               → Optional CLI tool (print parsed CUE as JSON)
```

## Existing Code to Migrate

Source: `MyMediaScanner/lib/core/utils/cue_parser.dart` (249 lines)

What to keep:
- Regex-based line parsing approach (simple, fast, correct)
- `_TrackBuilder` pattern for mutable state during parsing
- Encoding fallback (UTF-8 → Latin-1)
- End time derivation from next track's start
- MSF frame calculation (`ff * 1000 ~/ 75`)

What to change:
- Models need expanding (see above)
- Support multiple `FILE` commands (group tracks under files)
- Parse all `INDEX` entries, not just `01`
- Add `SONGWRITER`, `ISRC`, `PREGAP`, `POSTGAP`, `FLAGS`
- Expose all `REM` comments as a map
- Remove `dart:io` dependency from parser (keep in separate file_reader)
- Add `toCueString()` writer for round-trip support

## Test Plan

### Unit Tests (from string parsing — no I/O)

**Basic parsing:**
- Empty/blank content → null
- Minimal valid CUE (one FILE, one TRACK, one INDEX) → correct structure
- Album metadata (PERFORMER, TITLE, CATALOG, SONGWRITER)

**Track parsing:**
- Multiple tracks with titles, performers, songwriters
- Track type detection (AUDIO, CDG, MODE1/2048, etc.)
- ISRC extraction and validation
- FLAGS parsing (single and multiple flags)

**INDEX handling:**
- INDEX 00 (pregap marker) parsed correctly
- INDEX 01 (track start) parsed correctly
- INDEX 02+ (subindices) parsed correctly
- MSF timestamp conversion: `03:25:50` → correct Duration
- MSF edge cases: `00:00:00`, `99:59:74`

**Time derivation:**
- End times derived from next track's INDEX 01
- Last track has null end time
- Duration calculation (end - start)

**PREGAP / POSTGAP:**
- PREGAP parsed as Duration
- POSTGAP parsed as Duration

**FILE handling:**
- Single FILE with multiple tracks
- Multiple FILE commands — tracks grouped correctly
- File type detection (WAVE, MP3, AIFF, BINARY, MOTOROLA)
- Quoted filenames with spaces

**REM comments:**
- REM UPC, REM BARCODE, REM DISCNUMBER
- REM GENRE, REM DATE, REM YEAR
- REM DISCID
- Custom REM fields exposed in map
- Case-insensitive REM key matching

**Encoding:**
- UTF-8 content parses correctly
- Latin-1 content (non-ASCII artist/track names) parses correctly
- Bytes API with explicit encoding

**Real-world CUE sheets:**
- EAC-generated CUE (Windows line endings, typical formatting)
- XLD-generated CUE (Unix line endings)
- foobar2000-generated CUE
- Multi-disc CUE with DISCNUMBER

**Round-trip (writer):**
- Parse → write → re-parse produces equivalent CueSheet
- Writer output matches expected CUE format

**Error tolerance:**
- Missing PERFORMER/TITLE → null fields, not failure
- Track without INDEX 01 → startTime is null
- Unrecognised commands → ignored, no crash
- Mixed case commands (TRACK, Track, track) → all parsed

### Integration Tests
- `parseCueFile` reads from disk (temp file)
- `parseCueFile` returns null for non-existent path

### CLI Tests (if CLI included)
- `cueinfo path/to/file.cue` → JSON output
- `cueinfo --format text` → human-readable output
- Non-existent file → exit code 2

## Verification

1. `dart test` — all tests pass
2. `dart analyze` — no warnings
3. `dart doc` — generates clean API documentation
4. Manual: parse a real EAC-generated CUE sheet and verify all fields
5. Manual: parse a real XLD-generated CUE sheet and verify all fields
6. Round-trip: parse → toCueString → re-parse → compare
