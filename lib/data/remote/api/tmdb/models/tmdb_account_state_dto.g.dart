// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_account_state_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbAccountStateDto _$TmdbAccountStateDtoFromJson(Map<String, dynamic> json) =>
    TmdbAccountStateDto(
      id: (json['id'] as num).toInt(),
      favorite: json['favorite'] as bool? ?? false,
      watchlist: json['watchlist'] as bool? ?? false,
      rated: json['rated'],
    );

Map<String, dynamic> _$TmdbAccountStateDtoToJson(
  TmdbAccountStateDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'favorite': instance.favorite,
  'watchlist': instance.watchlist,
  'rated': instance.rated,
};
