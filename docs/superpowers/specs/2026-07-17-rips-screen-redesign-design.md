# Rip Library Screen Redesign — Design

**Date:** 2026-07-17
**Author:** Paul Snow
**Source design:** claude.ai/design project `ecec9774-d658-446f-bc0d-81d46538af09`, file `Media Scanner Themed.dc.html` ("Desktop · Rip Library — quality & playback" frame)

## Goal

Restyle the desktop Rip Library screen to match the new themed design: a health-first
layout with stat cards, status filter chips, richer album cards, and a redesigned
detail panel — while keeping every existing feature (table mode, multi-select batch
analysis, tag editing, playback queue, GNUDB lookup, collection linking) functional.
Secondarily, audit the other screens shown in the design (desktop Library, Insights,
mobile Dashboard/Library/Scanner/Item Detail/Appearance) and fix small cosmetic gaps.

## Approach

Restyle in place with new composable widgets (approach A). New pieces are built in
`lib/presentation/screens/rips/widgets/` and wired into the existing
`rip_library_view.dart` structure. One new derived-status provider supplies the
health model. No behavioural rewiring.

Rejected alternatives:

- **Parallel v2 screen + switchover** — duplicates ~1,100 lines of behaviour wiring
  and invites regressions in features the design doesn't show.
- **Minimal reskin** — colours/spacing only; fails to deliver the health model that
  is the design's core addition.

## 1. Typography foundation

- Bundle **Space Grotesk** (400–700) and **JetBrains Mono** (400–800) in
  `assets/fonts/` and register in `pubspec.yaml` (fonts are always bundled, never
  fetched at runtime).
- Extend `AppTypography` with opt-in helpers:
  - `displayTitle` — Space Grotesk, tight tracking; screen and card titles.
  - `monoLabel` — JetBrains Mono, uppercase, letterspaced; eyebrows, section
    labels, chips.
  - `monoNumeric` — JetBrains Mono, tight tracking; stat values.
- `AppTypography.displayNumeric()` switches its family to Space Grotesk (the
  in-code comment already anticipates this).
- **No app-wide `textTheme` family swap.** Classic and Popcorn keep their current
  identities; the new styles are applied per widget, starting with the rips screen.

## 2. Album health model

New derived provider `ripAlbumHealthProvider` classifying each album from its
tracks (`RipTrack` fields: `qualityCheckedAt`, `accurateRipStatus`,
`accurateRipConfidence`, defect counts):

| Status | Rule (first match wins) |
|---|---|
| `notAnalysed` | no track has `qualityCheckedAt` |
| `mismatch` | any track `accurateRipStatus == 'mismatch'` |
| `attention` | any track `totalDefects > 0`, or not all analysed tracks AR-verified |
| `verified` | all tracks AR-verified with zero defects |

Aggregate provider `ripLibraryHealthStatsProvider`:

- count of albums per status,
- AR coverage % = AR-verified tracks ÷ total tracks across the library,
- total library size in bytes.

Status colours map through the existing theme: verified → `mediaColors.book`,
attention → amber (`mediaColors.tv` family, as `QualityIcon` already does),
mismatch → `colorScheme.error` / `mediaColors.film`, notAnalysed → neutral.

Classification logic is implemented TDD (tests first).

## 3. Library view header

- `ScreenHeader` usage gains the eyebrow treatment: "FLAC RIP COLLECTION" in
  `monoLabel` accent colour above the "Rip Library" title (`displayTitle`).
- Right side: four compact stat cards — **Verified**, **Attention**,
  **AR coverage**, **Total size** — uppercase `monoLabel` captions and
  `monoNumeric` values; attention value tinted amber, size value tinted accent.
- Below the header: **status filter chips** — All / Verified / Needs attention /
  Mismatch / Not analysed — each with a colour dot and live count. The selected
  chip filters **both** the grid and the table view. Selection state lives in a
  small provider so grid/table share it.
- Existing toolbar (search field, Scan Library, Analyse all, grid/table toggle,
  Auto Play switch) is retained and restyled to the design's shapes (pill radii,
  tonal fills); Library/Coverage/Playlists segments stay in place.

