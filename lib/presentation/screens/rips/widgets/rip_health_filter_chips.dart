// Author: Paul Snow

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/rip_album_health.dart';
import 'package:mymediascanner/presentation/providers/rip_health_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_health_widgets.dart';

/// Health status filter chips for the rips Library view. The selected
/// value filters both the album grid and the table.
class RipHealthFilterChips extends ConsumerWidget {
  const RipHealthFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(ripHealthFilterProvider);
    final stats = ref.watch(ripLibraryHealthStatsProvider);

    int countFor(RipHealthFilter filter) => switch (filter) {
          RipHealthFilter.all => stats.totalAlbums,
          RipHealthFilter.verified =>
            stats.counts[RipAlbumHealth.verified] ?? 0,
          RipHealthFilter.attention =>
            stats.counts[RipAlbumHealth.attention] ?? 0,
          RipHealthFilter.mismatch =>
            stats.counts[RipAlbumHealth.mismatch] ?? 0,
          RipHealthFilter.notAnalysed =>
            stats.counts[RipAlbumHealth.notAnalysed] ?? 0,
        };

    Color? dotFor(RipHealthFilter filter) => switch (filter) {
          RipHealthFilter.all => null,
          RipHealthFilter.verified =>
            ripHealthColour(context, RipAlbumHealth.verified),
          RipHealthFilter.attention =>
            ripHealthColour(context, RipAlbumHealth.attention),
          RipHealthFilter.mismatch =>
            ripHealthColour(context, RipAlbumHealth.mismatch),
          RipHealthFilter.notAnalysed => null,
        };

    String labelFor(RipHealthFilter filter) => switch (filter) {
          RipHealthFilter.all => 'All',
          RipHealthFilter.verified => 'Verified',
          RipHealthFilter.attention => 'Needs attention',
          RipHealthFilter.mismatch => 'Mismatch',
          RipHealthFilter.notAnalysed => 'Not analysed',
        };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in RipHealthFilter.values) ...[
            ChoiceChip(
              selected: selected == filter,
              showCheckmark: false,
              shape: const StadiumBorder(),
              avatar: dotFor(filter) == null
                  ? null
                  : Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dotFor(filter),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
              label: Text('${labelFor(filter)} ${countFor(filter)}'),
              onSelected: (_) =>
                  ref.read(ripHealthFilterProvider.notifier).set(filter),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
