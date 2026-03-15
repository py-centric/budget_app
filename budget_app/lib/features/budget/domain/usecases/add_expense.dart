import '../entities/expense_entry.dart';
import '../repositories/budget_repository.dart';

class AddExpense {
  final BudgetRepository repository;

  AddExpense(this.repository);

  Future<void> call(ExpenseEntry expense) async {
    await repository.addExpense(expense);
  }
}
