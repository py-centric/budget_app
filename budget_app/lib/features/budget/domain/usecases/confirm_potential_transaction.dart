import '../entities/income_entry.dart';
import '../entities/expense_entry.dart';
import '../repositories/budget_repository.dart';

class ConfirmPotentialTransaction {
  final BudgetRepository repository;

  ConfirmPotentialTransaction(this.repository);

  Future<void> call({String? incomeId, String? expenseId}) async {
    if (incomeId != null) {
      final income = (await repository.getAllIncome()).firstWhere((i) => i.id == incomeId);
      final confirmed = IncomeEntry(
        id: income.id,
        budgetId: income.budgetId,
        amount: income.amount,
        categoryId: income.categoryId,
        description: income.description,
        date: income.date,
        periodMonth: income.periodMonth,
        periodYear: income.periodYear,
        categoryName: income.categoryName,
        categoryIcon: income.categoryIcon,
        isPotential: false,
      );
      await repository.updateIncome(confirmed);
    } else if (expenseId != null) {
      final expense = (await repository.getAllExpenses()).firstWhere((e) => e.id == expenseId);
      final confirmed = ExpenseEntry(
        id: expense.id,
        budgetId: expense.budgetId,
        amount: expense.amount,
        categoryId: expense.categoryId,
        description: expense.description,
        date: expense.date,
        periodMonth: expense.periodMonth,
        periodYear: expense.periodYear,
        categoryName: expense.categoryName,
        categoryIcon: expense.categoryIcon,
        isPotential: false,
      );
      await repository.updateExpense(confirmed);
    }
  }
}
