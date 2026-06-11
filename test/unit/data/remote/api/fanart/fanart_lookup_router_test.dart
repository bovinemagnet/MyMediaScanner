import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/remote/api/fanart/fanart_api.dart';
import 'package:mymediascanner/data/remote/api/fanart/fanart_lookup_router.dart';
import 'package:mymediascanner/data/remote/api/fanart/models/fanart_images_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

class _MockFanartApi extends Mock implements FanartApi {}

void main() {
  late _MockFanartApi api;

  setUp(() {
    api = _MockFanartApi();
  });

  group('FanartLookupRouter.fetchBestImageUrl', () {
    test('film routes tmdb_id to the movie endpoint and returns best poster',
        () async {
      when(() => api.getMovieImages(550)).thenAnswer(
        (_) async => const FanartMovieImagesDto(
          movieposter: [
            FanartImageDto(url: 'https://fanart.tv/movies/550/poster.jpg'),
          ],
        ),
      );

      final url = await FanartLookupRouter.fetchBestImageUrl(
        api,
        MediaType.film,
        {'tmdb_id': 550},
      );

      expect(url, 'https://fanart.tv/movies/550/poster.jpg');
      verify(() => api.getMovieImages(550)).called(1);
      verifyNoMoreInteractions(api);
    });

    test('film coerces a JSON double tmdb_id to int', () async {
      when(() => api.getMovieImages(550)).thenAnswer(
        (_) async => const FanartMovieImagesDto(
          movieposter: [FanartImageDto(url: 'https://x/poster.jpg')],
        ),
      );

      final url = await FanartLookupRouter.fetchBestImageUrl(
        api,
        MediaType.film,
        {'tmdb_id': 550.0},
      );

      expect(url, 'https://x/poster.jpg');
    });

    test('tv routes tvdb_id to the tv endpoint and returns best poster',
        () async {
      when(() => api.getTvImages(81189)).thenAnswer(
        (_) async => const FanartTvImagesDto(
          tvposter: [
            FanartImageDto(url: 'https://fanart.tv/tv/81189/poster.jpg'),
          ],
        ),
      );

      final url = await FanartLookupRouter.fetchBestImageUrl(
        api,
        MediaType.tv,
        {'tvdb_id': '81189'},
      );

      expect(url, 'https://fanart.tv/tv/81189/poster.jpg');
      verify(() => api.getTvImages(81189)).called(1);
      verifyNoMoreInteractions(api);
    });

    test(
        'music routes musicbrainz_release_group_id to the album endpoint '
        'and returns best cover', () async {
      when(() => api.getAlbumImages('rg-1')).thenAnswer(
        (_) async => const FanartAlbumImagesDto(
          albums: {
            'rg-1': FanartAlbumArtDto(
              albumcover: [
                FanartImageDto(url: 'https://fanart.tv/albums/rg-1/cover.jpg'),
              ],
            ),
          },
        ),
      );

      final url = await FanartLookupRouter.fetchBestImageUrl(
        api,
        MediaType.music,
        {'musicbrainz_release_group_id': 'rg-1'},
      );

      expect(url, 'https://fanart.tv/albums/rg-1/cover.jpg');
      verify(() => api.getAlbumImages('rg-1')).called(1);
      verifyNoMoreInteractions(api);
    });

    test('returns null without calling the API when the ID is missing',
        () async {
      expect(
        await FanartLookupRouter.fetchBestImageUrl(api, MediaType.film, {}),
        isNull,
      );
      expect(
        await FanartLookupRouter.fetchBestImageUrl(api, MediaType.tv, {}),
        isNull,
      );
      expect(
        await FanartLookupRouter.fetchBestImageUrl(api, MediaType.music, {}),
        isNull,
      );
      verifyZeroInteractions(api);
    });

    test('returns null for unsupported media types', () async {
      for (final type in [
        MediaType.book,
        MediaType.game,
        MediaType.unknown,
        null,
      ]) {
        expect(
          await FanartLookupRouter.fetchBestImageUrl(
            api,
            type,
            {'tmdb_id': 1, 'tvdb_id': 2, 'musicbrainz_release_group_id': 'x'},
          ),
          isNull,
        );
      }
      verifyZeroInteractions(api);
    });
  });
}
