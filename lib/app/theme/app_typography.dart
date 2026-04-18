import 'package:flutter/material.dart';

/// Typography system for the MyMediaScanner design system.
///
/// Display/Headline/Title roles use **Manrope** with tight letter-spacing.
/// Body/Label roles use **Inter** (dark mode) or **Manrope** (light mode).
abstract final class AppTypography {
  static const _manrope = 'Manrope';
  static const _inter = 'Inter';

  /// Display style for large numerics (hero stat cards, count badges).
  ///
  /// Uses extra-bold Manrope with a slight negative tracking. If the
  /// `Space Grotesk` font is added to `assets/fonts/` in future, swap the
  /// `fontFamily` here to pick it up everywhere without call-site churn.
  static TextStyle displayNumeric({
    required Color color,
    double fontSize = 64,
  }) {
    return TextStyle(
      fontFamily: _manrope,
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -fontSize * 0.02,
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
