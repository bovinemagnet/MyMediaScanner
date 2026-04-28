import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_tmdb_account_sync_repository.dart';
import 'package:mymediascanner/domain/usecases/mirror_ownership_change_usecase.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

class MockMirrorOwnershipChangeUseCase extends Mock
    implements MirrorOwnershipChangeUseCase {}

void main() {
  late SaveMediaItemUseCase useCase;
  late MockMediaItemRepository mockRepo;
  late MockMirrorOwnershipChangeUseCase mockMirror;

  setUpAll(() {
    registerFallbackValue(const MediaItem(
      id: '',
      barcode: '',
      barcodeType: '',
      mediaType: MediaType.unknown,
      title: '',
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    ));
  });

  setUp(() {
    mockRepo = MockMediaItemRepository();
    mockMirror = MockMirrorOwnershipChangeUseCase();
    useCase = SaveMediaItemUseCase(repository: mockRepo);
  });

  group('SaveMediaItemUseCase — core save', () {
    test('creates MediaItem from MetadataResult and saves', () async {
      when(() => mockRepo.save(any())).thenAnswer((_) async {});

      const metadata = MetadataResult(
        barcode: '9780141036144',
        barcodeType: 'isbn13',
        title: '1984',
        mediaType: MediaType.book,
        year: 1949,
      );

      final saved = await useCase.execute(metadata);

      expect(saved.title, '1984');
      expect(saved.barcode, '9780141036144');
      expect(saved.mediaType, MediaType.book);
      expect(saved.id, isNotEmpty);
      verify(() => mockRepo.save(any())).called(1);
    });
  });

  group('SaveMediaItemUseCase — mirror trigger', () {
    const movieMetadata = MetadataResult(
      barcode: '5051892012638',
      barcodeType: 'ean13',
      title: 'Inception',
      mediaType: MediaType.film,
      extraMetadata: {'tmdb_id': 27205, 'media_type': 'movie'},
    );

    const tvMetadata = MetadataResult(
      barcode: '5051892099999',
      barcodeType: 'ean13',
      title: 'Breaking Bad',
      mediaType: MediaType.tv,
      extraMetadata: {'tmdb_id': 1396, 'media_type': 'tv'},
    );

    const bookMetadata = MetadataResult(
      barcode: '9780141036144',
      barcodeType: 'isbn13',
      title: '1984',
      mediaType: MediaType.book,
    );

    setUp(() {
      when(() => mockRepo.save(any())).thenAnswer((_) async {});
      when(() => mockMirror.add(tmdbId: any(named: 'tmdbId')))
          .thenAnswer((_) async => const TmdbPushResult(success: true));
    });

    test('fires mirror.add for owned movie when mirror is enabled', () async {
      useCase = SaveMediaItemUseCase(
        repository: mockRepo,
        mirror: mockMirror,
        readMirrorEnabled: () => true,
      );

      await useCase.execute(movieMetadata);

      // Allow the fire-and-forget future to settle.
      await Future<void>.delayed(Duration.zero);

      verify(() => mockMirror.add(tmdbId: 27205)).called(1);
    });

    test('does NOT fire mirror.add for TV even when mirror is enabled',
        () async {
      useCase = SaveMediaItemUseCase(
        repository: mockRepo,
        mirror: mockMirror,
        readMirrorEnabled: () => true,
      );

      await useCase.execute(tvMetadata);
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => mockMirror.add(tmdbId: any(named: 'tmdbId')));
    });

    test('does NOT fire mirror.add when mirrorOwnership is disabled', () async {
      useCase = SaveMediaItemUseCase(
        repository: mockRepo,
        mirror: mockMirror,
        readMirrorEnabled: () => false,
      );

      await useCase.execute(movieMetadata);
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => mockMirror.add(tmdbId: any(named: 'tmdbId')));
    });

    test('does NOT fire mirror.add when no mirror dependency is injected',
        () async {
      // mirror is null — inline-constructed use cases (batch, import, gnudb).
      useCase = SaveMediaItemUseCase(repository: mockRepo);

      await useCase.execute(movieMetadata);
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => mockMirror.add(tmdbId: any(named: 'tmdbId')));
    });

    test('does NOT fire mirror.add for non-movie items (book)', () async {
      useCase = SaveMediaItemUseCase(
        repository: mockRepo,
        mirror: mockMirror,
        readMirrorEnabled: () => true,
      );

      await useCase.execute(bookMetadata);
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => mockMirror.add(tmdbId: any(named: 'tmdbId')));
    });

    test('does NOT fire mirror.add when ownershipStatus is wishlist', () async {
      useCase = SaveMediaItemUseCase(
        repository: mockRepo,
        mirror: mockMirror,
        readMirrorEnabled: () => true,
      );

      await useCase.execute(
        movieMetadata,
        ownershipStatus: OwnershipStatus.wishlist,
      );
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => mockMirror.add(tmdbId: any(named: 'tmdbId')));
    });

    test('local save succeeds even when mirror.add returns a failed future',
        () async {
      when(() => mockMirror.add(tmdbId: any(named: 'tmdbId'))).thenAnswer(
        (_) => Future.error(Exception('network failure')),
      );

      useCase = SaveMediaItemUseCase(
        repository: mockRepo,
        mirror: mockMirror,
        readMirrorEnabled: () => true,
      );

      // Should not throw — mirror errors are silently swallowed.
      final saved = await useCase.execute(movieMetadata);
      await Future<void>.delayed(Duration.zero);

      expect(saved.title, 'Inception');
      verify(() => mockRepo.save(any())).called(1);
    });

    test('handles tmdb_id stored as String (JSON round-trip)', () async {
      const metadataStringId = MetadataResult(
        barcode: '5051892012638',
        barcodeType: 'ean13',
        title: 'Inception',
        mediaType: MediaType.film,
        extraMetadata: {'tmdb_id': '27205', 'media_type': 'movie'},
      );

      useCase = SaveMediaItemUseCase(
        repository: mockRepo,
        mirror: mockMirror,
        readMirrorEnabled: () => true,
      );

      await useCase.execute(metadataStringId);
      await Future<void>.delayed(Duration.zero);

      verify(() => mockMirror.add(tmdbId: 27205)).called(1);
    });
  });
}
