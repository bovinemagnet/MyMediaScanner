import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/domain/entities/tmdb_conflict_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Theme choice (palette family × brightness) ───────────────────────

/// Palette family — which colour/component set powers the UI.
enum ThemeFamily { classic, popcorn }

/// Brightness preference for the selected family.
enum ThemeBrightness { system, light, dark }

/// Combined theme selection: a family paired with a brightness.
@immutable
class ThemeChoice {
  const ThemeChoice(this.family, this.brightness);

  /// Default for new installs and users who have never touched Settings.
  static const defaults =
      ThemeChoice(ThemeFamily.classic, ThemeBrightness.system);

  final ThemeFamily family;
  final ThemeBrightness brightness;

  ThemeChoice copyWith({ThemeFamily? family, ThemeBrightness? brightness}) =>
      ThemeChoice(family ?? this.family, brightness ?? this.brightness);

  @override
  bool operator ==(Object other) =>
      other is ThemeChoice &&
      other.family == family &&
      other.brightness == brightness;

  @override
  int get hashCode => Object.hash(family, brightness);

  @override
  String toString() => 'ThemeChoice($family, $brightness)';
}

class ThemeChoiceNotifier extends Notifier<ThemeChoice> {
  static const _familyKey = 'theme_family';
  static const _brightnessKey = 'theme_brightness';

  /// Legacy key from the single-dimension ThemeMode era. Read once during
  /// [_load] to seed [ThemeChoice.brightness] for existing users, then
  /// deleted so it can't drift.
  static const _legacyModeKey = 'theme_mode';

  @override
  ThemeChoice build() {
    _load();
    return ThemeChoice.defaults;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final storedFamily = prefs.getString(_familyKey);
    final storedBrightness = prefs.getString(_brightnessKey);

    // Fresh install or pre-2.x install with only the legacy key.
    if (storedFamily == null && storedBrightness == null) {
      final legacy = prefs.getString(_legacyModeKey);
      if (legacy != null) {
        final brightness = ThemeBrightness.values.firstWhere(
          (b) => b.name == legacy,
          orElse: () => ThemeBrightness.system,
        );
        final migrated = ThemeChoice(ThemeFamily.classic, brightness);
        if (!ref.mounted) return;
        state = migrated;
        await prefs.setString(_familyKey, migrated.family.name);
        await prefs.setString(_brightnessKey, migrated.brightness.name);
        await prefs.remove(_legacyModeKey);
      }
      return;
    }

    if (!ref.mounted) return;
    state = ThemeChoice(
      ThemeFamily.values.firstWhere(
        (f) => f.name == storedFamily,
        orElse: () => ThemeFamily.classic,
      ),
      ThemeBrightness.values.firstWhere(
        (b) => b.name == storedBrightness,
        orElse: () => ThemeBrightness.system,
      ),
    );
  }

  Future<void> setFamily(ThemeFamily family) async {
    state = state.copyWith(family: family);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_familyKey, family.name);
  }

  Future<void> setBrightness(ThemeBrightness brightness) async {
    state = state.copyWith(brightness: brightness);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_brightnessKey, brightness.name);
  }
}

final themeChoiceProvider =
    NotifierProvider<ThemeChoiceNotifier, ThemeChoice>(
        ThemeChoiceNotifier.new);

/// Maps [ThemeBrightness] to Material's [ThemeMode].
ThemeMode themeModeFrom(ThemeBrightness brightness) => switch (brightness) {
      ThemeBrightness.system => ThemeMode.system,
      ThemeBrightness.light => ThemeMode.light,
      ThemeBrightness.dark => ThemeMode.dark,
    };

// ── GnuDB username (identifier sent in the CDDB "hello" string) ──────

class GnudbUsernameNotifier extends Notifier<String> {
  static const _key = 'gnudb_username';
  static const _default = 'mymediascanner';

  @override
  String build() {
    _load();
    return _default;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored != null && stored.isNotEmpty && ref.mounted) {
      state = stored;
    }
  }

  Future<void> setUsername(String value) async {
    final trimmed = value.trim();
    state = trimmed.isEmpty ? _default : trimmed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, state);
  }
}

final gnudbUsernameProvider =
    NotifierProvider<GnudbUsernameNotifier, String>(GnudbUsernameNotifier.new);

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
  static const _twitchClientIdKey = 'api_key_twitch_client_id';
  static const _twitchClientSecretKey = 'api_key_twitch_client_secret';

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
      'twitch_client_id': await storage.read(key: _twitchClientIdKey),
      'twitch_client_secret': await storage.read(key: _twitchClientSecretKey),
    };
  }

  /// Writes [value] under [storageKey], or deletes the entry when the
  /// trimmed value is empty. Without the delete branch a cleared field
  /// would persist as `''`, which the metadata provider previously
  /// treated as configured and used to spin up authenticated clients
  /// with empty credentials.
  Future<void> _writeOrDelete(String storageKey, String value) async {
    final trimmed = value.trim();
    final storage = ref.read(secureStorageProvider);
    if (trimmed.isEmpty) {
      await storage.delete(key: storageKey);
    } else {
      await storage.write(key: storageKey, value: trimmed);
    }
    ref.invalidateSelf();
  }

  Future<void> setTmdbKey(String key) => _writeOrDelete(_tmdbKey, key);

  Future<void> setDiscogsKey(String key) => _writeOrDelete(_discogsKey, key);

  Future<void> setUpcitemdbKey(String key) =>
      _writeOrDelete(_upcitemdbKey, key);

  Future<void> setGoogleBooksKey(String key) =>
      _writeOrDelete(_googleBooksKey, key);

  Future<void> setTvdbKey(String key) => _writeOrDelete(_tvdbKey, key);

  Future<void> setFanartKey(String key) => _writeOrDelete(_fanartKey, key);

  Future<void> setTwitchClientId(String key) =>
      _writeOrDelete(_twitchClientIdKey, key);

  Future<void> setTwitchClientSecret(String key) =>
      _writeOrDelete(_twitchClientSecretKey, key);
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

