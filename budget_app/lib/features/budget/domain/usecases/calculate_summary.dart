import '../entities/income_entry.dart';
import '../entities/expense_entry.dart';
import '../entities/budget_period.dart';
import '../repositories/budget_repository.dart';

class BudgetSummary {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final double totalPotentialIncome;
  final double totalPotentialExpenses;
  final List<IncomeEntry> incomeEntries;
  final List<ExpenseEntry> expenseEntries;
  final int missedPotentialCount;

  const BudgetSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.totalPotentialIncome,
    required this.totalPotentialExpenses,
    required this.incomeEntries,
    required this.expenseEntries,
    this.missedPotentialCount = 0,
  });
}

class CalculateSummary {
  final BudgetRepository repository;

  CalculateSummary(this.repository);

  Future<BudgetSummary> call({BudgetPeriod? period, String? budgetId}) async {
    List<IncomeEntry> incomeEntries;
    List<ExpenseEntry> expenseEntries;

    if (budgetId != null) {
      incomeEntries = await repository.getIncomeForBudget(budgetId);
      expenseEntries = await repository.getExpensesForBudget(budgetId);
    } else if (period != null) {
      incomeEntries = await repository.getIncomeForPeriod(period);
      expenseEntries = await repository.getExpensesForPeriod(period);
    } else {
      incomeEntries = await repository.getAllIncome();
      expenseEntries = await repository.getAllExpenses();
    }

    final actualIncome = incomeEntries.where((e) => !e.isPotential).toList();
    final actualExpenses = expenseEntries.where((e) => !e.isPotential).toList();

    final totalIncome = actualIncome.fold<double>(
      0,
      (sum, entry) => sum + entry.amount,
    );

    final totalExpenses = actualExpenses.fold<double>(
      0,
      (sum, entry) => sum + entry.amount,
    );

    final totalPotentialIncome = incomeEntries.fold<double>(
      0,
      (sum, entry) => sum + entry.amount,
    );

    final totalPotentialExpenses = expenseEntries.fold<double>(
      0,
      (sum, entry) => sum + entry.amount,
    );

    final balance = totalIncome - totalExpenses;

    // FR-009: Identify missed potential transactions (past dates)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int missedCount = 0;
    missedCount += incomeEntries.where((e) => e.isPotential && e.date.isBefore(today)).length;
    missedCount += expenseEntries.where((e) => e.isPotential && e.date.isBefore(today)).length;

    return BudgetSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      balance: balance,
      totalPotentialIncome: totalPotentialIncome,
      totalPotentialExpenses: totalPotentialExpenses,
      incomeEntries: incomeEntries,
      expenseEntries: expenseEntries,
      missedPotentialCount: missedCount,
    );
  }
}
