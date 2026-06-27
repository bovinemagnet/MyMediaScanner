import 'package:flutter/material.dart';
import 'package:mymediascanner/app/theme/app_colors.dart';
import 'package:mymediascanner/app/theme/app_layout_extension.dart';
import 'package:mymediascanner/app/theme/app_media_colors.dart';
import 'package:mymediascanner/app/theme/app_shapes.dart';
import 'package:mymediascanner/app/theme/app_theme_extensions.dart';
import 'package:mymediascanner/app/theme/app_typography.dart';

abstract final class AppTheme {
  // ── Light theme ("Precision Editorial") ────────────────────────────
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      primaryContainer: AppColors.lightPrimaryContainer,
      onPrimaryContainer: AppColors.lightOnPrimaryContainer,
      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.lightOnSecondary,
      secondaryContainer: AppColors.lightSecondaryContainer,
      onSecondaryContainer: AppColors.lightOnSecondaryContainer,
      tertiary: AppColors.lightTertiary,
      onTertiary: AppColors.lightOnTertiary,
      tertiaryContainer: AppColors.lightTertiaryContainer,
      onTertiaryContainer: AppColors.lightOnTertiaryContainer,
      error: AppColors.lightError,
      onError: AppColors.lightOnError,
      errorContainer: AppColors.lightErrorContainer,
      onErrorContainer: AppColors.lightOnErrorContainer,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      surfaceDim: AppColors.lightSurfaceDim,
      surfaceBright: AppColors.lightSurfaceBright,
      surfaceContainerLowest: AppColors.lightSurfaceContainerLowest,
      surfaceContainerLow: AppColors.lightSurfaceContainerLow,
      surfaceContainer: AppColors.lightSurfaceContainer,
      surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,
      onSurfaceVariant: AppColors.lightOnSurfaceVariant,
      outline: AppColors.lightOutline,
      outlineVariant: AppColors.lightOutlineVariant,
      inverseSurface: AppColors.lightInverseSurface,
      onInverseSurface: AppColors.lightInverseOnSurface,
      inversePrimary: AppColors.lightInversePrimary,
      surfaceTint: AppColors.lightSurfaceTint,
    );

    return _buildTheme(
      colorScheme,
      AppTypography.lightTextTheme,
      AppDesignExtension.light(),
      AppMediaColors.classic(),
      AppLayoutExtension.classic(),
    );
  }

  // ── Dark theme ("Obsidian Lens") ───────────────────────────────────
  static ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      primaryContainer: AppColors.darkPrimaryContainer,
      onPrimaryContainer: AppColors.darkOnPrimaryContainer,
      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.darkOnSecondary,
      secondaryContainer: AppColors.darkSecondaryContainer,
      onSecondaryContainer: AppColors.darkOnSecondaryContainer,
      tertiary: AppColors.darkTertiary,
      onTertiary: AppColors.darkOnTertiary,
      tertiaryContainer: AppColors.darkTertiaryContainer,
      onTertiaryContainer: AppColors.darkOnTertiaryContainer,
      error: AppColors.darkError,
      onError: AppColors.darkOnError,
      errorContainer: AppColors.darkErrorContainer,
      onErrorContainer: AppColors.darkOnErrorContainer,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      surfaceDim: AppColors.darkSurfaceDim,
      surfaceBright: AppColors.darkSurfaceBright,
      surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
      surfaceContainerLow: AppColors.darkSurfaceContainerLow,
      surfaceContainer: AppColors.darkSurfaceContainer,
      surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      outline: AppColors.darkOutline,
      outlineVariant: AppColors.darkOutlineVariant,
      inverseSurface: AppColors.darkInverseSurface,
      onInverseSurface: AppColors.darkInverseOnSurface,
      inversePrimary: AppColors.darkInversePrimary,
      surfaceTint: AppColors.darkSurfaceTint,
    );

    return _buildTheme(
      colorScheme,
      AppTypography.darkTextTheme,
      AppDesignExtension.dark(),
      AppMediaColors.classic(),
      AppLayoutExtension.classic(),
    );
  }

  // ── Popcorn light ("Popcorn") ──────────────────────────────────────
  static ThemeData popcornLight() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.popcornPrimary,
      onPrimary: AppColors.popcornOnPrimary,
      primaryContainer: AppColors.popcornPrimaryContainer,
      onPrimaryContainer: AppColors.popcornOnPrimaryContainer,
      secondary: AppColors.popcornSecondary,
      onSecondary: AppColors.popcornOnSecondary,
      secondaryContainer: AppColors.popcornSecondaryContainer,
      onSecondaryContainer: AppColors.popcornOnSecondaryContainer,
      tertiary: AppColors.popcornTertiary,
      onTertiary: AppColors.popcornOnTertiary,
      tertiaryContainer: AppColors.popcornTertiaryContainer,
      onTertiaryContainer: AppColors.popcornOnTertiaryContainer,
      error: AppColors.popcornError,
      onError: AppColors.popcornOnError,
      errorContainer: AppColors.popcornErrorContainer,
      onErrorContainer: AppColors.popcornOnErrorContainer,
      surface: AppColors.popcornSurface,
      onSurface: AppColors.popcornOnSurface,
      surfaceDim: AppColors.popcornSurfaceDim,
      surfaceBright: AppColors.popcornSurfaceBright,
      surfaceContainerLowest: AppColors.popcornSurfaceContainerLowest,
      surfaceContainerLow: AppColors.popcornSurfaceContainerLow,
      surfaceContainer: AppColors.popcornSurfaceContainer,
      surfaceContainerHigh: AppColors.popcornSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.popcornSurfaceContainerHighest,
      onSurfaceVariant: AppColors.popcornOnSurfaceVariant,
      outline: AppColors.popcornOutline,
      outlineVariant: AppColors.popcornOutlineVariant,
      inverseSurface: AppColors.popcornInverseSurface,
      onInverseSurface: AppColors.popcornInverseOnSurface,
      inversePrimary: AppColors.popcornInversePrimary,
      surfaceTint: AppColors.popcornSurfaceTint,
    );

    return _popcornOverrides(
      _buildTheme(
        colorScheme,
        AppTypography.lightTextTheme,
        AppDesignExtension.popcornLight(),
        AppMediaColors.popcorn(),
        AppLayoutExtension.popcorn(),
      ),
      colorScheme,
    );
  }

  // ── Popcorn dark ("Popcorn Dark") ──────────────────────────────────
  static ThemeData popcornDark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.popcornDarkPrimary,
      onPrimary: AppColors.popcornDarkOnPrimary,
      primaryContainer: AppColors.popcornDarkPrimaryContainer,
      onPrimaryContainer: AppColors.popcornDarkOnPrimaryContainer,
      secondary: AppColors.popcornDarkSecondary,
      onSecondary: AppColors.popcornDarkOnSecondary,
      secondaryContainer: AppColors.popcornDarkSecondaryContainer,
      onSecondaryContainer: AppColors.popcornDarkOnSecondaryContainer,
      tertiary: AppColors.popcornDarkTertiary,
      onTertiary: AppColors.popcornDarkOnTertiary,
      tertiaryContainer: AppColors.popcornDarkTertiaryContainer,
      onTertiaryContainer: AppColors.popcornDarkOnTertiaryContainer,
      error: AppColors.popcornDarkError,
      onError: AppColors.popcornDarkOnError,
      errorContainer: AppColors.popcornDarkErrorContainer,
      onErrorContainer: AppColors.popcornDarkOnErrorContainer,
      surface: AppColors.popcornDarkSurface,
      onSurface: AppColors.popcornDarkOnSurface,
      surfaceDim: AppColors.popcornDarkSurfaceDim,
      surfaceBright: AppColors.popcornDarkSurfaceBright,
      surfaceContainerLowest: AppColors.popcornDarkSurfaceContainerLowest,
      surfaceContainerLow: AppColors.popcornDarkSurfaceContainerLow,
      surfaceContainer: AppColors.popcornDarkSurfaceContainer,
      surfaceContainerHigh: AppColors.popcornDarkSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.popcornDarkSurfaceContainerHighest,
      onSurfaceVariant: AppColors.popcornDarkOnSurfaceVariant,
      outline: AppColors.popcornDarkOutline,
      outlineVariant: AppColors.popcornDarkOutlineVariant,
      inverseSurface: AppColors.popcornDarkInverseSurface,
      onInverseSurface: AppColors.popcornDarkInverseOnSurface,
      inversePrimary: AppColors.popcornDarkInversePrimary,
      surfaceTint: AppColors.popcornDarkSurfaceTint,
    );

    return _popcornOverrides(
      _buildTheme(
        colorScheme,
        AppTypography.darkTextTheme,
        AppDesignExtension.popcornDark(),
        AppMediaColors.popcornDark(),
        AppLayoutExtension.popcorn(),
      ),
      colorScheme,
    );
  }

  // ── Kinetic dark ──────────────────────────────────────────────────
  static ThemeData kineticDark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.kineticDarkPrimary,
      onPrimary: AppColors.kineticDarkOnPrimary,
      primaryContainer: AppColors.kineticDarkPrimaryContainer,
      onPrimaryContainer: AppColors.kineticDarkOnPrimaryContainer,
      secondary: AppColors.kineticDarkSecondary,
      onSecondary: AppColors.kineticDarkOnSecondary,
      secondaryContainer: AppColors.kineticDarkSecondaryContainer,
      onSecondaryContainer: AppColors.kineticDarkOnSecondaryContainer,
      tertiary: AppColors.kineticDarkTertiary,
      onTertiary: AppColors.kineticDarkOnTertiary,
      tertiaryContainer: AppColors.kineticDarkTertiaryContainer,
      onTertiaryContainer: AppColors.kineticDarkOnTertiaryContainer,
      error: AppColors.kineticDarkError,
      onError: AppColors.kineticDarkOnError,
      errorContainer: AppColors.kineticDarkErrorContainer,
      onErrorContainer: AppColors.kineticDarkOnErrorContainer,
      surface: AppColors.kineticDarkSurface,
      onSurface: AppColors.kineticDarkOnSurface,
      surfaceDim: AppColors.kineticDarkSurfaceDim,
      surfaceBright: AppColors.kineticDarkSurfaceBright,
      surfaceContainerLowest: AppColors.kineticDarkSurfaceContainerLowest,
      surfaceContainerLow: AppColors.kineticDarkSurfaceContainerLow,
      surfaceContainer: AppColors.kineticDarkSurfaceContainer,
      surfaceContainerHigh: AppColors.kineticDarkSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.kineticDarkSurfaceContainerHighest,
      onSurfaceVariant: AppColors.kineticDarkOnSurfaceVariant,
      outline: AppColors.kineticDarkOutline,
      outlineVariant: AppColors.kineticDarkOutlineVariant,
      inverseSurface: AppColors.kineticDarkInverseSurface,
      onInverseSurface: AppColors.kineticDarkInverseOnSurface,
      inversePrimary: AppColors.kineticDarkInversePrimary,
      surfaceTint: AppColors.kineticDarkSurfaceTint,
    );
    return _buildTheme(
      colorScheme,
      AppTypography.darkTextTheme,
      AppDesignExtension.kineticDark(),
      AppMediaColors.kinetic(),
      AppLayoutExtension.classic(),
    );
  }

  // ── Kinetic light ──────────────────────────────────────────────────
  static ThemeData kineticLight() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.kineticLightPrimary,
      onPrimary: AppColors.kineticLightOnPrimary,
      primaryContainer: AppColors.kineticLightPrimaryContainer,
      onPrimaryContainer: AppColors.kineticLightOnPrimaryContainer,
      secondary: AppColors.kineticLightSecondary,
      onSecondary: AppColors.kineticLightOnSecondary,
      secondaryContainer: AppColors.kineticLightSecondaryContainer,
      onSecondaryContainer: AppColors.kineticLightOnSecondaryContainer,
      tertiary: AppColors.kineticLightTertiary,
      onTertiary: AppColors.kineticLightOnTertiary,
      tertiaryContainer: AppColors.kineticLightTertiaryContainer,
      onTertiaryContainer: AppColors.kineticLightOnTertiaryContainer,
      error: AppColors.kineticLightError,
      onError: AppColors.kineticLightOnError,
      errorContainer: AppColors.kineticLightErrorContainer,
      onErrorContainer: AppColors.kineticLightOnErrorContainer,
      surface: AppColors.kineticLightSurface,
      onSurface: AppColors.kineticLightOnSurface,
      surfaceDim: AppColors.kineticLightSurfaceDim,
      surfaceBright: AppColors.kineticLightSurfaceBright,
      surfaceContainerLowest: AppColors.kineticLightSurfaceContainerLowest,
      surfaceContainerLow: AppColors.kineticLightSurfaceContainerLow,
      surfaceContainer: AppColors.kineticLightSurfaceContainer,
      surfaceContainerHigh: AppColors.kineticLightSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.kineticLightSurfaceContainerHighest,
      onSurfaceVariant: AppColors.kineticLightOnSurfaceVariant,
      outline: AppColors.kineticLightOutline,
      outlineVariant: AppColors.kineticLightOutlineVariant,
      inverseSurface: AppColors.kineticLightInverseSurface,
      onInverseSurface: AppColors.kineticLightInverseOnSurface,
      inversePrimary: AppColors.kineticLightInversePrimary,
      surfaceTint: AppColors.kineticLightSurfaceTint,
    );
    return _buildTheme(
      colorScheme,
      AppTypography.lightTextTheme,
      AppDesignExtension.kineticLight(),
      AppMediaColors.kineticLight(),
      AppLayoutExtension.classic(),
    );
  }

  // ── Vault dark ────────────────────────────────────────────────────
  static ThemeData vaultDark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.vaultDarkPrimary,
      onPrimary: AppColors.vaultDarkOnPrimary,
      primaryContainer: AppColors.vaultDarkPrimaryContainer,
      onPrimaryContainer: AppColors.vaultDarkOnPrimaryContainer,
      secondary: AppColors.vaultDarkSecondary,
      onSecondary: AppColors.vaultDarkOnSecondary,
      secondaryContainer: AppColors.vaultDarkSecondaryContainer,
      onSecondaryContainer: AppColors.vaultDarkOnSecondaryContainer,
      tertiary: AppColors.vaultDarkTertiary,
      onTertiary: AppColors.vaultDarkOnTertiary,
      tertiaryContainer: AppColors.vaultDarkTertiaryContainer,
      onTertiaryContainer: AppColors.vaultDarkOnTertiaryContainer,
      error: AppColors.vaultDarkError,
      onError: AppColors.vaultDarkOnError,
      errorContainer: AppColors.vaultDarkErrorContainer,
      onErrorContainer: AppColors.vaultDarkOnErrorContainer,
      surface: AppColors.vaultDarkSurface,
      onSurface: AppColors.vaultDarkOnSurface,
      surfaceDim: AppColors.vaultDarkSurfaceDim,
      surfaceBright: AppColors.vaultDarkSurfaceBright,
      surfaceContainerLowest: AppColors.vaultDarkSurfaceContainerLowest,
      surfaceContainerLow: AppColors.vaultDarkSurfaceContainerLow,
      surfaceContainer: AppColors.vaultDarkSurfaceContainer,
      surfaceContainerHigh: AppColors.vaultDarkSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.vaultDarkSurfaceContainerHighest,
      onSurfaceVariant: AppColors.vaultDarkOnSurfaceVariant,
      outline: AppColors.vaultDarkOutline,
      outlineVariant: AppColors.vaultDarkOutlineVariant,
      inverseSurface: AppColors.vaultDarkInverseSurface,
      onInverseSurface: AppColors.vaultDarkInverseOnSurface,
      inversePrimary: AppColors.vaultDarkInversePrimary,
      surfaceTint: AppColors.vaultDarkSurfaceTint,
    );
    return _buildTheme(
      colorScheme,
      AppTypography.darkTextTheme,
      AppDesignExtension.vaultDark(),
      AppMediaColors.vault(),
      AppLayoutExtension.classic(),
    );
  }

  // ── Vault light ───────────────────────────────────────────────────
  static ThemeData vaultLight() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.vaultLightPrimary,
      onPrimary: AppColors.vaultLightOnPrimary,
      primaryContainer: AppColors.vaultLightPrimaryContainer,
      onPrimaryContainer: AppColors.vaultLightOnPrimaryContainer,
      secondary: AppColors.vaultLightSecondary,
      onSecondary: AppColors.vaultLightOnSecondary,
      secondaryContainer: AppColors.vaultLightSecondaryContainer,
      onSecondaryContainer: AppColors.vaultLightOnSecondaryContainer,
      tertiary: AppColors.vaultLightTertiary,
      onTertiary: AppColors.vaultLightOnTertiary,
      tertiaryContainer: AppColors.vaultLightTertiaryContainer,
      onTertiaryContainer: AppColors.vaultLightOnTertiaryContainer,
      error: AppColors.vaultLightError,
      onError: AppColors.vaultLightOnError,
      errorContainer: AppColors.vaultLightErrorContainer,
      onErrorContainer: AppColors.vaultLightOnErrorContainer,
      surface: AppColors.vaultLightSurface,
      onSurface: AppColors.vaultLightOnSurface,
      surfaceDim: AppColors.vaultLightSurfaceDim,
      surfaceBright: AppColors.vaultLightSurfaceBright,
      surfaceContainerLowest: AppColors.vaultLightSurfaceContainerLowest,
      surfaceContainerLow: AppColors.vaultLightSurfaceContainerLow,
      surfaceContainer: AppColors.vaultLightSurfaceContainer,
      surfaceContainerHigh: AppColors.vaultLightSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.vaultLightSurfaceContainerHighest,
      onSurfaceVariant: AppColors.vaultLightOnSurfaceVariant,
      outline: AppColors.vaultLightOutline,
      outlineVariant: AppColors.vaultLightOutlineVariant,
      inverseSurface: AppColors.vaultLightInverseSurface,
      onInverseSurface: AppColors.vaultLightInverseOnSurface,
      inversePrimary: AppColors.vaultLightInversePrimary,
      surfaceTint: AppColors.vaultLightSurfaceTint,
    );
    return _buildTheme(
      colorScheme,
      AppTypography.lightTextTheme,
      AppDesignExtension.vaultLight(),
      AppMediaColors.vaultLight(),
      AppLayoutExtension.classic(),
    );
  }

  // ── Index dark ────────────────────────────────────────────────────
  static ThemeData indexDark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.indexDarkPrimary,
      onPrimary: AppColors.indexDarkOnPrimary,
      primaryContainer: AppColors.indexDarkPrimaryContainer,
      onPrimaryContainer: AppColors.indexDarkOnPrimaryContainer,
      secondary: AppColors.indexDarkSecondary,
      onSecondary: AppColors.indexDarkOnSecondary,
      secondaryContainer: AppColors.indexDarkSecondaryContainer,
      onSecondaryContainer: AppColors.indexDarkOnSecondaryContainer,
      tertiary: AppColors.indexDarkTertiary,
      onTertiary: AppColors.indexDarkOnTertiary,
      tertiaryContainer: AppColors.indexDarkTertiaryContainer,
      onTertiaryContainer: AppColors.indexDarkOnTertiaryContainer,
      error: AppColors.indexDarkError,
      onError: AppColors.indexDarkOnError,
      errorContainer: AppColors.indexDarkErrorContainer,
      onErrorContainer: AppColors.indexDarkOnErrorContainer,
      surface: AppColors.indexDarkSurface,
      onSurface: AppColors.indexDarkOnSurface,
      surfaceDim: AppColors.indexDarkSurfaceDim,
      surfaceBright: AppColors.indexDarkSurfaceBright,
      surfaceContainerLowest: AppColors.indexDarkSurfaceContainerLowest,
      surfaceContainerLow: AppColors.indexDarkSurfaceContainerLow,
      surfaceContainer: AppColors.indexDarkSurfaceContainer,
      surfaceContainerHigh: AppColors.indexDarkSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.indexDarkSurfaceContainerHighest,
      onSurfaceVariant: AppColors.indexDarkOnSurfaceVariant,
      outline: AppColors.indexDarkOutline,
      outlineVariant: AppColors.indexDarkOutlineVariant,
      inverseSurface: AppColors.indexDarkInverseSurface,
      onInverseSurface: AppColors.indexDarkInverseOnSurface,
      inversePrimary: AppColors.indexDarkInversePrimary,
      surfaceTint: AppColors.indexDarkSurfaceTint,
    );
    return _buildTheme(
      colorScheme,
      AppTypography.darkTextTheme,
      AppDesignExtension.indexDark(),
      AppMediaColors.index(),
      AppLayoutExtension.classic(),
    );
  }

  // ── Index light ───────────────────────────────────────────────────
  static ThemeData indexLight() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.indexLightPrimary,
      onPrimary: AppColors.indexLightOnPrimary,
      primaryContainer: AppColors.indexLightPrimaryContainer,
      onPrimaryContainer: AppColors.indexLightOnPrimaryContainer,
      secondary: AppColors.indexLightSecondary,
      onSecondary: AppColors.indexLightOnSecondary,
      secondaryContainer: AppColors.indexLightSecondaryContainer,
      onSecondaryContainer: AppColors.indexLightOnSecondaryContainer,
      tertiary: AppColors.indexLightTertiary,
      onTertiary: AppColors.indexLightOnTertiary,
      tertiaryContainer: AppColors.indexLightTertiaryContainer,
      onTertiaryContainer: AppColors.indexLightOnTertiaryContainer,
      error: AppColors.indexLightError,
      onError: AppColors.indexLightOnError,
      errorContainer: AppColors.indexLightErrorContainer,
      onErrorContainer: AppColors.indexLightOnErrorContainer,
      surface: AppColors.indexLightSurface,
      onSurface: AppColors.indexLightOnSurface,
      surfaceDim: AppColors.indexLightSurfaceDim,
      surfaceBright: AppColors.indexLightSurfaceBright,
      surfaceContainerLowest: AppColors.indexLightSurfaceContainerLowest,
      surfaceContainerLow: AppColors.indexLightSurfaceContainerLow,
      surfaceContainer: AppColors.indexLightSurfaceContainer,
      surfaceContainerHigh: AppColors.indexLightSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.indexLightSurfaceContainerHighest,
      onSurfaceVariant: AppColors.indexLightOnSurfaceVariant,
      outline: AppColors.indexLightOutline,
      outlineVariant: AppColors.indexLightOutlineVariant,
      inverseSurface: AppColors.indexLightInverseSurface,
      onInverseSurface: AppColors.indexLightInverseOnSurface,
      inversePrimary: AppColors.indexLightInversePrimary,
      surfaceTint: AppColors.indexLightSurfaceTint,
    );
    return _buildTheme(
      colorScheme,
      AppTypography.lightTextTheme,
      AppDesignExtension.indexLight(),
      AppMediaColors.indexLight(),
      AppLayoutExtension.classic(),
    );
  }

  /// Popcorn-only overrides on top of [_buildTheme]: chunkier cards,
  /// pill-stadium chips/buttons, circular icon buttons.
  static ThemeData _popcornOverrides(ThemeData base, ColorScheme cs) {
    return base.copyWith(
      cardTheme: base.cardTheme.copyWith(
        color: cs.surfaceContainerLowest,
        shape: AppShapes.cardShape,
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: AppShapes.chipShape,
        side: BorderSide(color: cs.outlineVariant),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: base.chipTheme.labelStyle?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: AppShapes.chipShape,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(shape: WidgetStatePropertyAll(CircleBorder())),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: AppShapes.elevSheet,
        shape: const CircleBorder(),
      ),
    );
  }

  // ── Shared theme builder ───────────────────────────────────────────
  static ThemeData _buildTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
    AppDesignExtension designExtension,
    AppMediaColors mediaColors,
    AppLayoutExtension layoutExtension,
  ) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: 'Manrope',
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: [designExtension, mediaColors, layoutExtension],

      // AppBar — flat, no border
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // Card — tonal elevation, no border
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.zero,
      ),

      // Chips — secondary-container fill
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.secondaryContainer,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // SearchBar — container-highest background
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(
          colorScheme.surfaceContainerHighest,
        ),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        hintStyle: WidgetStatePropertyAll(
          textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),

      // Input fields — container-highest fill, primary focus border
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Divider — transparent ("no-line" rule)
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.15),
        thickness: 1,
        space: 0,
      ),

      // Dialog — container-high background, ambient shadow
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),

      // NavigationBar — container-low
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      // NavigationRail — container-low
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme:
            IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // DataTable — no dividers
      dataTableTheme: DataTableThemeData(
        headingRowColor:
            WidgetStatePropertyAll(colorScheme.surfaceContainerLow),
        dividerThickness: 0,
        headingTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        dataTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      // Filled button — primary fill
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Outlined button — ghost border style
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.15),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Text button — primary colour
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // FAB — primary gradient effect via colours
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: colorScheme.primary.withValues(alpha: 0.1),
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
      ),

      // PopupMenu
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: isDark ? 8 : 4,
        shadowColor: isDark
            ? Colors.black.withValues(alpha: 0.4)
            : colorScheme.onSurface.withValues(alpha: 0.06),
      ),

      // BottomSheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      // TabBar
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // ProgressIndicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
