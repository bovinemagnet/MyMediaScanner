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
import 'package:mymediascanner/presentation/widgets/sync_badge.dart';

void main() {
  group('SyncBadge', () {
    testWidgets('renders nothing when sync not configured', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncRepositoryProvider.overrideWithValue(null),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SyncBadge()),
          ),
        ),
      );

      // SizedBox.shrink — should find no Container decorations
      expect(find.byType(SyncBadge), findsOneWidget);
      expect(find.byType(Tooltip), findsNothing);
    });

    testWidgets('shows green dot when connected and idle', (tester) async {
      final statusController = StreamController<SyncStatus>.broadcast();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncRepositoryProvider.overrideWithValue(_FakeRepo()),
            syncStatusProvider.overrideWith(
              (ref) => statusController.stream,
            ),
            connectionHealthProvider.overrideWith(
              () => _FakeHealthNotifier(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SyncBadge()),
          ),
        ),
      );

      statusController.add(const SyncStatus(
        pendingCount: 0,
        isSyncing: false,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Tooltip), findsOneWidget);

      await statusController.close();
    });

    testWidgets('shows amber dot when pending changes', (tester) async {
      final statusController = StreamController<SyncStatus>.broadcast();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncRepositoryProvider.overrideWithValue(_FakeRepo()),
            syncStatusProvider.overrideWith(
              (ref) => statusController.stream,
            ),
            connectionHealthProvider.overrideWith(
              () => _FakeHealthNotifier(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SyncBadge()),
          ),
        ),
      );

      statusController.add(const SyncStatus(
        pendingCount: 3,
        isSyncing: false,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Tooltip), findsOneWidget);

      await statusController.close();
    });

    testWidgets('shows sync icon when syncing', (tester) async {
      final statusController = StreamController<SyncStatus>.broadcast();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncRepositoryProvider.overrideWithValue(_FakeRepo()),
            syncStatusProvider.overrideWith(
              (ref) => statusController.stream,
            ),
            connectionHealthProvider.overrideWith(
              () => _FakeHealthNotifier(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SyncBadge()),
          ),
        ),
      );

      statusController.add(const SyncStatus(
        pendingCount: 0,
        isSyncing: true,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sync), findsOneWidget);

      await statusController.close();
    });

    testWidgets('shows red dot on error', (tester) async {
      final statusController = StreamController<SyncStatus>.broadcast();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncRepositoryProvider.overrideWithValue(_FakeRepo()),
            syncStatusProvider.overrideWith(
              (ref) => statusController.stream,
            ),
            connectionHealthProvider.overrideWith(
              () => _FakeHealthNotifier(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SyncBadge()),
          ),
        ),
      );

      statusController.add(const SyncStatus(
        pendingCount: 0,
        isSyncing: false,
        error: 'Connection failed',
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Tooltip), findsOneWidget);

      await statusController.close();
    });
  });
}

class _FakeHealthNotifier extends ConnectionHealthNotifier {
  @override
  ConnectionHealth build() => ConnectionHealth.connected;
}

class _FakeRepo implements ISyncRepository {
  @override
  Stream<SyncStatus> watchSyncStatus() => const Stream.empty();
  @override
  Stream<SyncProgress> watchSyncProgress() => const Stream.empty();
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
