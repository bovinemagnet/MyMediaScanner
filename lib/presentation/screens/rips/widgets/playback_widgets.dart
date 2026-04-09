/// Shared playback widgets for rip album views.
///
/// Provides [PlayAlbumButton], [InlinePlayerControls], and the
/// [formatPlaybackDuration] helper used by both the detail dialog
/// and the master-detail side panel.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

/// Formats a [Duration] as `m:ss`.
String formatPlaybackDuration(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// Play/pause button for a rip album.
///
/// Shows pause when the album is currently playing, play otherwise.
/// Tapping loads and plays the album if it is not already loaded.
class PlayAlbumButton extends ConsumerWidget {
  /// Creates a [PlayAlbumButton].
  const PlayAlbumButton({super.key, required this.album});

  /// The album this button controls.
  final RipAlbum album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlaying = ref.watch(nowPlayingProvider);
    final playerState = ref.watch(playerStateProvider).value;
    final isThisAlbum = nowPlaying.album?.id == album.id;
    final isPlaying = playerState?.playing ?? false;

    if (isThisAlbum && isPlaying) {
      return IconButton(
        icon: Icon(Icons.pause_circle,
            size: 28, color: Theme.of(context).colorScheme.primary),
        tooltip: 'Pause',
        onPressed: () =>
            ref.read(playbackActionProvider.notifier).pause(),
      );
    }

    if (isThisAlbum && !isPlaying) {
      return IconButton(
        icon: Icon(Icons.play_circle,
            size: 28, color: Theme.of(context).colorScheme.primary),
        tooltip: 'Resume',
        onPressed: () =>
            ref.read(playbackActionProvider.notifier).resume(),
      );
    }

    return IconButton(
      icon: Icon(Icons.play_circle,
          size: 28, color: Theme.of(context).colorScheme.primary),
      tooltip: 'Play album',
      onPressed: () {
        final tracks = ref.read(ripTracksProvider(album.id)).value ?? [];
        if (tracks.isNotEmpty) {
          ref.read(playbackActionProvider.notifier).playAlbum(
                album: album,
                tracks: tracks,
              );
        }
      },
    );
  }
}

/// Inline player controls with seek bar, transport buttons, volume,
/// repeat mode, and shuffle toggle.
///
/// Only visible when the given [album] is the currently playing album.
class InlinePlayerControls extends ConsumerWidget {
  /// Creates [InlinePlayerControls].
  const InlinePlayerControls({super.key, required this.album});

  /// The album whose playback this widget controls.
  final RipAlbum album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlaying = ref.watch(nowPlayingProvider);
    if (nowPlaying.album?.id != album.id) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final playerState = ref.watch(playerStateProvider).value;
    final isPlaying = playerState?.playing ?? false;
    final position = ref.watch(playbackPositionProvider).value ?? Duration.zero;
    final duration =
        ref.watch(playbackDurationProvider).value ?? Duration.zero;
    final currentIndex = ref.watch(currentTrackIndexProvider).value ?? 0;
    final loopMode = ref.watch(loopModeProvider);
    final shuffleEnabled = ref.watch(shuffleEnabledProvider);
    final volume = ref.watch(volumeProvider);

    final trackTitle = currentIndex < nowPlaying.tracks.length
        ? (nowPlaying.tracks[currentIndex].title ??
            'Track ${nowPlaying.tracks[currentIndex].trackNumber}')
        : 'Unknown';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AlbumCoverArt(albumId: album.id, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    trackTitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Seek bar
            Row(
              children: [
                Text(
                  formatPlaybackDuration(position),
                  style: theme.textTheme.bodySmall,
                ),
                Expanded(
                  child: Slider(
                    value: duration.inMilliseconds > 0
                        ? position.inMilliseconds
                            .clamp(0, duration.inMilliseconds)
                            .toDouble()
                        : 0,
                    max: duration.inMilliseconds > 0
                        ? duration.inMilliseconds.toDouble()
                        : 1,
                    onChanged: (value) {
                      ref.read(playbackActionProvider.notifier).seek(
                            Duration(milliseconds: value.toInt()),
                          );
                    },
                  ),
                ),
                Text(
                  formatPlaybackDuration(duration),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            // Transport controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Shuffle toggle
                IconButton(
                  icon: Icon(
                    Icons.shuffle,
                    size: 20,
                    color: shuffleEnabled ? colors.primary : null,
                  ),
                  tooltip: shuffleEnabled ? 'Shuffle on' : 'Shuffle off',
                  onPressed: () => ref
                      .read(playbackActionProvider.notifier)
                      .setShuffleEnabled(!shuffleEnabled),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () =>
                      ref.read(playbackActionProvider.notifier).seekToPrevious(),
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 36),
                  onPressed: () => ref
                      .read(playbackActionProvider.notifier)
                      .togglePlayPause(),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () =>
                      ref.read(playbackActionProvider.notifier).seekToNext(),
                ),
                // Repeat mode toggle
                IconButton(
                  icon: Icon(
                    loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
                    size: 20,
                    color: loopMode != LoopMode.off ? colors.primary : null,
                  ),
                  tooltip: _loopModeLabel(loopMode),
                  onPressed: () {
                    final next = _nextLoopMode(loopMode);
                    ref
                        .read(playbackActionProvider.notifier)
                        .setLoopMode(next);
                  },
                ),
              ],
            ),
            // Volume slider + play-on-select toggle
            Row(
              children: [
                Icon(
                  volume > 0 ? Icons.volume_up : Icons.volume_off,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
                Expanded(
                  child: Slider(
                    value: volume,
                    min: 0,
                    max: 1,
                    onChanged: (value) =>
                        ref.read(playbackActionProvider.notifier).setVolume(value),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Play on select',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, size: 16,
                          color: colors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      SizedBox(
                        height: 24,
                        child: Switch(
                          value: ref.watch(playOnSelectProvider),
                          onChanged: (_) => ref
                              .read(playOnSelectProvider.notifier)
                              .toggle(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LoopMode _nextLoopMode(LoopMode current) {
    switch (current) {
      case LoopMode.off:
        return LoopMode.all;
      case LoopMode.all:
        return LoopMode.one;
      case LoopMode.one:
        return LoopMode.off;
    }
  }

  String _loopModeLabel(LoopMode mode) {
    switch (mode) {
      case LoopMode.off:
        return 'Repeat off';
      case LoopMode.all:
        return 'Repeat all';
      case LoopMode.one:
        return 'Repeat one';
    }
  }
}

/// Displays album cover art loaded from directory images or embedded FLAC
/// metadata. Shows a placeholder icon when no cover art is available.
class AlbumCoverArt extends ConsumerWidget {
  /// Creates an [AlbumCoverArt] widget.
  const AlbumCoverArt({super.key, required this.albumId, this.size = 48});

  /// The album ID to load cover art for.
  final String albumId;

  /// The width and height of the cover art image.
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverAsync = ref.watch(albumCoverArtProvider(albumId));
    final colors = Theme.of(context).colorScheme;

    return coverAsync.when(
      data: (Uint8List? bytes) {
        if (bytes == null) {
          return _placeholder(colors);
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _placeholder(colors),
          ),
        );
      },
      loading: () => SizedBox(width: size, height: size),
      error: (_, _) => SizedBox(width: size, height: size),
    );
  }

  Widget _placeholder(ColorScheme colors) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        Icons.album,
        size: size * 0.6,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}
