import 'package:json_annotation/json_annotation.dart';

part 'discogs_marketplace_stats_dto.g.dart';

@JsonSerializable()
class DiscogsMarketplaceStatsDto {
  const DiscogsMarketplaceStatsDto({
    this.lowestPrice,
    this.numForSale,
    this.blockedFromSale,
  });

  factory DiscogsMarketplaceStatsDto.fromJson(Map<String, dynamic> json) =>
      _$DiscogsMarketplaceStatsDtoFromJson(json);

  @JsonKey(name: 'lowest_price')
  final DiscogsMoneyDto? lowestPrice;

  @JsonKey(name: 'num_for_sale')
  final int? numForSale;

  @JsonKey(name: 'blocked_from_sale')
  final bool? blockedFromSale;

  Map<String, dynamic> toJson() => _$DiscogsMarketplaceStatsDtoToJson(this);
}

@JsonSerializable()
class DiscogsMoneyDto {
  const DiscogsMoneyDto({this.value, this.currency});

  factory DiscogsMoneyDto.fromJson(Map<String, dynamic> json) =>
      _$DiscogsMoneyDtoFromJson(json);

  final double? value;
  final String? currency;

  Map<String, dynamic> toJson() => _$DiscogsMoneyDtoToJson(this);
}
