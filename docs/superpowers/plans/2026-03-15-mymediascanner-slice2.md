# MyMediaScanner Slice 2: Scan + Metadata Lookup

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement barcode scanning (camera on Android, keyboard-wedge on macOS), API clients for all five metadata sources, tiered metadata lookup, confirm screen, and barcode cache.

**Architecture:** Platform-adaptive scanner feeds barcode into ScanBarcodeUseCase which orchestrates tiered API lookup via MetadataRepositoryImpl. Results displayed in MetadataConfirmScreen for user review before saving.

**Tech Stack:** Dio + Retrofit, mobile_scanner, Riverpod v3 codegen, Freezed DTOs

**Author:** Paul Snow

**Depends on:** Slice 1 complete

---

## File Structure (Slice 2)

```
lib/
  data/
    remote/
      api/
        tmdb/
          tmdb_api.dart
          models/
            tmdb_search_result_dto.dart
        discogs/
          discogs_api.dart
          models/
            discogs_release_dto.dart
        google_books/
          google_books_api.dart
          models/
            google_books_volume_dto.dart
        open_library/
          open_library_api.dart
          models/
            open_library_work_dto.dart
        upc/
          upcitemdb_api.dart
          models/
            upc_item_dto.dart
        dio_factory.dart
    mappers/
      tmdb_mapper.dart
      discogs_mapper.dart
      google_books_mapper.dart
      open_library_mapper.dart
      upc_mapper.dart
    repositories/
      metadata_repository_impl.dart
      media_item_repository_impl.dart
  domain/
    usecases/
      scan_barcode_usecase.dart
      save_media_item_usecase.dart
  presentation/
    providers/
      scanner_provider.dart
      metadata_provider.dart
      settings_provider.dart
    screens/
      scanner/
        scanner_screen.dart          (replace placeholder)
        desktop_scan_screen.dart
        scanner_controller.dart
        widgets/
          scan_overlay.dart
          batch_scan_counter.dart
      metadata_confirm/
        metadata_confirm_screen.dart
        widgets/
          editable_metadata_form.dart
test/
  unit/
    data/
      mappers/
        tmdb_mapper_test.dart
        google_books_mapper_test.dart
    domain/
      scan_barcode_usecase_test.dart
      save_media_item_usecase_test.dart
```

---

## Task 1: Dio Factory

**Files:**
- Create: `lib/data/remote/api/dio_factory.dart`

