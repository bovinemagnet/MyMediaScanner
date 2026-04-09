# Rips/Audio Player Enhancements — Design Spec

**Date:** 2026-04-09
**Author:** Paul Snow
**Version:** 0.0.0

## Overview

Four enhancement areas for the rips/audio player: queue & playlists, playback features (ReplayGain + speed control), batch operations, and bidirectional collection integration. All features are desktop-only (rips screen is desktop-only).

---

## 1. Queue & Playlists

### 1.1 Session Queue

An in-memory play queue extending the current `NowPlayingState` with upcoming items and play history.

**Queue State:**
- Ordered list of `QueueItem` (album + track reference + source tag)
- Source tags: `album` (from album playback), `manual` (user-added), `playlist` (from playlist)
- Play history: last 50 played tracks (in-memory, not persisted)

**Queue Actions on Albums/Tracks:**
- **Play Now** — replace queue with album/track, start playback
- **Play Next** — insert after currently playing item
- **Add to Queue** — append to end of queue
- **Add to Playlist** — submenu listing saved playlists + "New Playlist"

**Queue UI — Right-Side Panel:**
- 320px fixed-width panel overlaying detail content on the right
- Toggled via queue icon button (with badge count) in `InlinePlayerControls`
- Sections: Now Playing (highlighted), Up Next (with album separators), History (dimmed)
- Interactions: drag to reorder, swipe/delete to remove, tap to jump
- Footer actions: Clear Queue, Save as Playlist

**Queue Panel Visibility Provider:**
- `queueVisibleProvider` — bool, toggles panel open/closed

### 1.2 Persistent Playlists

Saved playlists stored in SQLite, accessible from a new tab in the rips screen.

**Database Tables (schema version 10):**

```
playlists
├── id           TEXT PRIMARY KEY (UUID)
├── name         TEXT NOT NULL
├── description  TEXT
├── coverAlbumId TEXT (FK → rip_albums, nullable)
├── createdAt    INTEGER NOT NULL
├── updatedAt    INTEGER NOT NULL
└── deleted      INTEGER NOT NULL DEFAULT 0

playlist_tracks
├── id           TEXT PRIMARY KEY (UUID)
├── playlistId   TEXT NOT NULL (FK → playlists)
├── ripTrackId   TEXT NOT NULL (FK → rip_tracks)
├── sortOrder    INTEGER NOT NULL
└── addedAt      INTEGER NOT NULL

-- playlist_tracks are orphaned when playlist is soft-deleted;
-- queries always join on playlists.deleted = 0 to filter them out.
```

**Playlists Tab:**
- Third segment in rips screen: Library | Coverage | **Playlists**
- Grid view of saved playlists showing cover art (from first album), name, track count, total duration
- "New Playlist" button in header

**Playlist Detail View:**
- Header: cover art, name, description, track count, total duration, created date
- Actions: Play All, Edit (name/description), Delete, Export
- Track listing: numbered, showing title, album attribution, duration
- Drag to reorder tracks, right-click/swipe to remove individual tracks

**Playlist Providers:**
- `allPlaylistsProvider` — StreamProvider watching all non-deleted playlists
- `playlistTracksProvider` — FutureProvider.family keyed by playlistId
- `playlistNotifierProvider` — NotifierProvider for CRUD operations (create, rename, delete, add/remove/reorder tracks)
- `selectedPlaylistProvider` — NotifierProvider tracking selected playlist in UI

**Playlist Cover Art:**
- Defaults to the cover art of the first album referenced in the playlist
- Uses existing `albumCoverArtProvider` with the `coverAlbumId`

---

## 2. Playback Features

### 2.1 ReplayGain

Volume normalisation using ReplayGain tags already present in FLAC Vorbis Comments.

**Tag Reading:**
- Read `REPLAYGAIN_TRACK_GAIN`, `REPLAYGAIN_ALBUM_GAIN`, `REPLAYGAIN_TRACK_PEAK`, `REPLAYGAIN_ALBUM_PEAK` from existing `trackRawTagsProvider`
- Tags contain values like `-6.5 dB` and `0.987654`

**Gain Calculation:**
```
linear_gain = 10^((rg_gain + preamp_db) / 20)
if prevent_clipping && linear_gain * peak > 1.0:
    linear_gain = 1.0 / peak
effective_volume = user_volume * linear_gain  (clamped to 0.0–1.0)
```

