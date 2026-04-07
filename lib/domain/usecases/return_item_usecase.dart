import 'package:mymediascanner/core/services/notification_service.dart';
import 'package:mymediascanner/domain/repositories/i_loan_repository.dart';

class ReturnItemUseCase {
  const ReturnItemUseCase({
    required ILoanRepository repository,
    NotificationService? notificationService,
  })  : _repo = repository,
        _notifications = notificationService;

  final ILoanRepository _repo;
  final NotificationService? _notifications;

  Future<void> execute(String loanId) async {
    // Cancel any overdue notification for this loan.
    _notifications?.cancelNotification(loanId.hashCode);
    await _repo.returnItem(loanId);
  }
}
