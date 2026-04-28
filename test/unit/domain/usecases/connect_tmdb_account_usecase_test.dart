import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/connect_tmdb_account_usecase.dart';

class _MockRepo extends Mock implements ITmdbAccountSyncRepository {}

void main() {
  late _MockRepo repo;
  late ConnectTmdbAccountUseCase useCase;
  Uri? launched;

  setUp(() {
    repo = _MockRepo();
    launched = null;
    useCase = ConnectTmdbAccountUseCase(
      repo: repo,
      launchUrl: (uri) async {
        launched = uri;
        return true;
      },
    );
  });

  test('startConnect launches approval URL and remembers token', () async {
    when(() => repo.startConnect()).thenAnswer((_) async => (
          requestToken: 'rqt-123',
          approvalUrl:
              Uri.parse('https://www.themoviedb.org/authenticate/rqt-123'),
        ));

    await useCase.startConnect();

    expect(launched.toString(),
        'https://www.themoviedb.org/authenticate/rqt-123');
    expect(useCase.pendingRequestToken, 'rqt-123');
  });

  test('finishConnect proxies to repo and clears pending token on success',
      () async {
    useCase.debugSetPendingToken('rqt-123');
    when(() => repo.finishConnect('rqt-123')).thenAnswer(
        (_) async => const TmdbConnected(accountId: 1, username: 'p'));

    final state = await useCase.finishConnect();

    expect(state, isA<TmdbConnected>());
    expect(useCase.pendingRequestToken, isNull);
  });

  test('cancel clears pending token without calling repo', () async {
    useCase.debugSetPendingToken('rqt-123');
    useCase.cancel();
    expect(useCase.pendingRequestToken, isNull);
    verifyNever(() => repo.finishConnect(any()));
  });
}
