// Rip library coverage card for the insights dashboard.
//
// Author: Paul Snow
// Since: 0.0.0

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mymediascanner/app/theme/app_colors.dart';

/// Card showing rip library statistics: total albums, matched/unmatched
/// ratio, music collection coverage, and total library size.
class RipCoverageCard extends StatelessWidget {
  const RipCoverageCard({
    super.key,
    required this.totalRipAlbums,
    required this.matchedRipAlbums,
    required this.unmatchedRipAlbums,
    required this.totalRipSizeBytes,
    required this.musicItemsWithRips,
    required this.totalMusicItems,
  });

  final int totalRipAlbums;
  final int matchedRipAlbums;
  final int unmatchedRipAlbums;
  final int totalRipSizeBytes;
  final int musicItemsWithRips;
  final int totalMusicItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (totalRipAlbums == 0 && totalMusicItems == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RIP COVERAGE',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No rip library data available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final coveragePercent = totalMusicItems > 0
        ? (musicItemsWithRips / totalMusicItems * 100)
        : 0.0;
    final matchedPercent = totalRipAlbums > 0
        ? (matchedRipAlbums / totalRipAlbums * 100)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RIP COVERAGE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // ── Total rip albums ─────────────────────────────
          Row(
            children: [
              const Icon(Icons.album, size: 24, color: AppColors.musicColor),
              const SizedBox(width: 8),
              Text(
                '$totalRipAlbums',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.musicColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'rip albums',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Matched / Unmatched progress bar ─────────────
          Text(
            'MATCHED VS UNMATCHED',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.0,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  if (matchedRipAlbums > 0)
                    Expanded(
                      flex: matchedRipAlbums,
                      child: Container(color: AppColors.musicColor),
                    ),
                  if (unmatchedRipAlbums > 0)
                    Expanded(
                      flex: unmatchedRipAlbums,
                      child: Container(
                          color: colors.surfaceContainerHighest),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$matchedRipAlbums matched (${matchedPercent.toStringAsFixed(0)}%)',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.musicColor,
                ),
              ),
              Text(
                '$unmatchedRipAlbums unmatched',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Music collection coverage ────────────────────
          Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CustomPaint(
                  painter: _CoverageRingPainter(
                    percentage: coveragePercent,
                    trackColour: colors.surfaceContainerHighest,
                    progressColour: AppColors.musicColor,
                  ),
                  child: Center(
                    child: Text(
                      '${coveragePercent.toStringAsFixed(0)}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Collection Coverage',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$musicItemsWithRips of $totalMusicItems music items ripped',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Total library size ───────────────────────────
          Row(
            children: [
              Icon(Icons.storage, size: 16, color: colors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                'Library size: ${_formatBytes(totalRipSizeBytes)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (math.log(bytes) / math.log(1024)).floor();
    final value = bytes / math.pow(1024, i);
    return '${value.toStringAsFixed(1)} ${suffixes[i]}';
  }
}

class _CoverageRingPainter extends CustomPainter {
  _CoverageRingPainter({
    required this.percentage,
    required this.trackColour,
    required this.progressColour,
  });

  final double percentage;
  final Color trackColour;
  final Color progressColour;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 3;
    const strokeWidth = 5.0;

    // Track
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..color = trackColour
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (percentage > 0) {
      final sweepAngle = (percentage / 100) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        Paint()
          ..color = progressColour
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CoverageRingPainter oldDelegate) =>
      percentage != oldDelegate.percentage;
}
