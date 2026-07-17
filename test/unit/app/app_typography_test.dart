import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/app/theme/app_typography.dart';

void main() {
  group('AppTypography new styles', () {
    test('displayTitle uses Space Grotesk with tight tracking', () {
      final style = AppTypography.displayTitle(color: Colors.white);
      expect(style.fontFamily, 'SpaceGrotesk');
      expect(style.fontSize, 34);
      expect(style.letterSpacing, lessThan(0));
    });

    test('monoLabel uses JetBrains Mono, uppercase-ready tracking', () {
      final style = AppTypography.monoLabel(color: Colors.white);
      expect(style.fontFamily, 'JetBrainsMono');
      expect(style.letterSpacing, greaterThan(0));
      expect(style.height, 1.0);
    });

    test('monoNumeric uses JetBrains Mono', () {
      final style = AppTypography.monoNumeric(color: Colors.white);
      expect(style.fontFamily, 'JetBrainsMono');
      expect(style.fontWeight, FontWeight.w700);
    });

    test('displayNumeric switches to Space Grotesk', () {
      final style = AppTypography.displayNumeric(color: Colors.white);
      expect(style.fontFamily, 'SpaceGrotesk');
    });
  });
}
