import 'package:flutter/material.dart';

/// Typography system for the MyMediaScanner design system.
///
/// Display/Headline/Title roles use **Manrope** with tight letter-spacing.
/// Body/Label roles use **Inter** (dark mode) or **Manrope** (light mode).
abstract final class AppTypography {
  static const _manrope = 'Manrope';
  static const _inter = 'Inter';
  static const _spaceGrotesk = 'SpaceGrotesk';
  static const _jetBrainsMono = 'JetBrainsMono';

  /// Display style for large numerics (hero stat cards, count badges).
  ///
  /// Uses extra-bold Space Grotesk with a slight negative tracking.
  static TextStyle displayNumeric({
    required Color color,
    double fontSize = 64,
  }) {
    return TextStyle(
      fontFamily: _spaceGrotesk,
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -fontSize * 0.02,
      height: 1.0,
      color: color,
    );
  }

  /// Display style for screen and card titles in the themed redesign.
  /// Space Grotesk with tight tracking — pairs with [monoLabel] eyebrows.
  static TextStyle displayTitle({
    required Color color,
    double fontSize = 34,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return TextStyle(
      fontFamily: _spaceGrotesk,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: -fontSize * 0.025,
      height: 1.1,
      color: color,
    );
  }

  /// Uppercase letterspaced technical label (eyebrows, section headers,
  /// chips). Callers supply already-uppercased text.
  static TextStyle monoLabel({
    required Color color,
    double fontSize = 10,
    double letterSpacing = 1.4,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return TextStyle(
      fontFamily: _jetBrainsMono,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: 1.0,
      color: color,
    );
  }

  /// Monospaced numeric for stat values and counters.
  static TextStyle monoNumeric({
    required Color color,
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return TextStyle(
      fontFamily: _jetBrainsMono,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: -fontSize * 0.03,
      height: 1.0,
      color: color,
    );
  }

  /// Dark mode text theme: Manrope for headlines, Inter for body/labels.
  static TextTheme get darkTextTheme => _buildTextTheme(
        bodyFamily: _inter,
        labelFamily: _inter,
      );

  /// Light mode text theme: Manrope throughout.
  static TextTheme get lightTextTheme => _buildTextTheme(
        bodyFamily: _manrope,
        labelFamily: _manrope,
      );

  static TextTheme _buildTextTheme({
    required String bodyFamily,
    required String labelFamily,
  }) {
    return TextTheme(
      // Display — editorial statements
      displayLarge: const TextStyle(
        fontFamily: _manrope,
        fontSize: 57,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.14, // -2%
        height: 1.12,
      ),
      displayMedium: const TextStyle(
        fontFamily: _manrope,
        fontSize: 45,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.9, // -2%
        height: 1.16,
      ),
      displaySmall: const TextStyle(
        fontFamily: _manrope,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.72, // -2%
        height: 1.22,
      ),

      // Headline — section anchors
      headlineLarge: const TextStyle(
        fontFamily: _manrope,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.64, // -2%
        height: 1.25,
      ),
      headlineMedium: const TextStyle(
        fontFamily: _manrope,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.56, // -2%
        height: 1.29,
      ),
      headlineSmall: const TextStyle(
        fontFamily: _manrope,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.48, // -2%
        height: 1.33,
      ),

      // Title — categorisation
      titleLarge: const TextStyle(
        fontFamily: _manrope,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.22, // -1%
        height: 1.27,
      ),
      titleMedium: const TextStyle(
        fontFamily: _manrope,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: const TextStyle(
        fontFamily: _manrope,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body — information workhorse
      bodyLarge: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label — technical metadata
      labelLarge: TextStyle(
        fontFamily: labelFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontFamily: labelFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontFamily: labelFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.55, // +5%
        height: 1.45,
      ),
    );
  }
}
