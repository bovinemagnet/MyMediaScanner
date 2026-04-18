// Author: Paul Snow

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/app/theme/app_media_colors.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

// ---------------------------------------------------------------------------
// QualityIcon
// ---------------------------------------------------------------------------

/// Displays a small icon representing a track's quality analysis status.
///
/// Wraps the icon in a [Tooltip] showing detailed quality information
/// when hovered or long-pressed.
class QualityIcon extends StatelessWidget {
  const QualityIcon({required this.track, super.key});

  final RipTrack track;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _tooltipText(),
      child: Icon(
        _icon(),
        color: _colour(context),
        size: 20,
      ),
    );
  }

  IconData _icon() {
    if (track.qualityCheckedAt == null) return Icons.help_outline;
    if (track.accurateRipStatus == 'verified' &&
        (track.clickCount ?? 0) > 0) {
      return Icons.warning_amber;
    }
    if (track.accurateRipStatus == 'verified') return Icons.check_circle;
    if (track.accurateRipStatus == 'mismatch') return Icons.cancel;
    if ((track.clickCount ?? 0) > 0) return Icons.warning_amber;
    return Icons.help_outline;
  }

  Color _colour(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final mediaColors = context.mediaColors;
    if (track.qualityCheckedAt == null) return colors.outline;
    if (track.accurateRipStatus == 'verified' &&
        (track.clickCount ?? 0) > 0) {
      return mediaColors.tv; // amber-like warning
    }
    if (track.accurateRipStatus == 'verified') return mediaColors.book;
    if (track.accurateRipStatus == 'mismatch') return colors.error;
    if ((track.clickCount ?? 0) > 0) return mediaColors.tv;
    return colors.outline;
  }

  String _tooltipText() {
    if (track.qualityCheckedAt == null) return 'Not analysed';

    final lines = <String>[];
    if (track.accurateRipStatus != null) {
      final arLine = StringBuffer('AR: ${track.accurateRipStatus}');
      if (track.accurateRipConfidence != null) {
        arLine.write(' (confidence: ${track.accurateRipConfidence})');
      }
      lines.add(arLine.toString());
    }
    if (track.peakLevel != null) {
      lines.add('Peak: ${track.peakLevel}');
    }
    if (track.clickCount != null) {
      lines.add('Clicks: ${track.clickCount}');
    }
    return lines.isEmpty ? 'Analysed' : lines.join('\n');
  }
}

// ---------------------------------------------------------------------------
// QualityAnalysisSection
// ---------------------------------------------------------------------------

/// Provides a button to trigger quality analysis for an album and shows
/// progress whilst the analysis is running.
class QualityAnalysisSection extends ConsumerWidget {
  const QualityAnalysisSection({required this.albumId, super.key});

  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(qualityAnalysisNotifierProvider);
    final tracksAsync = ref.watch(ripTracksProvider(albumId));
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status display
        if (analysisState.status == QualityAnalysisStatus.analysing) ...[
          LinearProgressIndicator(
            value: analysisState.totalTracks > 0
                ? analysisState.currentTrack / analysisState.totalTracks
                : null,
          ),
          const SizedBox(height: 4),
          if (analysisState.currentStep.isNotEmpty)
            Text(
              analysisState.currentStep,
              style: theme.textTheme.bodySmall,
            ),
          const SizedBox(height: 8),
        ],

        // Error display
        if (analysisState.status == QualityAnalysisStatus.complete &&
            analysisState.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              analysisState.error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.error,
              ),
            ),
          ),

        // Action button
        FilledButton.tonal(
          onPressed: analysisState.status == QualityAnalysisStatus.analysing
              ? null
              : () => ref
                  .read(qualityAnalysisNotifierProvider.notifier)
                  .analyse(albumId),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.analytics, size: 18),
              const SizedBox(width: 8),
              Text(_buttonLabel(analysisState, tracksAsync)),
            ],
          ),
        ),
      ],
    );
  }

  String _buttonLabel(
    QualityAnalysisState analysisState,
    AsyncValue<List<RipTrack>> tracksAsync,
  ) {
    if (analysisState.status == QualityAnalysisStatus.analysing) {
      return 'Analysing\u2026';
    }

    final tracks = tracksAsync.whenOrNull(data: (t) => t);
    if (tracks != null &&
        tracks.isNotEmpty &&
        tracks.every((t) => t.qualityCheckedAt != null)) {
      return 'Re-analyse Quality';
    }

    return 'Analyse Quality';
  }
}
