/// Riverpod providers for audio playback state management.
///
/// Provides singleton access to [AudioPlayerService], now-playing state,
/// playback stream providers, and a playback action notifier for controlling
/// album-based gapless playback.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mymediascanner/core/services/audio/audio_player_service.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

// ------------------------------------------------------------------
// AudioPlayerService singleton
// ------------------------------------------------------------------

/// Provides a singleton [AudioPlayerService] instance.
///
/// The service is disposed when the provider is disposed.
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ------------------------------------------------------------------
// Now-playing state
// ------------------------------------------------------------------

/// Simple state class holding the currently playing album and its tracks.
class NowPlayingState {
  /// Creates a [NowPlayingState].
  const NowPlayingState({this.album, this.tracks = const []});

  /// The currently loaded album, or null if nothing is playing.
  final RipAlbum? album;

  /// The tracks of the currently loaded album.
  final List<RipTrack> tracks;
}

/// Notifier managing the now-playing state (album + tracks).
class NowPlayingNotifier extends Notifier<NowPlayingState> {
  @override
  NowPlayingState build() => const NowPlayingState();

  /// Sets the now-playing album and tracks.
  void set({RipAlbum? album, List<RipTrack> tracks = const []}) {
    state = NowPlayingState(album: album, tracks: tracks);
  }

  /// Clears the now-playing state.
  void clear() {
    state = const NowPlayingState();
  }
}

/// Provider for the now-playing state.
final nowPlayingProvider =
    NotifierProvider<NowPlayingNotifier, NowPlayingState>(
        () => NowPlayingNotifier());

// ------------------------------------------------------------------
// Playback stream providers
// ------------------------------------------------------------------

/// Stream of the current playback position.
final playbackPositionProvider = StreamProvider<Duration>((ref) {
  return ref.watch(audioPlayerServiceProvider).positionStream;
});

/// Stream of the current track duration.
final playbackDurationProvider = StreamProvider<Duration?>((ref) {
  return ref.watch(audioPlayerServiceProvider).durationStream;
});

/// Stream of the player state (playing + processing state).
final playerStateProvider = StreamProvider<PlayerState>((ref) {
  return ref.watch(audioPlayerServiceProvider).playerStateStream;
});

/// Stream of the current track index within the playlist.
final currentTrackIndexProvider = StreamProvider<int?>((ref) {
  return ref.watch(audioPlayerServiceProvider).currentIndexStream;
});

// ------------------------------------------------------------------
// Playback action notifier
// ------------------------------------------------------------------

/// Notifier providing playback control methods.
///
/// Coordinates between the [NowPlayingNotifier] (state) and the
/// [AudioPlayerService] (audio engine).
class PlaybackActionNotifier extends Notifier<void> {
  @override
  void build() {}

  AudioPlayerService get _service => ref.read(audioPlayerServiceProvider);

  /// Loads and plays an album, updating the now-playing state first.
  Future<void> playAlbum({
    required RipAlbum album,
    required List<RipTrack> tracks,
    int startIndex = 0,
  }) async {
    ref.read(nowPlayingProvider.notifier).set(album: album, tracks: tracks);
    await _service.playAlbum(
      album: album,
      tracks: tracks,
      startIndex: startIndex,
    );
  }

  /// Pauses playback.
  Future<void> pause() async {
    await _service.pause();
  }

  /// Resumes playback.
  Future<void> resume() async {
    await _service.resume();
  }

  /// Toggles between play and pause.
  Future<void> togglePlayPause() async {
    if (_service.isPlaying) {
      await _service.pause();
    } else {
      await _service.resume();
    }
  }

  /// Stops playback and clears the now-playing state.
  Future<void> stop() async {
    await _service.stop();
    ref.read(nowPlayingProvider.notifier).clear();
  }

  /// Seeks to the given [position] within the current track.
  Future<void> seek(Duration position) async {
    await _service.seek(position);
  }

  /// Seeks to the next track in the playlist.
  Future<void> seekToNext() async {
    await _service.seekToNext();
  }

  /// Seeks to the previous track in the playlist.
  Future<void> seekToPrevious() async {
    await _service.seekToPrevious();
  }

  /// Sets the playback volume (0.0 to 1.0).
  Future<void> setVolume(double volume) async {
    await _service.setVolume(volume);
  }

  /// Sets the loop mode (off, one, all).
  Future<void> setLoopMode(LoopMode mode) async {
    await _service.setLoopMode(mode);
  }

  /// Enables or disables shuffle mode.
  Future<void> setShuffleEnabled(bool enabled) async {
    await _service.setShuffleEnabled(enabled);
  }
}

/// Provider for playback control actions.
final playbackActionProvider =
    NotifierProvider<PlaybackActionNotifier, void>(
        () => PlaybackActionNotifier());
