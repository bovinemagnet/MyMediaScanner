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
