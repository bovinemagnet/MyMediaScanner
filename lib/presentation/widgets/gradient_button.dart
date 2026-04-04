import 'package:flutter/material.dart';
import 'package:mymediascanner/app/theme/app_theme_extensions.dart';

/// A CTA button with a gradient background matching the design system's
/// primary-to-primary-container gradient at 135 degrees.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final design = theme.extension<AppDesignExtension>();
    final colors = theme.colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(8);

    final gradient = design?.gradientPrimary ??
        LinearGradient(
          colors: [colors.primary, colors.primaryContainer],
        );

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            gradient: onPressed != null ? gradient : null,
            color: onPressed == null
                ? colors.onSurface.withValues(alpha: 0.12)
                : null,
            borderRadius: radius,
          ),
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: DefaultTextStyle.merge(
            style: theme.textTheme.labelLarge?.copyWith(
              color: onPressed != null
                  ? colors.onPrimary
                  : colors.onSurface.withValues(alpha: 0.38),
              fontWeight: FontWeight.w600,
            ),
            child: IconTheme.merge(
              data: IconThemeData(
                color: onPressed != null
                    ? colors.onPrimary
                    : colors.onSurface.withValues(alpha: 0.38),
                size: 18,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
