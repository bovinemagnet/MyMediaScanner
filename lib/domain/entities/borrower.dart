import 'package:freezed_annotation/freezed_annotation.dart';

part 'borrower.freezed.dart';

@freezed
sealed class Borrower with _$Borrower {
  const factory Borrower({
    required String id,
    required String name,
    String? email,
    String? phone,
    String? notes,
    required int updatedAt,
    @Default(false) bool deleted,
  }) = _Borrower;
}
