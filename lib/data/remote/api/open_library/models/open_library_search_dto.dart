import 'package:json_annotation/json_annotation.dart';

part 'open_library_search_dto.g.dart';

/// Response shape for Open Library's `/search.json` endpoint. The full
/// response has many more fields; we only deserialise the ones we actually
/// read so schema drift on Open Library's side is non-fatal.
@JsonSerializable()
class OpenLibrarySearchResponseDto {
  const OpenLibrarySearchResponseDto({this.numFound, this.docs});

  factory OpenLibrarySearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OpenLibrarySearchResponseDtoFromJson(json);

  @JsonKey(name: 'numFound')
  final int? numFound;
  final List<OpenLibrarySearchDocDto>? docs;

  Map<String, dynamic> toJson() => _$OpenLibrarySearchResponseDtoToJson(this);
}

/// A single work summary from Open Library's search index.
@JsonSerializable()
class OpenLibrarySearchDocDto {
  const OpenLibrarySearchDocDto({
    this.key,
    this.title,
    this.authorName,
    this.firstPublishYear,
    this.coverI,
    this.isbn,
    this.subject,
    this.publisher,
  });

  factory OpenLibrarySearchDocDto.fromJson(Map<String, dynamic> json) =>
      _$OpenLibrarySearchDocDtoFromJson(json);

  /// Work key (e.g. `/works/OL27479W`). Stable identifier; we use it as the
  /// `MetadataCandidate.sourceId` for disambiguation.
  final String? key;
  final String? title;
  @JsonKey(name: 'author_name')
  final List<String>? authorName;
  @JsonKey(name: 'first_publish_year')
  final int? firstPublishYear;

  /// Cover image ID; cover URL is `https://covers.openlibrary.org/b/id/{coverI}-L.jpg`.
  @JsonKey(name: 'cover_i')
  final int? coverI;
  final List<String>? isbn;
  final List<String>? subject;
  final List<String>? publisher;

  Map<String, dynamic> toJson() => _$OpenLibrarySearchDocDtoToJson(this);

  /// Large cover URL derived from [coverI], or `null` when no cover is
  /// indexed for this work.
  String? get coverUrl => coverI == null
      ? null
      : 'https://covers.openlibrary.org/b/id/$coverI-L.jpg';
}
