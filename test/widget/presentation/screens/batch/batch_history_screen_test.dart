import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/batch_history_provider.dart';
import 'package:mymediascanner/presentation/screens/batch/batch_history_screen.dart';

// ── Stub notifiers ──────────────────────────────────────────────────

/// Returns an empty history list, bypassing the DAO.
class _EmptyBatchHistoryNotifier extends BatchHistoryNotifier {
  @override
  Future<List<BatchSessionSummary>> build() async => [];

  @override
  bool get hasMore => false;
}

/// Returns a fixed list of sessions, bypassing the DAO.
class _StubBatchHistoryNotifier extends BatchHistoryNotifier {
  _StubBatchHistoryNotifier(this._sessions);

  final List<BatchSessionSummary> _sessions;

  @override
  Future<List<BatchSessionSummary>> build() async => _sessions;

  @override
  bool get hasMore => false;
}

// ── Helpers ─────────────────────────────────────────────────────────

BatchSessionSummary _completedSession({
  String id = 'sess1',
  int itemCount = 3,
  int savedCount = 2,
  DateTime? createdAt,
}) =>
    BatchSessionSummary(
      id: id,
      createdAt: createdAt ?? DateTime(2024, 6, 1, 10, 30),
      status: 'completed',
      itemCount: itemCount,
      savedCount: savedCount,
    );

Widget _wrap(BatchHistoryNotifier notifier) {
  return ProviderScope(
    overrides: [
      batchHistoryProvider.overrideWith(() => notifier),
    ],
    child: const MaterialApp(
      home: BatchHistoryScreen(),
    ),
  );
}

void main() {
  testWidgets('renders empty state when there is no batch history',
      (tester) async {
    await tester.pumpWidget(_wrap(_EmptyBatchHistoryNotifier()));
    await tester.pumpAndSettle();

    expect(find.text('No batch history yet'), findsOneWidget);
  });

  testWidgets('renders a row per completed batch session', (tester) async {
    final sessions = [
      _completedSession(
          id: 's1',
          itemCount: 5,
          savedCount: 5,
          createdAt: DateTime(2024, 6, 1, 10, 30)),
      _completedSession(
          id: 's2',
          itemCount: 2,
          savedCount: 1,
          createdAt: DateTime(2024, 6, 2, 14, 0)),
    ];

    await tester.pumpWidget(_wrap(_StubBatchHistoryNotifier(sessions)));
    await tester.pumpAndSettle();

    // Each session card shows its item and saved counts.
    expect(find.textContaining('5 items'), findsOneWidget);
    expect(find.textContaining('2 items'), findsOneWidget);
    expect(find.textContaining('5 saved'), findsOneWidget);
    expect(find.textContaining('1 saved'), findsOneWidget);
  });
}
