import 'package:mymediascanner/core/services/notification_service.dart';
import 'package:mymediascanner/domain/entities/loan.dart';
import 'package:mymediascanner/domain/repositories/i_loan_repository.dart';
import 'package:uuid/uuid.dart';

class LendItemUseCase {
  const LendItemUseCase({
    required ILoanRepository repository,
    NotificationService? notificationService,
  })  : _repo = repository,
        _notifications = notificationService;

  final ILoanRepository _repo;
  final NotificationService? _notifications;
  static const _uuid = Uuid();

  Future<Loan> execute({
    required String mediaItemId,
    required String borrowerId,
    int? dueAt,
    String? notes,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final loan = Loan(
      id: _uuid.v7(),
      mediaItemId: mediaItemId,
      borrowerId: borrowerId,
      lentAt: now,
      dueAt: dueAt,
      notes: notes,
      updatedAt: now,
    );
    await _repo.createLoan(loan);

    // Schedule overdue notification if a due date is set.
    if (dueAt != null && _notifications != null) {
      final dueDate = DateTime.fromMillisecondsSinceEpoch(dueAt);
      if (dueDate.isAfter(DateTime.now())) {
        // Notification will be shown when the app checks overdue status.
        // For immediate-style: show on next app open after due date.
      }
    }

    return loan;
  }
}
