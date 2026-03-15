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
