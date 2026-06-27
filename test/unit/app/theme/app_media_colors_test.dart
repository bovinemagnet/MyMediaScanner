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

    for (final factory in <(String, AppMediaColors Function())>[
      ('kinetic()', AppMediaColors.kinetic),
      ('kineticLight()', AppMediaColors.kineticLight),
      ('vault()', AppMediaColors.vault),
      ('vaultLight()', AppMediaColors.vaultLight),
      ('index()', AppMediaColors.index),
      ('indexLight()', AppMediaColors.indexLight),
    ]) {
      final (label, build) = factory;
      test('$label yields a value for every MediaType', () {
        final mc = build();
        for (final type in MediaType.values) {
          expect(mc.solidFor(type), isA<Color>(),
              reason: 'solid missing for $type in $label');
          expect(mc.softFor(type), isA<Color>(),
              reason: 'soft missing for $type in $label');
          expect(mc.inkFor(type), isA<Color>(),
              reason: 'ink missing for $type in $label');
        }
      });
    }

    test('kinetic() and kineticLight() yield distinct palettes', () {
      expect(AppMediaColors.kinetic().film, isNot(AppMediaColors.kineticLight().film));
    });

    test('vault() and vaultLight() yield distinct palettes', () {
      expect(AppMediaColors.vault().film, isNot(AppMediaColors.vaultLight().film));
    });

    test('index() and indexLight() yield distinct palettes', () {
      expect(AppMediaColors.index().film, isNot(AppMediaColors.indexLight().film));
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

  group('All themes expose AppMediaColors extension', () {
    for (final entry in <(String, ThemeData Function())>[
      ('light()', AppTheme.light),
      ('dark()', AppTheme.dark),
      ('popcornLight()', AppTheme.popcornLight),
      ('popcornDark()', AppTheme.popcornDark),
      ('kineticLight()', AppTheme.kineticLight),
      ('kineticDark()', AppTheme.kineticDark),
      ('vaultLight()', AppTheme.vaultLight),
      ('vaultDark()', AppTheme.vaultDark),
      ('indexLight()', AppTheme.indexLight),
      ('indexDark()', AppTheme.indexDark),
    ]) {
      final (label, build) = entry;
      test('AppTheme.$label registers AppMediaColors', () {
        expect(build().extension<AppMediaColors>(), isNotNull);
      });
    }
  });
}
