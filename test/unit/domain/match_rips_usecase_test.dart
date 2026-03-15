import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/rip_album.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_rip_library_repository.dart';
import 'package:mymediascanner/domain/usecases/match_rips_usecase.dart';

class MockRipLibraryRepository extends Mock
    implements IRipLibraryRepository {}

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

MediaItem _musicItem({
  required String id,
  required String barcode,
  required String title,
  String? publisher,
  Map<String, dynamic> extraMetadata = const {},
}) =>
    MediaItem(
      id: id,
      barcode: barcode,
      barcodeType: 'EAN-13',
      mediaType: MediaType.music,
      title: title,
      publisher: publisher,
      extraMetadata: extraMetadata,
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    );

RipAlbum _ripAlbum({
  required String id,
  String? artist,
  String? albumTitle,
  String? barcode,
}) =>
    RipAlbum(
      id: id,
      libraryPath: 'music/$id',
      artist: artist,
      albumTitle: albumTitle,
      barcode: barcode,
      trackCount: 10,
      totalSizeBytes: 500000000,
      lastScannedAt: 0,
      updatedAt: 0,
    );

void main() {
  late MatchRipsUseCase useCase;
  late MockRipLibraryRepository mockRipRepo;
  late MockMediaItemRepository mockMediaRepo;

  setUp(() {
    mockRipRepo = MockRipLibraryRepository();
    mockMediaRepo = MockMediaItemRepository();
    useCase = MatchRipsUseCase(
      ripRepository: mockRipRepo,
      mediaItemRepository: mockMediaRepo,
    );
  });

  group('barcode matching', () {
    test('matches rip album to media item by barcode', () async {
      final rip = _ripAlbum(
        id: 'rip-1',
        artist: 'Pink Floyd',
        albumTitle: 'The Dark Side of the Moon',
        barcode: '0602445123456',
      );
      final item = _musicItem(
        id: 'item-1',
        barcode: '0602445123456',
        title: 'The Dark Side of the Moon',
      );

      when(() => mockRipRepo.getAllNonDeleted())
          .thenAnswer((_) async => [rip]);
      when(() => mockMediaRepo.watchAll(mediaType: MediaType.music))
          .thenAnswer((_) => Stream.value([item]));
      when(() => mockRipRepo.linkToMediaItem('rip-1', 'item-1'))
          .thenAnswer((_) async {});

      final matchCount = await useCase.execute();

      expect(matchCount, equals(1));
      verify(() => mockRipRepo.linkToMediaItem('rip-1', 'item-1')).called(1);
    });
  });

  group('normalised title matching', () {
    test('matches with "The" prefix stripped', () async {
      final rip = _ripAlbum(
        id: 'rip-2',
        artist: 'Beatles',
        albumTitle: 'The White Album',
      );
      final item = _musicItem(
        id: 'item-2',
        barcode: '000',
        title: 'White Album',
        extraMetadata: {
          'artists': ['Beatles'],
        },
      );

      when(() => mockRipRepo.getAllNonDeleted())
          .thenAnswer((_) async => [rip]);
      when(() => mockMediaRepo.watchAll(mediaType: MediaType.music))
          .thenAnswer((_) => Stream.value([item]));
      when(() => mockRipRepo.linkToMediaItem('rip-2', 'item-2'))
          .thenAnswer((_) async {});

      final matchCount = await useCase.execute();

      expect(matchCount, equals(1));
      verify(() => mockRipRepo.linkToMediaItem('rip-2', 'item-2')).called(1);
    });

    test('matches with punctuation removed', () async {
      final rip = _ripAlbum(
        id: 'rip-3',
        artist: 'Guns N Roses',
        albumTitle: 'Appetite for Destruction!',
      );
      final item = _musicItem(
        id: 'item-3',
        barcode: '000',
        title: 'Appetite for Destruction',
        extraMetadata: {
          'artists': ["Guns N' Roses"],
        },
      );

      when(() => mockRipRepo.getAllNonDeleted())
          .thenAnswer((_) async => [rip]);
      when(() => mockMediaRepo.watchAll(mediaType: MediaType.music))
          .thenAnswer((_) => Stream.value([item]));
      when(() => mockRipRepo.linkToMediaItem('rip-3', 'item-3'))
          .thenAnswer((_) async {});

      final matchCount = await useCase.execute();

      expect(matchCount, equals(1));
    });

    test('uses publisher as fallback artist', () async {
      final rip = _ripAlbum(
        id: 'rip-4',
        artist: 'Radiohead',
        albumTitle: 'OK Computer',
      );
      final item = _musicItem(
        id: 'item-4',
        barcode: '000',
        title: 'OK Computer',
        publisher: 'Radiohead',
      );

      when(() => mockRipRepo.getAllNonDeleted())
          .thenAnswer((_) async => [rip]);
      when(() => mockMediaRepo.watchAll(mediaType: MediaType.music))
          .thenAnswer((_) => Stream.value([item]));
      when(() => mockRipRepo.linkToMediaItem('rip-4', 'item-4'))
          .thenAnswer((_) async {});

      final matchCount = await useCase.execute();

      expect(matchCount, equals(1));
    });
  });

  group('no match', () {
    test('returns zero when no rips match', () async {
      final rip = _ripAlbum(
        id: 'rip-5',
        artist: 'Unknown Band',
        albumTitle: 'Obscure Album',
      );
      final item = _musicItem(
        id: 'item-5',
        barcode: '000',
        title: 'Different Album',
        publisher: 'Different Artist',
      );

      when(() => mockRipRepo.getAllNonDeleted())
          .thenAnswer((_) async => [rip]);
      when(() => mockMediaRepo.watchAll(mediaType: MediaType.music))
          .thenAnswer((_) => Stream.value([item]));

      final matchCount = await useCase.execute();

      expect(matchCount, equals(0));
      verifyNever(() => mockRipRepo.linkToMediaItem(any(), any()));
    });

    test('skips already-linked rip albums', () async {
      final rip = _ripAlbum(
        id: 'rip-6',
        artist: 'Linked Artist',
        albumTitle: 'Linked Album',
      ).copyWith(mediaItemId: 'already-linked');

      when(() => mockRipRepo.getAllNonDeleted())
          .thenAnswer((_) async => [rip]);
      when(() => mockMediaRepo.watchAll(mediaType: MediaType.music))
          .thenAnswer((_) => Stream.value([]));

      final matchCount = await useCase.execute();

      expect(matchCount, equals(0));
      verifyNever(() => mockRipRepo.linkToMediaItem(any(), any()));
    });
  });

  group('normalise', () {
    test('lowercases and trims', () {
      expect(MatchRipsUseCase.normalise('  Hello World  '),
          equals('hello world'));
    });

    test('strips leading "the "', () {
      expect(MatchRipsUseCase.normalise('The Beatles'), equals('beatles'));
    });

    test('removes punctuation', () {
      expect(MatchRipsUseCase.normalise("Rock 'n' Roll!"),
          equals('rock n roll'));
    });

    test('handles null', () {
      expect(MatchRipsUseCase.normalise(null), equals(''));
    });
  });
}
