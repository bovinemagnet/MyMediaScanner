import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final apiKeysProvider =
    AsyncNotifierProvider<ApiKeysNotifier, Map<String, String?>>(
  ApiKeysNotifier.new,
);

class ApiKeysNotifier extends AsyncNotifier<Map<String, String?>> {
  static const _tmdbKey = 'api_key_tmdb';
  static const _discogsKey = 'api_key_discogs';
  static const _upcitemdbKey = 'api_key_upcitemdb';

  @override
  Future<Map<String, String?>> build() async {
    final storage = ref.watch(secureStorageProvider);
    return {
      'tmdb': await storage.read(key: _tmdbKey),
      'discogs': await storage.read(key: _discogsKey),
      'upcitemdb': await storage.read(key: _upcitemdbKey),
    };
  }

  Future<void> setTmdbKey(String key) async {
    await ref.read(secureStorageProvider).write(key: _tmdbKey, value: key);
    ref.invalidateSelf();
  }

  Future<void> setDiscogsKey(String key) async {
    await ref.read(secureStorageProvider).write(key: _discogsKey, value: key);
    ref.invalidateSelf();
  }

  Future<void> setUpcitemdbKey(String key) async {
    await ref.read(secureStorageProvider).write(
        key: _upcitemdbKey, value: key);
    ref.invalidateSelf();
  }
}
