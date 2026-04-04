import 'package:flutter/material.dart';

/// Colour palette for the MyMediaScanner design system.
///
/// Dark mode follows the "Obsidian Lens" design language.
/// Light mode follows the "Precision Editorial" design language.
abstract final class AppColors {
  // ── Media type colours (shared across themes) ──────────────────────
  static const filmColor = Color(0xFFE53935);
  static const tvColor = Color(0xFFFF7043);
  static const musicColor = Color(0xFF7E57C2);
  static const bookColor = Color(0xFF43A047);
  static const gameColor = Color(0xFF1E88E5);
  static const unknownColor = Color(0xFF757575);

  // ── Dark mode: Obsidian Lens ───────────────────────────────────────
  static const darkSurface = Color(0xFF0E0E0E);
  static const darkSurfaceDim = Color(0xFF0E0E0E);
  static const darkSurfaceBright = Color(0xFF2C2C2C);
  static const darkSurfaceContainerLowest = Color(0xFF000000);
  static const darkSurfaceContainerLow = Color(0xFF131313);
  static const darkSurfaceContainer = Color(0xFF1A1A1A);
  static const darkSurfaceContainerHigh = Color(0xFF20201F);
  static const darkSurfaceContainerHighest = Color(0xFF262626);
  static const darkSurfaceVariant = Color(0xFF262626);

  static const darkPrimary = Color(0xFF6DDDFF);
  static const darkPrimaryContainer = Color(0xFF00D2FD);
  static const darkPrimaryDim = Color(0xFF00C3EB);
  static const darkOnPrimary = Color(0xFF004C5E);
  static const darkOnPrimaryContainer = Color(0xFF004352);

  static const darkSecondary = Color(0xFFE3E0F7);
  static const darkSecondaryContainer = Color(0xFF464557);
  static const darkOnSecondary = Color(0xFF515062);
  static const darkOnSecondaryContainer = Color(0xFFD0CEE4);

  static const darkTertiary = Color(0xFF82A3FF);
  static const darkTertiaryContainer = Color(0xFF6F94FA);
  static const darkOnTertiary = Color(0xFF002363);
  static const darkOnTertiaryContainer = Color(0xFF001747);

  static const darkOnSurface = Color(0xFFFFFFFF);
  static const darkOnSurfaceVariant = Color(0xFFADAAAA);
  static const darkOnBackground = Color(0xFFFFFFFF);

  static const darkOutline = Color(0xFF767575);
  static const darkOutlineVariant = Color(0xFF484847);

  static const darkError = Color(0xFFFF716C);
  static const darkErrorContainer = Color(0xFF9F0519);
  static const darkOnError = Color(0xFF490006);
  static const darkOnErrorContainer = Color(0xFFFFA8A3);

  static const darkInverseSurface = Color(0xFFFCF9F8);
  static const darkInverseOnSurface = Color(0xFF565555);
  static const darkInversePrimary = Color(0xFF00687E);

  static const darkSurfaceTint = Color(0xFF6DDDFF);

  // ── Light mode: Precision Editorial ────────────────────────────────
  static const lightSurface = Color(0xFFF5F6F7);
  static const lightSurfaceDim = Color(0xFFD1D5D7);
  static const lightSurfaceBright = Color(0xFFF5F6F7);
  static const lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const lightSurfaceContainerLow = Color(0xFFEFF1F2);
  static const lightSurfaceContainer = Color(0xFFE6E8EA);
  static const lightSurfaceContainerHigh = Color(0xFFE0E3E4);
  static const lightSurfaceContainerHighest = Color(0xFFDADDDF);
  static const lightSurfaceVariant = Color(0xFFDADDDF);

  static const lightPrimary = Color(0xFF00647A);
  static const lightPrimaryContainer = Color(0xFF00D2FD);
  static const lightPrimaryDim = Color(0xFF00576A);
  static const lightOnPrimary = Color(0xFFE1F6FF);
  static const lightOnPrimaryContainer = Color(0xFF004352);

  static const lightSecondary = Color(0xFF006383);
  static const lightSecondaryContainer = Color(0xFF94DBFF);
  static const lightOnSecondary = Color(0xFFE6F5FF);
  static const lightOnSecondaryContainer = Color(0xFF004D67);

  static const lightTertiary = Color(0xFF2B56B7);
  static const lightTertiaryContainer = Color(0xFF92AEFF);
  static const lightOnTertiary = Color(0xFFF1F2FF);
  static const lightOnTertiaryContainer = Color(0xFF002B75);

  static const lightOnSurface = Color(0xFF2C2F30);
  static const lightOnSurfaceVariant = Color(0xFF595C5D);
  static const lightOnBackground = Color(0xFF2C2F30);

  static const lightOutline = Color(0xFF757778);
  static const lightOutlineVariant = Color(0xFFABADAE);

  static const lightError = Color(0xFFB31B25);
  static const lightErrorContainer = Color(0xFFFB5151);
  static const lightOnError = Color(0xFFFFEFEE);
  static const lightOnErrorContainer = Color(0xFF570008);

  static const lightInverseSurface = Color(0xFF0C0F10);
  static const lightInverseOnSurface = Color(0xFF9B9D9E);
  static const lightInversePrimary = Color(0xFF00D2FD);

  static const lightSurfaceTint = Color(0xFF00647A);
}
