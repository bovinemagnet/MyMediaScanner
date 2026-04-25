import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/mappers/igdb_mapper.dart';
import 'package:mymediascanner/data/remote/api/igdb/models/igdb_game_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

void main() {
  group('IgdbMapper.fromGame', () {
    const barcode = '1234567890123';
    const barcodeType = 'ean13';

    test('maps a rich game payload onto MetadataResult', () {
      // Unix ts for 2022-02-25 = Elden Ring release day.
      const releaseTs = 1645747200;
      const dto = IgdbGameDto(
        id: 119133,
        name: 'Elden Ring',
        summary: 'Open-world action RPG.',
        cover: IgdbCoverDto(
          id: 1,
          url: '//images.igdb.com/igdb/image/upload/t_thumb/co4jni.jpg',
        ),
        platforms: [
          IgdbPlatformDto(id: 48, name: 'PlayStation 5'),
          IgdbPlatformDto(id: 49, name: 'Xbox Series X|S'),
          IgdbPlatformDto(id: 6, name: 'PC'),
        ],
        involvedCompanies: [
          IgdbInvolvedCompanyDto(
            company: IgdbCompanyDto(name: 'FromSoftware'),
            developer: true,
            publisher: false,
          ),
          IgdbInvolvedCompanyDto(
            company: IgdbCompanyDto(name: 'Bandai Namco'),
            developer: false,
            publisher: true,
          ),
        ],
        genres: [
          IgdbGenreDto(name: 'RPG'),
          IgdbGenreDto(name: 'Adventure'),
        ],
        firstReleaseDate: releaseTs,
        aggregatedRating: 94.5,
        rating: 91.3,
      );

      final result = IgdbMapper.fromGame(dto, barcode, barcodeType);

      expect(result.barcode, barcode);
      expect(result.barcodeType, barcodeType);
      expect(result.mediaType, MediaType.game);
      expect(result.title, 'Elden Ring');
      expect(result.subtitle, 'PlayStation 5');
      expect(result.description, 'Open-world action RPG.');
      expect(
        result.coverUrl,
        'https://images.igdb.com/igdb/image/upload/t_cover_big/co4jni.jpg',
      );
      expect(result.year, 2022);
      expect(result.publisher, 'Bandai Namco');
      expect(result.genres, ['RPG', 'Adventure']);
      expect(result.criticScore, 94.5);
      expect(result.criticSource, 'IGDB');
      expect(result.sourceApis, ['igdb']);
      expect(result.extraMetadata['igdb_id'], 119133);
      expect(result.extraMetadata['developer'], 'FromSoftware');
      expect(
        result.extraMetadata['platforms'],
        ['PlayStation 5', 'Xbox Series X|S', 'PC'],
      );
    });

    test('falls back to rating when aggregated_rating is null', () {
      const dto = IgdbGameDto(
        id: 1,
        name: 'Indie Gem',
        rating: 82.0,
      );

      final result = IgdbMapper.fromGame(dto, barcode, barcodeType);

      expect(result.criticScore, 82.0);
      expect(result.criticSource, 'IGDB');
    });

    test('leaves criticSource null when both scores are null', () {
      const dto = IgdbGameDto(id: 1, name: 'Unrated Game');

      final result = IgdbMapper.fromGame(dto, barcode, barcodeType);

      expect(result.criticScore, isNull);
      expect(result.criticSource, isNull);
    });

    test('copes with a cover that is already https and a different size', () {
      const dto = IgdbGameDto(
        id: 1,
        name: 'Game',
        cover: IgdbCoverDto(
          url: 'https://images.igdb.com/igdb/image/upload/t_720p/abc.jpg',
        ),
      );

      final result = IgdbMapper.fromGame(dto, barcode, barcodeType);

      // Not t_thumb, so it's left alone but kept as https.
      expect(
        result.coverUrl,
        'https://images.igdb.com/igdb/image/upload/t_720p/abc.jpg',
      );
    });

    test('returns null coverUrl when the DTO has no cover', () {
      const dto = IgdbGameDto(id: 1, name: 'Game');

      final result = IgdbMapper.fromGame(dto, barcode, barcodeType);

      expect(result.coverUrl, isNull);
    });

    test('omits subtitle when the game has no platforms', () {
      const dto = IgdbGameDto(id: 1, name: 'Game', platforms: []);

      final result = IgdbMapper.fromGame(dto, barcode, barcodeType);

      expect(result.subtitle, isNull);
      expect(result.extraMetadata.containsKey('platforms'), isFalse);
    });

    test('leaves publisher/developer null when no company has the role', () {
      const dto = IgdbGameDto(
        id: 1,
        name: 'Game',
        involvedCompanies: [
          IgdbInvolvedCompanyDto(
            company: IgdbCompanyDto(name: 'Porting Co.'),
          ),
        ],
      );

      final result = IgdbMapper.fromGame(dto, barcode, barcodeType);

      expect(result.publisher, isNull);
      expect(result.extraMetadata.containsKey('developer'), isFalse);
    });
  });

  group('IgdbMapper.toCandidate', () {
    test('builds a candidate with platform subtitle and upgraded cover', () {
      const dto = IgdbGameDto(
        id: 42,
        name: 'Hades',
        firstReleaseDate: 1600819200, // 2020-09-23
        cover: IgdbCoverDto(
          url: '//images.igdb.com/igdb/image/upload/t_thumb/hades.jpg',
        ),
        platforms: [IgdbPlatformDto(name: 'Switch')],
      );

      final candidate = IgdbMapper.toCandidate(dto);

      expect(candidate.sourceApi, 'igdb');
      expect(candidate.sourceId, '42');
      expect(candidate.title, 'Hades');
      expect(candidate.subtitle, 'Switch');
      expect(candidate.year, 2020);
      expect(candidate.mediaType, MediaType.game);
      expect(
        candidate.coverUrl,
        'https://images.igdb.com/igdb/image/upload/t_cover_big/hades.jpg',
      );
    });
  });
}
