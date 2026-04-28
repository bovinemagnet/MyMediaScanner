import 'package:json_annotation/json_annotation.dart';

part 'tmdb_account_lists_page_dto.g.dart';

/// Response from `GET /account/{id}/lists` (v3).
@JsonSerializable()
class TmdbAccountListsPageDto {
  const TmdbAccountListsPageDto({
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required this.results,
  });

  factory TmdbAccountListsPageDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbAccountListsPageDtoFromJson(json);

  final int page;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'total_results')
  final int totalResults;
  final List<TmdbAccountListSummaryDto> results;

  Map<String, dynamic> toJson() => _$TmdbAccountListsPageDtoToJson(this);
}

@JsonSerializable()
class TmdbAccountListSummaryDto {
  const TmdbAccountListSummaryDto({
    required this.id,
    required this.name,
    this.description,
    this.itemCount,
  });

  factory TmdbAccountListSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbAccountListSummaryDtoFromJson(json);

  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'item_count')
  final int? itemCount;

  Map<String, dynamic> toJson() => _$TmdbAccountListSummaryDtoToJson(this);
}
