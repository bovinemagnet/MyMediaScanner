import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mymediascanner/data/remote/api/google_books/models/google_books_volume_dto.dart';

part 'google_books_api.g.dart';

@RestApi()
abstract class GoogleBooksApi {
  factory GoogleBooksApi(Dio dio) = _GoogleBooksApi;

  @GET('/volumes')
  Future<GoogleBooksSearchResponseDto> searchByIsbn(
    @Query('q') String query,
  );
}
