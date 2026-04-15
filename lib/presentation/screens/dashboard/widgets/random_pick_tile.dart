// Dashboard tile that opens the "Pick something for me" bottom sheet.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:mymediascanner/presentation/screens/dashboard/widgets/random_pick_sheet.dart';

class RandomPickTile extends StatelessWidget {
  const RandomPickTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: () => _openSheet(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.casino_outlined, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              'Pick something for me',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Surprise me',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const RandomPickSheet(),
    );
  }
}
