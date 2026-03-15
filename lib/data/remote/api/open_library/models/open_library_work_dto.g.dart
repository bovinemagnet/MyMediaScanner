// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_library_work_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenLibraryBookDto _$OpenLibraryBookDtoFromJson(
  Map<String, dynamic> json,
) => OpenLibraryBookDto(
  title: json['title'] as String?,
  authors: (json['authors'] as List<dynamic>?)
      ?.map((e) => OpenLibraryAuthorDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  publishers: (json['publishers'] as List<dynamic>?)
      ?.map((e) => OpenLibraryPublisherDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  publishDate: json['publish_date'] as String?,
  numberOfPages: (json['number_of_pages'] as num?)?.toInt(),
  subjects: (json['subjects'] as List<dynamic>?)
      ?.map((e) => OpenLibrarySubjectDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  cover: json['cover'] == null
      ? null
      : OpenLibraryCoverDto.fromJson(json['cover'] as Map<String, dynamic>),
  isbn10: (json['isbn_10'] as List<dynamic>?)?.map((e) => e as String).toList(),
  isbn13: (json['isbn_13'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$OpenLibraryBookDtoToJson(OpenLibraryBookDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'authors': instance.authors,
      'publishers': instance.publishers,
      'publish_date': instance.publishDate,
      'number_of_pages': instance.numberOfPages,
      'subjects': instance.subjects,
      'cover': instance.cover,
      'isbn_10': instance.isbn10,
      'isbn_13': instance.isbn13,
    };

OpenLibraryAuthorDto _$OpenLibraryAuthorDtoFromJson(
  Map<String, dynamic> json,
) => OpenLibraryAuthorDto(name: json['name'] as String?);

Map<String, dynamic> _$OpenLibraryAuthorDtoToJson(
  OpenLibraryAuthorDto instance,
) => <String, dynamic>{'name': instance.name};

OpenLibraryPublisherDto _$OpenLibraryPublisherDtoFromJson(
  Map<String, dynamic> json,
) => OpenLibraryPublisherDto(name: json['name'] as String?);

Map<String, dynamic> _$OpenLibraryPublisherDtoToJson(
  OpenLibraryPublisherDto instance,
) => <String, dynamic>{'name': instance.name};

OpenLibrarySubjectDto _$OpenLibrarySubjectDtoFromJson(
  Map<String, dynamic> json,
) => OpenLibrarySubjectDto(name: json['name'] as String?);

Map<String, dynamic> _$OpenLibrarySubjectDtoToJson(
  OpenLibrarySubjectDto instance,
) => <String, dynamic>{'name': instance.name};

OpenLibraryCoverDto _$OpenLibraryCoverDtoFromJson(Map<String, dynamic> json) =>
    OpenLibraryCoverDto(
      small: json['small'] as String?,
      medium: json['medium'] as String?,
      large: json['large'] as String?,
    );

Map<String, dynamic> _$OpenLibraryCoverDtoToJson(
  OpenLibraryCoverDto instance,
) => <String, dynamic>{
  'small': instance.small,
  'medium': instance.medium,
  'large': instance.large,
};
