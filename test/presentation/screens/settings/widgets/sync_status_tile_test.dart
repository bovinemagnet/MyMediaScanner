import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/remote/sync/postgres_sync_client.dart';
import 'package:mymediascanner/domain/entities/sync_conflict.dart';
import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';
import 'package:mymediascanner/presentation/providers/connection_health_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/sync_provider.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/sync_status_tile.dart';

void main() {
  group('SyncStatusTile', () {
    testWidgets('shows not configured when no sync repo', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncRepositoryProvider.overrideWithValue(null),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SyncStatusTile()),
          ),
        ),
      );

      expect(find.text('Sync not configured'), findsOneWidget);
      expect(find.text('Set up PostgreSQL connection first'), findsOneWidget);
    });

    testWidgets('shows pending count and last sync time', (tester) async {
      final statusController = StreamController<SyncStatus>.broadcast();
      final progressController = StreamController<SyncProgress>.broadcast();

      final mockRepo = _FakeSyncRepository(
        statusStream: statusController.stream,
        progressStream: progressController.stream,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncRepositoryProvider.overrideWithValue(mockRepo),
            syncStatusProvider.overrideWith(
              (ref) => statusController.stream,
            ),
            syncProgressProvider.overrideWith(
              (ref) => progressController.stream,
            ),
            connectionHealthProvider.overrideWith(
              () => _FakeConnectionHealthNotifier(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SyncStatusTile()),
          ),
        ),
      );

      // Initially loading
      expect(find.text('Checking sync status...'), findsOneWidget);

      // Emit status
      statusController.add(SyncStatus(
        pendingCount: 5,
        lastSyncedAt: DateTime.now().millisecondsSinceEpoch,
        isSyncing: false,
      ));
      await tester.pumpAndSettle();

      expect(find.text('5 pending changes'), findsOneWidget);
      expect(find.text('Just now'), findsOneWidget);

      await statusController.close();
      await progressController.close();
    });

    testWidgets('shows progress bar during sync', (tester) async {
      final statusController = StreamController<SyncStatus>.broadcast();
      final progressController = StreamController<SyncProgress>.broadcast();

      final mockRepo = _FakeSyncRepository(
        statusStream: statusController.stream,
        progressStream: progressController.stream,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncRepositoryProvider.overrideWithValue(mockRepo),
            syncStatusProvider.overrideWith(
              (ref) => statusController.stream,
            ),
            syncProgressProvider.overrideWith(
              (ref) => progressController.stream,
            ),
            connectionHealthProvider.overrideWith(
              () => _FakeConnectionHealthNotifier(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SyncStatusTile()),
          ),
        ),
      );

      // Emit syncing status and progress
      statusController.add(const SyncStatus(
        pendingCount: 3,
        isSyncing: true,
      ));
      progressController.add(const SyncProgress(
        phase: SyncPhase.push,
        current: 2,
        total: 5,
        currentEntityType: 'media items',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Syncing...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Pushing 2/5 media items...'), findsOneWidget);

      await statusController.close();
      await progressController.close();
    });

    testWidgets('shows error state', (tester) async {
      final statusController = StreamController<SyncStatus>.broadcast();
      final progressController = StreamController<SyncProgress>.broadcast();

      final mockRepo = _FakeSyncRepository(
        statusStream: statusController.stream,
        progressStream: progressController.stream,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncRepositoryProvider.overrideWithValue(mockRepo),
            syncStatusProvider.overrideWith(
              (ref) => statusController.stream,
            ),
            syncProgressProvider.overrideWith(
              (ref) => progressController.stream,
            ),
            connectionHealthProvider.overrideWith(
              () => _FakeConnectionHealthNotifier(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SyncStatusTile()),
          ),
        ),
      );

      statusController.add(const SyncStatus(
        pendingCount: 0,
        error: 'Connection refused',
        isSyncing: false,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Connection refused'), findsOneWidget);

      await statusController.close();
      await progressController.close();
    });
  });
}

class _FakeConnectionHealthNotifier extends ConnectionHealthNotifier {
  @override
  ConnectionHealth build() => ConnectionHealth.connected;
}

class _FakeSyncRepository implements ISyncRepository {
  _FakeSyncRepository({
    required this.statusStream,
    required this.progressStream,
  });

  final Stream<SyncStatus> statusStream;
  final Stream<SyncProgress> progressStream;

  @override
  Stream<SyncStatus> watchSyncStatus() => statusStream;

  @override
  Stream<SyncProgress> watchSyncProgress() => progressStream;

  @override
  Future<void> pushChanges() async {}

  @override
  Future<void> pullChanges() async {}

  @override
  Future<bool> testConnection() async => true;

  @override
  Future<void> resetLocalDatabase() async {}

  @override
  Future<List<SyncConflict>> getConflicts() async => [];

  @override
  Future<void> resolveConflicts(List<SyncConflict> resolutions) async {}

  @override
  Future<List<SyncLogEntry>> getSyncHistory({
    int limit = 50,
    int offset = 0,
  }) async =>
      [];

  @override
  Future<void> purgeSyncHistory(int olderThanEpochMs) async {}

  @override
  Future<void> clearSyncHistory() async {}
}
