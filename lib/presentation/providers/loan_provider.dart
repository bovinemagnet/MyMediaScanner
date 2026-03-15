import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/borrower.dart';
import 'package:mymediascanner/domain/entities/loan.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

final allBorrowersProvider = StreamProvider<List<Borrower>>((ref) {
  return ref.watch(borrowerRepositoryProvider).watchAll();
});

final activeLoanForItemProvider =
    StreamProvider.family<Loan?, String>((ref, mediaItemId) {
  return ref.watch(loanRepositoryProvider).watchActiveLoanForItem(mediaItemId);
});

final activeLoansProvider = StreamProvider<List<Loan>>((ref) {
  return ref.watch(loanRepositoryProvider).watchActiveLoans();
});

/// Set of media item IDs that currently have active loans.
final lentItemIdsProvider = StreamProvider<Set<String>>((ref) {
  return ref
      .watch(loanRepositoryProvider)
      .watchActiveLoans()
      .map((loans) => loans.map((l) => l.mediaItemId).toSet());
});

final loansForItemProvider =
    StreamProvider.family<List<Loan>, String>((ref, mediaItemId) {
  return ref.watch(loanRepositoryProvider).watchLoansForItem(mediaItemId);
});
