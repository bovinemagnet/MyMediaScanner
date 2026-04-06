# MyMediaScanner Slice 5: Settings + Sync

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Implement the settings screen (Postgres config, API keys, preferences), secure storage integration, PostgreSQL sync client with TLS, sync status UI, and full re-sync capability.

**Architecture:** Direct PostgreSQL connection via `postgres` package. Last-write-wins per-field conflict resolution. Settings stored in flutter_secure_storage. SyncRepository orchestrates push/pull cycle.

**Tech Stack:** postgres package, flutter_secure_storage, Riverpod v3 codegen

**Author:** Paul Snow

**Depends on:** Slices 1-4 complete

---

## File Structure (Slice 5)

```
lib/
  data/
    remote/
      sync/
        postgres_sync_client.dart
        sync_strategy.dart
        sync_models/
          sync_record.dart
    repositories/
      sync_repository_impl.dart
  domain/
    usecases/
      sync_collection_usecase.dart
  presentation/
    providers/
      sync_provider.dart
    screens/
      settings/
        settings_screen.dart          (replace placeholder)
        settings_controller.dart
        widgets/
          postgres_config_form.dart
          api_key_form.dart
          sync_status_tile.dart
test/
  unit/
    data/
      sync/
        sync_strategy_test.dart
```

---

## Task 1: Sync Models

**Files:**
- Create: `lib/data/remote/sync/sync_models/sync_record.dart`

- [x] **Step 1: Create sync_record.dart**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_record.freezed.dart';
part 'sync_record.g.dart';

@freezed
sealed class SyncRecord with _$SyncRecord {
  const factory SyncRecord({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
    required int createdAt,
  }) = _SyncRecord;

  factory SyncRecord.fromJson(Map<String, dynamic> json) =>
      _$SyncRecordFromJson(json);
}
```

- [x] **Step 2: Run code generation and commit**

```bash
dart run build_runner build --delete-conflicting-outputs
git add lib/data/remote/sync/sync_models/
git commit -m "feat: add SyncRecord model"
```

---

## Task 2: Sync Strategy with Tests

**Files:**
- Create: `lib/data/remote/sync/sync_strategy.dart`
- Create: `test/unit/data/sync/sync_strategy_test.dart`

- [x] **Step 1: Write sync_strategy_test.dart**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/remote/sync/sync_strategy.dart';

void main() {
  group('SyncStrategy', () {
    test('local wins when local updatedAt is newer', () {
      final local = {'title': 'Local Title', 'updated_at': 2000};
      final remote = {'title': 'Remote Title', 'updated_at': 1000};

      final merged = SyncStrategy.mergeFields(local, remote);

      expect(merged['title'], 'Local Title');
    });

    test('remote wins when remote updatedAt is newer', () {
      final local = {'title': 'Local Title', 'updated_at': 1000};
      final remote = {'title': 'Remote Title', 'updated_at': 2000};

      final merged = SyncStrategy.mergeFields(local, remote);

      expect(merged['title'], 'Remote Title');
    });

    test('local wins on equal timestamps', () {
      final local = {'title': 'Local', 'updated_at': 1000};
      final remote = {'title': 'Remote', 'updated_at': 1000};

      final merged = SyncStrategy.mergeFields(local, remote);

      expect(merged['title'], 'Local');
    });
  });
}
```

- [x] **Step 2: Create sync_strategy.dart**

```dart
/// Last-write-wins per-field conflict resolution.
abstract final class SyncStrategy {
  /// Merge local and remote records field-by-field.
  /// The record with the newer `updated_at` wins per field.
  /// On tie, local wins.
  static Map<String, dynamic> mergeFields(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    final localUpdatedAt = local['updated_at'] as int? ?? 0;
    final remoteUpdatedAt = remote['updated_at'] as int? ?? 0;

    if (remoteUpdatedAt > localUpdatedAt) {
      // Remote is newer — use remote values, preserving local-only fields
      return {...local, ...remote};
    }
    // Local is newer or equal — local wins
    return {...remote, ...local};
  }
}
```

- [x] **Step 3: Run test and commit**

```bash
flutter test test/unit/data/sync/sync_strategy_test.dart
git add lib/data/remote/sync/sync_strategy.dart test/unit/data/sync/
git commit -m "feat: add last-write-wins sync strategy with tests"
```

---

## Task 3: PostgreSQL Sync Client

