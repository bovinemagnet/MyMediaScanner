/// Riverpod providers for audio playback state management.
///
/// Provides singleton access to [AudioPlayerService], now-playing state,
/// playback stream providers, and a playback action notifier for controlling
/// album-based gapless playback.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:io';
import 'dart:typed_data';

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
// Playback mode state providers
// ------------------------------------------------------------------

/// Notifier for the current loop mode.
class LoopModeNotifier extends Notifier<LoopMode> {
  @override
  LoopMode build() => LoopMode.off;

  /// Updates the loop mode.
  void set(LoopMode mode) => state = mode;
}

/// Provider for the current loop mode state (off, all, one).
final loopModeProvider =
    NotifierProvider<LoopModeNotifier, LoopMode>(() => LoopModeNotifier());

/// Notifier for shuffle enabled state.
class ShuffleEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Updates the shuffle state.
  void set(bool enabled) => state = enabled;
}

/// Provider for whether shuffle mode is enabled.
final shuffleEnabledProvider =
    NotifierProvider<ShuffleEnabledNotifier, bool>(
        () => ShuffleEnabledNotifier());

/// Notifier for playback volume.
class VolumeNotifier extends Notifier<double> {
  @override
  double build() => 1.0;

  /// Updates the volume.
  void set(double volume) => state = volume;
}

/// Provider for the current playback volume (0.0 to 1.0).
final volumeProvider =
    NotifierProvider<VolumeNotifier, double>(() => VolumeNotifier());

/// Whether clicking a track or album should auto-play it.
class PlayOnSelectNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final playOnSelectProvider =
    NotifierProvider<PlayOnSelectNotifier, bool>(() => PlayOnSelectNotifier());

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

  /// Seeks to the track at the given [index] within the playlist.
  Future<void> seekToIndex(int index) async {
    await _service.seekToIndex(index);
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
    ref.read(volumeProvider.notifier).set(volume);
  }

  /// Sets the loop mode (off, one, all).
  Future<void> setLoopMode(LoopMode mode) async {
    await _service.setLoopMode(mode);
    ref.read(loopModeProvider.notifier).set(mode);
  }

  /// Enables or disables shuffle mode.
  Future<void> setShuffleEnabled(bool enabled) async {
    await _service.setShuffleEnabled(enabled);
    ref.read(shuffleEnabledProvider.notifier).set(enabled);
  }
}

/// Provider for playback control actions.
final playbackActionProvider =
    NotifierProvider<PlaybackActionNotifier, void>(
        () => PlaybackActionNotifier());

// ------------------------------------------------------------------
// Album cover art provider
// ------------------------------------------------------------------

/// Loads album cover art bytes from directory images or embedded FLAC metadata.
///
/// Checks for common cover image filenames in the album directory first,
/// then falls back to extracting the embedded PICTURE metadata block from
/// the first FLAC file in the track list.
final albumCoverArtProvider =
    FutureProvider.family<Uint8List?, String>((ref, albumId) async {
  final nowPlaying = ref.watch(nowPlayingProvider);
  if (nowPlaying.album?.id != albumId) return null;

  final album = nowPlaying.album!;
  final dir = Directory(album.libraryPath);

  // Check for cover image files in album directory
  const coverNames = [
    'cover.jpg', 'cover.png', 'folder.jpg', 'folder.png',
    'front.jpg', 'front.png',
  ];

  if (await dir.exists()) {
    final files = await dir.list().toList();
    for (final name in coverNames) {
      final match = files.whereType<File>().where(
        (f) => f.path.split('/').last.toLowerCase() == name,
      ).firstOrNull;
      if (match != null) {
        return await match.readAsBytes();
      }
    }
  }

  // Fallback: extract PICTURE block from first FLAC track
  final tracks = nowPlaying.tracks;
  final flacTrack = tracks.where(
    (t) => t.filePath.toLowerCase().endsWith('.flac'),
  ).firstOrNull;
  if (flacTrack != null) {
    return await _extractFlacPicture(flacTrack.filePath);
  }

  return null;
});

/// Extracts the first PICTURE block (type 6) from a FLAC file.
///
/// Returns raw image bytes or null if no picture block is found.
Future<Uint8List?> _extractFlacPicture(String filePath) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) return null;

    final raf = await file.open(mode: FileMode.read);
    try {
      // Read FLAC magic bytes ('fLaC')
      final magic = await raf.read(4);
      if (magic.length < 4 || magic[0] != 0x66 || magic[1] != 0x4C ||
          magic[2] != 0x61 || magic[3] != 0x43) {
        return null;
      }

      var isLastBlock = false;
      while (!isLastBlock) {
        final header = await raf.read(4);
        if (header.length < 4) break;

        isLastBlock = (header[0] & 0x80) != 0;
        final blockType = header[0] & 0x7F;
        final blockLength =
            (header[1] << 16) | (header[2] << 8) | header[3];

        if (blockType == 6) {
          // PICTURE block
          final data = await raf.read(blockLength);
          if (data.length < 32) return null;

          // Parse PICTURE block structure:
          // 4 bytes: picture type
          var offset = 4;
          // 4 bytes: MIME string length + MIME string
          final mimeLen = (data[offset] << 24) | (data[offset + 1] << 16) |
              (data[offset + 2] << 8) | data[offset + 3];
          offset += 4 + mimeLen;

          // 4 bytes: description length + description string
          if (offset + 4 > data.length) return null;
          final descLen = (data[offset] << 24) | (data[offset + 1] << 16) |
              (data[offset + 2] << 8) | data[offset + 3];
          offset += 4 + descLen;

          // 16 bytes: width, height, colour depth, indexed colours
          offset += 16;

          // 4 bytes: picture data length
          if (offset + 4 > data.length) return null;
          final picLen = (data[offset] << 24) | (data[offset + 1] << 16) |
              (data[offset + 2] << 8) | data[offset + 3];
          offset += 4;

          if (offset + picLen > data.length) return null;
          return Uint8List.sublistView(
            Uint8List.fromList(data), offset, offset + picLen,
          );
        } else {
          await raf.setPosition(await raf.position() + blockLength);
        }
      }
    } finally {
      await raf.close();
    }
  } catch (_) {}
  return null;
}
