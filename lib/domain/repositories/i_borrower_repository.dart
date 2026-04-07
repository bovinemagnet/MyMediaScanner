import 'package:mymediascanner/domain/entities/borrower.dart';

abstract interface class IBorrowerRepository {
  Stream<List<Borrower>> watchAll();
  Future<Borrower?> getById(String id);
  Future<void> save(Borrower borrower);
  Future<void> update(Borrower borrower);
  Future<void> softDelete(String id);
}
