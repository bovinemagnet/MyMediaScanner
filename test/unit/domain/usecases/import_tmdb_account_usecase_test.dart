import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/tmdb_bridge_bucket.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/import_tmdb_account_usecase.dart';

class _MockRepo extends Mock implements ITmdbAccountSyncRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(<TmdbBucketSelection>{});
  });

  test('forwards selectedBuckets and progress callback to repo', () async {
    final repo = _MockRepo();
    when(() => repo.importAll(
          selectedBuckets: any(named: 'selectedBuckets'),
          progress: any(named: 'progress'),
        )).thenAnswer((_) async =>
        const TmdbSyncSummary(pulled: 10, failed: 1, lastError: 'oops'));

    final useCase = ImportTmdbAccountUseCase(repo);
    final summary = await useCase(
      selectedBuckets: {
        const TmdbBucketSelection(
            bucket: TmdbBridgeBucket.rated, mediaType: 'movie')
      },
    );
    expect(summary.pulled, 10);
    expect(summary.failed, 1);
    expect(summary.lastError, 'oops');
  });

  test('allBuckets() returns all six bucket-mediatype combinations', () {
    final all = ImportTmdbAccountUseCase.allBuckets();
    expect(all.length, 6);
  });
}
