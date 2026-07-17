import 'package:flutter/material.dart';
import 'package:mymediascanner/app/theme/app_typography.dart';

/// Inline screen header used on desktop in place of [AppBar].
///
/// Renders a large Manrope headline with an optional subtitle and
/// trailing actions row.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.actions,
    this.bottom,
    this.padding,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? bottom;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Outer Wrap so on narrow windows the actions group flows to
          // a new line below the title rather than overflowing.
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (eyebrow != null) ...[
                      Text(
                        eyebrow!,
                        style: AppTypography.monoLabel(
                          color: colors.primary,
                          letterSpacing: 2.4,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      title,
                      style: eyebrow != null
                          ? AppTypography.displayTitle(
                              color: colors.onSurface)
                          : theme.textTheme.headlineLarge,
                      softWrap: true,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null && actions!.isNotEmpty)
                // Inner Wrap so individual action widgets reflow onto
                // multiple lines instead of being squeezed and clipping.
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: actions!,
                ),
            ],
          ),
          if (bottom != null) ...[
            const SizedBox(height: 12),
            bottom!,
          ],
        ],
      ),
    );
  }
}
