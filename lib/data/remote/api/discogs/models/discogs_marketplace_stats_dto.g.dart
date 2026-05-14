// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discogs_marketplace_stats_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscogsMarketplaceStatsDto _$DiscogsMarketplaceStatsDtoFromJson(
  Map<String, dynamic> json,
) => DiscogsMarketplaceStatsDto(
  lowestPrice: json['lowest_price'] == null
      ? null
      : DiscogsMoneyDto.fromJson(json['lowest_price'] as Map<String, dynamic>),
  numForSale: (json['num_for_sale'] as num?)?.toInt(),
  blockedFromSale: json['blocked_from_sale'] as bool?,
);

Map<String, dynamic> _$DiscogsMarketplaceStatsDtoToJson(
  DiscogsMarketplaceStatsDto instance,
) => <String, dynamic>{
  'lowest_price': instance.lowestPrice,
  'num_for_sale': instance.numForSale,
  'blocked_from_sale': instance.blockedFromSale,
};

DiscogsMoneyDto _$DiscogsMoneyDtoFromJson(Map<String, dynamic> json) =>
    DiscogsMoneyDto(
      value: (json['value'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );

Map<String, dynamic> _$DiscogsMoneyDtoToJson(DiscogsMoneyDto instance) =>
    <String, dynamic>{'value': instance.value, 'currency': instance.currency};
