import '../entities/income_entry.dart';
import '../entities/expense_entry.dart';
import '../repositories/budget_repository.dart';

class UpdateEntry {
  final BudgetRepository repository;

  UpdateEntry(this.repository);

  Future<void> call({IncomeEntry? income, ExpenseEntry? expense}) async {
    if (income != null) {
      await repository.updateIncome(income);
    } else if (expense != null) {
      await repository.updateExpense(expense);
    }
  }
}
