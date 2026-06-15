import 'package:uuid/uuid.dart';
import '../entities/budget.dart';
import '../entities/budget_period.dart';
import '../entities/income_entry.dart';
import '../entities/expense_entry.dart';
import '../repositories/budget_repository.dart';
import 'package:budget_app/core/utils/date_utils.dart';

class DuplicateBudget {
  final BudgetRepository _repository;
  final Uuid _uuid = const Uuid();

  DuplicateBudget(this._repository);

  Future<Budget> call({
    required Budget sourceBudget,
    required BudgetPeriod targetPeriod,
    required String newName,
    bool includeTransactions = false,
  }) async {
    // Create new budget
    final newBudget = Budget(
      id: _uuid.v4(),
      name: newName.isEmpty ? '${sourceBudget.name} - Copy' : newName,
      periodMonth: targetPeriod.month,
      periodYear: targetPeriod.year,
      isActive: true, // Auto-select new budget
    );

    await _repository.addBudget(newBudget);

    // Note: Budget goals are tied to budget_id, but the repository does not yet expose
    // getBudgetGoalsForBudget. Categories are global, so they are not duplicated.
    // Future enhancement: add BudgetGoal duplication when the repository supports it.

    if (includeTransactions) {
      final sourceIncome = await _repository.getIncomeForBudget(
        sourceBudget.id,
      );
      final sourceExpenses = await _repository.getExpensesForBudget(
        sourceBudget.id,
      );

      for (var income in sourceIncome) {
        final shiftedDate = DateUtilsHelper.shiftDateToPeriod(
          income.date,
          targetPeriod.year,
          targetPeriod.month,
        );
        final newIncome = IncomeEntry(
          id: _uuid.v4(),
          budgetId: newBudget.id,
          amount: income.amount,
          description: income.description,
          date: shiftedDate,
          categoryId: income.categoryId,
        );
        await _repository.addIncome(newIncome);
      }

      for (var expense in sourceExpenses) {
        final shiftedDate = DateUtilsHelper.shiftDateToPeriod(
          expense.date,
          targetPeriod.year,
          targetPeriod.month,
        );
        final newExpense = ExpenseEntry(
          id: _uuid.v4(),
          budgetId: newBudget.id,
          amount: expense.amount,
          description: expense.description,
          date: shiftedDate,
          categoryId: expense.categoryId,
        );
        await _repository.addExpense(newExpense);
      }
    }

    return newBudget;
  }
}