- [ ] **Step 1: Create dio_factory.dart**

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Creates configured Dio instances for API clients.
class DioFactory {
  static Dio create({
    required String baseUrl,
    Map<String, String>? defaultHeaders,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 15),
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: defaultHeaders,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: false,
      ));
    }

    return dio;
  }

  /// Creates a Dio instance with an API key query parameter.
  static Dio createWithApiKey({
    required String baseUrl,
    required String apiKeyParam,
    required String apiKey,
    Map<String, String>? defaultHeaders,
  }) {
    final dio = create(baseUrl: baseUrl, defaultHeaders: defaultHeaders);
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.queryParameters[apiKeyParam] = apiKey;
        handler.next(options);
      },
    ));
    return dio;
  }

  /// Creates a Dio instance with a Bearer token header.
  static Dio createWithBearerToken({
    required String baseUrl,
    required String token,
    Map<String, String>? defaultHeaders,
  }) {
    final headers = {
      'Authorization': 'Bearer $token',
      ...?defaultHeaders,
    };
    return create(baseUrl: baseUrl, defaultHeaders: headers);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/remote/api/dio_factory.dart
git commit -m "feat: add Dio factory for API client configuration"
```

---

## Task 2: TMDB API Client + DTO

**Files:**
- Create: `lib/data/remote/api/tmdb/models/tmdb_search_result_dto.dart`
- Create: `lib/data/remote/api/tmdb/tmdb_api.dart`

- [ ] **Step 1: Create tmdb_search_result_dto.dart**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'tmdb_search_result_dto.g.dart';

@JsonSerializable()
class TmdbSearchResultDto {
  const TmdbSearchResultDto({
    this.id,
    this.title,
    this.name,
    this.overview,
    this.posterPath,
    this.releaseDate,
    this.firstAirDate,
    this.genreIds,
    this.mediaType,
  });

  factory TmdbSearchResultDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbSearchResultDtoFromJson(json);

  final int? id;
  final String? title;
  final String? name;
  final String? overview;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  @JsonKey(name: 'first_air_date')
  final String? firstAirDate;
  @JsonKey(name: 'genre_ids')
  final List<int>? genreIds;
  @JsonKey(name: 'media_type')
  final String? mediaType;

  Map<String, dynamic> toJson() => _$TmdbSearchResultDtoToJson(this);

  /// Effective title (movies use title, TV uses name).
  String? get effectiveTitle => title ?? name;

  /// Effective release year.
  int? get effectiveYear {
    final date = releaseDate ?? firstAirDate;
    if (date == null || date.length < 4) return null;
    return int.tryParse(date.substring(0, 4));
  }

  /// Full poster URL.
  String? get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : null;
}

@JsonSerializable()
class TmdbSearchResponseDto {
  const TmdbSearchResponseDto({this.results, this.totalResults});

  factory TmdbSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbSearchResponseDtoFromJson(json);

  final List<TmdbSearchResultDto>? results;
  @JsonKey(name: 'total_results')
  final int? totalResults;

  Map<String, dynamic> toJson() => _$TmdbSearchResponseDtoToJson(this);
}
```

- [ ] **Step 2: Create tmdb_api.dart**

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_search_result_dto.dart';

part 'tmdb_api.g.dart';

@RestApi()
abstract class TmdbApi {
  factory TmdbApi(Dio dio) = _TmdbApi;

  @GET('/search/multi')
  Future<TmdbSearchResponseDto> searchMulti(
    @Query('query') String query, {
    @Query('page') int page = 1,
  });

  @GET('/search/movie')
  Future<TmdbSearchResponseDto> searchMovie(
    @Query('query') String query, {
    @Query('page') int page = 1,
  });

  @GET('/search/tv')
  Future<TmdbSearchResponseDto> searchTv(
    @Query('query') String query, {
    @Query('page') int page = 1,
  });
}
```

- [ ] **Step 3: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Commit**

```bash
git add lib/data/remote/api/tmdb/
git commit -m "feat: add TMDB API client with DTOs"
```

---

## Task 3: Discogs API Client + DTO

**Files:**
- Create: `lib/data/remote/api/discogs/models/discogs_release_dto.dart`
- Create: `lib/data/remote/api/discogs/discogs_api.dart`

- [ ] **Step 1: Create discogs_release_dto.dart**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'discogs_release_dto.g.dart';

@JsonSerializable()
class DiscogsReleaseDto {
  const DiscogsReleaseDto({
    this.id,
    this.title,
    this.year,
    this.artists,
    this.labels,
    this.genres,
    this.styles,
    this.tracklist,
    this.images,
    this.catno,
  });

  factory DiscogsReleaseDto.fromJson(Map<String, dynamic> json) =>
      _$DiscogsReleaseDtoFromJson(json);

  final int? id;
  final String? title;
  final int? year;
  final List<DiscogsArtistDto>? artists;
  final List<DiscogsLabelDto>? labels;
  final List<String>? genres;
  final List<String>? styles;
  final List<DiscogsTrackDto>? tracklist;
  final List<DiscogsImageDto>? images;
  final String? catno;

  Map<String, dynamic> toJson() => _$DiscogsReleaseDtoToJson(this);

  String? get primaryImageUrl =>
      images?.isNotEmpty == true ? images!.first.uri : null;

  String? get artistName =>
      artists?.map((a) => a.name).join(', ');

  String? get labelName =>
      labels?.isNotEmpty == true ? labels!.first.name : null;
}

@JsonSerializable()
class DiscogsArtistDto {
  const DiscogsArtistDto({this.name});
  factory DiscogsArtistDto.fromJson(Map<String, dynamic> json) =>
      _$DiscogsArtistDtoFromJson(json);
  final String? name;
  Map<String, dynamic> toJson() => _$DiscogsArtistDtoToJson(this);
}

@JsonSerializable()
class DiscogsLabelDto {
  const DiscogsLabelDto({this.name, this.catno});
  factory DiscogsLabelDto.fromJson(Map<String, dynamic> json) =>
      _$DiscogsLabelDtoFromJson(json);
  final String? name;
  final String? catno;
  Map<String, dynamic> toJson() => _$DiscogsLabelDtoToJson(this);
}

@JsonSerializable()
class DiscogsTrackDto {
  const DiscogsTrackDto({this.position, this.title, this.duration});
  factory DiscogsTrackDto.fromJson(Map<String, dynamic> json) =>
      _$DiscogsTrackDtoFromJson(json);
  final String? position;
  final String? title;
  final String? duration;
  Map<String, dynamic> toJson() => _$DiscogsTrackDtoToJson(this);
}

@JsonSerializable()
class DiscogsImageDto {
  const DiscogsImageDto({this.uri, this.type});
  factory DiscogsImageDto.fromJson(Map<String, dynamic> json) =>
      _$DiscogsImageDtoFromJson(json);
  final String? uri;
  final String? type;
  Map<String, dynamic> toJson() => _$DiscogsImageDtoToJson(this);
}

@JsonSerializable()
class DiscogsSearchResponseDto {
  const DiscogsSearchResponseDto({this.results});
  factory DiscogsSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DiscogsSearchResponseDtoFromJson(json);
  final List<DiscogsSearchResultDto>? results;
  Map<String, dynamic> toJson() => _$DiscogsSearchResponseDtoToJson(this);
}

@JsonSerializable()
class DiscogsSearchResultDto {
  const DiscogsSearchResultDto({this.id, this.title, this.year, this.coverImage});
  factory DiscogsSearchResultDto.fromJson(Map<String, dynamic> json) =>
      _$DiscogsSearchResultDtoFromJson(json);
  final int? id;
  final String? title;
  final String? year;
  @JsonKey(name: 'cover_image')
  final String? coverImage;
  Map<String, dynamic> toJson() => _$DiscogsSearchResultDtoToJson(this);
}
```

- [ ] **Step 2: Create discogs_api.dart**

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mymediascanner/data/remote/api/discogs/models/discogs_release_dto.dart';

part 'discogs_api.g.dart';

@RestApi()
abstract class DiscogsApi {
  factory DiscogsApi(Dio dio) = _DiscogsApi;

  @GET('/database/search')
  Future<DiscogsSearchResponseDto> searchByBarcode(
    @Query('barcode') String barcode, {
    @Query('type') String type = 'release',
  });

  @GET('/releases/{id}')
  Future<DiscogsReleaseDto> getRelease(@Path('id') int id);
}
```

- [ ] **Step 3: Run code generation and commit**

```bash
dart run build_runner build --delete-conflicting-outputs
git add lib/data/remote/api/discogs/
git commit -m "feat: add Discogs API client with DTOs"
```

---

## Task 4: Google Books API Client + DTO

**Files:**
- Create: `lib/data/remote/api/google_books/models/google_books_volume_dto.dart`
- Create: `lib/data/remote/api/google_books/google_books_api.dart`

- [ ] **Step 1: Create google_books_volume_dto.dart**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'google_books_volume_dto.g.dart';

@JsonSerializable()
class GoogleBooksVolumeDto {
  const GoogleBooksVolumeDto({this.id, this.volumeInfo});
  factory GoogleBooksVolumeDto.fromJson(Map<String, dynamic> json) =>
      _$GoogleBooksVolumeDtoFromJson(json);
  final String? id;
  final GoogleBooksVolumeInfoDto? volumeInfo;
  Map<String, dynamic> toJson() => _$GoogleBooksVolumeDtoToJson(this);
}

@JsonSerializable()
class GoogleBooksVolumeInfoDto {
  const GoogleBooksVolumeInfoDto({
    this.title,
    this.subtitle,
    this.authors,
    this.publisher,
    this.publishedDate,
    this.description,
    this.pageCount,
    this.categories,
    this.imageLinks,
    this.industryIdentifiers,
  });

  factory GoogleBooksVolumeInfoDto.fromJson(Map<String, dynamic> json) =>
      _$GoogleBooksVolumeInfoDtoFromJson(json);

  final String? title;
  final String? subtitle;
  final List<String>? authors;
  final String? publisher;
  final String? publishedDate;
  final String? description;
  final int? pageCount;
  final List<String>? categories;
  final GoogleBooksImageLinksDto? imageLinks;
  final List<GoogleBooksIdentifierDto>? industryIdentifiers;

  Map<String, dynamic> toJson() => _$GoogleBooksVolumeInfoDtoToJson(this);

  int? get year {
    if (publishedDate == null || publishedDate!.length < 4) return null;
    return int.tryParse(publishedDate!.substring(0, 4));
  }

  String? get isbn13 => industryIdentifiers
      ?.where((i) => i.type == 'ISBN_13')
      .firstOrNull
      ?.identifier;

  String? get isbn10 => industryIdentifiers
      ?.where((i) => i.type == 'ISBN_10')
      .firstOrNull
      ?.identifier;
}

@JsonSerializable()
class GoogleBooksImageLinksDto {
  const GoogleBooksImageLinksDto({this.thumbnail, this.smallThumbnail});
  factory GoogleBooksImageLinksDto.fromJson(Map<String, dynamic> json) =>
      _$GoogleBooksImageLinksDtoFromJson(json);
  final String? thumbnail;
  final String? smallThumbnail;
  Map<String, dynamic> toJson() => _$GoogleBooksImageLinksDtoToJson(this);
}

@JsonSerializable()
class GoogleBooksIdentifierDto {
  const GoogleBooksIdentifierDto({this.type, this.identifier});
  factory GoogleBooksIdentifierDto.fromJson(Map<String, dynamic> json) =>
      _$GoogleBooksIdentifierDtoFromJson(json);
  final String? type;
  final String? identifier;
  Map<String, dynamic> toJson() => _$GoogleBooksIdentifierDtoToJson(this);
}

@JsonSerializable()
class GoogleBooksSearchResponseDto {
  const GoogleBooksSearchResponseDto({this.totalItems, this.items});
  factory GoogleBooksSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$GoogleBooksSearchResponseDtoFromJson(json);
  final int? totalItems;
  final List<GoogleBooksVolumeDto>? items;
  Map<String, dynamic> toJson() => _$GoogleBooksSearchResponseDtoToJson(this);
}
```

- [ ] **Step 2: Create google_books_api.dart**

```dart
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
```

- [ ] **Step 3: Run code generation and commit**

```bash
dart run build_runner build --delete-conflicting-outputs
git add lib/data/remote/api/google_books/
git commit -m "feat: add Google Books API client with DTOs"
```

---

## Task 5: Open Library API Client + DTO

**Files:**
- Create: `lib/data/remote/api/open_library/models/open_library_work_dto.dart`
- Create: `lib/data/remote/api/open_library/open_library_api.dart`

- [ ] **Step 1: Create open_library_work_dto.dart**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'open_library_work_dto.g.dart';

@JsonSerializable()
class OpenLibraryBookDto {
  const OpenLibraryBookDto({
    this.title,
    this.authors,
    this.publishers,
    this.publishDate,
    this.numberOfPages,
    this.subjects,
    this.cover,
    this.isbn10,
    this.isbn13,
  });

  factory OpenLibraryBookDto.fromJson(Map<String, dynamic> json) =>
      _$OpenLibraryBookDtoFromJson(json);

  final String? title;
  final List<OpenLibraryAuthorDto>? authors;
  final List<OpenLibraryPublisherDto>? publishers;
  @JsonKey(name: 'publish_date')
  final String? publishDate;
  @JsonKey(name: 'number_of_pages')
  final int? numberOfPages;
  final List<OpenLibrarySubjectDto>? subjects;
  final OpenLibraryCoverDto? cover;
  @JsonKey(name: 'isbn_10')
  final List<String>? isbn10;
  @JsonKey(name: 'isbn_13')
  final List<String>? isbn13;

  Map<String, dynamic> toJson() => _$OpenLibraryBookDtoToJson(this);

  int? get year {
    if (publishDate == null) return null;
    final match = RegExp(r'\d{4}').firstMatch(publishDate!);
    return match != null ? int.tryParse(match.group(0)!) : null;
  }
}

@JsonSerializable()
class OpenLibraryAuthorDto {
  const OpenLibraryAuthorDto({this.name});
  factory OpenLibraryAuthorDto.fromJson(Map<String, dynamic> json) =>
      _$OpenLibraryAuthorDtoFromJson(json);
  final String? name;
  Map<String, dynamic> toJson() => _$OpenLibraryAuthorDtoToJson(this);
}

@JsonSerializable()
class OpenLibraryPublisherDto {
  const OpenLibraryPublisherDto({this.name});
  factory OpenLibraryPublisherDto.fromJson(Map<String, dynamic> json) =>
      _$OpenLibraryPublisherDtoFromJson(json);
  final String? name;
  Map<String, dynamic> toJson() => _$OpenLibraryPublisherDtoToJson(this);
}

@JsonSerializable()
class OpenLibrarySubjectDto {
  const OpenLibrarySubjectDto({this.name});
  factory OpenLibrarySubjectDto.fromJson(Map<String, dynamic> json) =>
      _$OpenLibrarySubjectDtoFromJson(json);
  final String? name;
  Map<String, dynamic> toJson() => _$OpenLibrarySubjectDtoToJson(this);
}

@JsonSerializable()
class OpenLibraryCoverDto {
  const OpenLibraryCoverDto({this.small, this.medium, this.large});
  factory OpenLibraryCoverDto.fromJson(Map<String, dynamic> json) =>
      _$OpenLibraryCoverDtoFromJson(json);
  final String? small;
  final String? medium;
  final String? large;
  Map<String, dynamic> toJson() => _$OpenLibraryCoverDtoToJson(this);
}
```

- [ ] **Step 2: Create open_library_api.dart (hand-written Dio client)**

```dart
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
```

- [ ] **Step 3: Run code generation and commit**

```bash
dart run build_runner build --delete-conflicting-outputs
git add lib/data/remote/api/open_library/
git commit -m "feat: add Open Library API client with DTOs"
```

---

## Task 6: UPCitemdb API Client + DTO

**Files:**
- Create: `lib/data/remote/api/upc/models/upc_item_dto.dart`
- Create: `lib/data/remote/api/upc/upcitemdb_api.dart`

- [ ] **Step 1: Create upc_item_dto.dart**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'upc_item_dto.g.dart';

@JsonSerializable()
class UpcItemDto {
  const UpcItemDto({
    this.ean,
    this.title,
    this.description,
    this.brand,
    this.category,
    this.images,
  });

  factory UpcItemDto.fromJson(Map<String, dynamic> json) =>
      _$UpcItemDtoFromJson(json);

  final String? ean;
  final String? title;
  final String? description;
  final String? brand;
  final String? category;
  final List<String>? images;

  Map<String, dynamic> toJson() => _$UpcItemDtoToJson(this);

  String? get primaryImageUrl =>
      images?.isNotEmpty == true ? images!.first : null;
}

@JsonSerializable()
class UpcSearchResponseDto {
  const UpcSearchResponseDto({this.code, this.total, this.items});

  factory UpcSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UpcSearchResponseDtoFromJson(json);

  final String? code;
  final int? total;
  final List<UpcItemDto>? items;

  Map<String, dynamic> toJson() => _$UpcSearchResponseDtoToJson(this);
}
```

- [ ] **Step 2: Create upcitemdb_api.dart**

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mymediascanner/data/remote/api/upc/models/upc_item_dto.dart';

part 'upcitemdb_api.g.dart';

@RestApi()
abstract class UpcitemdbApi {
  factory UpcitemdbApi(Dio dio) = _UpcitemdbApi;

  @GET('/lookup')
  Future<UpcSearchResponseDto> lookup(@Query('upc') String barcode);
}
```

- [ ] **Step 3: Run code generation and commit**

```bash
dart run build_runner build --delete-conflicting-outputs
git add lib/data/remote/api/upc/
git commit -m "feat: add UPCitemdb API client with DTOs"
```

---

## Task 7: Mappers (all five)

**Files:**
- Create: `lib/data/mappers/tmdb_mapper.dart`
- Create: `lib/data/mappers/discogs_mapper.dart`
- Create: `lib/data/mappers/google_books_mapper.dart`
- Create: `lib/data/mappers/open_library_mapper.dart`
- Create: `lib/data/mappers/upc_mapper.dart`

- [ ] **Step 1: Create tmdb_mapper.dart**

```dart
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_search_result_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

abstract final class TmdbMapper {
  static MetadataResult fromSearchResult(
    TmdbSearchResultDto dto,
    String barcode,
    String barcodeType,
  ) {
    final isTV = dto.mediaType == 'tv';
    return MetadataResult(
      barcode: barcode,
      barcodeType: barcodeType,
      mediaType: isTV ? MediaType.tv : MediaType.film,
      title: dto.effectiveTitle,
      coverUrl: dto.posterUrl,
      year: dto.effectiveYear,
      description: dto.overview,
      extraMetadata: {
        'tmdb_id': dto.id,
        if (isTV) 'media_type': 'tv' else 'media_type': 'film',
      },
      sourceApis: ['tmdb'],
    );
  }
}
```

- [ ] **Step 2: Create discogs_mapper.dart**

```dart
import 'package:mymediascanner/data/remote/api/discogs/models/discogs_release_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

abstract final class DiscogsMapper {
  static MetadataResult fromRelease(
    DiscogsReleaseDto dto,
    String barcode,
    String barcodeType,
  ) {
    return MetadataResult(
      barcode: barcode,
      barcodeType: barcodeType,
      mediaType: MediaType.music,
      title: dto.title,
      coverUrl: dto.primaryImageUrl,
      year: dto.year,
      publisher: dto.labelName,
      genres: dto.genres ?? [],
      extraMetadata: {
        'discogs_release_id': dto.id,
        'artists': dto.artists?.map((a) => a.name).toList() ?? [],
        'catalogue_number': dto.catno,
        'label': dto.labelName,
        'track_listing': dto.tracklist
                ?.map((t) => {
                      'position': t.position,
                      'title': t.title,
                      'duration': t.duration,
                    })
                .toList() ??
            [],
      },
      sourceApis: ['discogs'],
    );
  }
}
```

- [ ] **Step 3: Create google_books_mapper.dart**

```dart
import 'package:mymediascanner/data/remote/api/google_books/models/google_books_volume_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

abstract final class GoogleBooksMapper {
  static MetadataResult fromVolume(
    GoogleBooksVolumeDto dto,
    String barcode,
    String barcodeType,
  ) {
    final info = dto.volumeInfo;
    return MetadataResult(
      barcode: barcode,
      barcodeType: barcodeType,
      mediaType: MediaType.book,
      title: info?.title,
      subtitle: info?.subtitle,
      description: info?.description,
      coverUrl: info?.imageLinks?.thumbnail,
      year: info?.year,
      publisher: info?.publisher,
      genres: info?.categories ?? [],
      extraMetadata: {
        'google_books_id': dto.id,
        'authors': info?.authors ?? [],
        'isbn10': info?.isbn10,
        'isbn13': info?.isbn13,
        'page_count': info?.pageCount,
      },
      sourceApis: ['google_books'],
    );
  }
}
```

- [ ] **Step 4: Create open_library_mapper.dart**

```dart
import 'package:mymediascanner/data/remote/api/open_library/models/open_library_work_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

abstract final class OpenLibraryMapper {
  static MetadataResult fromBook(
    OpenLibraryBookDto dto,
    String barcode,
    String barcodeType,
  ) {
    return MetadataResult(
      barcode: barcode,
      barcodeType: barcodeType,
      mediaType: MediaType.book,
      title: dto.title,
      coverUrl: dto.cover?.large ?? dto.cover?.medium,
      year: dto.year,
      publisher: dto.publishers?.firstOrNull?.name,
      genres: dto.subjects?.map((s) => s.name ?? '').where((s) => s.isNotEmpty).toList() ?? [],
      extraMetadata: {
        'authors': dto.authors?.map((a) => a.name).toList() ?? [],
        'isbn10': dto.isbn10?.firstOrNull,
        'isbn13': dto.isbn13?.firstOrNull,
        'page_count': dto.numberOfPages,
      },
      sourceApis: ['open_library'],
    );
  }
}
```

- [ ] **Step 5: Create upc_mapper.dart**

```dart
import 'package:mymediascanner/data/remote/api/upc/models/upc_item_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

abstract final class UpcMapper {
  static MetadataResult fromItem(
    UpcItemDto dto,
    String barcode,
    String barcodeType,
  ) {
    return MetadataResult(
      barcode: barcode,
      barcodeType: barcodeType,
      mediaType: _guessMediaType(dto.category),
      title: dto.title,
      description: dto.description,
      coverUrl: dto.primaryImageUrl,
      publisher: dto.brand,
      sourceApis: ['upcitemdb'],
    );
  }

  static MediaType _guessMediaType(String? category) {
    if (category == null) return MediaType.unknown;
    final lower = category.toLowerCase();
    if (lower.contains('book')) return MediaType.book;
    if (lower.contains('music') || lower.contains('cd') || lower.contains('vinyl')) {
      return MediaType.music;
    }
    if (lower.contains('movie') || lower.contains('dvd') ||
        lower.contains('blu-ray') || lower.contains('video')) {
      return MediaType.film;
    }
    if (lower.contains('game')) return MediaType.game;
    return MediaType.unknown;
  }
}
```

- [ ] **Step 6: Commit**

```bash
git add lib/data/mappers/
git commit -m "feat: add all five DTO-to-domain mappers"
```

---

## Task 8: Mapper Tests

**Files:**
- Create: `test/unit/data/mappers/tmdb_mapper_test.dart`
- Create: `test/unit/data/mappers/google_books_mapper_test.dart`

- [ ] **Step 1: Write tmdb_mapper_test.dart**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/mappers/tmdb_mapper.dart';
import 'package:mymediascanner/data/remote/api/tmdb/models/tmdb_search_result_dto.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

void main() {
  group('TmdbMapper', () {
    test('maps movie search result to MetadataResult', () {
      final dto = TmdbSearchResultDto(
        id: 550,
        title: 'Fight Club',
        overview: 'An insomniac office worker...',
        posterPath: '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
        releaseDate: '1999-10-15',
        mediaType: 'movie',
      );

      final result = TmdbMapper.fromSearchResult(dto, '5051892002172', 'ean13');

      expect(result.title, 'Fight Club');
      expect(result.mediaType, MediaType.film);
      expect(result.year, 1999);
      expect(result.coverUrl, contains('w500'));
      expect(result.sourceApis, ['tmdb']);
      expect(result.extraMetadata['tmdb_id'], 550);
    });

    test('maps TV search result correctly', () {
      final dto = TmdbSearchResultDto(
        id: 1396,
        name: 'Breaking Bad',
        firstAirDate: '2008-01-20',
        mediaType: 'tv',
      );

      final result = TmdbMapper.fromSearchResult(dto, '1234567890123', 'ean13');

      expect(result.title, 'Breaking Bad');
      expect(result.mediaType, MediaType.tv);
      expect(result.year, 2008);
    });
  });
}
```

- [ ] **Step 2: Write google_books_mapper_test.dart**

```dart
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
    });
  });
}
```

- [ ] **Step 3: Run tests**

```bash
flutter test test/unit/data/mappers/
```

Expected: All PASS.

- [ ] **Step 4: Commit**

```bash
git add test/unit/data/mappers/
git commit -m "test: add mapper unit tests for TMDB and Google Books"
```

---

## Task 9: MediaItemRepositoryImpl

**Files:**
- Create: `lib/data/repositories/media_item_repository_impl.dart`

- [ ] **Step 1: Create media_item_repository_impl.dart**

```dart
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/dao/media_items_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:uuid/uuid.dart';

class MediaItemRepositoryImpl implements IMediaItemRepository {
  MediaItemRepositoryImpl({
    required MediaItemsDao mediaItemsDao,
    required SyncLogDao syncLogDao,
  })  : _mediaItemsDao = mediaItemsDao,
        _syncLogDao = syncLogDao;

  final MediaItemsDao _mediaItemsDao;
  final SyncLogDao _syncLogDao;
  static const _uuid = Uuid();

  @override
  Stream<List<MediaItem>> watchAll({
    MediaType? mediaType,
    String? searchQuery,
    List<String>? tagIds,
    String? sortBy,
    bool ascending = true,
  }) {
    // Basic watch — filtering/sorting will be enhanced in Slice 3
    return _mediaItemsDao.watchAll().map(
      (rows) => rows
          .where((r) =>
              mediaType == null || r.mediaType == mediaType.name)
          .where((r) =>
              searchQuery == null ||
              r.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .map(_fromRow)
          .toList(),
    );
  }

  @override
  Future<MediaItem?> getById(String id) async {
    final row = await _mediaItemsDao.getById(id);
    return row != null ? _fromRow(row) : null;
  }

  @override
  Future<bool> barcodeExists(String barcode) {
    return _mediaItemsDao.barcodeExists(barcode);
  }

  @override
  Future<void> save(MediaItem item) async {
    await _mediaItemsDao.insertItem(_toCompanion(item));
    await _logSync('media_item', item.id, 'insert', item);
  }

  @override
  Future<void> update(MediaItem item) async {
    await _mediaItemsDao.updateItem(_toCompanion(item));
    await _logSync('media_item', item.id, 'update', item);
  }

  @override
  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _mediaItemsDao.softDelete(id, now);
    await _syncLogDao.insertLog(SyncLogTableCompanion(
      id: Value(_uuid.v7()),
      entityType: const Value('media_item'),
      entityId: Value(id),
      operation: const Value('delete'),
      payloadJson: Value(jsonEncode({'id': id, 'deleted': 1})),
      createdAt: Value(now),
    ));
  }

  @override
  Future<List<MediaItem>> getUnsynced() async {
    final rows = await _mediaItemsDao.getUnsynced();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> markSynced(String id, int syncedAt) {
    return _mediaItemsDao.markSynced(id, syncedAt);
  }

  MediaItem _fromRow(MediaItemsTableData row) {
    return MediaItem(
      id: row.id,
      barcode: row.barcode,
      barcodeType: row.barcodeType,
      mediaType: MediaType.fromString(row.mediaType),
      title: row.title,
      subtitle: row.subtitle,
      description: row.description,
      coverUrl: row.coverUrl,
      year: row.year,
      publisher: row.publisher,
      format: row.format,
      genres: (jsonDecode(row.genres) as List).cast<String>(),
      extraMetadata: jsonDecode(row.extraMetadata) as Map<String, dynamic>,
      sourceApis: (jsonDecode(row.sourceApis) as List).cast<String>(),
      userRating: row.userRating,
      userReview: row.userReview,
      dateAdded: row.dateAdded,
      dateScanned: row.dateScanned,
      updatedAt: row.updatedAt,
      syncedAt: row.syncedAt,
      deleted: row.deleted == 1,
    );
  }

  MediaItemsTableCompanion _toCompanion(MediaItem item) {
    return MediaItemsTableCompanion(
      id: Value(item.id),
      barcode: Value(item.barcode),
      barcodeType: Value(item.barcodeType),
      mediaType: Value(item.mediaType.name),
      title: Value(item.title),
      subtitle: Value(item.subtitle),
      description: Value(item.description),
      coverUrl: Value(item.coverUrl),
      year: Value(item.year),
      publisher: Value(item.publisher),
      format: Value(item.format),
      genres: Value(jsonEncode(item.genres)),
      extraMetadata: Value(jsonEncode(item.extraMetadata)),
      sourceApis: Value(jsonEncode(item.sourceApis)),
      userRating: Value(item.userRating),
      userReview: Value(item.userReview),
      dateAdded: Value(item.dateAdded),
      dateScanned: Value(item.dateScanned),
      updatedAt: Value(item.updatedAt),
      syncedAt: Value(item.syncedAt),
      deleted: Value(item.deleted ? 1 : 0),
    );
  }

  Future<void> _logSync(
      String entityType, String entityId, String operation, MediaItem item) {
    return _syncLogDao.insertLog(SyncLogTableCompanion(
      id: Value(_uuid.v7()),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payloadJson: Value(jsonEncode({
        'id': item.id,
        'barcode': item.barcode,
        'title': item.title,
        'media_type': item.mediaType.name,
      })),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/repositories/media_item_repository_impl.dart
git commit -m "feat: add MediaItemRepositoryImpl with sync logging"
```

---

## Task 10: MetadataRepositoryImpl (Tiered Lookup)

**Files:**
- Create: `lib/data/repositories/metadata_repository_impl.dart`

- [ ] **Step 1: Create metadata_repository_impl.dart**

```dart
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/core/errors/app_exception.dart';
import 'package:mymediascanner/core/utils/barcode_utils.dart';
import 'package:mymediascanner/data/local/dao/barcode_cache_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/data/mappers/discogs_mapper.dart';
import 'package:mymediascanner/data/mappers/google_books_mapper.dart';
import 'package:mymediascanner/data/mappers/open_library_mapper.dart';
import 'package:mymediascanner/data/mappers/tmdb_mapper.dart';
import 'package:mymediascanner/data/mappers/upc_mapper.dart';
import 'package:mymediascanner/data/remote/api/discogs/discogs_api.dart';
import 'package:mymediascanner/data/remote/api/google_books/google_books_api.dart';
import 'package:mymediascanner/data/remote/api/open_library/open_library_api.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_api.dart';
import 'package:mymediascanner/data/remote/api/upc/upcitemdb_api.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';

class MetadataRepositoryImpl implements IMetadataRepository {
  MetadataRepositoryImpl({
    required BarcodeCacheDao cacheDao,
    this.tmdbApi,
    this.discogsApi,
    this.googleBooksApi,
    this.openLibraryApi,
    this.upcitemdbApi,
  }) : _cacheDao = cacheDao;

  final BarcodeCacheDao _cacheDao;
  final TmdbApi? tmdbApi;
  final DiscogsApi? discogsApi;
  final GoogleBooksApi? googleBooksApi;
  final OpenLibraryApi? openLibraryApi;
  final UpcitemdbApi? upcitemdbApi;

  @override
  Future<MetadataResult> lookupBarcode(
    String barcode, {
    MediaType? typeHint,
  }) async {
    final barcodeType = BarcodeUtils.detectBarcodeType(barcode);
    final barcodeTypeStr = barcodeType.name;

    // 1. Check cache
    final cached = await _checkCache(barcode);
    if (cached != null) return cached;

    // 2. Route by barcode type + hint
    MetadataResult? result;

    if (BarcodeUtils.isIsbn(barcode)) {
      result = await _lookupBook(barcode, barcodeTypeStr);
    } else if (typeHint == MediaType.film || typeHint == MediaType.tv) {
      result = await _lookupFilm(barcode, barcodeTypeStr);
    } else if (typeHint == MediaType.music) {
      result = await _lookupMusic(barcode, barcodeTypeStr);
    } else {
      // Unknown type — try UPCitemdb first to classify
      result = await _lookupGeneral(barcode, barcodeTypeStr);
    }

    // 3. Fallback to UPCitemdb if specialist returned nothing
    if (result == null && typeHint != null) {
      result = await _lookupUpc(barcode, barcodeTypeStr);
    }

    // 4. Return barcode-only result if all lookups failed
    return result ??
        MetadataResult(
          barcode: barcode,
          barcodeType: barcodeTypeStr,
        );
  }

  Future<MetadataResult?> _checkCache(String barcode) async {
    final cached = await _cacheDao.getByBarcode(barcode);
    if (cached == null) return null;

    final age = DateTime.now().millisecondsSinceEpoch - cached.cachedAt;
    final maxAge = ApiConstants.cacheDurationDays * 24 * 60 * 60 * 1000;
    if (age > maxAge) return null;

    // Re-map from cached response
    // For simplicity, return a basic result from cached data
    try {
      final json = jsonDecode(cached.responseJson) as Map<String, dynamic>;
      return MetadataResult(
        barcode: barcode,
        barcodeType: BarcodeUtils.detectBarcodeType(barcode).name,
        title: json['title'] as String?,
        mediaType: cached.mediaTypeHint != null
            ? MediaType.fromString(cached.mediaTypeHint!)
            : null,
        sourceApis: [cached.sourceApi],
      );
    } catch (_) {
      return null;
    }
  }

  Future<MetadataResult?> _lookupBook(
      String barcode, String barcodeType) async {
    // Try Google Books first
    if (googleBooksApi != null) {
      try {
        final response =
            await googleBooksApi!.searchByIsbn('isbn:$barcode');
        final volume = response.items?.firstOrNull;
        if (volume != null) {
          await _cacheResponse(barcode, 'book', 'google_books', volume.toJson());
          return GoogleBooksMapper.fromVolume(volume, barcode, barcodeType);
        }
      } on Exception catch (_) {
        // Fall through to Open Library
      }
    }

    // Fallback to Open Library
    if (openLibraryApi != null) {
      try {
        final book = await openLibraryApi!.getByIsbn(barcode);
        if (book != null) {
          await _cacheResponse(barcode, 'book', 'open_library', book.toJson());
          return OpenLibraryMapper.fromBook(book, barcode, barcodeType);
        }
      } on Exception catch (_) {
        // Fall through
      }
    }

    return null;
  }

  Future<MetadataResult?> _lookupFilm(
      String barcode, String barcodeType) async {
    if (tmdbApi == null) return null;
    try {
      // TMDB doesn't support barcode search directly — use UPCitemdb
      // to get a title, then search TMDB by title
      final upcResult = await _lookupUpc(barcode, barcodeType);
      if (upcResult?.title == null) return null;

      final response = await tmdbApi!.searchMulti(upcResult!.title!);
      final result = response.results?.firstOrNull;
      if (result != null) {
        await _cacheResponse(barcode, 'film', 'tmdb', result.toJson());
        return TmdbMapper.fromSearchResult(result, barcode, barcodeType);
      }
    } on Exception catch (_) {
      // Fall through
    }
    return null;
  }

  Future<MetadataResult?> _lookupMusic(
      String barcode, String barcodeType) async {
    if (discogsApi == null) return null;
    try {
      final response = await discogsApi!.searchByBarcode(barcode);
      final searchResult = response.results?.firstOrNull;
      if (searchResult?.id != null) {
        final release = await discogsApi!.getRelease(searchResult!.id!);
        await _cacheResponse(barcode, 'music', 'discogs', release.toJson());
        return DiscogsMapper.fromRelease(release, barcode, barcodeType);
      }
    } on Exception catch (_) {
      // Fall through
    }
    return null;
  }

  Future<MetadataResult?> _lookupGeneral(
      String barcode, String barcodeType) async {
    final upcResult = await _lookupUpc(barcode, barcodeType);
    if (upcResult == null) return null;

    // If UPC gave us a type hint, try the specialist API
    if (upcResult.mediaType == MediaType.book) {
      return await _lookupBook(barcode, barcodeType) ?? upcResult;
    }
    if (upcResult.mediaType == MediaType.film ||
        upcResult.mediaType == MediaType.tv) {
      final filmResult = await _lookupFilm(barcode, barcodeType);
      return filmResult ?? upcResult;
    }
    if (upcResult.mediaType == MediaType.music) {
      final musicResult = await _lookupMusic(barcode, barcodeType);
      return musicResult ?? upcResult;
    }

    return upcResult;
  }

  Future<MetadataResult?> _lookupUpc(
      String barcode, String barcodeType) async {
    if (upcitemdbApi == null) return null;
    try {
      final response = await upcitemdbApi!.lookup(barcode);
      final item = response.items?.firstOrNull;
      if (item != null) {
        await _cacheResponse(barcode, null, 'upcitemdb', item.toJson());
        return UpcMapper.fromItem(item, barcode, barcodeType);
      }
    } on Exception catch (_) {
      // Fall through
    }
    return null;
  }

  Future<void> _cacheResponse(
    String barcode,
    String? mediaTypeHint,
    String sourceApi,
    Map<String, dynamic> responseJson,
  ) async {
    try {
      await _cacheDao.upsert(BarcodeCacheTableCompanion(
        barcode: Value(barcode),
        mediaTypeHint: Value(mediaTypeHint),
        responseJson: Value(jsonEncode(responseJson)),
        sourceApi: Value(sourceApi),
        cachedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));
    } on Exception catch (_) {
      // Cache failures are non-critical
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/repositories/metadata_repository_impl.dart
git commit -m "feat: add MetadataRepositoryImpl with tiered lookup"
```

---

## Task 11: Use Cases with Tests

**Files:**
- Create: `lib/domain/usecases/scan_barcode_usecase.dart`
- Create: `lib/domain/usecases/save_media_item_usecase.dart`
- Create: `test/unit/domain/scan_barcode_usecase_test.dart`
- Create: `test/unit/domain/save_media_item_usecase_test.dart`

- [ ] **Step 1: Write scan_barcode_usecase_test.dart**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';
import 'package:mymediascanner/domain/usecases/scan_barcode_usecase.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}
class MockMetadataRepository extends Mock implements IMetadataRepository {}

void main() {
  late ScanBarcodeUseCase useCase;
  late MockMediaItemRepository mockMediaItemRepo;
  late MockMetadataRepository mockMetadataRepo;

  setUp(() {
    mockMediaItemRepo = MockMediaItemRepository();
    mockMetadataRepo = MockMetadataRepository();
    useCase = ScanBarcodeUseCase(
      mediaItemRepository: mockMediaItemRepo,
      metadataRepository: mockMetadataRepo,
    );
  });

  group('ScanBarcodeUseCase', () {
    test('returns metadata result for new barcode', () async {
      const barcode = '9780141036144';
      final expected = MetadataResult(
        barcode: barcode,
        barcodeType: 'isbn13',
        title: '1984',
        mediaType: MediaType.book,
      );

      when(() => mockMediaItemRepo.barcodeExists(barcode))
          .thenAnswer((_) async => false);
      when(() => mockMetadataRepo.lookupBarcode(barcode, typeHint: null))
          .thenAnswer((_) async => expected);

      final result = await useCase.execute(barcode);

      expect(result.metadataResult.title, '1984');
      expect(result.isDuplicate, isFalse);
    });

    test('flags duplicate barcode', () async {
      const barcode = '9780141036144';

      when(() => mockMediaItemRepo.barcodeExists(barcode))
          .thenAnswer((_) async => true);
      when(() => mockMetadataRepo.lookupBarcode(barcode, typeHint: null))
          .thenAnswer((_) async => MetadataResult(
                barcode: barcode,
                barcodeType: 'isbn13',
              ));

      final result = await useCase.execute(barcode);

      expect(result.isDuplicate, isTrue);
    });
  });
}
```

- [ ] **Step 2: Create scan_barcode_usecase.dart**

```dart
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';

class ScanResult {
  const ScanResult({
    required this.metadataResult,
    required this.isDuplicate,
  });

  final MetadataResult metadataResult;
  final bool isDuplicate;
}

class ScanBarcodeUseCase {
  const ScanBarcodeUseCase({
    required IMediaItemRepository mediaItemRepository,
    required IMetadataRepository metadataRepository,
  })  : _mediaItemRepo = mediaItemRepository,
        _metadataRepo = metadataRepository;

  final IMediaItemRepository _mediaItemRepo;
  final IMetadataRepository _metadataRepo;

  Future<ScanResult> execute(
    String barcode, {
    MediaType? typeHint,
  }) async {
    final isDuplicate = await _mediaItemRepo.barcodeExists(barcode);
    final metadata = await _metadataRepo.lookupBarcode(
      barcode,
      typeHint: typeHint,
    );
    return ScanResult(
      metadataResult: metadata,
      isDuplicate: isDuplicate,
    );
  }
}
```

- [ ] **Step 3: Run scan barcode test**

```bash
flutter test test/unit/domain/scan_barcode_usecase_test.dart
```

Expected: All PASS.

- [ ] **Step 4: Write save_media_item_usecase_test.dart**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

void main() {
  late SaveMediaItemUseCase useCase;
  late MockMediaItemRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(MediaItem(
      id: '',
      barcode: '',
      barcodeType: '',
      mediaType: MediaType.unknown,
      title: '',
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    ));
  });

  setUp(() {
    mockRepo = MockMediaItemRepository();
    useCase = SaveMediaItemUseCase(repository: mockRepo);
  });

  group('SaveMediaItemUseCase', () {
    test('creates MediaItem from MetadataResult and saves', () async {
      when(() => mockRepo.save(any())).thenAnswer((_) async {});

      final metadata = MetadataResult(
        barcode: '9780141036144',
        barcodeType: 'isbn13',
        title: '1984',
        mediaType: MediaType.book,
        year: 1949,
      );

      final saved = await useCase.execute(metadata);

      expect(saved.title, '1984');
      expect(saved.barcode, '9780141036144');
      expect(saved.mediaType, MediaType.book);
      expect(saved.id, isNotEmpty);
      verify(() => mockRepo.save(any())).called(1);
    });
  });
}
```

- [ ] **Step 5: Create save_media_item_usecase.dart**

```dart
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:uuid/uuid.dart';

class SaveMediaItemUseCase {
  const SaveMediaItemUseCase({required IMediaItemRepository repository})
      : _repo = repository;

  final IMediaItemRepository _repo;
  static const _uuid = Uuid();

  Future<MediaItem> execute(MetadataResult metadata) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final item = MediaItem(
      id: _uuid.v7(),
      barcode: metadata.barcode,
      barcodeType: metadata.barcodeType,
      mediaType: metadata.mediaType ?? MediaType.unknown,
      title: metadata.title ?? 'Unknown',
      subtitle: metadata.subtitle,
      description: metadata.description,
      coverUrl: metadata.coverUrl,
      year: metadata.year,
      publisher: metadata.publisher,
      format: metadata.format,
      genres: metadata.genres,
      extraMetadata: metadata.extraMetadata,
      sourceApis: metadata.sourceApis,
      dateAdded: now,
      dateScanned: now,
      updatedAt: now,
    );

    await _repo.save(item);
    return item;
  }
}
```

- [ ] **Step 6: Run all tests**

```bash
flutter test test/unit/domain/
```

Expected: All PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/domain/usecases/ test/unit/domain/
git commit -m "feat: add ScanBarcode and SaveMediaItem use cases with tests"
```

---

## Task 12: Settings Provider (API Keys + Secure Storage)

**Files:**
- Create: `lib/presentation/providers/settings_provider.dart`

- [ ] **Step 1: Create settings_provider.dart**

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) {
  return const FlutterSecureStorage();
}

@riverpod
class ApiKeys extends _$ApiKeys {
  static const _tmdbKey = 'api_key_tmdb';
  static const _discogsKey = 'api_key_discogs';
  static const _upcitemdbKey = 'api_key_upcitemdb';

  @override
  Future<Map<String, String?>> build() async {
    final storage = ref.watch(secureStorageProvider);
    return {
      'tmdb': await storage.read(key: _tmdbKey),
      'discogs': await storage.read(key: _discogsKey),
      'upcitemdb': await storage.read(key: _upcitemdbKey),
    };
  }

  Future<void> setTmdbKey(String key) async {
    await ref.read(secureStorageProvider).write(key: _tmdbKey, value: key);
    ref.invalidateSelf();
  }

  Future<void> setDiscogsKey(String key) async {
    await ref.read(secureStorageProvider).write(key: _discogsKey, value: key);
    ref.invalidateSelf();
  }

  Future<void> setUpcitemdbKey(String key) async {
    await ref.read(secureStorageProvider).write(key: _upcitemdbKey, value: key);
    ref.invalidateSelf();
  }
}
```

- [ ] **Step 2: Run code generation and commit**

```bash
dart run build_runner build --delete-conflicting-outputs
git add lib/presentation/providers/settings_provider.dart
git commit -m "feat: add settings provider for API key management"
```

---

## Task 13: Repository Providers

**Files:**
- Modify: `lib/presentation/providers/repository_providers.dart`

- [ ] **Step 1: Populate repository_providers.dart**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mymediascanner/core/constants/api_constants.dart';
import 'package:mymediascanner/data/remote/api/dio_factory.dart';
import 'package:mymediascanner/data/remote/api/discogs/discogs_api.dart';
import 'package:mymediascanner/data/remote/api/google_books/google_books_api.dart';
import 'package:mymediascanner/data/remote/api/open_library/open_library_api.dart';
import 'package:mymediascanner/data/remote/api/tmdb/tmdb_api.dart';
import 'package:mymediascanner/data/remote/api/upc/upcitemdb_api.dart';
import 'package:mymediascanner/data/repositories/media_item_repository_impl.dart';
import 'package:mymediascanner/data/repositories/metadata_repository_impl.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/repositories/i_metadata_repository.dart';
import 'package:mymediascanner/presentation/providers/database_provider.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

part 'repository_providers.g.dart';

@riverpod
IMediaItemRepository mediaItemRepository(Ref ref) {
  return MediaItemRepositoryImpl(
    mediaItemsDao: ref.watch(mediaItemsDaoProvider),
    syncLogDao: ref.watch(syncLogDaoProvider),
  );
}

@riverpod
IMetadataRepository metadataRepository(Ref ref) {
  final apiKeys = ref.watch(apiKeysProvider).valueOrNull ?? {};

  final tmdbKey = apiKeys['tmdb'];
  final discogsKey = apiKeys['discogs'];
  final upcKey = apiKeys['upcitemdb'];

  return MetadataRepositoryImpl(
    cacheDao: ref.watch(barcodeCacheDaoProvider),
    tmdbApi: tmdbKey != null
        ? TmdbApi(DioFactory.createWithBearerToken(
            baseUrl: ApiConstants.tmdbBaseUrl,
            token: tmdbKey,
          ))
        : null,
    discogsApi: discogsKey != null
        ? DiscogsApi(DioFactory.createWithApiKey(
            baseUrl: ApiConstants.discogsBaseUrl,
            apiKeyParam: 'token',
            apiKey: discogsKey,
            defaultHeaders: {'User-Agent': 'MyMediaScanner/1.0'},
          ))
        : null,
    googleBooksApi: GoogleBooksApi(
        DioFactory.create(baseUrl: ApiConstants.googleBooksBaseUrl)),
    openLibraryApi: OpenLibraryApi(),
    upcitemdbApi: upcKey != null
        ? UpcitemdbApi(DioFactory.createWithApiKey(
            baseUrl: ApiConstants.upcItemDbBaseUrl,
            apiKeyParam: 'user_key',
            apiKey: upcKey,
          ))
        : null,
  );
}
```

- [ ] **Step 2: Run code generation and commit**

```bash
dart run build_runner build --delete-conflicting-outputs
git add lib/presentation/providers/repository_providers.dart
git commit -m "feat: add repository providers binding interfaces to implementations"
```

---

## Task 14: Scanner Provider

**Files:**
- Create: `lib/presentation/providers/scanner_provider.dart`

- [ ] **Step 1: Create scanner_provider.dart**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/usecases/scan_barcode_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

part 'scanner_provider.g.dart';

enum ScanState { idle, scanning, lookingUp, found, notFound, duplicate, error }

class ScannerState {
  const ScannerState({
    this.state = ScanState.idle,
    this.result,
    this.error,
  });

  final ScanState state;
  final ScanResult? result;
  final String? error;

  ScannerState copyWith({
    ScanState? state,
    ScanResult? result,
    String? error,
  }) => ScannerState(
    state: state ?? this.state,
    result: result ?? this.result,
    error: error ?? this.error,
  );
}

@riverpod
class Scanner extends _$Scanner {
  @override
  ScannerState build() => const ScannerState();

  Future<void> onBarcodeScanned(
    String barcode, {
    MediaType? typeHint,
  }) async {
    state = const ScannerState(state: ScanState.lookingUp);

    try {
      final useCase = ScanBarcodeUseCase(
        mediaItemRepository: ref.read(mediaItemRepositoryProvider),
        metadataRepository: ref.read(metadataRepositoryProvider),
      );

      final scanResult = await useCase.execute(barcode, typeHint: typeHint);

      if (scanResult.isDuplicate) {
        state = ScannerState(state: ScanState.duplicate, result: scanResult);
      } else if (scanResult.metadataResult.title != null) {
        state = ScannerState(state: ScanState.found, result: scanResult);
      } else {
        state = ScannerState(state: ScanState.notFound, result: scanResult);
      }
    } on Exception catch (e) {
      state = ScannerState(state: ScanState.error, error: e.toString());
    }
  }

  void reset() {
    state = const ScannerState();
  }
}
```

- [ ] **Step 2: Run code generation and commit**

```bash
dart run build_runner build --delete-conflicting-outputs
git add lib/presentation/providers/scanner_provider.dart
git commit -m "feat: add scanner state provider"
```

---

## Task 15: Desktop Scan Screen

**Files:**
- Create: `lib/presentation/screens/scanner/desktop_scan_screen.dart`

- [ ] **Step 1: Create desktop_scan_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

class DesktopScanScreen extends ConsumerStatefulWidget {
  const DesktopScanScreen({super.key});

  @override
  ConsumerState<DesktopScanScreen> createState() => _DesktopScanScreenState();
}

class _DesktopScanScreenState extends ConsumerState<DesktopScanScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSubmitted(String barcode) {
    if (barcode.trim().isEmpty) return;
    ref.read(scannerProvider.notifier).onBarcodeScanned(barcode.trim());
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerProvider);

    ref.listen(scannerProvider, (prev, next) {
      if (next.state == ScanState.found || next.state == ScanState.notFound) {
        context.go('/scan/confirm');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Scan with USB scanner or type barcode',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Barcode / ISBN',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                onSubmitted: _onSubmitted,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\dXx]')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (scannerState.state == ScanState.lookingUp)
              const LoadingIndicator(message: 'Looking up metadata...'),
            if (scannerState.state == ScanState.error)
              Text(
                scannerState.error ?? 'Unknown error',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error),
              ),
            if (scannerState.state == ScanState.duplicate)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('This barcode already exists in your collection.'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              ref.read(scannerProvider.notifier).reset();
                              _controller.clear();
                              _focusNode.requestFocus();
                            },
                            child: const Text('Scan again'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () => context.go('/scan/confirm'),
                            child: const Text('Add anyway'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/screens/scanner/desktop_scan_screen.dart
git commit -m "feat: add desktop barcode scan screen with keyboard-wedge input"
```

---

## Task 16: Update Scanner Screen (Platform Adaptive)

**Files:**
- Modify: `lib/presentation/screens/scanner/scanner_screen.dart`

- [ ] **Step 1: Replace scanner_screen.dart placeholder**

```dart
import 'package:flutter/material.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';
import 'package:mymediascanner/presentation/screens/scanner/desktop_scan_screen.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (PlatformCapability.isDesktop) {
      return const DesktopScanScreen();
    }

    // Mobile camera scanner — requires mobile_scanner package
    // Implemented conditionally to avoid desktop build issues
    return const _MobileScannerPlaceholder();
  }
}

class _MobileScannerPlaceholder extends StatelessWidget {
  const _MobileScannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: const Center(
        child: Text('Camera scanning available on Android/iOS only'),
      ),
    );
  }
}
```

Note: The actual mobile_scanner camera implementation will be added when Android builds are available. The platform check ensures desktop builds don't fail.

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/screens/scanner/scanner_screen.dart
git commit -m "feat: make scanner screen platform-adaptive"
```

