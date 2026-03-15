import 'package:dio/dio.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/data/remote/api/dio_factory.dart';
import 'package:mymediascanner/data/remote/api/open_library/models/open_library_work_dto.dart';

class OpenLibraryApi {
  OpenLibraryApi([Dio? dio])
      : _dio = dio ??
            DioFactory.create(baseUrl: ApiConstants.openLibraryBaseUrl);

  final Dio _dio;

  /// Look up a book by ISBN using the Books API.
  Future<OpenLibraryBookDto?> getByIsbn(String isbn) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/isbn/$isbn.json',
    );
    if (response.data == null) return null;
    return OpenLibraryBookDto.fromJson(response.data!);
  }
}
