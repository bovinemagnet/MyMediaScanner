import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/sync_conflict.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/sync_conflict_dialog.dart';

void main() {
  final testConflicts = [
    const SyncConflict(
      entityType: 'media_item',
      entityId: 'item-1',
      fieldName: 'title',
      localValue: 'Local Title',
      remoteValue: 'Remote Title',
      localUpdatedAt: 1000,
      remoteUpdatedAt: 1010,
    ),
    const SyncConflict(
      entityType: 'media_item',
      entityId: 'item-1',
      fieldName: 'year',
      localValue: 2020,
      remoteValue: 2021,
      localUpdatedAt: 1000,
      remoteUpdatedAt: 1010,
    ),
  ];

  group('SyncConflictDialog', () {
    testWidgets('displays all conflicts', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            SyncConflictDialog(conflicts: testConflicts),
                      );
                    },
                    child: const Text('Show'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Sync Conflicts Detected'), findsOneWidget);
      expect(find.text('media_item / title'), findsOneWidget);
      expect(find.text('media_item / year'), findsOneWidget);
      expect(find.text('Local Title'), findsOneWidget);
      expect(find.text('Remote Title'), findsOneWidget);
      expect(find.text('2020'), findsOneWidget);
      expect(find.text('2021'), findsOneWidget);
    });

    testWidgets('bulk all local button selects all local', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            SyncConflictDialog(conflicts: testConflicts),
                      );
                    },
                    child: const Text('Show'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Tap "All Local" button
      await tester.tap(find.text('All Local'));
      await tester.pumpAndSettle();

      // Verify local cards are selected (they have check_circle icons)
      // The "Local" label should appear with a check
      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('cancel button closes dialog', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            SyncConflictDialog(conflicts: testConflicts),
                      );
                    },
                    child: const Text('Show'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Sync Conflicts Detected'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Sync Conflicts Detected'), findsNothing);
    });

    testWidgets('shows field count description', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            SyncConflictDialog(conflicts: testConflicts),
                      );
                    },
                    child: const Text('Show'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('2 field(s) have conflicting changes'),
        findsOneWidget,
      );
    });
  });
}
