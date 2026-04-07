import 'package:flutter/material.dart';

/// A small chip showing "OVERDUE" with the number of days overdue.
/// Uses the error colour from the current theme.
class OverdueBadge extends StatelessWidget {
  const OverdueBadge({super.key, required this.daysOverdue});

  final int daysOverdue;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = daysOverdue == 1
        ? 'OVERDUE (1 day)'
        : 'OVERDUE ($daysOverdue days)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.error,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
