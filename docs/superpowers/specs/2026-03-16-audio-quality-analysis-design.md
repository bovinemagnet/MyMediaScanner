# Audio Quality Analysis + AccurateRip — Design Spec (Phase B)

**Date:** 2026-03-16
**Status:** Approved
**Platforms:** Desktop only (macOS, Windows, Linux)
**Depends on:** Phase A (Rip Library Scanner) complete

---

## 1. Overview

Add audio quality verification for ripped FLAC files. Three-tier analysis: parse rip log files first (cheapest), query AccurateRip database second, and run statistical click/pop detection as a final fallback. Results displayed per-track on the item detail screen.

---

## 2. Analysis Pipeline

For each track in a rip album, execute in order (stop at first conclusive result):

```
1. Check rip log file (.log in album directory)
   ├─ "Accurately ripped" → VERIFIED (store confidence, CRC, peak, quality)
   ├─ "Cannot be verified" / "Not present in database" → continue to step 2
   └─ No log file → continue to step 2

2. AccurateRip database query
   ├─ Decode FLAC → PCM via `flac -d -c -f track.flac`
   ├─ Compute AR v1 + v2 CRCs from PCM data
   ├─ Query http://www.accuraterip.com/accuraterip/[discId]
   ├─ CRC match → VERIFIED (store confidence)
   ├─ CRC mismatch → MISMATCH (flag for attention)
   └─ Disc not in database → continue to step 3

3. Click/pop detection (statistical)
   ├─ Analyse PCM samples from step 2 (reuse decoded data)
   ├─ Sliding window amplitude analysis
   ├─ No clicks detected → CLEAN
   └─ Clicks detected → CLICKS_FOUND (store count + timestamps)
```

All audio decoding and analysis runs in a separate isolate via `Isolate.run()`.

---

## 3. Rip Log Parser

**Location:** `lib/core/utils/rip_log_parser.dart`

**Supported formats:**

### EAC (Exact Audio Copy)
```
Track  1

     Filename Z:\CD\Various\Album\01. Track.wav

     Peak level 96.2 %
     Track quality 99.8 %
     Copy CRC 882B01BE
     Accurately ripped (confidence 1)  [F4E2268A]
     Copy OK
```

### XLD (X Lossless Decoder)
```
Track 01
  Filename : /path/to/01 Track.flac
  Pre-gap length : 00:00:00

  CRC32 hash               : 882B01BE
  AccurateRip v1 signature : F4E2268A
  AccurateRip v2 signature : A1B2C3D4
    ->Accurately ripped (v1+v2, confidence 3/3)
  Statistics
    Read error                           : 0
    Jitter error (maybe fixed)           : 0
    Peak level                           : 96.2 %
    Track quality                        : 100.0 %
```

**Parser output per track:**

```dart
class RipLogTrackResult {
  final int trackNumber;
  final String? filename;
  final double? peakLevel;        // 0.0–1.0
  final double? trackQuality;     // 0.0–1.0
  final String? copyCrc;          // hex string
  final String? accurateRipCrc;   // hex string
  final bool accuratelyRipped;
  final int? arConfidence;
  final String? logSource;        // 'EAC', 'XLD'
}
```

**Parser logic:**
- Detect format from log content (EAC logs contain "Exact Audio Copy", XLD logs contain "X Lossless Decoder")
- Split into per-track sections (regex on `Track\s+\d+`)
- Extract fields via regex patterns per format
- Return `List<RipLogTrackResult>`

---

## 4. AccurateRip Integration

**Location:** `lib/data/remote/api/accuraterip/accuraterip_client.dart`

### Disc ID Computation

AccurateRip identifies discs using three values computed from the CD's table of contents (track offsets in sectors, where 1 sector = 588 stereo samples = 1/75 second):

**Track offsets:** Derive from FLAC metadata. Track 1 starts at sector 0 (after the standard 150-sector lead-in, which AccurateRip accounts for by adding 150 to each offset). For subsequent tracks, cumulate: `offset[n] = offset[n-1] + (totalSamples[n-1] / 588)`. The lead-out offset = last track offset + last track's sector count.

**discId1:** `sum(trackOffset[i] + 150)` for all tracks, plus the lead-out offset + 150.

