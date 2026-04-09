/// Audio player service wrapping just_audio for album-based gapless playback.
///
/// Provides a high-level API for playing albums (as ordered track lists) with
/// controls for seeking, volume, looping, and shuffling. Accepts an optional
/// [AudioPlayer] in the constructor for testing.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:collection';

import 'package:just_audio/just_audio.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

/// Service that wraps [AudioPlayer] to provide album-based gapless playback.
class AudioPlayerService {
  /// Creates an [AudioPlayerService].
  ///
  /// If [player] is null, a real [AudioPlayer] is created.
  AudioPlayerService({AudioPlayer? player})
      : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  RipAlbum? _currentAlbum;
  List<RipTrack> _currentTracks = [];

  /// The currently loaded album, or null if nothing is loaded.
  RipAlbum? get currentAlbum => _currentAlbum;

  /// The tracks of the currently loaded album (unmodifiable).
  List<RipTrack> get currentTracks =>
      UnmodifiableListView<RipTrack>(_currentTracks);

  /// Whether the underlying player is currently playing.
  bool get isPlaying => _player.playing;

  /// Stream of the current playback position.
  Stream<Duration> get positionStream => _player.positionStream;

  /// Stream of the current track duration.
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Stream of the player state (playing + processing state).
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Stream of the current track index within the playlist.
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  /// Stream of the current sequence state (track, index, list, etc.).
  Stream<SequenceState?> get sequenceStateStream =>
      _player.sequenceStateStream;

  /// Loads and plays an album from the given [tracks], starting at
  /// [startIndex].
  ///
  /// Builds a [ConcatenatingAudioSource] from the track file paths for
  /// gapless playback.
  Future<void> playAlbum({
    required RipAlbum album,
    required List<RipTrack> tracks,
    int startIndex = 0,
  }) async {
    _currentAlbum = album;
    _currentTracks = List<RipTrack>.from(tracks);

    final source = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: tracks
          .map((track) => AudioSource.file(track.filePath, tag: track.title))
          .toList(),
    );

    await _player.setAudioSource(source, initialIndex: startIndex);
    await _player.play();
  }

  /// Resumes playback if paused.
  Future<void> resume() async {
    await _player.play();
  }

  /// Pauses playback.
  Future<void> pause() async {
    await _player.pause();
  }

  /// Stops playback and clears the current album and tracks.
  Future<void> stop() async {
    await _player.stop();
    _currentAlbum = null;
    _currentTracks = [];
  }

  /// Seeks to the given [position] within the current track.
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Seeks to a specific track [index] in the playlist, starting from the
  /// beginning of that track.
  Future<void> seekToIndex(int index) async {
    await _player.seek(Duration.zero, index: index);
  }

  /// Seeks to the next track in the playlist.
  Future<void> seekToNext() async {
    await _player.seekToNext();
  }

  /// Seeks to the previous track in the playlist.
  Future<void> seekToPrevious() async {
    await _player.seekToPrevious();
  }

  /// Sets the playback volume (0.0 to 1.0).
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  /// Sets the loop mode (off, one, all).
  Future<void> setLoopMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  /// Enables or disables shuffle mode.
  Future<void> setShuffleEnabled(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  /// Disposes the underlying player and releases resources.
  Future<void> dispose() async {
    await _player.dispose();
  }
}