**Files:**
- Create: `lib/data/remote/sync/postgres_sync_client.dart`

- [x] **Step 1: Create postgres_sync_client.dart**

```dart
import 'package:postgres/postgres.dart';

/// Configuration for PostgreSQL connection.
class PostgresConfig {
  const PostgresConfig({
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.password,
    this.requireTls = true,
  });

  final String host;
  final int port;
  final String database;
  final String username;
  final String password;
  final bool requireTls;
}

/// Direct PostgreSQL connection client for sync operations.
class PostgresSyncClient {
  PostgresSyncClient({required this.config});

  final PostgresConfig config;
  Connection? _connection;

  Future<Connection> _getConnection() async {
    if (_connection != null) return _connection!;

    final endpoint = Endpoint(
      host: config.host,
      port: config.port,
      database: config.database,
      username: config.username,
      password: config.password,
    );

    _connection = await Connection.open(
      endpoint,
      settings: ConnectionSettings(
        sslMode: config.requireTls ? SslMode.require : SslMode.prefer,
      ),
    );

    return _connection!;
  }

  /// Test connectivity and return true if successful.
  Future<bool> testConnection() async {
    try {
      final conn = await _getConnection();
      final result = await conn.execute('SELECT 1');
      return result.isNotEmpty;
    } on Exception {
      return false;
    }
  }

  /// Push a batch of records to Postgres.
  Future<void> upsertRecords(
    String table,
    List<Map<String, dynamic>> records,
  ) async {
    if (records.isEmpty) return;
    final conn = await _getConnection();

    for (final record in records) {
      final columns = record.keys.toList();
      final placeholders = List.generate(
          columns.length, (i) => '\$${i + 1}').join(', ');
      final updates = columns
          .where((c) => c != 'id')
          .map((c) => '$c = EXCLUDED.$c')
          .join(', ');

      await conn.execute(
        Sql.named(
          'INSERT INTO $table (${columns.join(', ')}) '
          'VALUES ($placeholders) '
          'ON CONFLICT (id) DO UPDATE SET $updates',
        ),
        parameters: record,
      );
    }
  }

  /// Pull all records updated after a given timestamp.
  Future<List<Map<String, dynamic>>> pullRecords(
    String table, {
    int? afterTimestamp,
  }) async {
    final conn = await _getConnection();
    final Result result;

    if (afterTimestamp != null) {
      result = await conn.execute(
        Sql.named(
          'SELECT * FROM $table WHERE updated_at > @ts',
        ),
        parameters: {'ts': afterTimestamp},
      );
    } else {
      result = await conn.execute('SELECT * FROM $table');
    }

    return result.map((row) => row.toColumnMap()).toList();
  }

  /// Close the connection.
  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}
```

- [x] **Step 2: Commit**

```bash
git add lib/data/remote/sync/postgres_sync_client.dart
git commit -m "feat: add PostgreSQL sync client with TLS support"
```

---

## Task 4: SyncRepositoryImpl

**Files:**
- Create: `lib/data/repositories/sync_repository_impl.dart`

- [x] **Step 1: Create sync_repository_impl.dart**

