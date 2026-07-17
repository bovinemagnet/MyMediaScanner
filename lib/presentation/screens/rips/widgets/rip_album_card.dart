// Author: Paul Snow

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/app/theme/app_typography.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_album_health.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/audio_player_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_health_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_album_detail_dialog.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_cover_thumb.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_health_widgets.dart';

/// Redesigned album card: cover, artist eyebrow, title, health pill,
/// meta row, AccurateRip progress and detail chips.
class RipAlbumCard extends ConsumerWidget {
  const RipAlbumCard({
    required this.album,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.showCheckbox = false,
    super.key,
  });

  final RipAlbum album;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool showCheckbox;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tracks =
        ref.watch(ripTracksProvider(album.id)).whenOrNull(data: (t) => t) ??
            const <RipTrack>[];
    final healthMap = ref.watch(ripAlbumHealthMapProvider);
    final health = ripAlbumHealthOf(healthMap, album.id);
    final healthColour = ripHealthColour(context, health);
    final nowPlayingAlbumId =
        ref.watch(nowPlayingProvider.select((s) => s.album?.id));
    final isNowPlaying = nowPlayingAlbumId == album.id;

    final arVerified =
        tracks.where((t) => t.accurateRipStatus == 'verified').length;
    final totalDefects =
        tracks.fold<int>(0, (sum, t) => sum + t.totalDefects);
    final totalDurationMs =
        tracks.fold<int>(0, (sum, t) => sum + (t.durationMs ?? 0));
    final hasCue = album.cueFilePath != null;
    final hasLog = tracks.any((t) => t.ripLogSource != null);
    final format = _formatOf(tracks);

    final highlight = isSelected || isNowPlaying;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: highlight
            ? BorderSide(color: colors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap ??
            () => showDialog<void>(
                  context: context,
                  builder: (_) => RipAlbumDetailDialog(album: album),
                ),
        onLongPress: onLongPress,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RipCoverThumb(coverPath: album.coverPath, size: 56),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (album.artist ?? 'UNKNOWN ARTIST')
                                  .toUpperCase(),
                              style: AppTypography.monoLabel(
                                color: colors.onSurfaceVariant,
                                fontSize: 8.5,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              album.albumTitle ?? 'Unknown Album',
                              style: AppTypography.displayTitle(
                                color: colors.onSurface,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      RipStatusPill(health: health),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.music_note,
                          size: 13, color: colors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${album.trackCount}', style: _metaStyle(colors)),
                      const SizedBox(width: 15),
                      Text(_formatSize(album.totalSizeBytes),
                          style: _metaStyle(colors)),
                      if (totalDurationMs > 0) ...[
                        const SizedBox(width: 15),
                        Text(_formatTotalDuration(totalDurationMs),
                            style: _metaStyle(colors)),
                      ],
                      const Spacer(),
                      if (isNowPlaying)
                        Icon(Icons.volume_up,
                            size: 14, color: colors.primary),
                      if (album.mediaItemId != null)
                        Padding(
                          padding:
                              EdgeInsets.only(left: isNowPlaying ? 6 : 0),
                          child: Icon(Icons.link,
                              size: 14, color: colors.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ACCURATERIP',
                        style: AppTypography.monoLabel(
                          color: colors.outline,
                          fontSize: 8.5,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        health == RipAlbumHealth.notAnalysed
                            ? '— / ${tracks.length}'
                            : '$arVerified / ${tracks.length}',
                        style: AppTypography.monoLabel(
                          color: healthColour,
                          fontSize: 8.5,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: tracks.isEmpty ? 0 : arVerified / tracks.length,
                      minHeight: 5,
                      backgroundColor: colors.surfaceContainerHighest,
                      color: healthColour,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (format != null)
                        _MiniChip(label: format),
                      if (health == RipAlbumHealth.notAnalysed)
                        _MiniChip(
                          label: 'Analyse',
                          icon: Icons.analytics,
                          colour: colors.primary,
                          onTap: () => ref
                              .read(qualityAnalysisNotifierProvider.notifier)
                              .analyse(album.id),
                        )
                      else
                        _MiniChip(
                          label: totalDefects == 0
                              ? '0 defects'
                              : '$totalDefects defects',
                          colour: totalDefects == 0
                              ? ripHealthColour(
                                  context, RipAlbumHealth.verified)
                              : ripHealthColour(
                                  context, RipAlbumHealth.attention),
                        ),
                      if (hasCue || hasLog)
                        _MiniChip(
                          label: hasCue && hasLog
                              ? 'CUE + LOG'
                              : hasCue
                                  ? 'CUE'
                                  : 'LOG',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (showCheckbox)
              Positioned(
                top: 6,
                right: 6,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primary
                          : colors.surface.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: isSelected
                          ? colors.onPrimary
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  TextStyle _metaStyle(ColorScheme colors) => AppTypography.monoLabel(
        color: colors.onSurfaceVariant,
        fontSize: 10,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w600,
      );

  String? _formatOf(List<RipTrack> tracks) {
    if (tracks.isEmpty) return null;
    final path = tracks.first.filePath.toLowerCase();
    if (path.endsWith('.flac')) return 'FLAC';
    if (path.endsWith('.mp3')) return 'MP3';
    return null;
  }

  String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  }

  String _formatTotalDuration(int ms) {
    final totalSeconds = ms ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final mm = minutes.toString().padLeft(hours > 0 ? 2 : 1, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$mm:$ss' : '$mm:$ss';
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, this.icon, this.colour, this.onTap});

  final String label;
  final IconData? icon;
  final Color? colour;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fg = colour ?? colors.onSurfaceVariant;
    final bg = colour != null
        ? colour!.withValues(alpha: 0.12)
        : colors.surfaceContainerHighest;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTypography.monoLabel(
              color: fg,
              fontSize: 9.5,
              letterSpacing: 0.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return chip;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: chip,
    );
  }
}
