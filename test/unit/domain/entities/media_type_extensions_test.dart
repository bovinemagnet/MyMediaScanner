import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/progress_unit.dart';

void main() {
  group('MediaTypeProgress', () {
    group('defaultProgressUnit', () {
      test('book defaults to page', () {
        expect(MediaType.book.defaultProgressUnit, ProgressUnit.page);
      });

      test('tv defaults to episode', () {
        expect(MediaType.tv.defaultProgressUnit, ProgressUnit.episode);
      });

      test('all other types default to minute', () {
        expect(MediaType.film.defaultProgressUnit, ProgressUnit.minute);
        expect(MediaType.music.defaultProgressUnit, ProgressUnit.minute);
        expect(MediaType.game.defaultProgressUnit, ProgressUnit.minute);
        expect(MediaType.unknown.defaultProgressUnit, ProgressUnit.minute);
      });
    });

    group('progressActionLabel', () {
      test('book reads, everything else watches', () {
        expect(MediaType.book.progressActionLabel, 'Start reading');
        expect(MediaType.film.progressActionLabel, 'Start watching');
        expect(MediaType.tv.progressActionLabel, 'Start watching');
        expect(MediaType.music.progressActionLabel, 'Start watching');
        expect(MediaType.game.progressActionLabel, 'Start watching');
        expect(MediaType.unknown.progressActionLabel, 'Start watching');
      });
    });
  });

  group('MediaTypeMetadataFields', () {
    List<String> labelsFor(MediaType type) =>
        type.metadataFields.map((f) => f.label).toList();

    test('film and tv expose director and runtime', () {
      expect(labelsFor(MediaType.film), ['Director', 'Runtime']);
      expect(labelsFor(MediaType.tv), ['Director', 'Runtime']);
    });

    test('music exposes artist and label', () {
      expect(labelsFor(MediaType.music), ['Artist', 'Label']);
    });

    test('book exposes author, pages and isbn', () {
      expect(labelsFor(MediaType.book), ['Author', 'Pages', 'ISBN']);
    });

    test('game and unknown expose no extra fields', () {
      expect(MediaType.game.metadataFields, isEmpty);
      expect(MediaType.unknown.metadataFields, isEmpty);
    });

    test('film extractors read director and format runtime in minutes', () {
      final extra = <String, dynamic>{
        'director': 'Ridley Scott',
        'runtime_minutes': 117,
      };
      final fields = MediaType.film.metadataFields;
      expect(fields[0].extract(extra), 'Ridley Scott');
      expect(fields[1].extract(extra), '117 min');
    });

    test('film extractors return null when keys are absent', () {
      final fields = MediaType.film.metadataFields;
      expect(fields[0].extract({}), isNull);
      expect(fields[1].extract({}), isNull);
    });

    test('music extractors join artists and read label', () {
      final extra = <String, dynamic>{
        'artists': ['Daft Punk', 'Pharrell Williams'],
        'label': 'Columbia',
      };
      final fields = MediaType.music.metadataFields;
      expect(fields[0].extract(extra), 'Daft Punk, Pharrell Williams');
      expect(fields[1].extract(extra), 'Columbia');
    });

    test('book extractors join authors, stringify pages and prefer isbn13',
        () {
      final extra = <String, dynamic>{
        'authors': ['Terry Pratchett', 'Neil Gaiman'],
        'page_count': 412,
        'isbn13': '9780552137034',
        'isbn10': '0552137030',
      };
      final fields = MediaType.book.metadataFields;
      expect(fields[0].extract(extra), 'Terry Pratchett, Neil Gaiman');
      expect(fields[1].extract(extra), '412');
      expect(fields[2].extract(extra), '9780552137034');
    });

    test('book isbn extractor falls back to isbn10', () {
      final isbnField = MediaType.book.metadataFields[2];
      expect(isbnField.extract({'isbn10': '0552137030'}), '0552137030');
      expect(isbnField.extract({}), isNull);
    });
  });

  group('MediaTypeSearchCredentials', () {
    test('film and tv require a TMDB key', () {
      for (final type in [MediaType.film, MediaType.tv]) {
        final requirement = type.searchCredentialRequirement;
        expect(requirement, isNotNull);
        expect(requirement!.requiredKeys, ['tmdb']);
        expect(requirement.credentialLabel, 'TMDB API key');
        expect(requirement.searchSubject, 'films and TV');
      }
    });

    test('game requires Twitch client id and secret', () {
      final requirement = MediaType.game.searchCredentialRequirement;
      expect(requirement, isNotNull);
      expect(
        requirement!.requiredKeys,
        ['twitch_client_id', 'twitch_client_secret'],
      );
      expect(requirement.credentialLabel, 'Twitch Client ID and Secret');
      expect(requirement.searchSubject, 'games (IGDB)');
    });

    test('music, book and unknown require nothing', () {
      expect(MediaType.music.searchCredentialRequirement, isNull);
      expect(MediaType.book.searchCredentialRequirement, isNull);
      expect(MediaType.unknown.searchCredentialRequirement, isNull);
    });

    group('isSatisfiedBy', () {
      test('true when all required keys are present and non-empty', () {
        final requirement = MediaType.game.searchCredentialRequirement!;
        expect(
          requirement.isSatisfiedBy({
            'twitch_client_id': 'id',
            'twitch_client_secret': 'secret',
          }),
          isTrue,
        );
      });

      test('false when any required key is missing, null or empty', () {
        final requirement = MediaType.game.searchCredentialRequirement!;
        expect(requirement.isSatisfiedBy({}), isFalse);
        expect(
          requirement.isSatisfiedBy({'twitch_client_id': 'id'}),
          isFalse,
        );
        expect(
          requirement.isSatisfiedBy({
            'twitch_client_id': 'id',
            'twitch_client_secret': '',
          }),
          isFalse,
        );
        expect(
          requirement.isSatisfiedBy({
            'twitch_client_id': null,
            'twitch_client_secret': 'secret',
          }),
          isFalse,
        );
      });

      test('film requirement satisfied only by a non-empty tmdb key', () {
        final requirement = MediaType.film.searchCredentialRequirement!;
        expect(requirement.isSatisfiedBy({'tmdb': 'key'}), isTrue);
        expect(requirement.isSatisfiedBy({'tmdb': ''}), isFalse);
        expect(requirement.isSatisfiedBy({}), isFalse);
      });
    });
  });
}
