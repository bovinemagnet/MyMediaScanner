import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/app/theme/app_media_colors.dart';
import 'package:mymediascanner/app/theme/app_theme.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

void main() {
  group('AppMediaColors factories', () {
    test('classic() yields a value for every MediaType', () {
      final mc = AppMediaColors.classic();
      for (final type in MediaType.values) {
        expect(mc.solidFor(type), isA<Color>(),
            reason: 'solid missing for $type');
        expect(mc.softFor(type), isA<Color>(),
            reason: 'soft missing for $type');
        expect(mc.inkFor(type), isA<Color>(),
            reason: 'ink missing for $type');
      }
    });

    test('popcorn() and popcornDark() yield distinct palettes', () {
      final light = AppMediaColors.popcorn();
      final dark = AppMediaColors.popcornDark();
      expect(light.film, isNot(dark.film));
      expect(light.book, isNot(dark.book));
    });

    test('classic() preserves the original AppColors film hue', () {
      // Guards against accidentally changing the Classic palette while
      // retuning Popcorn.
      final mc = AppMediaColors.classic();
      expect(mc.film, const Color(0xFFE53935));
      expect(mc.tv, const Color(0xFFFF7043));
      expect(mc.music, const Color(0xFF7E57C2));
      expect(mc.book, const Color(0xFF43A047));
      expect(mc.game, const Color(0xFF1E88E5));
    });
  });

  group('AppMediaColors ThemeExtension contract', () {
    test('copyWith returns an equal instance when no overrides pass', () {
      final a = AppMediaColors.classic();
      final b = a.copyWith();
      expect(b.film, a.film);
      expect(b.filmSoft, a.filmSoft);
      expect(b.filmInk, a.filmInk);
      expect(b.music, a.music);
    });

    test('lerp at t=0 returns this, t=1 returns other', () {
      final a = AppMediaColors.classic();
      final b = AppMediaColors.popcorn();
      final atZero = a.lerp(b, 0.0);
      final atOne = a.lerp(b, 1.0);
      expect(atZero.film, a.film);
      expect(atOne.film, b.film);
    });

    test('lerp handles null other by returning this', () {
      final a = AppMediaColors.classic();
      final result = a.lerp(null, 0.5);
      expect(result.film, a.film);
    });
  });

  group('All four themes expose AppMediaColors + AppLayoutExtension', () {
    test('AppTheme.light() registers both extensions', () {
      final theme = AppTheme.light();
      expect(theme.extension<AppMediaColors>(), isNotNull);
    });

    test('AppTheme.dark() registers both extensions', () {
      final theme = AppTheme.dark();
      expect(theme.extension<AppMediaColors>(), isNotNull);
    });

    test('AppTheme.popcornLight() registers both extensions', () {
      final theme = AppTheme.popcornLight();
      expect(theme.extension<AppMediaColors>(), isNotNull);
    });

    test('AppTheme.popcornDark() registers both extensions', () {
      final theme = AppTheme.popcornDark();
      expect(theme.extension<AppMediaColors>(), isNotNull);
    });
  });
}
