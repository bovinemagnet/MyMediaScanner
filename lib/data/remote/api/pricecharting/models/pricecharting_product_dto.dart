import 'package:json_annotation/json_annotation.dart';

part 'pricecharting_product_dto.g.dart';

/// Subset of the PriceCharting `/api/product` response that we use.
///
/// Prices are reported in US cents as integers. The `loose-price`,
/// `cib-price` (complete-in-box), and `new-price` fields are the three
/// most commonly looked-at quotes; we surface the CIB price as the
/// canonical "current value" and fall back to loose if absent.
@JsonSerializable()
class PriceChartingProductDto {
  const PriceChartingProductDto({
    this.id,
    this.productName,
    this.consoleName,
    this.loosePrice,
    this.cibPrice,
    this.newPrice,
  });

  factory PriceChartingProductDto.fromJson(Map<String, dynamic> json) =>
      _$PriceChartingProductDtoFromJson(json);

  final String? id;

  @JsonKey(name: 'product-name')
  final String? productName;

  @JsonKey(name: 'console-name')
  final String? consoleName;

  @JsonKey(name: 'loose-price')
  final int? loosePrice;

  @JsonKey(name: 'cib-price')
  final int? cibPrice;

  @JsonKey(name: 'new-price')
  final int? newPrice;

  Map<String, dynamic> toJson() => _$PriceChartingProductDtoToJson(this);
}
