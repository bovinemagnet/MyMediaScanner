import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatchScanCounter extends StatelessWidget {
  const BatchScanCounter({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Review batch',
      child: Material(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.go('/batch'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 16,
                    color: colors.onPrimaryContainer),
                const SizedBox(width: 4),
                Text(
                  '$count scanned',
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.chevron_right, size: 14,
                    color: colors.onPrimaryContainer),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
