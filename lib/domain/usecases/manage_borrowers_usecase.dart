import 'package:mymediascanner/domain/entities/borrower.dart';
import 'package:mymediascanner/domain/repositories/i_borrower_repository.dart';
import 'package:uuid/uuid.dart';

class ManageBorrowersUseCase {
  const ManageBorrowersUseCase({required IBorrowerRepository repository})
      : _repo = repository;

  final IBorrowerRepository _repo;
  static const _uuid = Uuid();

  Future<Borrower> createBorrower({
    required String name,
    String? email,
    String? phone,
    String? notes,
  }) async {
    final borrower = Borrower(
      id: _uuid.v7(),
      name: name,
      email: email,
      phone: phone,
      notes: notes,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _repo.save(borrower);
    return borrower;
  }

  Future<void> deleteBorrower(String id) => _repo.softDelete(id);

  Stream<List<Borrower>> watchAll() => _repo.watchAll();
}
