import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

ProviderContainer _makeContainer(MockFlutterSecureStorage storage) {
  final container = ProviderContainer(
    overrides: [secureStorageProvider.overrideWithValue(storage)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  MockFlutterSecureStorage stubbedStorage() {
    final storage = MockFlutterSecureStorage();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() => storage.write(
            key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    when(() => storage.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});
    return storage;
  }

  group('ApiKeysNotifier.setTmdbKey clears dependent account sync', () {
    test('clearing the TMDB key disables account sync', () async {
      final storage = stubbedStorage();
      final container = _makeContainer(storage);

      // Enable account sync (as if the user had connected with a key).
      await container
          .read(tmdbAccountSyncSettingsProvider.notifier)
          .setEnabled(true);
      expect(
          container.read(tmdbAccountSyncSettingsProvider).enabled, isTrue);

      // Clearing the key must disable account sync so dependent scan/save
      // paths and the sidebar never reach the now-unavailable repository.
      await container.read(apiKeysProvider.notifier).setTmdbKey('');

      expect(
          container.read(tmdbAccountSyncSettingsProvider).enabled, isFalse);
      verify(() => storage.delete(key: 'api_key_tmdb')).called(1);
    });

    test('whitespace-only key is treated as cleared and disables sync',
        () async {
      final storage = stubbedStorage();
      final container = _makeContainer(storage);

      await container
          .read(tmdbAccountSyncSettingsProvider.notifier)
          .setEnabled(true);

      await container.read(apiKeysProvider.notifier).setTmdbKey('   ');

      expect(
          container.read(tmdbAccountSyncSettingsProvider).enabled, isFalse);
    });

    test('setting a non-empty key leaves account sync untouched', () async {
      final storage = stubbedStorage();
      final container = _makeContainer(storage);

      await container
          .read(tmdbAccountSyncSettingsProvider.notifier)
          .setEnabled(true);

      await container
          .read(apiKeysProvider.notifier)
          .setTmdbKey('abc123token');

      expect(
          container.read(tmdbAccountSyncSettingsProvider).enabled, isTrue);
      verify(() => storage.write(key: 'api_key_tmdb', value: 'abc123token'))
          .called(1);
    });
  });
}
