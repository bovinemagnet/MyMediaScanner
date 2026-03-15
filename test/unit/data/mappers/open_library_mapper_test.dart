import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/mappers/open_library_mapper.dart';
import 'package:mymediascanner/data/remote/api/open_library/models/open_library_work_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

void main() {
  group('OpenLibraryMapper', () {
    test('maps book with authors and subjects', () {
      const dto = OpenLibraryBookDto(
        title: 'The Hitchhiker\'s Guide to the Galaxy',
        authors: [
          OpenLibraryAuthorDto(name: 'Douglas Adams'),
        ],
        publishers: [
          OpenLibraryPublisherDto(name: 'Pan Books'),
        ],
        publishDate: 'October 12, 1979',
        numberOfPages: 180,
        subjects: [
          OpenLibrarySubjectDto(name: 'Science Fiction'),
          OpenLibrarySubjectDto(name: 'Humour'),
        ],
        cover: OpenLibraryCoverDto(
          small: 'https://covers.openlibrary.org/b/id/123-S.jpg',
          medium: 'https://covers.openlibrary.org/b/id/123-M.jpg',
          large: 'https://covers.openlibrary.org/b/id/123-L.jpg',
        ),
        isbn10: ['0330258648'],
        isbn13: ['9780330258647'],
      );

      final result = OpenLibraryMapper.fromBook(dto, '9780330258647', 'isbn13');

      expect(result.title, 'The Hitchhiker\'s Guide to the Galaxy');
      expect(result.mediaType, MediaType.book);
      expect(result.barcode, '9780330258647');
      expect(result.barcodeType, 'isbn13');
      expect(result.year, 1979);
      expect(result.publisher, 'Pan Books');
      expect(result.coverUrl, 'https://covers.openlibrary.org/b/id/123-L.jpg');
      expect(result.genres, ['Science Fiction', 'Humour']);
      expect(result.sourceApis, ['open_library']);

      final authors = result.extraMetadata['authors'] as List;
      expect(authors, ['Douglas Adams']);
      expect(result.extraMetadata['isbn13'], '9780330258647');
      expect(result.extraMetadata['isbn10'], '0330258648');
      expect(result.extraMetadata['page_count'], 180);
    });

    test('handles null fields gracefully', () {
      const dto = OpenLibraryBookDto(
        title: 'Minimal Book',
      );

      final result = OpenLibraryMapper.fromBook(dto, '0000000000', 'isbn10');

      expect(result.title, 'Minimal Book');
      expect(result.mediaType, MediaType.book);
      expect(result.year, isNull);
      expect(result.publisher, isNull);
      expect(result.coverUrl, isNull);
      expect(result.genres, isEmpty);
      expect(result.extraMetadata['authors'], isEmpty);
      expect(result.extraMetadata['isbn10'], isNull);
      expect(result.extraMetadata['isbn13'], isNull);
      expect(result.extraMetadata['page_count'], isNull);
    });

    test('uses medium cover URL when large is null', () {
      const dto = OpenLibraryBookDto(
        title: 'Medium Cover Book',
        cover: OpenLibraryCoverDto(
          small: 'https://covers.openlibrary.org/b/id/456-S.jpg',
          medium: 'https://covers.openlibrary.org/b/id/456-M.jpg',
        ),
      );

      final result = OpenLibraryMapper.fromBook(dto, '1111', 'isbn13');

      expect(result.coverUrl, 'https://covers.openlibrary.org/b/id/456-M.jpg');
    });

    test('filters out empty subject names', () {
      const dto = OpenLibraryBookDto(
        title: 'Mixed Subjects',
        subjects: [
          OpenLibrarySubjectDto(name: 'Fiction'),
          OpenLibrarySubjectDto(name: null),
          OpenLibrarySubjectDto(name: ''),
          OpenLibrarySubjectDto(name: 'Adventure'),
        ],
      );

      final result = OpenLibraryMapper.fromBook(dto, '2222', 'isbn13');

      expect(result.genres, ['Fiction', 'Adventure']);
    });
  });
}
