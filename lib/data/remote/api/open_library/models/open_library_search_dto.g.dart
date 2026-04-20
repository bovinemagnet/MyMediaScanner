// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_library_search_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenLibrarySearchResponseDto _$OpenLibrarySearchResponseDtoFromJson(
  Map<String, dynamic> json,
) => OpenLibrarySearchResponseDto(
  numFound: (json['numFound'] as num?)?.toInt(),
  docs: (json['docs'] as List<dynamic>?)
      ?.map((e) => OpenLibrarySearchDocDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OpenLibrarySearchResponseDtoToJson(
  OpenLibrarySearchResponseDto instance,
) => <String, dynamic>{'numFound': instance.numFound, 'docs': instance.docs};

OpenLibrarySearchDocDto _$OpenLibrarySearchDocDtoFromJson(
  Map<String, dynamic> json,
) => OpenLibrarySearchDocDto(
  key: json['key'] as String?,
  title: json['title'] as String?,
  authorName: (json['author_name'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  firstPublishYear: (json['first_publish_year'] as num?)?.toInt(),
  coverI: (json['cover_i'] as num?)?.toInt(),
  isbn: (json['isbn'] as List<dynamic>?)?.map((e) => e as String).toList(),
  subject: (json['subject'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  publisher: (json['publisher'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$OpenLibrarySearchDocDtoToJson(
  OpenLibrarySearchDocDto instance,
) => <String, dynamic>{
  'key': instance.key,
  'title': instance.title,
  'author_name': instance.authorName,
  'first_publish_year': instance.firstPublishYear,
  'cover_i': instance.coverI,
  'isbn': instance.isbn,
  'subject': instance.subject,
  'publisher': instance.publisher,
};
