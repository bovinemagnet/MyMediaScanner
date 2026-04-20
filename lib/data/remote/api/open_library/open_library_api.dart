import 'package:dio/dio.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/data/remote/api/dio_factory.dart';
import 'package:mymediascanner/data/remote/api/open_library/models/open_library_search_dto.dart';
import 'package:mymediascanner/data/remote/api/open_library/models/open_library_work_dto.dart';

class OpenLibraryApi {
  OpenLibraryApi([Dio? dio])
    : _dio = dio ?? DioFactory.create(baseUrl: ApiConstants.openLibraryBaseUrl);

  final Dio _dio;

  /// Look up a book by ISBN using the Books API.
  ///
  /// Uses the `/api/books?jscmd=data` endpoint, which returns resolved
  /// author/publisher/subject names as objects. The `/isbn/{isbn}.json`
  /// edition endpoint returns `publishers`/`subjects` as string arrays and
  /// `authors` as `[{key}]` stubs, which the DTO can't parse.
  Future<OpenLibraryBookDto?> getByIsbn(String isbn) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/books',
      queryParameters: {
        'bibkeys': 'ISBN:$isbn',
        'format': 'json',
        'jscmd': 'data',
      },
    );
    final data = response.data;
    if (data == null || data.isEmpty) return null;

    final entry = data['ISBN:$isbn'];
    if (entry is! Map<String, dynamic>) return null;

    // `jscmd=data` nests ISBNs under `identifiers`; lift them to the flat
    // shape the DTO expects.
    final book = Map<String, dynamic>.from(entry);
    final identifiers = book['identifiers'];
    if (identifiers is Map) {
      final isbn10 = identifiers['isbn_10'];
      if (isbn10 != null) book['isbn_10'] = isbn10;
      final isbn13 = identifiers['isbn_13'];
      if (isbn13 != null) book['isbn_13'] = isbn13;
    }

    return OpenLibraryBookDto.fromJson(book);
  }

  /// Search books by free-text title. Used as a fallback when Google Books
  /// is unavailable (rate-limited, 5xx, or network error) so an OCR'd cover
  /// doesn't dead-end on Google's outage.
  Future<OpenLibrarySearchResponseDto?> searchByTitle(
    String title, {
    int limit = 10,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/search.json',
      queryParameters: {
        'title': title,
        'limit': limit,
        // Only request the fields we deserialise — keeps the response small.
        'fields':
            'key,title,author_name,first_publish_year,cover_i,isbn,'
            'subject,publisher',
      },
    );
    final data = response.data;
    if (data == null) return null;
    return OpenLibrarySearchResponseDto.fromJson(data);
  }
}