**discId2:** `sum((trackOffset[i] + 150) × (i + 1))` for all tracks (1-indexed), plus `(leadOutOffset + 150) × (trackCount + 1)`.

**cddbDiscId (CDDB/FreeDB):**
```
For each track: seconds = (offset + 150) / 75; digitSum = sum of decimal digits of seconds
n = sum of all digitSums
t = (leadOutOffset + 150) / 75 - (firstTrackOffset + 150) / 75  (total disc length in seconds)
cddbDiscId = ((n % 0xFF) << 24) | (t << 8) | trackCount
```

**Partial rips:** If only some tracks were ripped (e.g. a compilation where you skipped some), the disc ID computation will be incorrect and the AccurateRip lookup will return no match. This is expected — the implementation should treat it as `not_found`, not as an error.

### CRC Computation

**Location:** `lib/core/utils/accuraterip_crc.dart`

**Sample packing:** Read the raw PCM stream (16-bit signed LE, stereo interleaved) as sequential little-endian uint32 values. Each uint32 naturally packs as `left_16bit | (right_16bit << 16)` — no manual bit manipulation needed.

**AccurateRip v1 CRC:**
```
uint32 crc = 0
// i is zero-based index into the uint32 sample stream
// multiplier is (i + 1), i.e. 1-based, starting from the first NON-SKIPPED sample
for each uint32 sample at index i (after skip region):
  crc += (uint32)(sample * (i + 1))   // 32-bit overflow wraps naturally
```
For the first track on the disc: skip the first 5 × 588 = 2940 uint32 samples.
For the last track on the disc: skip the last 5 × 588 = 2940 uint32 samples.
The multiplier `(i + 1)` counts from 1 starting at the first non-skipped sample.

**AccurateRip v2 CRC:**
```
uint32 crc = 0
for each uint32 sample at index i (after skip region):
  uint64 mult = (uint64)sample * (uint64)(i + 1)   // 64-bit multiply
  crc += (uint32)(mult & 0xFFFFFFFF) + (uint32)(mult >> 32)  // fold upper 32 bits back
```
Same first/last track skip rules. In Dart, `int` is 64-bit so compute as: `int mult = sample * (i + 1); crc = (crc + (mult & 0xFFFFFFFF) + ((mult >> 32) & 0xFFFFFFFF)) & 0xFFFFFFFF;`

### HTTP Query

```
GET http://www.accuraterip.com/accuraterip/{a}/{b}/{c}/dBAR-{trackCount}-{discId1:08x}-{discId2:08x}-{cddbDiscId:08x}.bin
```

Where `{a}` = last hex char of discId1, `{b}` = second-to-last + last of discId1, `{c}` = third-to-last + second-to-last + last of discId1.

**Response binary format:**

The response contains one or more "chunks", each representing a different pressing of the disc:

```
Per chunk:
  trackCount     (1 byte)
  discId1        (4 bytes, LE uint32)
  discId2        (4 bytes, LE uint32)
  cddbDiscId     (4 bytes, LE uint32)
  Per track (trackCount entries):
    confidence   (1 byte)
    crcV1        (4 bytes, LE uint32)
    crcV2        (4 bytes, LE uint32)
```

Chunks repeat until end of file. Multiple chunks = multiple pressings of the same disc.

Match our computed v1 CRC against each chunk's `crcV1` per track, and v2 CRC against `crcV2`. If either matches, the track is verified with the corresponding confidence count. Prefer v2 matches (more reliable).

**Client class:**

```dart
class AccurateRipClient {
  Future<AccurateRipDiscResult?> queryDisc(AccurateRipDiscId discId);
}

class AccurateRipDiscId {
  final int discId1;
  final int discId2;
  final int cddbDiscId;
  final int trackCount;
}

class AccurateRipDiscResult {
  final List<AccurateRipTrackResult> tracks;
}

class AccurateRipTrackResult {
  final int trackNumber;
  final List<AccurateRipEntry> entries; // multiple pressings
}

class AccurateRipEntry {
  final int confidence;
  final int crcV1;
  final int crcV2;
}
```

---

## 5. Click/Pop Detection

**Location:** `lib/core/utils/click_detector.dart`

**Algorithm (statistical amplitude analysis):**

