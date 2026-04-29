import 'package:flutter/material.dart';

/// Inline screen header used on desktop in place of [AppBar].
///
/// Renders a large Manrope headline with an optional subtitle and
/// trailing actions row.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.bottom,
    this.padding,
  });

  final String title;
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineLarge,
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
                // OverflowBar switches to a Column when the actions
                // can't fit in the available width on the same row,
                // preventing the bare-Row overflow that surfaced on
                // narrow desktop windows / the master pane.
                Flexible(
                  child: OverflowBar(
                    alignment: MainAxisAlignment.end,
                    spacing: 8,
                    overflowSpacing: 4,
                    children: actions!,
                  ),
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
