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
    int? dueAt,
    String? notes,
    required int updatedAt,
    @Default(false) bool deleted,
  }) = _Loan;

  bool get isActive => returnedAt == null;

  bool get isOverdue =>
      dueAt != null &&
      returnedAt == null &&
      DateTime.now().millisecondsSinceEpoch > dueAt!;

  /// Number of days overdue. Returns 0 if not overdue.
  int get daysOverdue {
    if (!isOverdue) return 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    return ((now - dueAt!) / (1000 * 60 * 60 * 24)).floor();
  }
}
