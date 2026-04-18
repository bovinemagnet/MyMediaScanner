import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mymediascanner/app/theme/app_colors.dart';

/// Design system extension carrying glassmorphism, gradient, and
/// ghost-border tokens that Material's [ColorScheme] does not cover.
class AppDesignExtension extends ThemeExtension<AppDesignExtension> {
  const AppDesignExtension({
    required this.ghostBorderColor,
    required this.gradientPrimary,
    required this.glassOpacity,
    required this.glassBlur,
    required this.ambientShadow,
    required this.sidebarActiveBackground,
  });

  factory AppDesignExtension.light() => AppDesignExtension(
        ghostBorderColor:
            AppColors.lightOutlineVariant.withValues(alpha: 0.15),
        gradientPrimary: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.lightPrimary, AppColors.lightPrimaryDim],
        ),
        glassOpacity: 0.8,
        glassBlur: 24.0,
        ambientShadow: BoxShadow(
          color: AppColors.lightOnSurface.withValues(alpha: 0.06),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
        sidebarActiveBackground:
            AppColors.lightPrimary.withValues(alpha: 0.10),
      );

  factory AppDesignExtension.dark() => AppDesignExtension(
        ghostBorderColor:
            AppColors.darkOutlineVariant.withValues(alpha: 0.15),
        gradientPrimary: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkPrimary, AppColors.darkPrimaryContainer],
        ),
        glassOpacity: 0.6,
        glassBlur: 12.0,
        ambientShadow: BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
        sidebarActiveBackground:
            AppColors.darkPrimary.withValues(alpha: 0.10),
      );

  /// Warm-neutral Popcorn light tuning.
  factory AppDesignExtension.popcornLight() => AppDesignExtension(
        ghostBorderColor:
            AppColors.popcornOutlineVariant.withValues(alpha: 0.35),
        gradientPrimary: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.popcornPrimary, AppColors.popcornPrimaryContainer],
        ),
        glassOpacity: 0.85,
        glassBlur: 24.0,
        ambientShadow: BoxShadow(
          color: AppColors.popcornOnSurface.withValues(alpha: 0.08),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
        sidebarActiveBackground:
            AppColors.popcornPrimary.withValues(alpha: 0.12),
      );

  /// Warm-charcoal Popcorn dark tuning.
  factory AppDesignExtension.popcornDark() => AppDesignExtension(
        ghostBorderColor:
            AppColors.popcornDarkOutlineVariant.withValues(alpha: 0.45),
        gradientPrimary: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.popcornDarkPrimary,
            AppColors.popcornDarkPrimaryContainer,
          ],
        ),
        glassOpacity: 0.7,
        glassBlur: 16.0,
        ambientShadow: BoxShadow(
          color: Colors.black.withValues(alpha: 0.45),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
        sidebarActiveBackground:
            AppColors.popcornDarkPrimary.withValues(alpha: 0.14),
      );

  /// Ghost border — outline-variant at 15 % opacity.
  final Color ghostBorderColor;

  /// Primary gradient for CTA buttons (135 deg, primary → primary-container).
  final LinearGradient gradientPrimary;

  /// Opacity for glassmorphism surfaces.
  final double glassOpacity;

  /// Backdrop blur radius for glassmorphism surfaces.
  final double glassBlur;

  /// Ambient shadow for floating elements.
  final BoxShadow ambientShadow;

  /// Active-item tint for sidebar navigation.
  final Color sidebarActiveBackground;

  // ── ThemeExtension contract ────────────────────────────────────────

  @override
  AppDesignExtension copyWith({
    Color? ghostBorderColor,
    LinearGradient? gradientPrimary,
    double? glassOpacity,
    double? glassBlur,
    BoxShadow? ambientShadow,
    Color? sidebarActiveBackground,
  }) {
    return AppDesignExtension(
      ghostBorderColor: ghostBorderColor ?? this.ghostBorderColor,
      gradientPrimary: gradientPrimary ?? this.gradientPrimary,
      glassOpacity: glassOpacity ?? this.glassOpacity,
      glassBlur: glassBlur ?? this.glassBlur,
      ambientShadow: ambientShadow ?? this.ambientShadow,
      sidebarActiveBackground:
          sidebarActiveBackground ?? this.sidebarActiveBackground,
    );
  }

  @override
  AppDesignExtension lerp(
      covariant ThemeExtension<AppDesignExtension>? other, double t) {
    if (other is! AppDesignExtension) return this;
    return AppDesignExtension(
      ghostBorderColor:
          Color.lerp(ghostBorderColor, other.ghostBorderColor, t)!,
      gradientPrimary:
          LinearGradient.lerp(gradientPrimary, other.gradientPrimary, t)!,
      glassOpacity: lerpDouble(glassOpacity, other.glassOpacity, t)!,
      glassBlur: lerpDouble(glassBlur, other.glassBlur, t)!,
      ambientShadow:
          BoxShadow.lerp(ambientShadow, other.ambientShadow, t)!,
      sidebarActiveBackground: Color.lerp(
          sidebarActiveBackground, other.sidebarActiveBackground, t)!,
    );
  }
}
