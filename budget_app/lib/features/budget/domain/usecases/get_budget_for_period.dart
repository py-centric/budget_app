import '../entities/budget_period.dart';
import '../entities/income_entry.dart';
import '../entities/expense_entry.dart';
import '../repositories/budget_repository.dart';

class GetBudgetForPeriodResult {
  final List<IncomeEntry> incomes;
  final List<ExpenseEntry> expenses;

  GetBudgetForPeriodResult({required this.incomes, required this.expenses});

  double get totalIncome => incomes.fold(0, (sum, item) => sum + item.amount);
  double get totalExpenses => expenses.fold(0, (sum, item) => sum + item.amount);
  double get balance => totalIncome - totalExpenses;
}

class GetBudgetForPeriod {
  final BudgetRepository _repository;

  GetBudgetForPeriod(this._repository);

  Future<GetBudgetForPeriodResult> call(BudgetPeriod period) async {
    final incomes = await _repository.getIncomeForPeriod(period);
    final expenses = await _repository.getExpensesForPeriod(period);

    return GetBudgetForPeriodResult(
      incomes: incomes,
      expenses: expenses,
    );
  }
}
