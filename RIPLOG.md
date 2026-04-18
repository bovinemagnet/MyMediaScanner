# Product Plan: `dart_rip_log` — Pure Dart Rip Log Parser

## Problem

There is no rip log parser available on [pub.dev](https://pub.dev) for the Dart ecosystem. CD ripping tools (EAC, XLD, CUERipper, dBpoweramp, Whipper) generate log files containing per-track quality metrics — AccurateRip verification, CRC checksums, peak levels, error counts, and drive information. Any Dart/Flutter application assessing rip quality needs to parse these files.

## Product Vision

A pure Dart library that parses rip log files from all major CD ripping tools into structured quality data. Zero dependencies beyond the Dart SDK. Provides a unified data model regardless of which tool generated the log.

## Target Users

- Developers building media library/collection apps with quality tracking
- Audio archival tool developers
- CD rip verification and cataloguing tools
- Music server/player apps that display rip quality metadata

## Package Details

- **Name:** `dart_rip_log`
- **Repository:** `github.com/bovinemagnet/dart_rip_log`
- **Licence:** GPL v3 (consistent with `dart_accuraterip`, `audio_defect_detector`, and `dart_cue`)
- **SDK constraint:** `>=3.5.0 <4.0.0`
- **Dependencies:** None (pure Dart)
- **Author:** Paul Snow
- **Version:** 0.0.1

## Supported Log Formats

### Must Have (v0.0.1)
| Tool | Platform | Detection String |
|------|----------|-----------------|
| **EAC** (Exact Audio Copy) | Windows | `Exact Audio Copy` |
| **XLD** (X Lossless Decoder) | macOS | `X Lossless Decoder` |

### Should Have (v0.1.0)
| Tool | Platform | Detection String |
|------|----------|-----------------|
| **CUERipper** | Windows | `CUERipper` |
| **Whipper** | Linux | `whipper` |
| **dBpoweramp** | Windows/macOS | `dBpoweramp` |

### Could Have (future)
| Tool | Platform | Notes |
|------|----------|-------|
| **fre:ac** | Cross-platform | Less common, simpler logs |
| **cdparanoia** | Linux | Raw output, less structured |

## Data Models

### `RipLog`

Top-level result from parsing a complete log file.

```
- logFormat: RipLogFormat (eac, xld, cueRipper, whipper, dbPoweramp)
- toolVersion: String? (e.g. "V1.6", "20230916 (153.8)")
- extractionDate: DateTime?
- drive: DriveInfo?
- readMode: String? (e.g. "Secure", "Paranoid", "Burst")
- readOffset: int? (read offset correction in samples)
- overread: bool? (whether overread into lead-in/lead-out was used)
- gapHandling: String? (e.g. "Appended to previous track")
- mediaType: String? (e.g. "Pressed CD", "CD-R")
- tracks: List<RipLogTrack>
- accurateRipSummary: String? (e.g. "All tracks accurately ripped")
- integrityHash: String? (EAC/XLD log signature hash)
- errors: List<String> (any parsing warnings)
```

### `DriveInfo`
```
- name: String (e.g. "ASUS BW-16D1HT")
- readOffset: int? (drive offset)
- adapter: String? (e.g. "ATAPI")
```

### `RipLogTrack`

Per-track quality data — unified across all log formats.

```
- trackNumber: int
- filename: String?
- peakLevel: double? (0.0–1.0)
- trackQuality: double? (0.0–1.0)
- copyCrc: String? (hex CRC32)
- testCrc: String? (hex CRC32 from test pass, EAC only)
- accurateRipStatus: AccurateRipStatus (verified, mismatch, notInDatabase, notChecked)
- accurateRipCrcV1: String? (hex)
- accurateRipCrcV2: String? (hex)
- accurateRipConfidence: int?
- copyOk: bool (whether the tool reported copy success)
- errors: TrackErrors
- logFormat: RipLogFormat (which tool produced this track entry)
```

### `TrackErrors`

Error counts reported by the ripper.

```
- readErrors: int (default 0)
- skipErrors: int (default 0)
- jitterErrors: int (default 0)
- edgeJitterErrors: int (default 0)
- atomJitterErrors: int (default 0)
- driftErrors: int (default 0)
- droppedBytes: int (default 0)
- duplicatedBytes: int (default 0)
- inconsistentErrorSectors: int (default 0)
- damagedSectors: int (default 0)
- hasErrors: bool (convenience: any count > 0)
```

### Enums
```
RipLogFormat { eac, xld, cueRipper, whipper, dbPoweramp, unknown }

AccurateRipStatus { verified, mismatch, notInDatabase, notChecked }
```

## Public API

### Parsing
```dart
/// Parse a rip log from its string content.
/// Auto-detects the log format from content signatures.
RipLog parseRipLog(String content);

/// Parse a rip log from a file path.
Future<RipLog> parseRipLogFile(String filePath);

/// Detect which tool generated this log without full parsing.
RipLogFormat detectLogFormat(String content);
```

### Convenience
```dart
/// Returns true if all tracks were accurately ripped.
bool isFullyVerified(RipLog log);

/// Returns tracks that have any errors.
List<RipLogTrack> tracksWithErrors(RipLog log);

/// Returns tracks that failed AccurateRip verification.
List<RipLogTrack> tracksWithArMismatch(RipLog log);
```

### Serialisation
```dart
/// Convert RipLog to JSON map.
Map<String, dynamic> toJson(RipLog log);
```

## Architecture

```
lib/
  dart_rip_log.dart              → Public API exports
  src/
    models.dart                  → RipLog, RipLogTrack, TrackErrors, enums
    parser.dart                  → Format detection + dispatch
    parsers/
      eac_parser.dart            → EAC-specific parsing
      xld_parser.dart            → XLD-specific parsing
      cue_ripper_parser.dart     → CUERipper parsing (v0.1.0)
      whipper_parser.dart        → Whipper parsing (v0.1.0)
      dbpoweramp_parser.dart     → dBpoweramp parsing (v0.1.0)
    file_reader.dart             → File I/O helper
    utils.dart                   → Shared regex helpers, percentage parsing
bin/
  riplog.dart                    → Optional CLI tool (print parsed log as JSON/text)
```

The parser architecture should make it trivial to add new log formats — each format gets its own parser file implementing a common internal interface.

## Existing Code to Migrate

Source: `MyMediaScanner/lib/core/utils/rip_log_parser.dart` (186 lines)

What to keep:
- Section splitting by `Track N` pattern
- Regex field extraction approach
- EAC and XLD parsing logic (the regex patterns are proven correct)
- Percentage-to-fraction conversion (`/ 100`)

What to change:
- Expand `RipLogTrackResult` → `RipLogTrack` with richer fields (test CRC, AR v1/v2 separate, error counts)
- Add top-level `RipLog` with drive info, extraction date, tool version
- Parse header sections (before first track) for drive/settings info
- Parse error statistics sections (EAC: "Read error", XLD: "Statistics" block)
- Separate AR v1 and v2 CRCs (currently only v1 from XLD, only combined from EAC)
- Parse `Copy OK` / `Copy finished` status
- Parse test CRC (EAC "Test CRC" field when test+copy mode is used)
- Add format detection as a separate function
- Structured `TrackErrors` instead of ignoring error lines
- Remove `dart:io` dependency from parser (keep in separate file_reader)

## EAC Log Sections to Parse

```
Header:
  "Exact Audio Copy V1.6 from 23. October 2019"  → toolVersion
  "EAC extraction logfile from 15. March 2026"    → extractionDate
  "Used drive  : ASUS BW-16D1HT"                 → drive.name
  "Read mode   : Secure"                          → readMode
  "Read offset correction : 6"                    → readOffset
  "Overread into Lead-In and Lead-Out : No"       → overread
  "Gap handling : Appended to previous track"     → gapHandling

Per track:
  "Track  1"                                       → trackNumber
  "Filename ..."                                   → filename
  "Peak level 96.2 %"                              → peakLevel
  "Track quality 99.8 %"                           → trackQuality
  "Test CRC 882B01BE"                              → testCrc
  "Copy CRC 882B01BE"                              → copyCrc
  "Accurately ripped (confidence 1)  [F4E2268A]"   → AR status + confidence + CRC
  "Cannot be verified as accurate  [12345678]"     → AR notInDatabase
  "Track not present in AccurateRip database"      → AR notInDatabase
  "Copy OK"                                        → copyOk

Footer:
  "All tracks accurately ripped"                   → accurateRipSummary
  "End of status report"
  Log checksum line (if present)                   → integrityHash
```

## XLD Log Sections to Parse

```
Header:
  "X Lossless Decoder version 20230916 (153.8)"   → toolVersion
  "XLD extraction logfile from 2026-03-15 ..."     → extractionDate
  "Used drive : ..."                               → drive.name
  "Read offset correction : 6"                     → readOffset
  "Gap status : ..."                               → gapHandling

Per track:
  "Track 01"                                       → trackNumber
  "Filename : ..."                                 → filename
  "CRC32 hash               : 882B01BE"            → copyCrc
  "AccurateRip v1 signature : F4E2268A"             → accurateRipCrcV1
  "AccurateRip v2 signature : A1B2C3D4"             → accurateRipCrcV2
  "->Accurately ripped (v1+v2, confidence 3/3)"     → AR status + confidence
  "->NOT verified as accurate ..."                  → AR mismatch
  "->Track not present in AccurateRip database"     → AR notInDatabase
  Statistics block:
    "Read error                           : 0"     → errors.readErrors
    "Jitter error (maybe fixed)           : 0"     → errors.jitterErrors
    "Retry sector count                   : 0"
    "Damaged sector count                 : 0"     → errors.damagedSectors
    "Peak level                           : 96.2 %" → peakLevel
    "Track quality                        : 100.0 %" → trackQuality
```

## Test Plan

### Unit Tests (from string parsing — no I/O)

**Format detection:**
- EAC log → `RipLogFormat.eac`
- XLD log → `RipLogFormat.xld`
- Unknown content → `RipLogFormat.unknown`
- Empty string → `RipLogFormat.unknown`

**EAC parsing — header:**
- Tool version extracted
- Extraction date parsed to DateTime
- Drive name extracted
- Read mode extracted
- Read offset extracted
- Gap handling extracted

**EAC parsing — tracks:**
- Track number extraction
- Filename extraction (with backslash paths)
- Peak level as fraction (96.2% → 0.962)
- Track quality as fraction (99.8% → 0.998)
- Copy CRC hex string
- Test CRC hex string (when test+copy mode)
- AccurateRip verified with confidence and CRC
- AccurateRip "Cannot be verified" → mismatch
- AccurateRip "not present in database" → notInDatabase
- Copy OK status
- Multiple tracks parsed in order

**EAC parsing — footer:**
- AccurateRip summary extracted
- Log checksum/integrity hash extracted (if present)

**XLD parsing — header:**
- Tool version extracted (with build number)
- Extraction date parsed to DateTime
- Drive name extracted
- Read offset extracted

**XLD parsing — tracks:**
- Track number extraction
- Filename extraction (with forward slash paths)
- CRC32 hash
- AR v1 signature (separate from v2)
- AR v2 signature (separate from v1)
- AR verification with confidence (v1, v2, v1+v2 variants)
- Statistics block: read errors, jitter errors, damaged sectors
- Peak level and track quality
- Multiple tracks parsed in order

**XLD parsing — AR status variants:**
- `->Accurately ripped (v1+v2, confidence 3/3)` → verified, confidence 3
- `->Accurately ripped (v1, confidence 5/5)` → verified, confidence 5
- `->Accurately ripped (v2, confidence 2/4)` → verified, confidence 2
- `->NOT verified as accurate` → mismatch
- `->Track not present in AccurateRip database` → notInDatabase

**Convenience functions:**
- `isFullyVerified` with all-verified log → true
- `isFullyVerified` with one mismatch → false
- `tracksWithErrors` returns only tracks with non-zero error counts
- `tracksWithArMismatch` returns only mismatched tracks

**Error tolerance:**
- Truncated log (header only, no tracks) → RipLog with empty tracks list
- Missing fields → null, not failure
- Garbled lines → skipped, not crash
- Windows line endings (CRLF) → parsed correctly
- Unix line endings (LF) → parsed correctly
- Mixed line endings → parsed correctly

**Real-world logs:**
- Full EAC log from a real rip (multi-track, mixed AR results)
- Full XLD log from a real rip (multi-track, statistics blocks)
- EAC log with test+copy mode (both Test CRC and Copy CRC)
- Log with tracks having read errors

**Serialisation:**
- `toJson` produces valid JSON with all fields
- Round-trip: parse → toJson → verify structure

### Integration Tests
- `parseRipLogFile` reads from disk (temp file)
- `parseRipLogFile` throws for non-existent path

### CLI Tests (if CLI included)
- `riplog path/to/file.log` → JSON output
- `riplog --format text` → human-readable summary
- `riplog --summary` → one-line per track (number, AR status, quality)
- Non-existent file → exit code 2

## Verification

1. `dart test` — all tests pass
2. `dart analyze` — no warnings
3. `dart doc` — generates clean API documentation
4. Manual: parse a real EAC log and verify all fields match the log content
5. Manual: parse a real XLD log and verify all fields match the log content
6. Compare: ensure the library produces equivalent results to the current inline parser for the same test logs
