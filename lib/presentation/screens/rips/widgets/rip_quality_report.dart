// Author: Paul Snow

import 'package:flutter/material.dart';
import 'package:mymediascanner/app/theme/app_typography.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';

/// 2×2 grid of album-level quality metrics derived from analysed tracks.
class RipQualityReport extends StatelessWidget {
  const RipQualityReport({required this.tracks, super.key});

  final List<RipTrack> tracks;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final qualities = tracks
        .map((t) => t.trackQuality)
        .whereType<double>()
        .toList(growable: false);
    final avgQuality = qualities.isEmpty
        ? null
        : qualities.reduce((a, b) => a + b) / qualities.length;

    final confidences = tracks
        .where((t) => t.accurateRipStatus == 'verified')
        .map((t) => t.accurateRipConfidence)
        .whereType<int>()
        .toList(growable: false);
    final minConfidence = confidences.isEmpty
        ? null
        : confidences.reduce((a, b) => a < b ? a : b);

    final peaks = tracks
        .map((t) => t.peakLevel)
        .whereType<double>()
        .toList(growable: false);
    final maxPeak = peaks.isEmpty
        ? null
        : peaks.reduce((a, b) => a > b ? a : b);

    final totalDefects = tracks.fold<int>(0, (sum, t) => sum + t.totalDefects);

    String peakText(double p) =>
        p <= 1 ? '${(p * 100).toStringAsFixed(1)}%' : p.toStringAsFixed(2);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 9,
      crossAxisSpacing: 9,
      childAspectRatio: 2.6,
      children: [
        _MetricTile(
          label: 'QUALITY SCORE',
          value: avgQuality == null ? '—' : '${(avgQuality * 100).round()}',
          suffix: avgQuality == null ? null : '/100',
        ),
        _MetricTile(
          label: 'AR CONFIDENCE',
          value: minConfidence?.toString() ?? '—',
        ),
        _MetricTile(
          label: 'PEAK LEVEL',
          value: maxPeak == null ? '—' : peakText(maxPeak),
        ),
        _MetricTile(
          label: 'DEFECTS',
          value: '$totalDefects',
          valueColour: totalDefects > 0 ? colors.error : null,
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    this.suffix,
    this.valueColour,
  });

  final String label;
  final String value;
  final String? suffix;
  final Color? valueColour;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.monoLabel(
              color: colors.onSurfaceVariant,
              fontSize: 8.5,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text.rich(
            TextSpan(
              text: value,
              style: AppTypography.monoNumeric(
                color: valueColour ?? colors.onSurface,
                fontSize: 21,
              ),
              children: [
                if (suffix != null)
                  TextSpan(
                    text: suffix,
                    style: AppTypography.monoNumeric(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Provenance rows: rip tool, CUE/LOG presence, GNUDB disc ID.
class RipSourceSection extends StatelessWidget {
  const RipSourceSection({
    required this.album,
    required this.tracks,
    super.key,
  });

  final RipAlbum album;
  final List<RipTrack> tracks;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ripTool = tracks
        .map((t) => t.ripLogSource)
        .whereType<String>()
        .firstOrNull;
    final hasCue = album.cueFilePath != null;
    final hasLog = ripTool != null;
    final cueLog = hasCue && hasLog
        ? 'CUE + LOG'
        : hasCue
        ? 'CUE only'
        : hasLog
        ? 'LOG only'
        : 'None';

    Widget row(IconData icon, String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.outline),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.monoLabel(
              color: colors.onSurface,
              fontSize: 11,
              letterSpacing: 0.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        row(Icons.album, 'Ripped with', ripTool ?? '—'),
        row(Icons.verified_user, 'CUE + LOG', cueLog),
        row(Icons.travel_explore, 'GNUDB disc', album.gnudbDiscId ?? '—'),
      ],
    );
  }
}