**Application:**
- Gain recalculated on every track change via `currentTrackIndexProvider` listener
- Applied through `AudioPlayerService.setVolume()` (combining user volume with RG adjustment)
- When ReplayGain is off, volume equals user's manual slider value

**Settings UI (Settings screen → Playback section):**
- **ReplayGain Mode** — three-way segmented toggle: Off | Track | Album
- **Pre-amp** — slider from -6.0 to +6.0 dB, default 0 dB
- **Prevent Clipping** — toggle switch, default on

**Providers:**
- `replayGainModeProvider` — NotifierProvider, enum (off/track/album), persisted to SharedPreferences
- `replayGainPreampProvider` — NotifierProvider, double (-6.0 to +6.0), persisted to SharedPreferences
- `preventClippingProvider` — NotifierProvider, bool, persisted to SharedPreferences

**ReplayGain Service:**
- `ReplayGainService` class in `core/services/audio/`
- Method: `calculateVolume(rawTags, mode, preamp, preventClipping, userVolume) → double`
- Pure calculation, no side effects — easy to unit test
- Called by `PlaybackActionNotifier` when track index changes

### 2.2 Playback Speed

Variable speed playback using just_audio's native `setSpeed()`.

**Speed Range:** 0.5× to 2.0× in 0.05 increments

**UI — Speed Button in InlinePlayerControls:**
- Small button showing current speed (e.g. "1.0×")
- Subtle appearance at 1.0×, highlighted cyan when ≠ 1.0×
- Tap opens popup with:
  - Preset buttons: 0.75×, 1.0×, 1.25×, 1.5×
  - Fine-control slider: 0.5× to 2.0×

**Provider:**
- `playbackSpeedProvider` — NotifierProvider, double, default 1.0, persisted to SharedPreferences
- Speed applied via `AudioPlayerService` wrapping `just_audio.setSpeed()`
- Duration display in seek bar is actual duration (not adjusted for speed)

---

## 3. Batch Operations

### 3.1 Multi-Select Mode

Selection mode for the rips library view enabling bulk actions on albums.

**Entering Selection Mode:**
- Long-press on album card (grid view)
- Ctrl+Click on album card (grid view)
- Checkbox column in table view
- Shift+Click for range select (table view)

**Selection Toolbar:**
- Appears above the album grid/table when ≥1 album selected
- Shows: selection count, action buttons, Select All, Cancel
- Actions: Analyse Quality, Edit Tags, Play All, Add to Playlist

**Selection State:**
- `albumSelectionProvider` — NotifierProvider holding `Set<String>` of selected album IDs
- Methods: toggle(id), selectAll(), clear(), selectRange(from, to)
- `isInSelectionModeProvider` — derived, true when set is non-empty

### 3.2 Batch Quality Analysis

Queue multiple albums for sequential AccurateRip + click detection analysis.

**Batch Analysis State:**
```dart
@freezed class BatchAnalysisState {
  factory BatchAnalysisState({
    @Default(BatchStatus.idle) BatchStatus overallStatus,
    @Default({}) Map<String, AlbumAnalysisStatus> albumStatuses,
    String? currentAlbumId,
    @Default(0) int currentTrackIndex,
    @Default(0) int totalAlbums,
    @Default(0) int completedAlbums,
    String? error,
  })
}

enum AlbumAnalysisStatus { queued, analysing, done, error }
```

**Provider:**
- `batchAnalysisProvider` — NotifierProvider
- Method: `analyseAlbums(List<String> albumIds)` — queues and processes sequentially
- Reuses existing `AnalyseRipQualityUsecase` per album
- Non-blocking: UI remains interactive during analysis

**UI — Progress Panel:**
- Shown in the library view when batch analysis is running
- Collapsible panel at top of album list
- Per-album status list: Done (green tick), In Progress (spinner + track count), Queued (grey), Error (red)
- Overall progress bar
- Cancel button

**"Analyse All" Shortcut:**
- Available when no albums are selected
- Button in toolbar: "Analyse All Un-analysed"
- Queries albums where no tracks have `qualityCheckedAt` set
- Feeds into same `batchAnalysisProvider`

