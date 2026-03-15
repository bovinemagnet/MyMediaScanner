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