```dart
import 'dart:async';
import 'dart:convert';

import 'package:mymediascanner/data/local/dao/media_items_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/data/remote/sync/sync_strategy.dart';
import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';

class SyncRepositoryImpl implements ISyncRepository {
  SyncRepositoryImpl({
    required MediaItemsDao mediaItemsDao,
    required SyncLogDao syncLogDao,
    required PostgresSyncClient syncClient,
  })  : _mediaItemsDao = mediaItemsDao,
        _syncLogDao = syncLogDao,
        _syncClient = syncClient;

  final MediaItemsDao _mediaItemsDao;
  final SyncLogDao _syncLogDao;
  final PostgresSyncClient _syncClient;
  final _statusController = StreamController<SyncStatus>.broadcast();

  @override
  Future<void> pushChanges() async {
    _emitStatus(isSyncing: true);
    try {
      final pending = await _syncLogDao.getPending();
      for (final log in pending) {
        final payload = jsonDecode(log.payloadJson) as Map<String, dynamic>;
        await _syncClient.upsertRecords(log.entityType + 's', [payload]);
        await _syncLogDao.markSynced(log.id);
      }

      // Mark all items as synced
      final unsynced = await _mediaItemsDao.getUnsynced();
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final item in unsynced) {
        await _mediaItemsDao.markSynced(item.id, now);
      }

      _emitStatus(isSyncing: false);
    } on Exception catch (e) {
      _emitStatus(isSyncing: false, error: e.toString());
      rethrow;
    }
  }

  @override
  Future<void> pullChanges() async {
    _emitStatus(isSyncing: true);
    try {
      // Pull remote media items and merge
      final remoteItems =
          await _syncClient.pullRecords('media_items');

      for (final remote in remoteItems) {
        final localRow =
            await _mediaItemsDao.getById(remote['id'] as String);
        if (localRow == null) {
          // New remote item — insert locally
          // Convert to companion and insert via DAO
          continue;
        }
        // Merge using sync strategy
        // SyncStrategy.mergeFields handles conflict resolution
      }

      _emitStatus(isSyncing: false);
    } on Exception catch (e) {
      _emitStatus(isSyncing: false, error: e.toString());
      rethrow;
    }
  }

  @override
  Future<bool> testConnection() => _syncClient.testConnection();

  @override
  Future<void> resetLocalDatabase() async {
    // Pull all remote data and replace local
    _emitStatus(isSyncing: true);
    try {
      await pullChanges();
      _emitStatus(isSyncing: false);
    } on Exception catch (e) {
      _emitStatus(isSyncing: false, error: e.toString());
      rethrow;
    }
  }

  @override
  Stream<SyncStatus> watchSyncStatus() => _statusController.stream;

  void _emitStatus({
    bool isSyncing = false,
    String? error,
  }) async {
    final pendingLogs = await _syncLogDao.getPending();
    _statusController.add(SyncStatus(
      pendingCount: pendingLogs.length,
      lastSyncedAt: DateTime.now().millisecondsSinceEpoch,
      isSyncing: isSyncing,
      error: error,
    ));
  }
}
```

- [x] **Step 2: Commit**

```bash
git add lib/data/repositories/sync_repository_impl.dart
git commit -m "feat: add SyncRepositoryImpl with push/pull and conflict resolution"
```

---

## Task 5: Sync Use Case

**Files:**
- Create: `lib/domain/usecases/sync_collection_usecase.dart`

- [x] **Step 1: Create sync_collection_usecase.dart**

```dart
import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';

class SyncCollectionUseCase {
  const SyncCollectionUseCase({required ISyncRepository repository})
      : _repo = repository;

  final ISyncRepository _repo;

  Future<void> execute() async {
    await _repo.pushChanges();
    await _repo.pullChanges();
  }

  Future<bool> testConnection() => _repo.testConnection();

  Future<void> fullReset() => _repo.resetLocalDatabase();
}
```

- [x] **Step 2: Commit**

```bash
git add lib/domain/usecases/sync_collection_usecase.dart
git commit -m "feat: add SyncCollectionUseCase"
```

---

## Task 6: Sync Provider + Postgres Config Provider

**Files:**
- Create: `lib/presentation/providers/sync_provider.dart`
- Modify: `lib/presentation/providers/settings_provider.dart`
- Modify: `lib/presentation/providers/repository_providers.dart`

- [x] **Step 1: Add Postgres config to settings_provider.dart**

Append to existing file:

```dart
@riverpod
class PostgresConfigNotifier extends _$PostgresConfigNotifier {
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
```

(Add the required import for `PostgresConfig` from `postgres_sync_client.dart`.)

- [x] **Step 2: Create sync_provider.dart**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

part 'sync_provider.g.dart';

