// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_account_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbAccountDto _$TmdbAccountDtoFromJson(Map<String, dynamic> json) =>
    TmdbAccountDto(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$TmdbAccountDtoToJson(TmdbAccountDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
    };
