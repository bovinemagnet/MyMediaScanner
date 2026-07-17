// Author: Paul Snow

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/app/theme/app_media_colors.dart';
import 'package:mymediascanner/app/theme/app_typography.dart';
import 'package:mymediascanner/domain/entities/rip_album_health.dart';
import 'package:mymediascanner/presentation/providers/rip_health_provider.dart';

Color ripHealthColour(BuildContext context, RipAlbumHealth health) {
  final colors = Theme.of(context).colorScheme;
  final mediaColors = context.mediaColors;
  return switch (health) {
    RipAlbumHealth.verified => mediaColors.book,
    RipAlbumHealth.attention => mediaColors.tv,
    RipAlbumHealth.mismatch => colors.error,
    RipAlbumHealth.notAnalysed => colors.outline,
  };
}

String ripHealthLabel(RipAlbumHealth health) => switch (health) {
      RipAlbumHealth.verified => 'VERIFIED',
      RipAlbumHealth.attention => 'ATTENTION',
      RipAlbumHealth.mismatch => 'MISMATCH',
      RipAlbumHealth.notAnalysed => 'NOT ANALYSED',
    };

IconData ripHealthIcon(RipAlbumHealth health) => switch (health) {
      RipAlbumHealth.verified => Icons.verified,
      RipAlbumHealth.attention => Icons.warning_amber,
      RipAlbumHealth.mismatch => Icons.error,
      RipAlbumHealth.notAnalysed => Icons.help_outline,
    };

/// Small rounded status pill: icon + uppercase label, optionally suffixed
/// with a mono detail such as `AR 16/16`.
class RipStatusPill extends StatelessWidget {
  const RipStatusPill({required this.health, this.detail, super.key});

  final RipAlbumHealth health;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final colour = ripHealthColour(context, health);
    final label = detail == null
        ? ripHealthLabel(health)
        : '${ripHealthLabel(health)} · $detail';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ripHealthIcon(health), size: 12, color: colour),
          const SizedBox(width: 5),
          Text(label, style: AppTypography.monoLabel(color: colour)),
        ],
      ),
    );
  }
}

/// Four compact header stat cards: verified / attention / AR coverage /
/// total size. Reads [ripLibraryHealthStatsProvider].
class RipHealthStatCards extends ConsumerWidget {
  const RipHealthStatCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(ripLibraryHealthStatsProvider);
    final theme = Theme.of(context);
    final mediaColors = context.mediaColors;

    String formatSize(int bytes) {
      if (bytes >= 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(0)} GB';
      }
      return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatCard(
          label: 'VERIFIED',
          value: '${stats.counts[RipAlbumHealth.verified] ?? 0}',
          dotColour: mediaColors.book,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'ATTENTION',
          value: '${stats.counts[RipAlbumHealth.attention] ?? 0}',
          dotColour: mediaColors.tv,
          valueColour: mediaColors.tv,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'AR COVERAGE',
          value: '${(stats.arCoverage * 100).round()}%',
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'TOTAL SIZE',
          value: formatSize(stats.totalSizeBytes),
          valueColour: theme.colorScheme.primary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.dotColour,
    this.valueColour,
  });

  final String label;
  final String value;
  final Color? dotColour;
  final Color? valueColour;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 104),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColour != null) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColour,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTypography.monoLabel(
                  color: colors.onSurfaceVariant,
                  fontSize: 9,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: AppTypography.monoNumeric(
              color: valueColour ?? colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
