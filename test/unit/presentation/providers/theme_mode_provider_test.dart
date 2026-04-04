import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Provide empty SharedPreferences for tests
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeModeNotifier', () {
    test('initial state is ThemeMode.system', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('setMode updates state to light', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(themeModeProvider.notifier).setMode(ThemeMode.light);

      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    test('setMode updates state to dark', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(themeModeProvider.notifier).setMode(ThemeMode.dark);

      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('setMode back to system works', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
      await container.read(themeModeProvider.notifier).setMode(ThemeMode.system);

      expect(container.read(themeModeProvider), ThemeMode.system);
    });
  });
}
