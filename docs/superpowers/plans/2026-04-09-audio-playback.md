# Audio Playback Plan

> **Status:** Future — not yet started

**Goal:** Add audio playback capability to the rip library, allowing users to play FLAC and MP3 files directly from the rips screen.

**Author:** Paul Snow

---

## Proposed Features

- Play FLAC and MP3 files from the rip library detail panel
- Mini-player widget in the rips detail panel (play/pause, seek bar, track title, duration)
- Optional: global mini-player in app scaffold footer (persistent across screens)
- Optional: playlist mode (play all tracks in an album sequentially)
- CUE-based playback: seek to track start time within a single audio file (using CUE sheet INDEX 01 timestamps)

## Likely Technology

- **Package:** `just_audio` — supports FLAC and MP3 on all platforms (Android, iOS, macOS, Windows, Linux)
- **State:** Riverpod hand-written `Notifier` wrapping a `just_audio` `AudioPlayer` instance
- **Gapless playback:** `just_audio` supports `ConcatenatingAudioSource` for seamless album playback

## Dependencies

- Rip metadata viewer/editor plan must be complete (file paths and metadata in DB) ✓
- CUE sheet parsing must be complete (for CUE-based seeking) ✓

## Architecture Notes

- The `AudioPlayer` instance should be managed as a singleton via a Riverpod provider
- Playback state (playing, paused, position, duration, current track) exposed via a `StreamProvider`
- The mini-player widget should be a `ConsumerWidget` watching the playback state provider
- CUE-based playback: use `AudioSource.uri` with `clippingAudioSource` or seek-to-position for track boundaries
- Desktop platforms may need platform-specific audio backend configuration

## Out of Scope

- Streaming from network sources
- Audio equaliser or DSP effects
- Playlist persistence across app restarts
- Album art display in mini-player (could be added as a follow-up)
