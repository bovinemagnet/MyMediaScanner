import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/push_tmdb_change_usecase.dart';

class _MockRepo extends Mock implements ITmdbAccountSyncRepository {}

void main() {
  test('forwards pushOne to repo', () async {
    final repo = _MockRepo();
    when(() => repo.pushOne(
            tmdbId: any(named: 'tmdbId'),
            mediaType: any(named: 'mediaType')))
        .thenAnswer((_) async => const TmdbPushResult(success: true));
    final useCase = PushTmdbChangeUseCase(repo);
    final r = await useCase(tmdbId: 1, mediaType: 'movie');
    expect(r.success, isTrue);
    verify(() => repo.pushOne(tmdbId: 1, mediaType: 'movie')).called(1);
  });

  test('all() forwards pushAllDirty to repo', () async {
    final repo = _MockRepo();
    when(() => repo.pushAllDirty()).thenAnswer((_) async =>
        const TmdbPushSummary(attempted: 0, succeeded: 0, failed: 0));
    final useCase = PushTmdbChangeUseCase(repo);
    final s = await useCase.all();
    expect(s.attempted, 0);
  });
}