1. Read PCM samples as 16-bit signed integers
2. Slide a window of 1024 samples across the data, advancing by 512 (50% overlap)
3. For each window, compute local RMS: `sqrt(sum(sample²) / windowSize)`
4. For each sample in the window, if `|sample| > threshold × localRMS`, flag as a click candidate
5. Skip samples where `localRMS < silenceThreshold` (avoid false positives in silent passages)
6. Merge adjacent detections within 4410 samples (100ms at 44.1kHz) into a single click event
7. Return list of click events with timestamp (ms) and severity (spike/RMS ratio)

**Parameters:**
- `threshold` — default 8.0, configurable in settings (range 4.0–16.0)
- `silenceThreshold` — fixed at 100 (absolute sample value RMS below which we skip)
- `windowSize` — 1024 samples
- `mergeDistanceSamples` — 4410 (100ms at 44.1kHz)

**Output:**

```dart
class ClickDetectionResult {
  final int clickCount;
  final List<ClickEvent> clicks;
  final double peakLevel; // 0.0–1.0, computed from max |sample| / 32767
}

class ClickEvent {
  final int timestampMs;
  final double severity; // ratio of spike amplitude to local RMS
}
```

---

## 6. FLAC Decoding

**Location:** `lib/core/utils/flac_decoder.dart`

Wraps the `flac` CLI tool:

```dart
class FlacDecoder {
  /// Decode a FLAC file to raw PCM bytes (16-bit signed LE, stereo).
  /// Returns the raw bytes or throws if flac is not installed or decode fails.
  Future<Uint8List> decode(String flacFilePath);

  /// Check if the flac CLI is available on PATH.
  Future<bool> isAvailable();

  /// Get the flac binary path (default: 'flac', overridable in settings).
  String get binaryPath;
}
```

Implementation: `Process.run('flac', ['-d', '-c', '-f', '--force-raw-format', '--endian=little', '--sign=signed', filePath])` capturing stdout as bytes.

The `--force-raw-format` flag ensures we get headerless raw PCM (no WAV header to skip).

---

## 7. Data Model Changes

Add columns to `rip_tracks` table (Drift migration, schema version 5):

| Column | Type | Description |
|---|---|---|
| `accuraterip_status` | TEXT | `verified`, `not_found`, `mismatch`, `not_checked` |
| `accuraterip_confidence` | INTEGER | AR confidence count (null if not verified) |
| `accuraterip_crc` | TEXT | Hex string of matching CRC |
| `peak_level` | REAL | 0.0–1.0 |
| `track_quality` | REAL | 0.0–1.0 (from rip log) |
| `copy_crc` | TEXT | CRC from rip log |
| `click_count` | INTEGER | Number of detected clicks |
| `rip_log_source` | TEXT | 'EAC', 'XLD', or null |
| `quality_checked_at` | INTEGER | Unix ms timestamp of last quality check |

---

## 8. DAO and Entity Updates

### RipTrack Entity Update

Update `lib/domain/entities/rip_track.dart` (@freezed) to add:
- `accurateRipStatus` (String?) — `verified`, `not_found`, `mismatch`, `not_checked`
- `accurateRipConfidence` (int?)
- `accurateRipCrc` (String?)
- `peakLevel` (double?)
- `trackQuality` (double?)
- `copyCrc` (String?)
- `clickCount` (int?)
- `ripLogSource` (String?)
- `qualityCheckedAt` (int?)

### DAO Update

Add to `RipLibraryDao`:
- `updateTrackQuality(String trackId, {...fields})` — updates quality-related columns
- `getTracksWithQualityForAlbum(String ripAlbumId)` — returns tracks with all quality fields

Update `RipLibraryRepositoryImpl` mapper to include the new fields in both directions.

---

## 9. Use Cases

Note: All internal data transfer objects (`RipLogTrackResult`, `ClickDetectionResult`, `ClickEvent`, `QualityAnalysisProgress`, AccurateRip model classes) are plain Dart classes, not Freezed — they are ephemeral DTOs, not persisted domain entities.

### AnalyseRipQualityUseCase

**Location:** `lib/domain/usecases/analyse_rip_quality_usecase.dart`

Takes a `ripAlbumId`. For each track in the album:

1. Check for `.log` file in the album directory (parse with `RipLogParser`)
2. If log provides AR verification → update track, done
3. If not → check `flac` availability, decode track
4. Compute AccurateRip disc ID from all track durations
5. Query AccurateRip database
6. If AR match → update track, done
7. If no AR match → run click detection on the decoded PCM
8. Update track with results

