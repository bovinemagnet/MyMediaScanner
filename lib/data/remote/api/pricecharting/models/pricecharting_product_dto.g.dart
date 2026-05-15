// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricecharting_product_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceChartingProductDto _$PriceChartingProductDtoFromJson(
  Map<String, dynamic> json,
) => PriceChartingProductDto(
  id: json['id'] as String?,
  productName: json['product-name'] as String?,
  consoleName: json['console-name'] as String?,
  loosePrice: (json['loose-price'] as num?)?.toInt(),
  cibPrice: (json['cib-price'] as num?)?.toInt(),
  newPrice: (json['new-price'] as num?)?.toInt(),
);

Map<String, dynamic> _$PriceChartingProductDtoToJson(
  PriceChartingProductDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'product-name': instance.productName,
  'console-name': instance.consoleName,
  'loose-price': instance.loosePrice,
  'cib-price': instance.cibPrice,
  'new-price': instance.newPrice,
};
