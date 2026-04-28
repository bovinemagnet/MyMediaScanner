// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_account_lists_page_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbAccountListsPageDto _$TmdbAccountListsPageDtoFromJson(
  Map<String, dynamic> json,
) => TmdbAccountListsPageDto(
  page: (json['page'] as num).toInt(),
  totalPages: (json['total_pages'] as num).toInt(),
  totalResults: (json['total_results'] as num).toInt(),
  results: (json['results'] as List<dynamic>)
      .map((e) => TmdbAccountListSummaryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TmdbAccountListsPageDtoToJson(
  TmdbAccountListsPageDto instance,
) => <String, dynamic>{
  'page': instance.page,
  'total_pages': instance.totalPages,
  'total_results': instance.totalResults,
  'results': instance.results,
};

TmdbAccountListSummaryDto _$TmdbAccountListSummaryDtoFromJson(
  Map<String, dynamic> json,
) => TmdbAccountListSummaryDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  itemCount: (json['item_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$TmdbAccountListSummaryDtoToJson(
  TmdbAccountListSummaryDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'item_count': instance.itemCount,
};