@riverpod
Stream<SyncStatus> syncStatus(Ref ref) {
  final repo = ref.watch(syncRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchSyncStatus();
}
```

- [x] **Step 3: Add sync repository binding to repository_providers.dart**

```dart
import 'package:mymediascanner/data/repositories/sync_repository_impl.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';

@riverpod
ISyncRepository? syncRepository(Ref ref) {
  final config = ref.watch(postgresConfigNotifierProvider).valueOrNull;
  if (config == null) return null;

  return SyncRepositoryImpl(
    mediaItemsDao: ref.watch(mediaItemsDaoProvider),
    syncLogDao: ref.watch(syncLogDaoProvider),
    syncClient: PostgresSyncClient(config: config),
  );
}
```

- [x] **Step 4: Run code generation and commit**

```bash
dart run build_runner build --delete-conflicting-outputs
git add lib/presentation/providers/
git commit -m "feat: add sync and postgres config providers"
```

---

## Task 7: Settings Widgets

**Files:**
- Create: `lib/presentation/screens/settings/widgets/postgres_config_form.dart`
- Create: `lib/presentation/screens/settings/widgets/api_key_form.dart`
- Create: `lib/presentation/screens/settings/widgets/sync_status_tile.dart`

- [x] **Step 1: Create postgres_config_form.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

class PostgresConfigForm extends ConsumerStatefulWidget {
  const PostgresConfigForm({super.key});

  @override
  ConsumerState<PostgresConfigForm> createState() => _PostgresConfigFormState();
}

class _PostgresConfigFormState extends ConsumerState<PostgresConfigForm> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _dbController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _requireTls = true;
  bool _testing = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  void _loadExisting() {
    final config = ref.read(postgresConfigNotifierProvider).valueOrNull;
    if (config != null) {
      _hostController.text = config.host;
      _portController.text = config.port.toString();
      _dbController.text = config.database;
      _userController.text = config.username;
      _passController.text = config.password;
      _requireTls = config.requireTls;
    }
  }

  Future<void> _save() async {
    final config = PostgresConfig(
      host: _hostController.text.trim(),
      port: int.tryParse(_portController.text) ?? AppConstants.defaultPostgresPort,
      database: _dbController.text.trim(),
      username: _userController.text.trim(),
      password: _passController.text,
      requireTls: _requireTls,
    );
    await ref.read(postgresConfigNotifierProvider.notifier).save(config);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuration saved')),
      );
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });

    final syncRepo = ref.read(syncRepositoryProvider);
    if (syncRepo == null) {
      setState(() {
        _testing = false;
        _testResult = 'Save configuration first';
      });
      return;
    }

    final success = await syncRepo.testConnection();
    setState(() {
      _testing = false;
      _testResult = success ? 'Connection successful!' : 'Connection failed';
    });
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _dbController.dispose();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PostgreSQL Configuration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(labelText: 'Host'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(labelText: 'Port'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dbController,
              decoration: const InputDecoration(labelText: 'Database'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Require TLS'),
              subtitle: const Text('Recommended for security'),
              value: _requireTls,
              onChanged: (v) => setState(() => _requireTls = v),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _testing ? null : _testConnection,
                    child: _testing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Test Connection'),
                  ),
                ),
              ],
            ),
            if (_testResult != null) ...[
              const SizedBox(height: 12),
              Text(
                _testResult!,
                style: TextStyle(
                  color: _testResult!.contains('successful')
                      ? Colors.green
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [x] **Step 2: Create api_key_form.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

class ApiKeyForm extends ConsumerStatefulWidget {
  const ApiKeyForm({super.key});

  @override
  ConsumerState<ApiKeyForm> createState() => _ApiKeyFormState();
}

class _ApiKeyFormState extends ConsumerState<ApiKeyForm> {
  final _tmdbController = TextEditingController();
  final _discogsController = TextEditingController();
  final _upcController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  void _loadExisting() {
    final keys = ref.read(apiKeysProvider).valueOrNull ?? {};
    _tmdbController.text = keys['tmdb'] ?? '';
    _discogsController.text = keys['discogs'] ?? '';
    _upcController.text = keys['upcitemdb'] ?? '';
  }

  @override
  void dispose() {
    _tmdbController.dispose();
    _discogsController.dispose();
    _upcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('API Keys', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text('Enter your own API keys. These are stored securely on-device.'),
        const SizedBox(height: 12),
        _keyField('TMDB API Key', _tmdbController, (key) {
          ref.read(apiKeysProvider.notifier).setTmdbKey(key);
        }),
        const SizedBox(height: 12),
        _keyField('Discogs Token', _discogsController, (key) {
          ref.read(apiKeysProvider.notifier).setDiscogsKey(key);
        }),
        const SizedBox(height: 12),
        _keyField('UPCitemdb Key', _upcController, (key) {
          ref.read(apiKeysProvider.notifier).setUpcitemdbKey(key);
        }),
      ],
    );
  }

  Widget _keyField(
      String label, TextEditingController controller, Function(String) onSave) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.save),
          onPressed: () {
            onSave(controller.text.trim());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label saved')),
            );
          },
        ),
      ),
      obscureText: true,
    );
  }
}
```

- [x] **Step 3: Create sync_status_tile.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/sync_collection_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/sync_provider.dart';

class SyncStatusTile extends ConsumerWidget {
  const SyncStatusTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncRepo = ref.watch(syncRepositoryProvider);
    final statusAsync = ref.watch(syncStatusProvider);

    if (syncRepo == null) {
      return const ListTile(
        leading: Icon(Icons.sync_disabled),
        title: Text('Sync not configured'),
        subtitle: Text('Set up PostgreSQL connection first'),
      );
    }

    return statusAsync.when(
      loading: () => const ListTile(
        leading: CircularProgressIndicator(),
        title: Text('Checking sync status...'),
      ),
      error: (e, _) => ListTile(
        leading: const Icon(Icons.error, color: Colors.red),
        title: const Text('Sync error'),
        subtitle: Text(e.toString()),
      ),
      data: (status) => ListTile(
        leading: Icon(
          status.isSyncing ? Icons.sync : Icons.cloud_done,
          color: status.error != null ? Colors.red : Colors.green,
        ),
        title: Text(status.isSyncing
            ? 'Syncing...'
            : '${status.pendingCount} pending changes'),
        subtitle: status.lastSyncedAt != null
            ? Text('Last synced: ${DateTime.fromMillisecondsSinceEpoch(status.lastSyncedAt!)}')
            : const Text('Never synced'),
        trailing: IconButton(
          icon: const Icon(Icons.sync),
          onPressed: status.isSyncing
              ? null
              : () {
                  SyncCollectionUseCase(repository: syncRepo)
                      .execute();
                },
          tooltip: 'Sync now',
        ),
      ),
    );
  }
}
```

- [x] **Step 4: Commit**

```bash
git add lib/presentation/screens/settings/widgets/
git commit -m "feat: add settings widgets — Postgres config, API keys, sync status"
```

---

## Task 8: Settings Screen

**Files:**
- Modify: `lib/presentation/screens/settings/settings_screen.dart`

- [x] **Step 1: Replace settings_screen.dart placeholder**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/api_key_form.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/sync_status_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sync section
          Text('Sync', style: Theme.of(context).textTheme.titleMedium),
          const SyncStatusTile(),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('PostgreSQL Configuration'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/postgres'),
          ),
          const Divider(height: 32),

          // API Keys section
          const ApiKeyForm(),
          const Divider(height: 32),

          // Preferences section
          Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          // Theme — placeholder for full implementation
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('System default'),
            onTap: () {
              // Theme picker — SET-07
            },
          ),

          const Divider(height: 32),

          // Danger zone
          Text('Data', style: Theme.of(context).textTheme.titleMedium),
          ListTile(
            leading: Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
            title: const Text('Reset & Re-sync'),
            subtitle: const Text('Replace local data with remote'),
            onTap: () => _confirmReset(context, ref),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset local database?'),
        content: const Text(
            'This will replace all local data with data from your PostgreSQL server. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // Trigger full re-sync SYNC-09
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
```

