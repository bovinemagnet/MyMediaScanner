import 'package:json_annotation/json_annotation.dart';

part 'tmdb_account_dto.g.dart';

@JsonSerializable()
class TmdbAccountDto {
  const TmdbAccountDto({
    required this.id,
    required this.username,
    this.name,
  });

  factory TmdbAccountDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbAccountDtoFromJson(json);

  final int id;
  final String username;
  final String? name;

  Map<String, dynamic> toJson() => _$TmdbAccountDtoToJson(this);
}
