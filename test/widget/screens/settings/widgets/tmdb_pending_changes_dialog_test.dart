import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/entities/tmdb_pending_change.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/retry_push_usecase.dart';
import 'package:mymediascanner/presentation/providers/tmdb_account_sync_provider.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_pending_changes_dialog.dart';

class _MockUseCase extends Mock implements RetryPushUseCase {}

void main() {
  late _MockUseCase useCase;

  setUpAll(() {
    registerFallbackValue(<TmdbBridgeKey>[]);
    registerFallbackValue(
        const TmdbBridgeKey(tmdbId: 0, mediaType: 'movie'));
  });

  setUp(() {
    useCase = _MockUseCase();
    when(() => useCase.retry(any())).thenAnswer(
        (_) async => const TmdbPushSummary(
              attempted: 0,
              succeeded: 0,
              failed: 0,
            ));
    when(() => useCase.retryOne(any()))
        .thenAnswer((_) async => const TmdbPushResult(success: true));
  });

  TmdbPendingChange change({
    required int id,
    String? error,
  }) =>
      TmdbPendingChange(
        tmdbId: id,
        mediaType: 'movie',
        title: 'Movie $id',
        actions: const [TmdbPendingAction.watchlist()],
        lastPushedAt: null,
        lastError: error,
      );

  Future<void> openDialog(
      WidgetTester tester, List<TmdbPendingChange> rows) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        tmdbPendingChangesProvider.overrideWith((_) => Stream.value(rows)),
        retryPushUseCaseProvider.overrideWithValue(useCase),
      ],
      child: MaterialApp(
        home: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => showDialog<void>(
              context: ctx,
              builder: (_) => const TmdbPendingChangesDialog(),
            ),
            child: const Text('open'),
          );
        }),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders empty state when no rows', (tester) async {
    await openDialog(tester, const []);
    expect(find.text('All caught up — no pending changes.'),
        findsOneWidget);
  });

  testWidgets('renders one tile per pending change', (tester) async {
    await openDialog(tester, [change(id: 1), change(id: 2)]);
    expect(find.text('Movie 1'), findsOneWidget);
    expect(find.text('Movie 2'), findsOneWidget);
  });

  testWidgets('shows error excerpt when lastError is set',
      (tester) async {
    await openDialog(tester, [change(id: 1, error: 'boom')]);
    expect(find.text('boom'), findsOneWidget);
  });

  testWidgets('Retry all failed is absent when no failures exist',
      (tester) async {
    await openDialog(tester, [change(id: 1)]);
    expect(find.text('Retry all failed'), findsNothing);
  });

  testWidgets('Retry all failed is shown when at least one failure exists',
      (tester) async {
    await openDialog(tester, [change(id: 1, error: 'boom')]);
    expect(find.text('Retry all failed'), findsOneWidget);
  });

  testWidgets('tapping per-row retry calls useCase.retryOne',
      (tester) async {
    await openDialog(tester, [change(id: 42)]);
    await tester.tap(find.byTooltip('Retry this change'));
    await tester.pumpAndSettle();
    verify(() => useCase.retryOne(
            const TmdbBridgeKey(tmdbId: 42, mediaType: 'movie')))
        .called(1);
  });
}
