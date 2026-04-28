import 'package:json_annotation/json_annotation.dart';

part 'tmdb_account_state_dto.g.dart';

@JsonSerializable()
class TmdbAccountStateDto {
  const TmdbAccountStateDto({
    required this.id,
    this.favorite = false,
    this.watchlist = false,
    this.rated,
  });

  factory TmdbAccountStateDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbAccountStateDtoFromJson(json);

  final int id;
  final bool favorite;
  final bool watchlist;

  /// Either `false` or a map `{ "value": <double> }`.
  @JsonKey(name: 'rated')
  final Object? rated;

  Map<String, dynamic> toJson() => _$TmdbAccountStateDtoToJson(this);

  double? get ratingValue {
    final r = rated;
    if (r is Map && r['value'] is num) {
      return (r['value'] as num).toDouble();
    }
    return null;
  }
}
