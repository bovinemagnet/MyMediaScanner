/// Persistent mini player bar widget for audio playback.
///
/// Displays the currently playing track with transport controls and a
/// progress indicator. Hidden when nothing is playing.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';

/// A persistent mini player bar shown at the bottom of the screen.
///
/// Watches Riverpod providers for playback state and displays track info,
/// transport controls, and a thin progress indicator. Returns
/// [SizedBox.shrink] when no album is loaded.
class MiniPlayerBar extends ConsumerWidget {
  /// Creates a [MiniPlayerBar].
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlaying = ref.watch(nowPlayingProvider);

    if (nowPlaying.album == null) {
      return const SizedBox.shrink();
    }

    final currentIndex =
        ref.watch(currentTrackIndexProvider).value ?? 0;
    final position =
        ref.watch(playbackPositionProvider).value ?? Duration.zero;
    final duration =
        ref.watch(playbackDurationProvider).value ?? Duration.zero;
    final isPlaying =
        ref.watch(playerStateProvider).value?.playing ?? false;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Bounds-check track index
    final tracks = nowPlaying.tracks;
    final safeIndex =
        (currentIndex >= 0 && currentIndex < tracks.length) ? currentIndex : 0;
    final track = tracks.isNotEmpty ? tracks[safeIndex] : null;

    final trackTitle =
        track?.title ?? 'Track ${track?.trackNumber ?? safeIndex + 1}';
    final artist = nowPlaying.album?.artist ?? 'Unknown Artist';

    final durationMs = duration.inMilliseconds;
    final progressValue =
        durationMs > 0 ? position.inMilliseconds / durationMs : 0.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withAlpha(38), // ~0.15 alpha
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: progressValue,
            minHeight: 2,
            color: colorScheme.primary,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Track info — tap to navigate to rips screen
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.go('/rips'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          trackTitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          artist,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                // Transport controls
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 24),
                  onPressed: () => ref
                      .read(playbackActionProvider.notifier)
                      .seekToPrevious(),
                  tooltip: 'Previous track',
                ),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 32,
                  ),
                  onPressed: () => ref
                      .read(playbackActionProvider.notifier)
                      .togglePlayPause(),
                  tooltip: isPlaying ? 'Pause' : 'Play',
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 24),
                  onPressed: () =>
                      ref.read(playbackActionProvider.notifier).seekToNext(),
                  tooltip: 'Next track',
                ),
                // Close button
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () =>
                      ref.read(playbackActionProvider.notifier).stop(),
                  tooltip: 'Stop playback',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
