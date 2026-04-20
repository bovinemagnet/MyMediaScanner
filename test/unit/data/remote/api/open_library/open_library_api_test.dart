import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/remote/api/open_library/open_library_api.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _jsonResponse(
  String path,
  Map<String, dynamic> body,
) => Response<Map<String, dynamic>>(
  requestOptions: RequestOptions(path: path),
  data: body,
  statusCode: 200,
);

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  late _MockDio dio;
  late OpenLibraryApi api;

  setUp(() {
    dio = _MockDio();
    api = OpenLibraryApi(dio);
  });

  test('parses a jscmd=data response with nested identifiers', () async {
    const isbn = '9780330258647';
    when(
      () => dio.get<Map<String, dynamic>>(
        '/api/books',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => _jsonResponse('/api/books', {
        'ISBN:$isbn': {
          'title': "The Hitchhiker's Guide to the Galaxy",
          'authors': [
            {'name': 'Douglas Adams', 'url': 'https://example.com/da'},
          ],
          'publishers': [
            {'name': 'Pan Books'},
          ],
          'publish_date': '1979',
          'number_of_pages': 180,
          'subjects': [
            {'name': 'Science fiction', 'url': 'https://example.com/sf'},
            {'name': 'Humour', 'url': 'https://example.com/hu'},
          ],
          'cover': {
            'small': 'https://covers.example.com/s.jpg',
            'medium': 'https://covers.example.com/m.jpg',
            'large': 'https://covers.example.com/l.jpg',
          },
          'identifiers': {
            'isbn_10': ['0330258648'],
            'isbn_13': ['9780330258647'],
          },
        },
      }),
    );

    final book = await api.getByIsbn(isbn);

    expect(book, isNotNull);
    expect(book!.title, "The Hitchhiker's Guide to the Galaxy");
    expect(book.authors?.single.name, 'Douglas Adams');
    expect(book.publishers?.single.name, 'Pan Books');
    expect(book.subjects?.map((s) => s.name).toList(), [
      'Science fiction',
      'Humour',
    ]);
    expect(book.isbn10, ['0330258648']);
    expect(book.isbn13, ['9780330258647']);
    expect(book.cover?.large, 'https://covers.example.com/l.jpg');
    expect(book.numberOfPages, 180);
    expect(book.year, 1979);
  });

  test('returns null when the response has no matching ISBN key', () async {
    const isbn = '9999999999999';
    when(
      () => dio.get<Map<String, dynamic>>(
        '/api/books',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => _jsonResponse('/api/books', const {}));

    final book = await api.getByIsbn(isbn);

    expect(book, isNull);
  });

  test('returns null when Dio returns no body', () async {
    const isbn = '9780330258647';
    when(
      () => dio.get<Map<String, dynamic>>(
        '/api/books',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/api/books'),
        statusCode: 200,
      ),
    );

    final book = await api.getByIsbn(isbn);

    expect(book, isNull);
  });

  group('searchByTitle', () {
    test('parses docs with author_name, cover_i, isbn list', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          '/search.json',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _jsonResponse('/search.json', {
          'numFound': 2,
          'docs': [
            {
              'key': '/works/OL27479W',
              'title': 'The Gruffalo',
              'author_name': ['Julia Donaldson', 'Axel Scheffler'],
              'first_publish_year': 1999,
              'cover_i': 8315657,
              'isbn': ['9780333710937', '0333710932'],
              'subject': ['Picture books'],
              'publisher': ['Macmillan'],
            },
            {
              'key': '/works/OL99999W',
              'title': 'The Gruffalo\'s Child',
              'author_name': ['Julia Donaldson'],
            },
          ],
        }),
      );

      final response = await api.searchByTitle('Gruffalo');

      expect(response, isNotNull);
      expect(response!.numFound, 2);
      expect(response.docs, hasLength(2));
      final first = response.docs!.first;
      expect(first.title, 'The Gruffalo');
      expect(first.authorName, ['Julia Donaldson', 'Axel Scheffler']);
      expect(first.firstPublishYear, 1999);
      expect(first.coverI, 8315657);
      expect(first.isbn, contains('9780333710937'));
      expect(
        first.coverUrl,
        'https://covers.openlibrary.org/b/id/8315657-L.jpg',
      );
    });

    test('returns response with empty docs when nothing matches', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          '/search.json',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _jsonResponse('/search.json', {'numFound': 0, 'docs': []}),
      );

      final response = await api.searchByTitle('zxnothingmatchesz');

      expect(response, isNotNull);
      expect(response!.numFound, 0);
      expect(response.docs, isEmpty);
    });
  });
}
