import 'package:flutter/material.dart';

/// Radius and elevation tokens.
///
/// Themes opt in to these shapes via `cardTheme`, `chipTheme`, etc. The
/// Obsidian Lens and Precision Editorial themes keep their existing
/// 8-pixel radii; the Popcorn theme uses the chunkier values below.
abstract final class AppShapes {
  // Radii
  static const double radiusXs = 6; // tiny chips, badges
  static const double radiusSm = 10; // covers, small cards
  static const double radiusMd = 14; // medium cards
  static const double radiusLg = 20; // big cards, sheets
  static const double radiusXl = 24; // hero cards
  static const double radiusPill = 100; // chips, FAB

  // Elevations (M3 uses tonal elevation; these are semantic)
  static const double elevCard = 0;
  static const double elevHover = 1;
  static const double elevSheet = 3;
  static const double elevModal = 6;

  // Radius shortcuts
  static const cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(radiusLg)),
  );
  static const heroShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(radiusXl)),
  );
  static const coverShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
  );
  static const chipShape = StadiumBorder();
}
