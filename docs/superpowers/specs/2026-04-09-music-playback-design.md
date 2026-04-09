# Music Playback for Rip Library — Design Spec

**Date:** 2026-04-09
**Author:** Paul Snow
**Status:** Approved

## Summary

Add music playback to the rip library screen, enabling both quick track preview and full sequential album playback with gapless transitions. Playback persists across screen navigation via a mini player bar. Desktop-only (Linux, macOS, Windows).

## Library Choice

**`just_audio`** — supports FLAC/MP3 natively on all desktop platforms, provides gapless playback via `ConcatenatingAudioSource`, and exposes position/duration/state streams that integrate cleanly with Riverpod.

## Architecture

### Audio Service Layer

`lib/core/services/audio/audio_player_service.dart`:

- Wraps `just_audio` `AudioPlayer` instance
- Exposes streams: position, duration, player state, current track index, sequence state
- Methods: `playAlbum(tracks, startIndex)`, `play()`, `pause()`, `seek(position)`, `seekToNext()`, `seekToPrevious()`, `stop()`, `setRepeatMode()`, `setShuffleEnabled()`
- Builds `ConcatenatingAudioSource` from `RipTrack.filePath` list
- Singleton lifecycle — not disposed on screen change

### Providers

`lib/presentation/providers/audio_player_provider.dart`:

- `audioPlayerServiceProvider` — singleton `AudioPlayerService` instance
- `audioPlayerStateProvider` — `StreamProvider` exposing combined playback state (playing/paused, current track index, position, duration)
- `nowPlayingAlbumProvider` — `StateProvider` holding current `RipAlbum` + `List<RipTrack>`
- `playbackModeProvider` — repeat off / repeat album / repeat track / shuffle

### No Domain or Data Layer Changes

Playback is purely a presentation concern. It reads existing `RipTrack.filePath` data — no new entities, repositories, use cases, or database changes required.

## UI Components

### Mini Player Bar

`lib/presentation/widgets/mini_player_bar.dart`:

- Fixed at bottom of screen, above any navigation
- Displays: track title, artist, album title, progress bar, play/pause, prev/next buttons
- Tap to scroll/navigate to the album detail
- Only visible when something is playing or paused
- Integrated into `AppScaffold` so it persists across all screens

### Album Detail Dialog Enhancements

Modifications to `rip_album_detail_dialog.dart`:

**Track list:**
- Each track row gets a play button (or tap-to-play)
- Currently playing track highlighted with accent colour
- Speaker/equaliser icon on the active track
- "Play All" / "Pause" button in the dialog header

**Inline player controls (below track list):**
- Seek slider with position/duration labels
- Play/pause, prev/next, repeat mode toggle, shuffle toggle
- Volume slider

### Album Highlighting

Minor modifications to `rip_library_view.dart` and `rip_table_view.dart`:
- Highlight the currently playing album in grid and table views

### Keyboard Shortcuts

Desktop-only shortcuts:
- `Space` — play/pause
- `←/→` — seek back/forward 5 seconds
- `Ctrl+←/→` — previous/next track

## Playback Behaviour

### Playing an Album

- "Play All" starts from track 1, disc 1, ordered by disc number then track number
- Tapping a specific track starts album playback from that track onwards
- All tracks loaded into `ConcatenatingAudioSource` upfront for gapless transitions

### Track Progression

- Sequential by default (disc number, then track number order)
- Shuffle randomises order within the album
- Repeat modes: off (stop after last track), repeat album (loop back to start), repeat track (loop current)

### Switching Albums

- Playing a track from a different album replaces the current queue entirely
- No cross-album playlists

### Lifecycle

- Playback continues when navigating away from rips screen (mini player stays visible)
- Closing/dismissing the mini player stops playback and clears state
- No persistence across app restarts — playback state is ephemeral

### Error Handling

- Missing file (deleted/moved since scan): skip to next track, show brief snackbar notification
- Unsupported format: same skip-and-notify behaviour

## File Structure

### New Files (3)

| File | Purpose |
|------|---------|
| `lib/core/services/audio/audio_player_service.dart` | `just_audio` wrapper with gapless album playback |
| `lib/presentation/providers/audio_player_provider.dart` | Riverpod providers for playback state |
| `lib/presentation/widgets/mini_player_bar.dart` | Persistent bottom mini player bar |

### Modified Files (3)

| File | Change |
|------|--------|
| `lib/presentation/screens/rips/widgets/rip_album_detail_dialog.dart` | Add track play buttons, inline player controls |
| `lib/presentation/screens/rips/widgets/rip_library_view.dart` | Highlight now-playing album |
| `lib/presentation/screens/rips/widgets/rip_table_view.dart` | Highlight now-playing album row |

### Infrastructure

| File | Change |
|------|--------|
| `pubspec.yaml` | Add `just_audio` dependency |

## Testing Strategy

- **Unit tests** for `AudioPlayerService` — mock `just_audio` `AudioPlayer`, verify play/pause/seek/queue behaviour
- **Unit tests** for providers — mock service, verify state transitions and now-playing updates
- **Widget tests** for mini player bar — verify visibility, controls, track info display
- **Widget tests** for modified detail dialog — verify play buttons, active track highlighting, inline controls

## Out of Scope

- Cross-album playlists or queue management
- Waveform visualisation
- Playback state persistence across app restarts
- Mobile playback
- Album art in mini player (could be added later if cover art is available)
- Background audio / media session integration (not needed for desktop media scanner)
