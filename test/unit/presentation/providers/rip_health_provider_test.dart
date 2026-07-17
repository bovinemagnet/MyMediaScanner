import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/entities/rip_album_health.dart';
import 'package:mymediascanner/domain/entities/rip_track.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/rip_health_provider.dart';
import 'package:mymediascanner/presentation/providers/rip_provider.dart';

class MockRipLibraryRepository extends Mock implements IRipLibraryRepository {}

void main() {
  late MockRipLibraryRepository repo;
  late ProviderContainer container;

  const albumA = RipAlbum(
    id: 'a', libraryPath: '/a', trackCount: 1, totalSizeBytes: 100,
    lastScannedAt: 0, updatedAt: 0,
  );
  const trackVerified = RipTrack(
    id: 't1', ripAlbumId: 'a', trackNumber: 1, filePath: '/a/1.flac',
    fileSizeBytes: 10, updatedAt: 0,
    qualityCheckedAt: 1, accurateRipStatus: 'verified',
  );

  setUp(() {
    repo = MockRipLibraryRepository();
    when(() => repo.watchAll()).thenAnswer((_) => Stream.value([albumA]));
    when(() => repo.watchAllTracksByAlbum()).thenAnswer(
      (_) => Stream.value({'a': [trackVerified]}),
    );
    container = ProviderContainer(overrides: [
      ripLibraryRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);
  });

  test('health map classifies albums from the tracks stream', () async {
    // Riverpod 3: listen before awaiting .future or the test hangs.
    container.listen(ripAllTracksByAlbumProvider, (_, _) {});
    await container.read(ripAllTracksByAlbumProvider.future);
    final map = container.read(ripAlbumHealthMapProvider);
    expect(map['a'], RipAlbumHealth.verified);
  });

  test('stats provider aggregates albums and tracks', () async {
    container.listen(ripAllTracksByAlbumProvider, (_, _) {});
    container.listen(allRipAlbumsProvider, (_, _) {});
    await container.read(ripAllTracksByAlbumProvider.future);
    await container.read(allRipAlbumsProvider.future);
    final stats = container.read(ripLibraryHealthStatsProvider);
    expect(stats.counts[RipAlbumHealth.verified], 1);
    expect(stats.totalSizeBytes, 100);
  });

  test('filter matches', () {
    expect(RipHealthFilter.all.matches(RipAlbumHealth.mismatch), isTrue);
    expect(
      RipHealthFilter.verified.matches(RipAlbumHealth.verified), isTrue);
    expect(
      RipHealthFilter.verified.matches(RipAlbumHealth.attention), isFalse);
    expect(container.read(ripHealthFilterProvider), RipHealthFilter.all);
    container.read(ripHealthFilterProvider.notifier)
        .set(RipHealthFilter.mismatch);
    expect(container.read(ripHealthFilterProvider), RipHealthFilter.mismatch);
  });
}
