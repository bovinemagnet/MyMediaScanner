import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/loan.dart';

void main() {
  group('Loan entity', () {
    Loan makeLoan({int? returnedAt, int? dueAt}) {
      return Loan(
        id: 'loan-1',
        mediaItemId: 'item-1',
        borrowerId: 'borrower-1',
        lentAt: DateTime(2026, 1, 1).millisecondsSinceEpoch,
        returnedAt: returnedAt,
        dueAt: dueAt,
        updatedAt: DateTime(2026, 1, 1).millisecondsSinceEpoch,
      );
    }

    group('isActive', () {
      test('returns true when returnedAt is null', () {
        final loan = makeLoan();
        expect(loan.isActive, isTrue);
      });

      test('returns false when returnedAt is set', () {
        final loan = makeLoan(
          returnedAt: DateTime(2026, 2, 1).millisecondsSinceEpoch,
        );
        expect(loan.isActive, isFalse);
      });
    });

    group('isOverdue', () {
      test('returns false when dueAt is null', () {
        final loan = makeLoan();
        expect(loan.isOverdue, isFalse);
      });

      test('returns false when loan is returned even if dueAt is in the past',
          () {
        final loan = makeLoan(
          dueAt: DateTime(2026, 1, 15).millisecondsSinceEpoch,
          returnedAt: DateTime(2026, 1, 20).millisecondsSinceEpoch,
        );
        expect(loan.isOverdue, isFalse);
      });

      test('returns true when active and dueAt is in the past', () {
        final pastDue =
            DateTime.now().subtract(const Duration(days: 5)).millisecondsSinceEpoch;
        final loan = makeLoan(dueAt: pastDue);
        expect(loan.isOverdue, isTrue);
      });

      test('returns false when active and dueAt is in the future', () {
        final futureDue =
            DateTime.now().add(const Duration(days: 5)).millisecondsSinceEpoch;
        final loan = makeLoan(dueAt: futureDue);
        expect(loan.isOverdue, isFalse);
      });
    });

    group('daysOverdue', () {
      test('returns 0 when not overdue', () {
        final loan = makeLoan();
        expect(loan.daysOverdue, 0);
      });

      test('returns positive number of days when overdue', () {
        final pastDue =
            DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch;
        final loan = makeLoan(dueAt: pastDue);
        expect(loan.daysOverdue, greaterThanOrEqualTo(3));
      });
    });
  });
}
