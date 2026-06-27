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

  /// Kinetic dark: electric green on near-black.
  factory AppDesignExtension.kineticDark() => AppDesignExtension(
        ghostBorderColor:
            AppColors.kineticDarkOutlineVariant.withValues(alpha: 0.20),
        gradientPrimary: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.kineticDarkPrimary,
            AppColors.kineticDarkPrimaryContainer,
          ],
        ),
        glassOpacity: 0.6,
        glassBlur: 12.0,
        ambientShadow: BoxShadow(
          color: Colors.black.withValues(alpha: 0.45),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
        sidebarActiveBackground:
            AppColors.kineticDarkPrimary.withValues(alpha: 0.12),
      );

  /// Kinetic light: mint-green on sage.
  factory AppDesignExtension.kineticLight() => AppDesignExtension(
        ghostBorderColor:
            AppColors.kineticLightOutlineVariant.withValues(alpha: 0.20),
        gradientPrimary: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.kineticLightPrimary,
            AppColors.kineticLightPrimaryContainer,
          ],
        ),
        glassOpacity: 0.82,
        glassBlur: 24.0,
        ambientShadow: BoxShadow(
          color: AppColors.kineticLightOnSurface.withValues(alpha: 0.05),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
        sidebarActiveBackground:
            AppColors.kineticLightPrimary.withValues(alpha: 0.10),
      );

  /// Vault dark: warm brass on espresso.
  factory AppDesignExtension.vaultDark() => AppDesignExtension(
        ghostBorderColor:
            AppColors.vaultDarkOutlineVariant.withValues(alpha: 0.25),
        gradientPrimary: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.vaultDarkPrimary,
            AppColors.vaultDarkPrimaryContainer,
          ],
        ),
        glassOpacity: 0.6,
        glassBlur: 12.0,
        ambientShadow: BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
        sidebarActiveBackground:
            AppColors.vaultDarkPrimary.withValues(alpha: 0.14),
      );

  /// Vault light: amber-brown on parchment.
  factory AppDesignExtension.vaultLight() => AppDesignExtension(
        ghostBorderColor:
            AppColors.vaultLightOutlineVariant.withValues(alpha: 0.35),
        gradientPrimary: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.vaultLightPrimary,
            AppColors.vaultLightPrimaryContainer,
          ],
        ),
        glassOpacity: 0.82,
        glassBlur: 24.0,
        ambientShadow: BoxShadow(
          color: AppColors.vaultLightOnSurface.withValues(alpha: 0.07),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
        sidebarActiveBackground:
            AppColors.vaultLightPrimary.withValues(alpha: 0.10),
      );

  /// Index dark: cobalt on deep navy.
  factory AppDesignExtension.indexDark() => AppDesignExtension(
        ghostBorderColor:
            AppColors.indexDarkOutlineVariant.withValues(alpha: 0.25),
        gradientPrimary: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.indexDarkPrimary,
            AppColors.indexDarkPrimaryContainer,
          ],
        ),
        glassOpacity: 0.6,
        glassBlur: 12.0,
        ambientShadow: BoxShadow(
          color: Colors.black.withValues(alpha: 0.45),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
        sidebarActiveBackground:
            AppColors.indexDarkPrimary.withValues(alpha: 0.12),
      );

  /// Index light: deep cobalt on cool blue-grey.
  factory AppDesignExtension.indexLight() => AppDesignExtension(
        ghostBorderColor:
            AppColors.indexLightOutlineVariant.withValues(alpha: 0.20),
        gradientPrimary: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.indexLightPrimary,
            AppColors.indexLightPrimaryContainer,
          ],
        ),
        glassOpacity: 0.82,
        glassBlur: 24.0,
        ambientShadow: BoxShadow(
          color: AppColors.indexLightOnSurface.withValues(alpha: 0.05),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
        sidebarActiveBackground:
            AppColors.indexLightPrimary.withValues(alpha: 0.10),
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
