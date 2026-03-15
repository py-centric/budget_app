import '../repositories/budget_repository.dart';

enum EntryType { income, expense }

class DeleteEntry {
  final BudgetRepository repository;

  DeleteEntry(this.repository);

  Future<void> call(String id, EntryType type) async {
    if (type == EntryType.income) {
      await repository.deleteIncome(id);
    } else {
      await repository.deleteExpense(id);
    }
  }
}
