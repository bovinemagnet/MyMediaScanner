import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Theme mode provider ──────────────────────────────────────────────

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored != null) {
      state = ThemeMode.values.firstWhere(
        (m) => m.name == stored,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// ── Secure storage ───────────────────────────────────────────────────

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
  static const _googleBooksKey = 'api_key_google_books';
  static const _tvdbKey = 'api_key_tvdb';
  static const _fanartKey = 'api_key_fanart';

  @override
  Future<Map<String, String?>> build() async {
    final storage = ref.watch(secureStorageProvider);
    return {
      'tmdb': await storage.read(key: _tmdbKey),
      'discogs': await storage.read(key: _discogsKey),
      'upcitemdb': await storage.read(key: _upcitemdbKey),
      'google_books': await storage.read(key: _googleBooksKey),
      'tvdb': await storage.read(key: _tvdbKey),
      'fanart': await storage.read(key: _fanartKey),
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

  Future<void> setGoogleBooksKey(String key) async {
    await ref.read(secureStorageProvider).write(
        key: _googleBooksKey, value: key);
    ref.invalidateSelf();
  }

  Future<void> setTvdbKey(String key) async {
    await ref.read(secureStorageProvider).write(key: _tvdbKey, value: key);
    ref.invalidateSelf();
  }

  Future<void> setFanartKey(String key) async {
    await ref.read(secureStorageProvider).write(key: _fanartKey, value: key);
    ref.invalidateSelf();
  }
}

final postgresConfigProvider =
    AsyncNotifierProvider<PostgresConfigNotifier, PostgresConfig?>(
  PostgresConfigNotifier.new,
);

class PostgresConfigNotifier extends AsyncNotifier<PostgresConfig?> {
  static const _hostKey = 'pg_host';
  static const _portKey = 'pg_port';
  static const _dbKey = 'pg_database';
  static const _userKey = 'pg_username';
  static const _passKey = 'pg_password';
  static const _tlsKey = 'pg_require_tls';

  @override
  Future<PostgresConfig?> build() async {
    final storage = ref.watch(secureStorageProvider);
    final host = await storage.read(key: _hostKey);
    if (host == null) return null;

    return PostgresConfig(
      host: host,
      port: int.tryParse(await storage.read(key: _portKey) ?? '') ?? 5432,
      database: await storage.read(key: _dbKey) ?? '',
      username: await storage.read(key: _userKey) ?? '',
      password: await storage.read(key: _passKey) ?? '',
      requireTls: (await storage.read(key: _tlsKey)) != 'false',
    );
  }

  Future<void> save(PostgresConfig config) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: _hostKey, value: config.host);
    await storage.write(key: _portKey, value: config.port.toString());
    await storage.write(key: _dbKey, value: config.database);
    await storage.write(key: _userKey, value: config.username);
    await storage.write(key: _passKey, value: config.password);
    await storage.write(key: _tlsKey, value: config.requireTls.toString());
    ref.invalidateSelf();
  }
}
