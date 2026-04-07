import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/repositories/i_sync_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/sync_provider.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/sync_log_viewer.dart';

void main() {
  group('SyncLogViewer', () {
    testWidgets('shows empty state when no history', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncRepositoryProvider.overrideWithValue(null),
            syncHistoryProvider(0).overrideWith(
              (ref) async => <SyncLogEntry>[],
            ),
          ],
          child: const MaterialApp(
            home: SyncLogViewer(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No sync history yet'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('displays sync log entries', (tester) async {
      final entries = [
        SyncLogEntry(
          id: 'log-1',
          entityType: 'media_item',
          entityId: 'item-1',
          operation: 'upsert',
          createdAt: DateTime(2026, 4, 7, 14, 30).millisecondsSinceEpoch,
          synced: true,
          direction: 'push',
          durationMs: 120,
        ),
        SyncLogEntry(
          id: 'log-2',
          entityType: 'media_item',
          entityId: 'item-2',
          operation: 'upsert',
          createdAt: DateTime(2026, 4, 7, 14, 25).millisecondsSinceEpoch,
          synced: false,
          errorMessage: 'Connection refused',
          direction: 'push',
          durationMs: 5000,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncRepositoryProvider.overrideWithValue(null),
            syncHistoryProvider(0).overrideWith(
              (ref) async => entries,
            ),
          ],
          child: const MaterialApp(
            home: SyncLogViewer(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check entries are displayed
      expect(find.text('upsert — media_item'), findsNWidgets(2));
      expect(find.text('Synced'), findsOneWidget);
      expect(find.text('120ms'), findsOneWidget);
      expect(find.text('5000ms'), findsOneWidget);

      // Check direction icons
      expect(find.byIcon(Icons.cloud_upload), findsNWidgets(2));
    });

    testWidgets('expands error on tap', (tester) async {
      final entries = [
        SyncLogEntry(
          id: 'log-1',
          entityType: 'media_item',
          entityId: 'item-1',
          operation: 'upsert',
          createdAt: DateTime(2026, 4, 7, 14, 30).millisecondsSinceEpoch,
          synced: false,
          errorMessage: 'Connection timeout',
          direction: 'push',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncRepositoryProvider.overrideWithValue(null),
            syncHistoryProvider(0).overrideWith(
              (ref) async => entries,
            ),
          ],
          child: const MaterialApp(
            home: SyncLogViewer(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Error should not be visible initially
      expect(find.text('Connection timeout'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('upsert — media_item'));
      await tester.pumpAndSettle();

      // Error should now be visible
      expect(find.text('Connection timeout'), findsOneWidget);
    });

    testWidgets('shows pagination controls', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncRepositoryProvider.overrideWithValue(null),
            syncHistoryProvider(0).overrideWith(
              (ref) async => <SyncLogEntry>[],
            ),
          ],
          child: const MaterialApp(
            home: SyncLogViewer(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Page 1'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });
}
