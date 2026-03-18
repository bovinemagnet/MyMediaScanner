import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/mappers/enrichment_merger.dart';
import 'package:mymediascanner/data/remote/api/theaudiodb/models/theaudiodb_album_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

void main() {
  group('EnrichmentMerger', () {
    const baseResult = MetadataResult(
      barcode: '602498746400',
      barcodeType: 'ean13',
      mediaType: MediaType.music,
      title: 'Vertigo 2005',
      sourceApis: ['musicbrainz'],
    );

    group('mergeAudioDb', () {
      test('adds critic score when base has none', () {
        const audioDb = TheAudioDbAlbumDto(
          idAlbum: '123',
          intScore: '8.5',
          intScoreVotes: '100',
        );

        final result = EnrichmentMerger.mergeAudioDb(baseResult, audioDb);

        expect(result.criticScore, 8.5);
        expect(result.criticSource, 'TheAudioDB');
      });

      test('does not overwrite existing critic score', () {
        final withScore = baseResult.copyWith(
          criticScore: 7.0,
          criticSource: 'Discogs',
        );
        const audioDb = TheAudioDbAlbumDto(intScore: '9.0');

        final result = EnrichmentMerger.mergeAudioDb(withScore, audioDb);

        expect(result.criticScore, 7.0);
        expect(result.criticSource, 'Discogs');
      });

      test('adds cover when base has none', () {
        const audioDb = TheAudioDbAlbumDto(
          strAlbumThumb: 'https://example.com/cover.jpg',
        );

        final result = EnrichmentMerger.mergeAudioDb(baseResult, audioDb);

        expect(result.coverUrl, 'https://example.com/cover.jpg');
      });

      test('does not overwrite existing cover', () {
        final withCover = baseResult.copyWith(
          coverUrl: 'https://existing.com/cover.jpg',
        );
        const audioDb = TheAudioDbAlbumDto(
          strAlbumThumb: 'https://new.com/cover.jpg',
        );

        final result = EnrichmentMerger.mergeAudioDb(withCover, audioDb);

        expect(result.coverUrl, 'https://existing.com/cover.jpg');
      });

      test('adds review to extraMetadata', () {
        const audioDb = TheAudioDbAlbumDto(
          strReview: 'A great album',
          strDescriptionEN: 'Live concert recording',
        );

        final result = EnrichmentMerger.mergeAudioDb(baseResult, audioDb);

        expect(result.extraMetadata['theaudiodb_review'], 'A great album');
        expect(result.extraMetadata['theaudiodb_description'],
            'Live concert recording');
      });
    });

    group('mergeFanartCover', () {
      test('sets cover when base has none', () {
        final result = EnrichmentMerger.mergeFanartCover(
          baseResult,
          'https://fanart.tv/poster.jpg',
        );

        expect(result.coverUrl, 'https://fanart.tv/poster.jpg');
      });

      test('upgrades Cover Art Archive cover', () {
        final withCaa = baseResult.copyWith(
          coverUrl: 'https://coverartarchive.org/release/abc/front-250',
        );

        final result = EnrichmentMerger.mergeFanartCover(
          withCaa,
          'https://fanart.tv/poster.jpg',
        );

        expect(result.coverUrl, 'https://fanart.tv/poster.jpg');
      });

      test('does not overwrite high-quality cover', () {
        final withGoodCover = baseResult.copyWith(
          coverUrl: 'https://image.tmdb.org/t/p/w500/poster.jpg',
        );

        final result = EnrichmentMerger.mergeFanartCover(
          withGoodCover,
          'https://fanart.tv/poster.jpg',
        );

        expect(result.coverUrl, 'https://image.tmdb.org/t/p/w500/poster.jpg');
      });

      test('returns base when fanart URL is null', () {
        final result =
            EnrichmentMerger.mergeFanartCover(baseResult, null);

        expect(result.coverUrl, isNull);
      });
    });
  });
}
