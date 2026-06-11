import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/tmdb_media_type.dart';

void main() {
  group('TmdbMediaType', () {
    test('exposes the TMDB media-type string constants', () {
      expect(TmdbMediaType.movie, 'movie');
      expect(TmdbMediaType.tv, 'tv');
    });

    group('isTmdbMovie', () {
      test('true only for the movie string', () {
        expect(TmdbMediaType.isTmdbMovie('movie'), isTrue);
        expect(TmdbMediaType.isTmdbMovie('tv'), isFalse);
        expect(TmdbMediaType.isTmdbMovie('film'), isFalse);
        expect(TmdbMediaType.isTmdbMovie(null), isFalse);
      });
    });

    group('isTmdbTv', () {
      test('true only for the tv string', () {
        expect(TmdbMediaType.isTmdbTv('tv'), isTrue);
        expect(TmdbMediaType.isTmdbTv('movie'), isFalse);
        expect(TmdbMediaType.isTmdbTv('TV'), isFalse);
        expect(TmdbMediaType.isTmdbTv(null), isFalse);
      });
    });

    group('isTmdbMovieOrTv', () {
      test('true for movie and tv strings', () {
        expect(TmdbMediaType.isTmdbMovieOrTv('movie'), isTrue);
        expect(TmdbMediaType.isTmdbMovieOrTv('tv'), isTrue);
      });

      test('false for anything else, including non-strings', () {
        expect(TmdbMediaType.isTmdbMovieOrTv('book'), isFalse);
        expect(TmdbMediaType.isTmdbMovieOrTv(''), isFalse);
        expect(TmdbMediaType.isTmdbMovieOrTv(null), isFalse);
        expect(TmdbMediaType.isTmdbMovieOrTv(42), isFalse);
      });
    });
  });
}
