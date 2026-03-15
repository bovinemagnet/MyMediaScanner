import 'package:freezed_annotation/freezed_annotation.dart';

part 'shelf.freezed.dart';

@freezed
sealed class Shelf with _$Shelf {
  const factory Shelf({
    required String id,
    required String name,
    String? description,
    @Default(0) int sortOrder,
    required int updatedAt,
    @Default(false) bool deleted,
  }) = _Shelf;
}