**Progress reporting:** Yields `Stream<QualityAnalysisProgress>`:
```dart
class QualityAnalysisProgress {
  final int currentTrack;
  final int totalTracks;
  final String currentStep; // 'Parsing log', 'Decoding', 'Checking AccurateRip', 'Detecting clicks'
}
```

**Isolate boundary:** CPU-intensive work (FLAC decoding via Process.run, CRC computation, click detection) runs in an isolate via `Isolate.run()`. The orchestration and HTTP calls stay on the main isolate. Flow: main isolate decodes FLAC in isolate → gets PCM bytes back → computes disc ID in isolate → gets CRCs back → main isolate calls AccurateRip HTTP → if no match, sends PCM bytes to isolate for click detection → gets results back. Dio cannot cross isolate boundaries.

**Memory:** Decode and analyse one track at a time to bound memory usage (~50 MB for a 5-minute track). Do not hold multiple tracks' PCM data simultaneously.

---

## 10. Presentation

### Item Detail — Enhanced Rip Status

Extend the existing rip status section for music items. When quality has been checked, show per-track:

| Icon | Status | Detail |
|---|---|---|
| Green checkmark | AR Verified | "AccurateRip verified (confidence 12)" |
| Green checkmark | AR Verified (log) | "Verified via EAC log (confidence 1)" |
| Green checkmark | Clean | "No issues detected" |
| Amber warning | Clicks found | "3 clicks detected" — expandable to show timestamps |
| Red cross | AR Mismatch | "AccurateRip CRC mismatch — consider re-ripping" |
| Grey dash | Not checked | "Not yet analysed" |

Additional track info when expanded:
- Peak level (as percentage)
- Track quality (from log, if available)
- CRC values

**"Check Quality" button** on the rip status section header. Shows per-track progress during analysis.

### Settings

Add to existing FLAC Library section (desktop only):
- `flac` binary path override (text field, default empty = use PATH)
- Click detection threshold slider (4.0–16.0, default 8.0)
- Both stored in secure storage

---

## 11. Providers

All hand-written (no riverpod_generator).

- `qualityAnalysisNotifierProvider` — Notifier managing analysis state (idle/analysing/complete) with progress stream per album
- `flacDecoderProvider` — Provider returning FlacDecoder instance (reads binary path from settings)
- `accurateRipClientProvider` — Provider returning AccurateRipClient (uses Dio)
- `clickDetectionThresholdProvider` — reads from secure storage, default 8.0

---

## 12. Testing

### Rip Log Parser
- EAC format: fixture string with 3 tracks, verify all fields extracted
- XLD format: fixture string, verify field extraction
- Mixed results: one track verified, one "cannot be verified", verify correct parsing
- Malformed log: graceful failure returning empty list

### AccurateRip CRC
- Unit test with known PCM byte sequence and pre-computed expected CRC v1 and v2
- Test first-track skip behaviour (2940 samples)
- Test last-track skip behaviour

### Click Detection
- Clean sine wave (44100 Hz, 1 second, 16-bit) → 0 clicks
- Sine wave with 3 injected spikes at known positions → 3 clicks at correct timestamps
- Silence → 0 clicks, no false positives
- Clipping (samples at ±32767) → detected as clicks

### FLAC Decoder
- Integration test: decode a real minimal FLAC file, verify PCM output length matches expected sample count
- Test missing `flac` binary: returns clear error

### Analysis Pipeline
- Mock flac decoder, mock AR client, mock log parser
- Test: log provides verification → no decode needed
- Test: no log, AR matches → verified without click detection
- Test: no log, no AR → falls through to click detection

---

## 13. Dependencies

No new pub dependencies. Uses:
- `dart:io` Process for `flac` CLI
- `dart:typed_data` for PCM byte manipulation
- Existing `Dio` for AccurateRip HTTP query
- `Isolate.run()` for background processing

---

## 14. Out of Scope

- Automatic re-ripping
- Audio waveform visualisation (could be Phase C)
- Support for non-FLAC formats (WAV, ALAC, MP3)
- Editing/repairing detected clicks
- AccurateRip submission (uploading our CRCs to the database)
