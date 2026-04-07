// Time period selector for the insights dashboard.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Available time periods for growth chart filtering.
enum TimePeriod {
  threeMonths('3 months', 3),
  sixMonths('6 months', 6),
  twelveMonths('12 months', 12),
  allTime('All time', 0);

  const TimePeriod(this.label, this.months);

  final String label;

  /// Number of months to show. 0 means all time.
  final int months;
}

/// Notifier holding the currently selected time period.
class TimePeriodNotifier extends Notifier<TimePeriod> {
  @override
  TimePeriod build() => TimePeriod.twelveMonths;

  void setPeriod(TimePeriod period) {
    state = period;
  }
}

/// Provider holding the currently selected time period.
final timePeriodProvider =
    NotifierProvider<TimePeriodNotifier, TimePeriod>(TimePeriodNotifier.new);

/// Segmented button for selecting a time period.
class TimePeriodSelector extends ConsumerWidget {
  const TimePeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(timePeriodProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TIME PERIOD',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<TimePeriod>(
            segments: TimePeriod.values.map((period) {
              return ButtonSegment<TimePeriod>(
                value: period,
                label: Text(period.label),
              );
            }).toList(),
            selected: {selected},
            onSelectionChanged: (newSelection) {
              ref
                  .read(timePeriodProvider.notifier)
                  .setPeriod(newSelection.first);
            },
            style: SegmentedButton.styleFrom(
              selectedForegroundColor: colors.onPrimary,
              selectedBackgroundColor: colors.primary,
              foregroundColor: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
