import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeChoiceNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state is Classic + System', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeChoiceProvider), ThemeChoice.defaults);
    });

    test('setFamily changes palette family only', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(themeChoiceProvider.notifier)
          .setFamily(ThemeFamily.popcorn);

      final choice = container.read(themeChoiceProvider);
      expect(choice.family, ThemeFamily.popcorn);
      expect(choice.brightness, ThemeBrightness.system);
    });

    test('setBrightness changes brightness only', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(themeChoiceProvider.notifier)
          .setBrightness(ThemeBrightness.dark);

      final choice = container.read(themeChoiceProvider);
      expect(choice.family, ThemeFamily.classic);
      expect(choice.brightness, ThemeBrightness.dark);
    });

    test('setFamily and setBrightness compose', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeChoiceProvider.notifier);
      await notifier.setFamily(ThemeFamily.popcorn);
      await notifier.setBrightness(ThemeBrightness.light);

      expect(container.read(themeChoiceProvider),
          const ThemeChoice(ThemeFamily.popcorn, ThemeBrightness.light));
    });

    test('persists across provider rebuilds', () async {
      // First container writes the preference.
      final c1 = ProviderContainer();
      await c1
          .read(themeChoiceProvider.notifier)
          .setFamily(ThemeFamily.popcorn);
      await c1
          .read(themeChoiceProvider.notifier)
          .setBrightness(ThemeBrightness.dark);
      c1.dispose();

      // Second container reads the same stored prefs.
      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      // _load is fire-and-forget; pump the microtask loop.
      c2.read(themeChoiceProvider);
      await Future<void>.delayed(Duration.zero);

      expect(c2.read(themeChoiceProvider),
          const ThemeChoice(ThemeFamily.popcorn, ThemeBrightness.dark));
    });
  });

  group('Legacy theme_mode migration', () {
    test('migrates stored theme_mode=dark to Classic + Dark and clears key',
        () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'dark');

      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(themeChoiceProvider);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(themeChoiceProvider),
          const ThemeChoice(ThemeFamily.classic, ThemeBrightness.dark));

      final after = await SharedPreferences.getInstance();
      expect(after.getString('theme_mode'), isNull);
      expect(after.getString('theme_family'), ThemeFamily.classic.name);
      expect(after.getString('theme_brightness'), ThemeBrightness.dark.name);
    });

    test('new keys win over legacy when both are present', () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': 'dark',
        'theme_family': ThemeFamily.popcorn.name,
        'theme_brightness': ThemeBrightness.light.name,
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(themeChoiceProvider);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(themeChoiceProvider),
          const ThemeChoice(ThemeFamily.popcorn, ThemeBrightness.light));
    });
  });

  group('themeModeFrom', () {
    test('maps each brightness to the matching ThemeMode', () {
      expect(themeModeFrom(ThemeBrightness.system), ThemeMode.system);
      expect(themeModeFrom(ThemeBrightness.light), ThemeMode.light);
      expect(themeModeFrom(ThemeBrightness.dark), ThemeMode.dark);
    });
  });
}
