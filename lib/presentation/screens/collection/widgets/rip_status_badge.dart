/// Small overlay badge indicating the rip status of a collection item.
///
/// Renders as a 20-px circular badge positioned in the top-right corner of
/// its parent stack.  Returns a [SizedBox.shrink] when the item has no rip or
/// while the status is still loading.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/app/theme/app_media_colors.dart';
import 'package:mymediascanner/presentation/providers/collection_rip_status_provider.dart';

class RipStatusBadge extends ConsumerWidget {
  const RipStatusBadge({super.key, required this.mediaItemId});

  final String mediaItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(mediaItemRipStatusProvider(mediaItemId));

    return statusAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (status) {
        if (status == RipStatus.noRip) return const SizedBox.shrink();

        final mediaColors = context.mediaColors;
        final Color badgeColour;
        final IconData badgeIcon;

        switch (status) {
          case RipStatus.verified:
            badgeColour = mediaColors.book;
            badgeIcon = Icons.check;
          case RipStatus.qualityIssues:
            badgeColour = mediaColors.tv;
            badgeIcon = Icons.priority_high;
          case RipStatus.ripped:
            badgeColour = mediaColors.music;
            badgeIcon = Icons.music_note;
          case RipStatus.noRip:
            return const SizedBox.shrink();
        }

        return Positioned(
          top: 6,
          right: 6,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: badgeColour.withValues(alpha: 0.15),
              border: Border.all(color: badgeColour.withValues(alpha: 0.3)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              badgeIcon,
              size: 12,
              color: badgeColour,
            ),
          ),
        );
      },
    );
  }
}
