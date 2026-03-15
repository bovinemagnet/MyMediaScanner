import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/mappers/google_books_mapper.dart';
import 'package:mymediascanner/data/remote/api/google_books/models/google_books_volume_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

void main() {
  group('GoogleBooksMapper', () {
    test('maps volume to MetadataResult', () {
      final dto = GoogleBooksVolumeDto(
        id: 'abc123',
        volumeInfo: GoogleBooksVolumeInfoDto(
          title: '1984',
          subtitle: 'A Novel',
          authors: ['George Orwell'],
          publisher: 'Secker & Warburg',
          publishedDate: '1949-06-08',
          pageCount: 328,
          categories: ['Fiction', 'Dystopian'],
          industryIdentifiers: [
            GoogleBooksIdentifierDto(type: 'ISBN_13', identifier: '9780141036144'),
            GoogleBooksIdentifierDto(type: 'ISBN_10', identifier: '0141036141'),
          ],
          averageRating: 4.5,
          ratingsCount: 1200,
        ),
      );

      final result = GoogleBooksMapper.fromVolume(dto, '9780141036144', 'isbn13');

      expect(result.title, '1984');
      expect(result.subtitle, 'A Novel');
      expect(result.mediaType, MediaType.book);
      expect(result.year, 1949);
      expect(result.publisher, 'Secker & Warburg');
      expect(result.genres, ['Fiction', 'Dystopian']);
      expect(result.extraMetadata['authors'], ['George Orwell']);
      expect(result.extraMetadata['isbn13'], '9780141036144');
      expect(result.extraMetadata['page_count'], 328);
      expect(result.sourceApis, ['google_books']);
      expect(result.criticScore, 9.0);
      expect(result.criticSource, 'Google Books');
    });
  });
}