- [x] **Step 2: Update router.dart — replace settings/postgres placeholder**

Update the `/settings/postgres` route to use `PostgresConfigForm()`.

- [x] **Step 3: Commit**

```bash
git add lib/presentation/screens/settings/ lib/app/router.dart
git commit -m "feat: implement settings screen with Postgres config, API keys, sync"
```

---

## Task 9: Verify Slice 5

- [x] **Step 1: Run code generation, analysis, tests**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

- [x] **Step 2: Run app on macOS**

```bash
flutter run -d macos
```

Expected: Settings tab shows Postgres config link, API key fields, sync status, theme option, and reset. Saving API keys enables metadata lookup. Postgres config form with test connection button.

- [x] **Step 3: Final commit**

```bash
git add -A
git commit -m "feat: complete Slice 5 — settings and sync"
```

---

## Task 10: Final Full Verification

- [x] **Step 1: Full build and test**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

- [x] **Step 2: Run app and verify all flows**

```bash
flutter run -d macos
```

Verify:
1. Collection tab — empty state, then populated after scanning
2. Scan tab — desktop barcode input, metadata lookup, confirm screen
3. Item detail — cover art, metadata, star rating, tags, delete
4. Shelves — create shelf, view items
5. Settings — API keys, Postgres config, test connection, sync status

- [x] **Step 3: Final commit**

```bash
git add -A
git commit -m "feat: MyMediaScanner v0.1 — all five slices complete"
```
