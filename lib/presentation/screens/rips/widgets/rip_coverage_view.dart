// Author: Paul Snow

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/app/theme/app_typography.dart';
import 'package:mymediascanner/domain/entities/rip_coverage.dart';
import 'package:mymediascanner/presentation/providers/rip_coverage_provider.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_cover_thumb.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_health_widgets.dart';

/// Displays rip coverage across the music collection: how much of the
/// physical CD collection has been ripped to FLAC, and the quality of those
/// rips. Aggregate counts live in the screen header ([RipCoverageStatCards]).
class RipCoverageView extends ConsumerStatefulWidget {
  const RipCoverageView({super.key});

  @override
  ConsumerState<RipCoverageView> createState() => _RipCoverageViewState();
}

class _RipCoverageViewState extends ConsumerState<RipCoverageView> {
  Set<CoverageStatus> _activeFilters = {};

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(ripCoverageEntriesProvider);
    final stats = ref.watch(ripCoverageStatsProvider);

    final filtered = _activeFilters.isEmpty
        ? entries
        : entries.where((e) => _activeFilters.contains(e.status)).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final status in CoverageStatus.values) ...[
                  _CoverageFilterChip(
                    status: status,
                    count: stats.countOf(status),
                    selected: _activeFilters.contains(status),
                    onSelected: (selected) {
                      setState(() {
                        _activeFilters = {..._activeFilters};
                        if (selected) {
                          _activeFilters.add(status);
                        } else {
                          _activeFilters.remove(status);
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    entries.isEmpty
                        ? 'No music items in the collection yet.'
                        : 'No items match the current filters.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _CoverageRow(entry: filtered[index]),
                ),
        ),
      ],
    );
  }
}

String coverageStatusLabel(CoverageStatus status) => switch (status) {
      CoverageStatus.notRipped => 'Not ripped',
      CoverageStatus.partiallyRipped => 'Partially ripped',
      CoverageStatus.fullyRipped => 'Fully ripped',
      CoverageStatus.qualityIssues => 'Quality issues',
    };

IconData coverageStatusIcon(CoverageStatus status) => switch (status) {
      CoverageStatus.notRipped => Icons.cancel,
      CoverageStatus.partiallyRipped => Icons.timelapse,
      CoverageStatus.fullyRipped => Icons.check_circle,
      CoverageStatus.qualityIssues => Icons.warning,
    };

/// Pill-style filter chip mirroring the Library tab's health chips.
class _CoverageFilterChip extends StatelessWidget {
  const _CoverageFilterChip({
    required this.status,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  final CoverageStatus status;
  final int count;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final colour = coverageStatusColour(context, status);
    return ChoiceChip(
      selected: selected,
      showCheckmark: false,
      shape: const StadiumBorder(),
      avatar: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: colour,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      label: Text('${coverageStatusLabel(status)} $count'),
      onSelected: onSelected,
    );
  }
}

/// A single coverage row: cover, title/artist, status pill and track count.
class _CoverageRow extends StatelessWidget {
  const _CoverageRow({required this.entry});

  final RipCoverageEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final colour = coverageStatusColour(context, entry.status);

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/collection/item/${entry.item.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              RipCoverThumb(coverPath: entry.album?.coverPath, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.item.title,
                      style: AppTypography.displayTitle(
                        color: colors.onSurface,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((entry.item.subtitle ?? '').isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        entry.item.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _CoveragePill(status: entry.status, colour: colour),
              if (entry.album != null) ...[
                const SizedBox(width: 12),
                Text(
                  '${entry.album!.trackCount} tracks',
                  style: AppTypography.monoLabel(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CoveragePill extends StatelessWidget {
  const _CoveragePill({required this.status, required this.colour});

  final CoverageStatus status;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(coverageStatusIcon(status), size: 12, color: colour),
          const SizedBox(width: 5),
          Text(
            coverageStatusLabel(status).toUpperCase(),
            style: AppTypography.monoLabel(color: colour),
          ),
        ],
      ),
    );
  }
}
