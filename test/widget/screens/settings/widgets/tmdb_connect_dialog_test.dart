import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/domain/usecases/connect_tmdb_account_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/settings/widgets/tmdb_connect_dialog.dart';

class _MockConnect extends Mock implements ConnectTmdbAccountUseCase {}

void main() {
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
}
