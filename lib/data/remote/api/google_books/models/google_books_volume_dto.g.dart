// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_books_volume_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleBooksVolumeDto _$GoogleBooksVolumeDtoFromJson(
  Map<String, dynamic> json,
) => GoogleBooksVolumeDto(
  id: json['id'] as String?,
  volumeInfo: json['volumeInfo'] == null
      ? null
      : GoogleBooksVolumeInfoDto.fromJson(
          json['volumeInfo'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$GoogleBooksVolumeDtoToJson(
  GoogleBooksVolumeDto instance,
) => <String, dynamic>{'id': instance.id, 'volumeInfo': instance.volumeInfo};

GoogleBooksVolumeInfoDto _$GoogleBooksVolumeInfoDtoFromJson(
  Map<String, dynamic> json,
) => GoogleBooksVolumeInfoDto(
  title: json['title'] as String?,
  subtitle: json['subtitle'] as String?,
  authors: (json['authors'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  publisher: json['publisher'] as String?,
  publishedDate: json['publishedDate'] as String?,
  description: json['description'] as String?,
  pageCount: (json['pageCount'] as num?)?.toInt(),
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  imageLinks: json['imageLinks'] == null
      ? null
      : GoogleBooksImageLinksDto.fromJson(
          json['imageLinks'] as Map<String, dynamic>,
        ),
  industryIdentifiers: (json['industryIdentifiers'] as List<dynamic>?)
      ?.map((e) => GoogleBooksIdentifierDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  averageRating: (json['averageRating'] as num?)?.toDouble(),
  ratingsCount: (json['ratingsCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$GoogleBooksVolumeInfoDtoToJson(
  GoogleBooksVolumeInfoDto instance,
) => <String, dynamic>{
  'title': instance.title,
  'subtitle': instance.subtitle,
  'authors': instance.authors,
  'publisher': instance.publisher,
  'publishedDate': instance.publishedDate,
  'description': instance.description,
  'pageCount': instance.pageCount,
  'categories': instance.categories,
  'imageLinks': instance.imageLinks,
  'industryIdentifiers': instance.industryIdentifiers,
  'averageRating': instance.averageRating,
  'ratingsCount': instance.ratingsCount,
};

GoogleBooksImageLinksDto _$GoogleBooksImageLinksDtoFromJson(
  Map<String, dynamic> json,
) => GoogleBooksImageLinksDto(
  thumbnail: json['thumbnail'] as String?,
  smallThumbnail: json['smallThumbnail'] as String?,
);

Map<String, dynamic> _$GoogleBooksImageLinksDtoToJson(
  GoogleBooksImageLinksDto instance,
) => <String, dynamic>{
  'thumbnail': instance.thumbnail,
  'smallThumbnail': instance.smallThumbnail,
};

GoogleBooksIdentifierDto _$GoogleBooksIdentifierDtoFromJson(
  Map<String, dynamic> json,
) => GoogleBooksIdentifierDto(
  type: json['type'] as String?,
  identifier: json['identifier'] as String?,
);

Map<String, dynamic> _$GoogleBooksIdentifierDtoToJson(
  GoogleBooksIdentifierDto instance,
) => <String, dynamic>{
  'type': instance.type,
  'identifier': instance.identifier,
};

GoogleBooksSearchResponseDto _$GoogleBooksSearchResponseDtoFromJson(
  Map<String, dynamic> json,
) => GoogleBooksSearchResponseDto(
  totalItems: (json['totalItems'] as num?)?.toInt(),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => GoogleBooksVolumeDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GoogleBooksSearchResponseDtoToJson(
  GoogleBooksSearchResponseDto instance,
) => <String, dynamic>{
  'totalItems': instance.totalItems,
  'items': instance.items,
};
