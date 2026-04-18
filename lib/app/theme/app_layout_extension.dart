import 'package:flutter/material.dart';

/// Layout feature flags carried by each theme.
///
/// Widgets check these instead of branching on `ThemeFamily` directly, so
/// enabling a Popcorn-style treatment on a future Citrus palette is one
/// factory change rather than a cross-cutting edit.
@immutable
class AppLayoutExtension extends ThemeExtension<AppLayoutExtension> {
  const AppLayoutExtension({
    required this.floatingNavBar,
    required this.gradientItemDetailHero,
    required this.heroStatGlow,
    required this.pillChips,
    required this.proceduralCovers,
  });

  /// Restrained layout used by Obsidian Lens + Precision Editorial.
  factory AppLayoutExtension.classic() => const AppLayoutExtension(
        floatingNavBar: false,
        gradientItemDetailHero: false,
        heroStatGlow: false,
        pillChips: false,
        proceduralCovers: false,
      );

  /// Full-chrome layout used by the Popcorn palette.
  factory AppLayoutExtension.popcorn() => const AppLayoutExtension(
        floatingNavBar: true,
        gradientItemDetailHero: true,
        heroStatGlow: true,
        pillChips: true,
        proceduralCovers: true,
      );

  /// Mobile bottom nav renders a floating pill bar with a raised FAB.
  final bool floatingNavBar;

  /// Item detail screen renders a gradient SliverAppBar with floating cover.
  final bool gradientItemDetailHero;

  /// Dashboard hero stat card gets a radial primary-colour glow.
  final bool heroStatGlow;

  /// Chips render as full stadium pills with bold labels.
  final bool pillChips;

  /// Missing cover art uses the procedural placeholder painter instead of
  /// a flat icon.
  final bool proceduralCovers;

  @override
  AppLayoutExtension copyWith({
    bool? floatingNavBar,
    bool? gradientItemDetailHero,
    bool? heroStatGlow,
    bool? pillChips,
    bool? proceduralCovers,
  }) {
    return AppLayoutExtension(
      floatingNavBar: floatingNavBar ?? this.floatingNavBar,
      gradientItemDetailHero:
          gradientItemDetailHero ?? this.gradientItemDetailHero,
      heroStatGlow: heroStatGlow ?? this.heroStatGlow,
      pillChips: pillChips ?? this.pillChips,
      proceduralCovers: proceduralCovers ?? this.proceduralCovers,
    );
  }

  @override
  AppLayoutExtension lerp(
      covariant ThemeExtension<AppLayoutExtension>? other, double t) {
    if (other is! AppLayoutExtension) return this;
    // Bool lerp: snap at the midpoint.
    bool pickBool(bool a, bool b) => t < 0.5 ? a : b;
    return AppLayoutExtension(
      floatingNavBar: pickBool(floatingNavBar, other.floatingNavBar),
      gradientItemDetailHero:
          pickBool(gradientItemDetailHero, other.gradientItemDetailHero),
      heroStatGlow: pickBool(heroStatGlow, other.heroStatGlow),
      pillChips: pickBool(pillChips, other.pillChips),
      proceduralCovers: pickBool(proceduralCovers, other.proceduralCovers),
    );
  }
}

extension AppLayoutExtensionContext on BuildContext {
  /// Current layout feature flags. Falls back to [AppLayoutExtension.classic]
  /// (all flags off) when no extension is registered, so widget tests that
  /// pump a bare [MaterialApp] keep working.
  AppLayoutExtension get layoutFlags =>
      Theme.of(this).extension<AppLayoutExtension>() ??
      AppLayoutExtension.classic();
}
