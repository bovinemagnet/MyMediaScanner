// Integration test bootstrap helper.
//
// Pumps the real App widget with an in-memory Drift database,
// mocked secure storage, and disabled PostgreSQL sync.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/app/app.dart';
import 'package:mymediascanner/app/router.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/presentation/providers/database_provider.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_secure_storage.dart';

typedef TestResources = ({
  AppDatabase db,
  MockFlutterSecureStorage storage,
});

extension IntegrationTestApp on WidgetTester {
  /// Pumps the full [App] widget with provider overrides suitable for
  /// integration testing. Returns handles to the in-memory database and
  /// mock secure storage so tests can seed data or verify writes.
  Future<TestResources> pumpTestApp() async {
    SharedPreferences.setMockInitialValues({});

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final storage = createMockSecureStorage();

    // GoRouter is a top-level singleton, so navigation performed by a
    // prior test in the same `flutter test` run leaks across setup.
    // Reset to the dashboard before pumping the widget tree.
    router.go('/');

    await pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          secureStorageProvider.overrideWithValue(storage),
          apiKeysProvider.overrideWith(
            () => _ImmediateApiKeysNotifier(),
          ),
          postgresConfigProvider.overrideWith(
            () => _NullPostgresConfigNotifier(),
          ),
        ],
        child: const App(),
      ),
    );

    addTearDown(() => db.close());

    return (db: db, storage: storage);
  }
}

/// Returns an empty API keys map immediately, avoiding any
/// FlutterSecureStorage reads.
class _ImmediateApiKeysNotifier extends ApiKeysNotifier {
  @override
  Future<Map<String, String?>> build() async => {};
}

/// Returns null immediately, disabling PostgreSQL sync, connection
/// health monitoring, and sync badge rendering.
class _NullPostgresConfigNotifier extends PostgresConfigNotifier {
  @override
  Future<PostgresConfig?> build() async => null;
}