---

## Task 17: MetadataConfirmScreen + EditableMetadataForm

**Files:**
- Create: `lib/presentation/screens/metadata_confirm/widgets/editable_metadata_form.dart`
- Create: `lib/presentation/screens/metadata_confirm/metadata_confirm_screen.dart`

- [ ] **Step 1: Create editable_metadata_form.dart**

```dart
import 'package:flutter/material.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

class EditableMetadataForm extends StatefulWidget {
  const EditableMetadataForm({
    super.key,
    required this.initial,
    required this.onSave,
  });

  final MetadataResult initial;
  final void Function(MetadataResult edited) onSave;

  @override
  State<EditableMetadataForm> createState() => _EditableMetadataFormState();
}

class _EditableMetadataFormState extends State<EditableMetadataForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _yearController;
  late final TextEditingController _publisherController;
  late final TextEditingController _formatController;
  late MediaType _mediaType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial.title ?? '');
    _subtitleController =
        TextEditingController(text: widget.initial.subtitle ?? '');
    _descriptionController =
        TextEditingController(text: widget.initial.description ?? '');
    _yearController =
        TextEditingController(text: widget.initial.year?.toString() ?? '');
    _publisherController =
        TextEditingController(text: widget.initial.publisher ?? '');
    _formatController =
        TextEditingController(text: widget.initial.format ?? '');
    _mediaType = widget.initial.mediaType ?? MediaType.unknown;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    _publisherController.dispose();
    _formatController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(widget.initial.copyWith(
      title: _titleController.text.isEmpty ? null : _titleController.text,
      subtitle:
          _subtitleController.text.isEmpty ? null : _subtitleController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      year: int.tryParse(_yearController.text),
      publisher:
          _publisherController.text.isEmpty ? null : _publisherController.text,
      format: _formatController.text.isEmpty ? null : _formatController.text,
      mediaType: _mediaType,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.initial.coverUrl != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.initial.coverUrl!,
                  height: 200,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    size: 100,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          DropdownButtonFormField<MediaType>(
            value: _mediaType,
            decoration: const InputDecoration(labelText: 'Media Type'),
            items: MediaType.values
                .map((t) =>
                    DropdownMenuItem(value: t, child: Text(t.label)))
                .toList(),
            onChanged: (v) => setState(() => _mediaType = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subtitleController,
            decoration: const InputDecoration(labelText: 'Subtitle'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _yearController,
            decoration: const InputDecoration(labelText: 'Year'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _publisherController,
            decoration:
                const InputDecoration(labelText: 'Publisher / Studio / Label'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _formatController,
            decoration: const InputDecoration(
                labelText: 'Format (e.g. Blu-ray, CD, Hardcover)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Save to Collection'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Create metadata_confirm_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/editable_metadata_form.dart';

class MetadataConfirmScreen extends ConsumerWidget {
  const MetadataConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerState = ref.watch(scannerProvider);
    final metadata = scannerState.result?.metadataResult;

    if (metadata == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Confirm')),
        body: const Center(child: Text('No scan result')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Metadata'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(scannerProvider.notifier).reset();
            context.go('/scan');
          },
        ),
      ),
      body: EditableMetadataForm(
        initial: metadata,
        onSave: (edited) async {
          final useCase = SaveMediaItemUseCase(
            repository: ref.read(mediaItemRepositoryProvider),
          );
          await useCase.execute(edited);
          ref.read(scannerProvider.notifier).reset();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${edited.title ?? "Item"} saved'),
              ),
            );
            context.go('/');
          }
        },
      ),
    );
  }
}
```

- [ ] **Step 3: Update router.dart to use MetadataConfirmScreen**

Replace the placeholder `/scan/confirm` route builder with:

```dart
import 'package:mymediascanner/presentation/screens/metadata_confirm/metadata_confirm_screen.dart';

// In the scan branch, replace the confirm route builder:
builder: (context, state) => const MetadataConfirmScreen(),
```

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/screens/metadata_confirm/ lib/app/router.dart
git commit -m "feat: add MetadataConfirmScreen with editable form"
```

---

## Task 18: Verify Slice 2

- [ ] **Step 1: Run full code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 2: Run analysis**

```bash
flutter analyze
```

- [ ] **Step 3: Run all tests**

```bash
flutter test
```

Expected: All tests pass (barcode_utils, DAO, mappers, use cases).

- [ ] **Step 4: Run app on macOS**

```bash
flutter run -d macos
```

Expected: App launches, Scan tab shows desktop barcode input. Typing a barcode + Enter triggers metadata lookup (will fail without API keys configured, but UI flow works).

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: complete Slice 2 — scan and metadata lookup"
```
