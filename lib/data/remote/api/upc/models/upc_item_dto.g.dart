// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upc_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpcItemDto _$UpcItemDtoFromJson(Map<String, dynamic> json) => UpcItemDto(
  ean: json['ean'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  brand: json['brand'] as String?,
  category: json['category'] as String?,
  images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$UpcItemDtoToJson(UpcItemDto instance) =>
    <String, dynamic>{
      'ean': instance.ean,
      'title': instance.title,
      'description': instance.description,
      'brand': instance.brand,
      'category': instance.category,
      'images': instance.images,
    };

UpcSearchResponseDto _$UpcSearchResponseDtoFromJson(
  Map<String, dynamic> json,
) => UpcSearchResponseDto(
  code: json['code'] as String?,
  total: (json['total'] as num?)?.toInt(),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => UpcItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UpcSearchResponseDtoToJson(
  UpcSearchResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'total': instance.total,
  'items': instance.items,
};