// ── TMDB account-sync prefs ─────────────────────────────────────

class TmdbAccountSyncSettings {
  const TmdbAccountSyncSettings({
    this.enabled = false,
    this.enrichScans = true,
    this.twoWaySync = true,
    this.mirrorOwnership = false,
    this.conflictPolicy = TmdbConflictPolicy.preferLatestTimestamp,
    this.lastSyncAt,
    this.lastSyncPulled = 0,
    this.lastSyncFailed = 0,
    this.lastError,
  });

  final bool enabled;
  final bool enrichScans;
  final bool twoWaySync;
  final bool mirrorOwnership;
  final TmdbConflictPolicy conflictPolicy;
  final DateTime? lastSyncAt;
  final int lastSyncPulled;
  final int lastSyncFailed;
  final String? lastError;

  TmdbAccountSyncSettings copyWith({
    bool? enabled,
    bool? enrichScans,
    bool? twoWaySync,
    bool? mirrorOwnership,
    TmdbConflictPolicy? conflictPolicy,
    DateTime? lastSyncAt,
    int? lastSyncPulled,
    int? lastSyncFailed,
    String? lastError,
    bool clearLastError = false,
  }) =>
      TmdbAccountSyncSettings(
        enabled: enabled ?? this.enabled,
        enrichScans: enrichScans ?? this.enrichScans,
        twoWaySync: twoWaySync ?? this.twoWaySync,
        mirrorOwnership: mirrorOwnership ?? this.mirrorOwnership,
        conflictPolicy: conflictPolicy ?? this.conflictPolicy,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        lastSyncPulled: lastSyncPulled ?? this.lastSyncPulled,
        lastSyncFailed: lastSyncFailed ?? this.lastSyncFailed,
        lastError: clearLastError ? null : (lastError ?? this.lastError),
      );
}

class TmdbAccountSyncSettingsNotifier
    extends Notifier<TmdbAccountSyncSettings> {
  static const _kEnabled = 'tmdb.account_sync.enabled';
  static const _kEnrichScans = 'tmdb.account_sync.enrich_scans';
  static const _kTwoWay = 'tmdb.account_sync.two_way_sync';
  static const _kMirror = 'tmdb.account_sync.mirror_ownership';
  static const _kConflictPolicy = 'tmdb.account_sync.conflict_policy';
  static const _kLastSyncAt = 'tmdb.account_sync.last_sync_at';
  static const _kLastPulled = 'tmdb.account_sync.last_sync_pulled';
  static const _kLastFailed = 'tmdb.account_sync.last_sync_failed';
  static const _kLastError = 'tmdb.account_sync.last_error';

  @override
  TmdbAccountSyncSettings build() {
    _load();
    return const TmdbAccountSyncSettings();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!ref.mounted) return;
    final lastSyncMs = p.getInt(_kLastSyncAt);
    state = TmdbAccountSyncSettings(
      enabled: p.getBool(_kEnabled) ?? false,
      enrichScans: p.getBool(_kEnrichScans) ?? true,
      twoWaySync: p.getBool(_kTwoWay) ?? true,
      mirrorOwnership: p.getBool(_kMirror) ?? false,
      conflictPolicy: TmdbConflictPolicy.fromName(p.getString(_kConflictPolicy)),
      lastSyncAt: lastSyncMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastSyncMs),
      lastSyncPulled: p.getInt(_kLastPulled) ?? 0,
      lastSyncFailed: p.getInt(_kLastFailed) ?? 0,
      lastError: p.getString(_kLastError),
    );
  }

  Future<void> setEnabled(bool v) async {
    state = state.copyWith(enabled: v);
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kEnabled, v);
  }

  Future<void> setEnrichScans(bool v) async {
    state = state.copyWith(enrichScans: v);
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kEnrichScans, v);
  }

  Future<void> setTwoWaySync(bool v) async {
    state = state.copyWith(twoWaySync: v);
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kTwoWay, v);
  }

  Future<void> setMirrorOwnership(bool v) async {
    state = state.copyWith(mirrorOwnership: v);
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kMirror, v);
  }

  Future<void> setConflictPolicy(TmdbConflictPolicy policy) async {
    state = state.copyWith(conflictPolicy: policy);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kConflictPolicy, policy.name);
  }

  Future<void> recordSyncResult({
    required int pulled,
    required int failed,
    String? error,
  }) async {
    final now = DateTime.now();
    state = state.copyWith(
      lastSyncAt: now,
      lastSyncPulled: pulled,
      lastSyncFailed: failed,
      lastError: error,
      clearLastError: error == null,
    );
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kLastSyncAt, now.millisecondsSinceEpoch);
    await p.setInt(_kLastPulled, pulled);
    await p.setInt(_kLastFailed, failed);
    if (error == null) {
      await p.remove(_kLastError);
    } else {
      await p.setString(_kLastError, error);
    }
  }
}

final tmdbAccountSyncSettingsProvider = NotifierProvider<
    TmdbAccountSyncSettingsNotifier,
    TmdbAccountSyncSettings>(TmdbAccountSyncSettingsNotifier.new);
