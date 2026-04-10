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

import 'package:dart_metaflac/dart_metaflac.dart';
import 'package:dart_metaflac/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mymediascanner/core/services/audio/audio_player_service.dart';
import 'package:mymediascanner/core/services/audio/replay_gain_service.dart';
import 'package:mymediascanner/domain/entities/queue_item.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/playback_speed_provider.dart';
import 'package:mymediascanner/presentation/providers/queue_provider.dart';
import 'package:mymediascanner/presentation/providers/replay_gain_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

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

  /// Loads and plays an album, updating the now-playing state and queue first.
  Future<void> playAlbum({
    required RipAlbum album,
    required List<RipTrack> tracks,
    int startIndex = 0,
  }) async {
    ref.read(nowPlayingProvider.notifier).set(album: album, tracks: tracks);
    ref.read(queueProvider.notifier).replaceQueue(album, tracks, startIndex: startIndex);
    await _service.playAlbum(
      album: album,
      tracks: tracks,
      startIndex: startIndex,
    );
  }

  /// Plays the track at [index] in the current queue.
  ///
  /// Updates the queue's current index, sets the now-playing state to reflect
  /// the queued item's album and its sibling tracks, and seeks the audio engine
  /// to the corresponding track.
  Future<void> playFromQueue(int index) async {
    final queueState = ref.read(queueProvider);
    if (index < 0 || index >= queueState.items.length) return;

    ref.read(queueProvider.notifier).setCurrentIndex(index);
    final item = queueState.items[index];
    final albumTracks = queueState.items
        .where((i) => i.album.id == item.album.id)
        .map((i) => i.track)
        .toList();

    ref.read(nowPlayingProvider.notifier).set(
          album: item.album,
          tracks: albumTracks,
        );
    await _service.seekToIndex(albumTracks.indexOf(item.track));
  }

  /// Loads and plays a cross-album playlist from [items].
  ///
  /// Each [QueueItem] carries its own [RipTrack] and [RipAlbum]. The queue is
  /// replaced with all items and the first album is used for now-playing
  /// display metadata. Playback starts from the first item.
  Future<void> playPlaylist(List<QueueItem> items) async {
    if (items.isEmpty) return;

    final firstItem = items.first;
    final allTracks = items.map((i) => i.track).toList();
    final queueNotifier = ref.read(queueProvider.notifier);

    // Group items by album (preserving playlist order) then load them into the
    // queue — replaceQueue for the first album, addAlbumToQueue for the rest.
    final seen = <String>{};
    final albumGroups = <(RipAlbum, List<RipTrack>)>[];
    for (final item in items) {
      if (seen.add(item.album.id)) {
        albumGroups.add((
          item.album,
          items
              .where((i) => i.album.id == item.album.id)
              .map((i) => i.track)
              .toList(),
        ));
      }
    }

    final (firstAlbum, firstTracks) = albumGroups.first;
    queueNotifier.replaceQueue(firstAlbum, firstTracks, startIndex: 0);
    for (var idx = 1; idx < albumGroups.length; idx++) {
      final (album, tracks) = albumGroups[idx];
      queueNotifier.addAlbumToQueue(album, tracks);
    }

    ref.read(nowPlayingProvider.notifier).set(
          album: firstItem.album,
          tracks: allTracks,
        );

    await _service.playTracks(
      album: firstItem.album,
      tracks: allTracks,
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
  ///
  /// The supplied [volume] is the user-selected level.  Before forwarding to
  /// the audio service, ReplayGain normalisation is applied (if enabled) using
  /// the current track's embedded gain tags.
  Future<void> setVolume(double volume) async {
    final effective = await _calculateEffectiveVolume(volume);
    await _service.setVolume(effective);
    ref.read(volumeProvider.notifier).set(volume);
  }

  /// Calculates the effective volume after applying ReplayGain normalisation.
  ///
  /// Reads the current ReplayGain settings from their providers and uses
  /// [ReplayGainService] to compute the normalised level.  When the mode is
  /// [ReplayGainMode.off], [userVolume] is returned unchanged.
  ///
  /// Tags are sourced from the currently playing track when available.  If no
  /// track is loaded, or the track carries no gain tags, the service falls back
  /// to returning [userVolume] directly.
  Future<double> _calculateEffectiveVolume(double userVolume) async {
    final mode = ref.read(replayGainModeProvider);
    final preamp = ref.read(replayGainPreampProvider);
    final preventClipping = ref.read(preventClippingProvider);
    final service = ref.read(replayGainServiceProvider);

    // Collect raw tags from the currently playing track (if any).
    final rawTags = await _currentTrackTags();

    return service.calculateVolume(
      rawTags: rawTags,
      mode: mode,
      preampDb: preamp,
      preventClipping: preventClipping,
      userVolume: userVolume,
    );
  }

  /// Returns the ReplayGain raw tags for the currently playing track.
  ///
  /// Reads tags from [trackRawTagsProvider] for the active track so that
  /// ReplayGain normalisation can apply the embedded gain values.  Returns an
  /// empty map if no track is loaded or tag reading fails.
  Future<Map<String, String>> _currentTrackTags() async {
    final nowPlaying = ref.read(nowPlayingProvider);
    final currentIndex = ref.read(currentTrackIndexProvider).value;
    if (nowPlaying.tracks.isEmpty ||
        currentIndex == null ||
        currentIndex < 0 ||
        currentIndex >= nowPlaying.tracks.length) {
      return const {};
    }
    final track = nowPlaying.tracks[currentIndex];
    try {
      return await ref.read(trackRawTagsProvider(track.filePath).future);
    } catch (_) {
      return const {};
    }
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

  /// Sets the playback speed (0.5 to 2.0).
  Future<void> setSpeed(double speed) async {
    await _service.setSpeed(speed);
    ref.read(playbackSpeedProvider.notifier).setSpeed(speed);
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

/// Extracts embedded cover art from a FLAC file.
///
/// Prefers a PICTURE block marked as [PictureType.frontCover]; falls back
/// to the first picture of any type. Returns `null` if the file cannot be
/// read, is not a valid FLAC, or contains no pictures.
Future<Uint8List?> _extractFlacPicture(String filePath) async {
  try {
    final doc = await FlacFileEditor.readFile(filePath);
    if (doc.pictures.isEmpty) return null;
    final front = doc.pictures.firstWhere(
      (p) => p.pictureType == PictureType.frontCover,
      orElse: () => doc.pictures.first,
    );
    return front.data;
  } catch (_) {
    return null;
  }
}
