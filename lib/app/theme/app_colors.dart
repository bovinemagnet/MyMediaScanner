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

  // ── Popcorn light ──────────────────────────────────────────────────
  // Warm ivory surfaces, coral primary, mint secondary, periwinkle tertiary.
  static const popcornSurface = Color(0xFFFFF6EC);
  static const popcornSurfaceDim = Color(0xFFFBE9D2);
  static const popcornSurfaceBright = Color(0xFFFFFFFF);
  static const popcornSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const popcornSurfaceContainerLow = Color(0xFFFBE9D2);
  static const popcornSurfaceContainer = Color(0xFFF5E6D0);
  static const popcornSurfaceContainerHigh = Color(0xFFEFDCC2);
  static const popcornSurfaceContainerHighest = Color(0xFFE8D3B4);

  static const popcornPrimary = Color(0xFFFF5E3A);
  static const popcornOnPrimary = Color(0xFFFFFFFF);
  static const popcornPrimaryContainer = Color(0xFFFFE0D4);
  static const popcornOnPrimaryContainer = Color(0xFF661E10);

  static const popcornSecondary = Color(0xFF00C4B8);
  static const popcornOnSecondary = Color(0xFFFFFFFF);
  static const popcornSecondaryContainer = Color(0xFFC6F2EE);
  static const popcornOnSecondaryContainer = Color(0xFF003B37);

  static const popcornTertiary = Color(0xFF4A6CF7);
  static const popcornOnTertiary = Color(0xFFFFFFFF);
  static const popcornTertiaryContainer = Color(0xFFD6DEFF);
  static const popcornOnTertiaryContainer = Color(0xFF122269);

  static const popcornOnSurface = Color(0xFF1D1A17);
  static const popcornOnSurfaceVariant = Color(0xFF5A5149);

  static const popcornOutline = Color(0xFFEFE2CF);
  static const popcornOutlineVariant = Color(0xFFE0CFB3);

  static const popcornError = Color(0xFFE53946);
  static const popcornOnError = Color(0xFFFFFFFF);
  static const popcornErrorContainer = Color(0xFFFFD9DE);
  static const popcornOnErrorContainer = Color(0xFF5C0010);

  static const popcornInverseSurface = Color(0xFF1D1A17);
  static const popcornInverseOnSurface = Color(0xFFFFF6EC);
  static const popcornInversePrimary = Color(0xFFFFB5A0);
  static const popcornSurfaceTint = Color(0xFFFF5E3A);

  // ── Popcorn dark ───────────────────────────────────────────────────
  // Warm charcoals + lifted accents to keep coral/mint legible on dark.
  static const popcornDarkSurface = Color(0xFF161416);
  static const popcornDarkSurfaceDim = Color(0xFF0E0D0F);
  static const popcornDarkSurfaceBright = Color(0xFF2A272B);
  static const popcornDarkSurfaceContainerLowest = Color(0xFF0A090B);
  static const popcornDarkSurfaceContainerLow = Color(0xFF1A171A);
  static const popcornDarkSurfaceContainer = Color(0xFF201E22);
  static const popcornDarkSurfaceContainerHigh = Color(0xFF2A272B);
  static const popcornDarkSurfaceContainerHighest = Color(0xFF342F34);

  static const popcornDarkPrimary = Color(0xFFFF7A5C);
  static const popcornDarkOnPrimary = Color(0xFF4D140A);
  static const popcornDarkPrimaryContainer = Color(0xFF7A2414);
  static const popcornDarkOnPrimaryContainer = Color(0xFFFFD5C5);

  static const popcornDarkSecondary = Color(0xFF2FDAD0);
  static const popcornDarkOnSecondary = Color(0xFF003B37);
  static const popcornDarkSecondaryContainer = Color(0xFF005751);
  static const popcornDarkOnSecondaryContainer = Color(0xFFC6F2EE);

  static const popcornDarkTertiary = Color(0xFF8AA0FF);
  static const popcornDarkOnTertiary = Color(0xFF0B1447);
  static const popcornDarkTertiaryContainer = Color(0xFF2C3F9C);
  static const popcornDarkOnTertiaryContainer = Color(0xFFD6DEFF);

  static const popcornDarkOnSurface = Color(0xFFF8F4EE);
  static const popcornDarkOnSurfaceVariant = Color(0xFFB8AFA3);

  static const popcornDarkOutline = Color(0xFF2D2A2E);
  static const popcornDarkOutlineVariant = Color(0xFF3E3A3F);

  static const popcornDarkError = Color(0xFFFF8A92);
  static const popcornDarkOnError = Color(0xFF4A0009);
  static const popcornDarkErrorContainer = Color(0xFF8A0A1A);
  static const popcornDarkOnErrorContainer = Color(0xFFFFDADE);

  static const popcornDarkInverseSurface = Color(0xFFF8F4EE);
  static const popcornDarkInverseOnSurface = Color(0xFF1D1A17);
  static const popcornDarkInversePrimary = Color(0xFFFF5E3A);
  static const popcornDarkSurfaceTint = Color(0xFFFF7A5C);

  // ── Kinetic dark ───────────────────────────────────────────────────
  // Electric green accent on near-black obsidian. Technical, monochrome base.
  static const kineticDarkSurface = Color(0xFF0A0B0D);
  static const kineticDarkSurfaceDim = Color(0xFF06070A);
  static const kineticDarkSurfaceBright = Color(0xFF2D3440);
  static const kineticDarkSurfaceContainerLowest = Color(0xFF0E1013);
  static const kineticDarkSurfaceContainerLow = Color(0xFF15181C);
  static const kineticDarkSurfaceContainer = Color(0xFF1C2026);
  static const kineticDarkSurfaceContainerHigh = Color(0xFF252A31);
  static const kineticDarkSurfaceContainerHighest = Color(0xFF2D3440);

  static const kineticDarkPrimary = Color(0xFF00E5A0);
  static const kineticDarkOnPrimary = Color(0xFF04130D);
  static const kineticDarkPrimaryContainer = Color(0xFF052918);
  static const kineticDarkOnPrimaryContainer = Color(0xFF6EF5C4);

  static const kineticDarkSecondary = Color(0xFF7EC4FF);
  static const kineticDarkOnSecondary = Color(0xFF003048);
  static const kineticDarkSecondaryContainer = Color(0xFF0D2233);
  static const kineticDarkOnSecondaryContainer = Color(0xFFB8DFFF);

  static const kineticDarkTertiary = Color(0xFFC08CFF);
  static const kineticDarkOnTertiary = Color(0xFF1F0047);
  static const kineticDarkTertiaryContainer = Color(0xFF1A0A2E);
  static const kineticDarkOnTertiaryContainer = Color(0xFFD9C0FF);

  static const kineticDarkOnSurface = Color(0xFFF3F6F4);
  static const kineticDarkOnSurfaceVariant = Color(0xFF8B938F);

  static const kineticDarkOutline = Color(0xFF565D59);
  static const kineticDarkOutlineVariant = Color(0xFF2D3430);

  static const kineticDarkError = Color(0xFFFF6E6E);
  static const kineticDarkOnError = Color(0xFF490006);
  static const kineticDarkErrorContainer = Color(0xFF7A0019);
  static const kineticDarkOnErrorContainer = Color(0xFFFFDADA);

  static const kineticDarkInverseSurface = Color(0xFFF3F6F4);
  static const kineticDarkInverseOnSurface = Color(0xFF252A31);
  static const kineticDarkInversePrimary = Color(0xFF00A870);
  static const kineticDarkSurfaceTint = Color(0xFF00E5A0);

  // ── Kinetic light ──────────────────────────────────────────────────
  // Cool mint-green on muted sage backgrounds. Clean, precise.
  static const kineticLightSurface = Color(0xFFEAEEEC);
  static const kineticLightSurfaceDim = Color(0xFFCBD1CE);
  static const kineticLightSurfaceBright = Color(0xFFEAEEEC);
  static const kineticLightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const kineticLightSurfaceContainerLow = Color(0xFFF5F8F6);
  static const kineticLightSurfaceContainer = Color(0xFFEEF2F0);
  static const kineticLightSurfaceContainerHigh = Color(0xFFE5EBE7);
  static const kineticLightSurfaceContainerHighest = Color(0xFFDAE1DC);

  static const kineticLightPrimary = Color(0xFF00C389);
  static const kineticLightOnPrimary = Color(0xFF042016);
  static const kineticLightPrimaryContainer = Color(0xFFADF5DC);
  static const kineticLightOnPrimaryContainer = Color(0xFF00351D);

  static const kineticLightSecondary = Color(0xFF2F6BE0);
  static const kineticLightOnSecondary = Color(0xFFFFFFFF);
  static const kineticLightSecondaryContainer = Color(0xFFD4E3FF);
  static const kineticLightOnSecondaryContainer = Color(0xFF00296E);

  static const kineticLightTertiary = Color(0xFF8A4DD6);
  static const kineticLightOnTertiary = Color(0xFFFFFFFF);
  static const kineticLightTertiaryContainer = Color(0xFFECDDFF);
  static const kineticLightOnTertiaryContainer = Color(0xFF2A0060);

  static const kineticLightOnSurface = Color(0xFF0C1410);
  static const kineticLightOnSurfaceVariant = Color(0xFF5D655F);

  static const kineticLightOutline = Color(0xFF9AA39D);
  static const kineticLightOutlineVariant = Color(0xFFBEC7C0);

  static const kineticLightError = Color(0xFFE0455C);
  static const kineticLightOnError = Color(0xFFFFFFFF);
  static const kineticLightErrorContainer = Color(0xFFFFDADE);
  static const kineticLightOnErrorContainer = Color(0xFF69001A);

  static const kineticLightInverseSurface = Color(0xFF1C2026);
  static const kineticLightInverseOnSurface = Color(0xFFF3F6F4);
  static const kineticLightInversePrimary = Color(0xFF00E5A0);
  static const kineticLightSurfaceTint = Color(0xFF00C389);

  // ── Vault dark ─────────────────────────────────────────────────────
  // Warm brass accent on deep espresso. Spotlit shelf aesthetic.
  static const vaultDarkSurface = Color(0xFF100E0F);
  static const vaultDarkSurfaceDim = Color(0xFF0A0809);
  static const vaultDarkSurfaceBright = Color(0xFF36302E);
  static const vaultDarkSurfaceContainerLowest = Color(0xFF171314);
  static const vaultDarkSurfaceContainerLow = Color(0xFF1A1617);
  static const vaultDarkSurfaceContainer = Color(0xFF221D1E);
  static const vaultDarkSurfaceContainerHigh = Color(0xFF2C2526);
  static const vaultDarkSurfaceContainerHighest = Color(0xFF363032);

  static const vaultDarkPrimary = Color(0xFFE3A85A);
  static const vaultDarkOnPrimary = Color(0xFF1A1206);
  static const vaultDarkPrimaryContainer = Color(0xFF3D2A08);
  static const vaultDarkOnPrimaryContainer = Color(0xFFF5D89A);

  static const vaultDarkSecondary = Color(0xFF6FC58C);
  static const vaultDarkOnSecondary = Color(0xFF0C2E1A);
  static const vaultDarkSecondaryContainer = Color(0xFF163D23);
  static const vaultDarkOnSecondaryContainer = Color(0xFFA9E8BC);

  static const vaultDarkTertiary = Color(0xFFB98BE0);
  static const vaultDarkOnTertiary = Color(0xFF1E0A38);
  static const vaultDarkTertiaryContainer = Color(0xFF281245);
  static const vaultDarkOnTertiaryContainer = Color(0xFFDFC5FF);

  static const vaultDarkOnSurface = Color(0xFFF2EBE0);
  static const vaultDarkOnSurfaceVariant = Color(0xFF9A9088);

  static const vaultDarkOutline = Color(0xFF6E655D);
  static const vaultDarkOutlineVariant = Color(0xFF3D3530);

  static const vaultDarkError = Color(0xFFE0654C);
  static const vaultDarkOnError = Color(0xFF3A1205);
  static const vaultDarkErrorContainer = Color(0xFF5A1E0F);
  static const vaultDarkOnErrorContainer = Color(0xFFFFD0C4);

  static const vaultDarkInverseSurface = Color(0xFFF2EBE0);
  static const vaultDarkInverseOnSurface = Color(0xFF2C2526);
  static const vaultDarkInversePrimary = Color(0xFF7A5E2A);
  static const vaultDarkSurfaceTint = Color(0xFFE3A85A);

  // ── Vault light ────────────────────────────────────────────────────
  // Amber-brown accent on warm parchment. Library lantern light.
  static const vaultLightSurface = Color(0xFFF0E9DB);
  static const vaultLightSurfaceDim = Color(0xFFD6CAB5);
  static const vaultLightSurfaceBright = Color(0xFFF0E9DB);
  static const vaultLightSurfaceContainerLowest = Color(0xFFFBF7EE);
  static const vaultLightSurfaceContainerLow = Color(0xFFF6F1E6);
  static const vaultLightSurfaceContainer = Color(0xFFEFE6D4);
  static const vaultLightSurfaceContainerHigh = Color(0xFFE7DCC6);
  static const vaultLightSurfaceContainerHighest = Color(0xFFDDD1B5);

  static const vaultLightPrimary = Color(0xFF9A6A37);
  static const vaultLightOnPrimary = Color(0xFFFFFFFF);
  static const vaultLightPrimaryContainer = Color(0xFFEDD5A8);
  static const vaultLightOnPrimaryContainer = Color(0xFF3A2009);

  static const vaultLightSecondary = Color(0xFF3C7350);
  static const vaultLightOnSecondary = Color(0xFFFFFFFF);
  static const vaultLightSecondaryContainer = Color(0xFFBEF0D0);
  static const vaultLightOnSecondaryContainer = Color(0xFF0C2E1A);

  static const vaultLightTertiary = Color(0xFF6B4E96);
  static const vaultLightOnTertiary = Color(0xFFFFFFFF);
  static const vaultLightTertiaryContainer = Color(0xFFE8D5FF);
  static const vaultLightOnTertiaryContainer = Color(0xFF240747);

  static const vaultLightOnSurface = Color(0xFF1F1B16);
  static const vaultLightOnSurfaceVariant = Color(0xFF6E6456);

  static const vaultLightOutline = Color(0xFFA89C88);
  static const vaultLightOutlineVariant = Color(0xFFCCC0A9);

  static const vaultLightError = Color(0xFFA83A2C);
  static const vaultLightOnError = Color(0xFFFFFFFF);
  static const vaultLightErrorContainer = Color(0xFFFFD8D0);
  static const vaultLightOnErrorContainer = Color(0xFF410A03);

  static const vaultLightInverseSurface = Color(0xFF1F1B16);
  static const vaultLightInverseOnSurface = Color(0xFFF0E9DB);
  static const vaultLightInversePrimary = Color(0xFFE3A85A);
  static const vaultLightSurfaceTint = Color(0xFF9A6A37);

  // ── Index dark ─────────────────────────────────────────────────────
  // Cool cobalt accent on cool navy. Data-dense, GitHub-adjacent.
  static const indexDarkSurface = Color(0xFF0E1116);
  static const indexDarkSurfaceDim = Color(0xFF080B10);
  static const indexDarkSurfaceBright = Color(0xFF364252);
  static const indexDarkSurfaceContainerLowest = Color(0xFF161B22);
  static const indexDarkSurfaceContainerLow = Color(0xFF1A2029);
  static const indexDarkSurfaceContainer = Color(0xFF222A35);
  static const indexDarkSurfaceContainerHigh = Color(0xFF2C3643);
  static const indexDarkSurfaceContainerHighest = Color(0xFF364252);

  static const indexDarkPrimary = Color(0xFF5B7BFF);
  static const indexDarkOnPrimary = Color(0xFF0A1230);
  static const indexDarkPrimaryContainer = Color(0xFF0D1D4D);
  static const indexDarkOnPrimaryContainer = Color(0xFFA8BBFF);

  static const indexDarkSecondary = Color(0xFF3FD18A);
  static const indexDarkOnSecondary = Color(0xFF004D26);
  static const indexDarkSecondaryContainer = Color(0xFF00391C);
  static const indexDarkOnSecondaryContainer = Color(0xFFB3FFCC);

  static const indexDarkTertiary = Color(0xFFA98BFF);
  static const indexDarkOnTertiary = Color(0xFF1B003E);
  static const indexDarkTertiaryContainer = Color(0xFF24004D);
  static const indexDarkOnTertiaryContainer = Color(0xFFD9C0FF);

  static const indexDarkOnSurface = Color(0xFFE6EAF0);
  static const indexDarkOnSurfaceVariant = Color(0xFF8A93A0);

  static const indexDarkOutline = Color(0xFF576070);
  static const indexDarkOutlineVariant = Color(0xFF2A3344);

  static const indexDarkError = Color(0xFFFF6B6B);
  static const indexDarkOnError = Color(0xFF490000);
  static const indexDarkErrorContainer = Color(0xFF7A0000);
  static const indexDarkOnErrorContainer = Color(0xFFFFDADA);

  static const indexDarkInverseSurface = Color(0xFFE6EAF0);
  static const indexDarkInverseOnSurface = Color(0xFF2C3643);
  static const indexDarkInversePrimary = Color(0xFF2742C8);
  static const indexDarkSurfaceTint = Color(0xFF5B7BFF);

  // ── Index light ────────────────────────────────────────────────────
  // Deep cobalt on cool blue-grey. Precise, data-forward.
  static const indexLightSurface = Color(0xFFEEF0F3);
  static const indexLightSurfaceDim = Color(0xFFCDD3DC);
  static const indexLightSurfaceBright = Color(0xFFEEF0F3);
  static const indexLightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const indexLightSurfaceContainerLow = Color(0xFFF7F8FA);
  static const indexLightSurfaceContainer = Color(0xFFEEF1F6);
  static const indexLightSurfaceContainerHigh = Color(0xFFE2E6EC);
  static const indexLightSurfaceContainerHighest = Color(0xFFD5DBE5);

  static const indexLightPrimary = Color(0xFF2742C8);
  static const indexLightOnPrimary = Color(0xFFFFFFFF);
  static const indexLightPrimaryContainer = Color(0xFFDBE1FF);
  static const indexLightOnPrimaryContainer = Color(0xFF0B1A6E);

  static const indexLightSecondary = Color(0xFF1F9B63);
  static const indexLightOnSecondary = Color(0xFFFFFFFF);
  static const indexLightSecondaryContainer = Color(0xFFBBF0D4);
  static const indexLightOnSecondaryContainer = Color(0xFF003D22);

  static const indexLightTertiary = Color(0xFF7A3FD0);
  static const indexLightOnTertiary = Color(0xFFFFFFFF);
  static const indexLightTertiaryContainer = Color(0xFFEBD6FF);
  static const indexLightOnTertiaryContainer = Color(0xFF270055);

  static const indexLightOnSurface = Color(0xFF161A20);
  static const indexLightOnSurfaceVariant = Color(0xFF5B6470);

  static const indexLightOutline = Color(0xFF9AA3B0);
  static const indexLightOutlineVariant = Color(0xFFBCC4CF);

  static const indexLightError = Color(0xFFD33B3B);
  static const indexLightOnError = Color(0xFFFFFFFF);
  static const indexLightErrorContainer = Color(0xFFFFDADA);
  static const indexLightOnErrorContainer = Color(0xFF6A0000);

  static const indexLightInverseSurface = Color(0xFF222A35);
  static const indexLightInverseOnSurface = Color(0xFFE6EAF0);
  static const indexLightInversePrimary = Color(0xFF7E97FF);
  static const indexLightSurfaceTint = Color(0xFF2742C8);
}