## 4. Album cards

Redesigned `_RipAlbumCard`:

- 58 px `RipCoverThumb`, uppercase mono artist eyebrow, Space Grotesk album title.
- Status pill top-right (VERIFIED / ATTENTION / MISMATCH / NOT ANALYSED) with icon,
  soft tinted background.
- Meta row: track count · total size · total duration (sum of `durationMs`).
- **AccurateRip progress bar**: verified/total with `x / n` caption, bar colour by
  status.
- Chip row: format chip (`FLAC` / `MP3` from file extension), defects chip
  (`0 defects` green or `n clicks · n pops…` amber summary), `CUE + LOG` chip when
  `cueFilePath` present / any `ripLogSource` set. Unanalysed albums instead show an
  inline **Analyse** action chip.
- Selection-mode checkbox, playing indicator, and collection-link icon retained.
- Grid sizing adjusts to the richer card (wider min extent, taller ratio).

**Simplification:** the mock's "FLAC 16/44.1" sample rate is not persisted on
`RipTrack`; v1 shows the format only. Persisting sample rate/bit depth at scan time
(schema migration) is a deferred follow-up.

## 5. Detail panel

Restyle existing `_RipAlbumDetailPanel` (no behaviour changes):

- Header: 76 px cover, artist eyebrow, title, status pill including `AR x/n`, close
  button; edit and GNUDB actions retained.
- Transport: existing `InlinePlayerControls` restyled as the tonal "now playing"
  card (track title, mono `TRACK nn · NOW PLAYING` caption, progress, transport
  buttons with accent circular play/pause).
- Scrollable region below:
  - **Quality report** 2×2 grid — Quality score (avg `trackQuality`),
    AR confidence (minimum `accurateRipConfidence` among AR-verified tracks — the weakest link), Peak level (max `peakLevel`, dB),
    Defects (library totals for the album).
  - **Source** rows — Ripped with (`ripLogSource`), CUE + LOG presence,
    GNUDB disc ID.
  - **Tracks** list — status icon, mono track number, title, `AR n` confidence,
    duration; accent-tinted now-playing row; tap-to-play retained.
- Edit mode (inline tag editor) and collection-link section stay as-is
  functionally, restyled to match.

## 6. Other screens — audit + small fixes

Compare against the design frames and fix **cosmetic drift only**:

- Desktop Library (grid, chips, stat cards), Desktop Insights (stat cards, chart
  labels), Mobile Dashboard / Library / Scanner / Item Detail / Appearance.
- In scope: chip shapes, label casing, stat-card caption/value styling where those
  widgets already exist.
- Out of scope (report only): structural changes, the mock's sidebar "Rip health"
  legend and user-profile footer (design fiction — the app sidebar is shared
  navigation), any new screens.
- Deliverable: a short discrepancy table — fixed vs deferred.

## 7. Error handling

- Health classification treats missing/unknown `accurateRipStatus` strings as
  "analysed but unverified" (→ attention), never as mismatch.
- Albums with zero tracks classify as `notAnalysed`; duration/size render as `—`.
- Stats provider guards division by zero (empty library → 0 % coverage).

## 8. Testing

- Unit tests (written first) for health classification and aggregate stats.
- Widget tests: status chips filter the album list; card shows correct pill per
  status; stat cards render counts.
- Full `flutter test` suite stays green.
- Manual smoke via Marionette on macOS: Kinetic/Vault/Index × light/dark, grid and
  table modes, playback transport, edit mode, batch analysis.

## Success criteria

1. Rips Library view visually matches the design frame across the three designed
   palettes (both brightnesses) while remaining coherent in Classic/Popcorn.
2. All pre-existing rips features still work (table, selection, batch analysis,
   tag editing, queue, GNUDB, linking, playback).
3. New health chips/stats reflect real track data and update after analysis runs.
4. `flutter test` passes; new logic is covered by tests.
5. Discrepancy table delivered for the audited screens with small gaps fixed.
