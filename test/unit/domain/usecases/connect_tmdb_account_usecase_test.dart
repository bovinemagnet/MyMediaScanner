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

  group('redirect_to injection', () {
    late _MockRepo repoLocal;
    late List<Uri> launchedUris;

    setUp(() {
      repoLocal = _MockRepo();
      launchedUris = [];
      when(() => repoLocal.startConnect()).thenAnswer((_) async => (
            requestToken: 'tok-1',
            approvalUrl: Uri.parse(
                'https://www.themoviedb.org/authenticate/tok-1'),
          ));
    });

    Future<bool> launch(Uri uri) async {
      launchedUris.add(uri);
      return true;
    }

    test('with redirectTo null, the approval URL is unchanged', () async {
      final uc = ConnectTmdbAccountUseCase(
        repo: repoLocal,
        launchUrl: launch,
      );
      await uc.startConnect();
      expect(launchedUris.single.toString(),
          'https://www.themoviedb.org/authenticate/tok-1');
    });

    test('with redirectTo set, ?redirect_to=... is appended', () async {
      final uc = ConnectTmdbAccountUseCase(
        repo: repoLocal,
        launchUrl: launch,
        redirectTo: () => Uri.parse('mymediascanner://tmdb-callback'),
      );
      await uc.startConnect();
      final launched = launchedUris.single;
      expect(launched.queryParameters['redirect_to'],
          'mymediascanner://tmdb-callback');
      expect(launched.path, '/authenticate/tok-1');
    });

    test('redirectTo is invoked at startConnect time, not constructor time',
        () async {
      var calls = 0;
      final uc = ConnectTmdbAccountUseCase(
        repo: repoLocal,
        launchUrl: launch,
        redirectTo: () {
          calls++;
          return Uri.parse('mymediascanner://tmdb-callback');
        },
      );
      expect(calls, 0);
      await uc.startConnect();
      expect(calls, 1);
    });
  });
}
