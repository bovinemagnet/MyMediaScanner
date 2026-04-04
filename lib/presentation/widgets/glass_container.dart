import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mymediascanner/app/theme/app_theme_extensions.dart';

/// A container with glassmorphism effect (backdrop blur + semi-transparent
/// background). Falls back to an opaque surface if the platform does not
/// support [BackdropFilter].
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final design = theme.extension<AppDesignExtension>();
    final colors = theme.colorScheme;

    final radius = borderRadius ?? BorderRadius.circular(8);
    final blur = design?.glassBlur ?? 12.0;
    final opacity = design?.glassOpacity ?? 0.6;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: colors.surfaceContainer.withValues(alpha: opacity),
            borderRadius: radius,
            border: Border.all(
              color: design?.ghostBorderColor ??
                  colors.outlineVariant.withValues(alpha: 0.15),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
