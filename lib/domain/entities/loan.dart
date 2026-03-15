import 'package:freezed_annotation/freezed_annotation.dart';

part 'loan.freezed.dart';

@freezed
sealed class Loan with _$Loan {
  const Loan._();

  const factory Loan({
    required String id,
    required String mediaItemId,
    required String borrowerId,
    required int lentAt,
    int? returnedAt,
    String? notes,
    required int updatedAt,
    @Default(false) bool deleted,
  }) = _Loan;

  bool get isActive => returnedAt == null;
}
