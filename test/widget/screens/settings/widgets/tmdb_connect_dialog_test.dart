import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/services/tmdb_deep_link_handler.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/domain/entities/tmdb_deep_link_event.dart';
import 'package:mymediascanner/domain/usecases/connect_tmdb_account_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_connect_dialog.dart';

class _MockConnect extends Mock implements ConnectTmdbAccountUseCase {}

/// Fake [TmdbDeepLinkHandler] that uses a broadcast [StreamController] so
/// tests can push events at will. We extend the concrete class and pass
/// a dummy [Stream.empty] URI stream so the parent constructor is
/// satisfied without starting any real work.
class _FakeHandler extends TmdbDeepLinkHandler {
  _FakeHandler(_MockConnect connect)
      : super(connect: connect, uriStream: const Stream.empty());

  final _controller = StreamController<TmdbDeepLinkEvent>.broadcast();

  @override
  Stream<TmdbDeepLinkEvent> get events => _controller.stream;

  void emit(TmdbDeepLinkEvent e) => _controller.add(e);
}

void main() {
  // ---------------------------------------------------------------------------
  // Existing test — Continue button flow
  // ---------------------------------------------------------------------------

  testWidgets('Continue success dismisses dialog with TmdbConnected',
      (tester) async {
    final connect = _MockConnect();
    when(() => connect.startConnect()).thenAnswer((_) async {});
    when(() => connect.finishConnect()).thenAnswer(
        (_) async => const TmdbConnected(accountId: 1, username: 'p'));

    TmdbConnectionState? popped;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        connectTmdbAccountUseCaseProvider.overrideWithValue(connect),
      ],
      child: MaterialApp(
        home: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () async {
              popped = await showDialog<TmdbConnectionState>(
                context: ctx,
                builder: (_) => const TmdbConnectDialog(),
              );
            },
            child: const Text('open'),
          );
        }),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("I've approved it — continue"));
    await tester.pumpAndSettle();

    expect(popped, isA<TmdbConnected>());
  });

  // ---------------------------------------------------------------------------
  // Deep-link reaction tests
  // ---------------------------------------------------------------------------

  late _MockConnect connect;
  late _FakeHandler handler;

  setUp(() {
    connect = _MockConnect();
    when(() => connect.startConnect()).thenAnswer((_) async {});
    when(() => connect.cancel()).thenReturn(null);
    handler = _FakeHandler(connect);
  });

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        connectTmdbAccountUseCaseProvider.overrideWithValue(connect),
        tmdbDeepLinkHandlerProvider.overrideWithValue(handler),
      ],
      child: MaterialApp(
        home: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => showDialog<void>(
              context: ctx,
              builder: (_) => const TmdbConnectDialog(),
            ),
            child: const Text('open'),
          );
        }),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pump(); // show dialog
    await tester.pump(); // initState Future.microtask
  }

  testWidgets('dismisses on TmdbDeepLinkSuccess', (tester) async {
    await openDialog(tester);

    handler.emit(const TmdbDeepLinkSuccess());
    await tester.pumpAndSettle();

    expect(find.byType(TmdbConnectDialog), findsNothing);
  });

  testWidgets('shows denied message on TmdbDeepLinkCancelled', (tester) async {
    await openDialog(tester);

    handler.emit(const TmdbDeepLinkCancelled());
    await tester.pump();

    expect(find.textContaining('Approval was denied'), findsOneWidget);
  });

  testWidgets('shows mismatch reason on TmdbDeepLinkMismatch', (tester) async {
    await openDialog(tester);

    handler.emit(const TmdbDeepLinkMismatch('bad token'));
    await tester.pump();

    expect(find.textContaining('bad token'), findsOneWidget);
  });
}
