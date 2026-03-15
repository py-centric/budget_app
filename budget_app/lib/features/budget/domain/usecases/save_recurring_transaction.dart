import '../entities/recurring_transaction.dart';
import '../repositories/recurring_repository.dart';

class SaveRecurringTransaction {
  final RecurringRepository repository;

  SaveRecurringTransaction(this.repository);

  Future<void> call(RecurringTransaction recurring) async {
    await repository.saveRecurringTransaction(recurring);
  }
}