### 3.3 Batch Metadata Editing

Bulk tag editing across selected albums with preview and undo.

**Bulk Tag Editor Dialog:**
- Opens when "Edit Tags" clicked with albums selected
- Header: "Edit Tags — N Albums (M tracks)"
- Tag fields: Genre, Date/Year, Album Artist, Comment (most common bulk edits)
- Each field shows current value if consistent, "mixed" placeholder if albums differ
- Empty fields are skipped (existing values preserved)
- Track title pattern field: `%n`, `%t`, `%a`, `%d` tokens for reformatting titles

**Preview Dialog:**
- Accessed via "Preview Changes" link before applying
- Diff-style display: old value (red strikethrough) → new value (green)
- Per-track listing grouped by album
- Confirm & Apply or Back buttons

**Undo Mechanism:**
- Before writing, store original tag values in memory: `Map<String, Map<String, String>>` (trackId → tag → old value)
- After apply, show snackbar: "Updated N tracks across M albums" with UNDO button
- 30-second undo window
- Undo re-writes original values via `MetaflacWriter`
- Only last batch operation is undoable
- State held in memory (not persisted across sessions)

**Providers:**
- `batchMetadataEditProvider` — NotifierProvider managing edit state, preview generation, apply, and undo
- Reuses existing `EditRipMetadataUsecase` and `MetaflacWriter` for actual tag writing

---

## 4. Collection Integration

### 4.1 Rip Status Badges

Visual indicators on collection items showing rip and quality status.

**Status Enum:**
```dart
enum RipStatus { noRip, ripped, verified, qualityIssues }
```

**Badge Display (collection grid cards):**
- `noRip` — no badge shown
- `ripped` — cyan music note badge (♪), top-right corner
- `verified` — green tick badge (✓), top-right corner
- `qualityIssues` — amber warning badge (!), top-right corner

**Badge styling:**
- 20px circular badge with tonal background matching status colour at 15% opacity
- Border at 30% opacity
- Positioned absolute, top-right of card

**Only shown on music media types** (CD, Vinyl, Cassette) — not on DVD/Blu-ray/Book items.

**Provider:**
- `mediaItemRipStatusProvider` — FutureProvider.family keyed by mediaItemId
- Sources: `rippedItemIdsProvider` for existence check, then queries quality data from `RipLibraryDao`
- Returns `RipStatus` enum

### 4.2 Rip Status Filter

New filter chip in the collection filter bar.

**Filter Values:** All | Has Rip | No Rip | Quality Verified | Quality Issues

**Provider:**
- `ripStatusFilterProvider` — NotifierProvider holding selected `RipStatusFilter` enum
- Integrates with existing collection filtering logic in the collection providers

**Implementation:**
- Add `RipStatusFilter` to existing filter state
- Filter applied after existing type/shelf filters
- Uses `rippedItemIdsProvider` and quality data to evaluate each item

### 4.3 Item Detail — Rip Details Section

Collapsible section on the collection item detail screen showing linked rip information.

**When rip is linked:**
- Section header: "RIP DETAILS" with status indicator (● Verified / ● Issues / ● Ripped)
- Info grid: path, format + track count + size, quality summary, last scanned date
- Action buttons: Play, View in Rips Library, Unlink

**When no rip is linked:**
- Dashed border container
- "No rip linked to this item" text
- "Link Rip Album →" button opens existing linking dialog

**Section placement:**
- After existing metadata sections, before lending section
- Collapsible (default expanded when rip exists, collapsed when no rip)
- Only shown for music media types

### 4.4 Cross-Navigation

Bidirectional navigation between collection items and rip albums.

**Collection → Rips:**
- "View in Rips Library" button on rip details section
- Action: navigate to `/rips` route, set `selectedRipAlbumProvider` to the linked album ID
- Album opens in detail panel

**Rips → Collection:**
- "View in Collection" button on album detail dialog (partially exists)
- Action: navigate to `/collection/item/:mediaItemId`

**Play from Collection:**
- Play button on rip details section
- Loads tracks via `ripTracksProvider`, starts playback via `playbackActionProvider`
- `InlinePlayerControls` appear (already global)

### 4.5 Collection Rip Statistics

Aggregate rip coverage stats for the insights dashboard.

**Provider:**
- `collectionRipStatsProvider` — FutureProvider computing:
  - Total music items count
  - Ripped count
  - Verified count
  - Quality issues count
  - Rip coverage percentage

---

## Implementation Priority

Recommended build order based on dependencies:

1. **Database migration** (schema v10) — playlists + playlist_tracks tables
2. **Queue system** — extends NowPlayingState, queue panel UI
3. **Playlists** — CRUD, tab, detail view (depends on queue for "Save as Playlist")
4. **Multi-select mode** — selection state, toolbar (foundation for batch ops)
5. **Batch quality analysis** — uses multi-select, extends existing analysis
6. **Batch metadata editing** — uses multi-select, preview/undo system
7. **ReplayGain** — service + settings UI + player integration
8. **Playback speed** — speed provider + popup UI
9. **Collection rip status badges** — new provider + badge widget
10. **Collection rip status filter** — filter provider + chip UI
11. **Item detail rip section** — collapsible section + cross-navigation
12. **Collection rip statistics** — stats provider for insights

## Files to Create

- `lib/data/local/database/tables/playlists_table.dart`
- `lib/data/local/database/tables/playlist_tracks_table.dart`
- `lib/domain/entities/playlist.dart`
- `lib/domain/entities/queue_item.dart`
- `lib/core/services/audio/replay_gain_service.dart`
- `lib/presentation/providers/queue_provider.dart`
- `lib/presentation/providers/playlist_provider.dart`
- `lib/presentation/providers/batch_analysis_provider.dart`
- `lib/presentation/providers/batch_metadata_edit_provider.dart`
- `lib/presentation/providers/album_selection_provider.dart`
- `lib/presentation/providers/collection_rip_status_provider.dart`
- `lib/presentation/screens/rips/widgets/queue_panel.dart`
- `lib/presentation/screens/rips/widgets/playlist_view.dart`
- `lib/presentation/screens/rips/widgets/playlist_detail.dart`
- `lib/presentation/screens/rips/widgets/batch_analysis_panel.dart`
- `lib/presentation/screens/rips/widgets/batch_tag_editor_dialog.dart`
- `lib/presentation/screens/rips/widgets/batch_tag_preview_dialog.dart`
- `lib/presentation/screens/rips/widgets/speed_control_popup.dart`
- `lib/presentation/screens/collection/widgets/rip_status_badge.dart`
- `lib/presentation/screens/collection/widgets/rip_details_section.dart`

## Files to Modify

- `lib/data/local/database/app_database.dart` — schema v10 migration, register new tables
- `lib/data/local/dao/rip_library_dao.dart` — playlist queries, batch quality queries
- `lib/presentation/providers/audio_player_provider.dart` — integrate ReplayGain, speed, queue
- `lib/presentation/screens/rips/rips_screen.dart` — add Playlists segment
- `lib/presentation/screens/rips/widgets/rip_library_view.dart` — multi-select mode, selection toolbar, batch analysis panel
- `lib/presentation/screens/rips/widgets/rip_album_detail_dialog.dart` — context menu actions (Play Next, Add to Queue, etc.)
- `lib/presentation/screens/rips/widgets/playback_widgets.dart` — speed button, queue toggle button
- `lib/presentation/screens/settings/settings_screen.dart` — ReplayGain settings section
- `lib/presentation/screens/collection/collection_screen.dart` — rip status filter chip
- `lib/presentation/screens/item_detail/item_detail_screen.dart` — rip details section
- `lib/presentation/widgets/collection_item_card.dart` (or equivalent) — rip status badge overlay
- `lib/core/services/audio/audio_player_service.dart` — setSpeed() wrapper

## Verification

- Unit tests for `ReplayGainService` calculation (various gain/peak/preamp combos)
- Unit tests for queue operations (add, remove, reorder, play next)
- Unit tests for playlist CRUD operations
- Unit tests for batch analysis state transitions
- Unit tests for batch metadata preview generation
- Widget tests for queue panel, speed popup, rip status badge
- Integration test: create playlist, add tracks, play playlist
- Integration test: batch analyse 2+ albums
- Integration test: filter collection by rip status
- Manual test: ReplayGain volume changes audibly on track transitions
- Manual test: speed control affects playback rate
