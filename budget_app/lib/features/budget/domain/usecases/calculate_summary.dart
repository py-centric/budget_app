import '../entities/income_entry.dart';
import '../entities/expense_entry.dart';
import '../entities/budget_period.dart';
import '../repositories/budget_repository.dart';
import '../repositories/recurring_repository.dart';
import 'package:budget_app/core/utils/recurrence_calculator.dart';

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
  final RecurringRepository? recurringRepository;

  CalculateSummary(this.repository, {this.recurringRepository});

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

    // Add recurring transactions that fall within the period
    if (recurringRepository != null) {
      final recurringTemplates = await recurringRepository!
          .getAllRecurringTransactions();
      final filteredTemplates = budgetId != null
          ? recurringTemplates.where((t) => t.budgetId == budgetId).toList()
          : recurringTemplates;
      final overrides = await recurringRepository!.getAllOverrides();

      // Determine date range
      DateTime startDate;
      DateTime endDate = DateTime.now();

      if (period != null) {
        startDate = period.startDate;
        endDate = period.endDate;
      } else {
        // Default to current month
        final now = DateTime.now();
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
      }

      // Generate recurring instances
      for (final template in filteredTemplates) {
        final instances = RecurrenceCalculator.getInstancesInRange(
          template: template,
          overrides: overrides
              .where((o) => o.recurringTransactionId == template.id)
              .toList(),
          start: startDate,
          end: endDate,
        );

        for (final instance in instances) {
          if (template.type == 'INCOME') {
            incomeEntries.add(
              IncomeEntry(
                id: instance.templateId,
                budgetId: template.budgetId,
                amount: instance.amount,
                categoryId: instance.categoryId,
                description: instance.description,
                date: instance.date,
                isPotential: instance.isOverride ? false : true,
              ),
            );
          } else {
            expenseEntries.add(
              ExpenseEntry(
                id: instance.templateId,
                budgetId: template.budgetId,
                amount: instance.amount,
                categoryId: instance.categoryId,
                description: instance.description,
                date: instance.date,
                isPotential: instance.isOverride ? false : true,
              ),
            );
          }
        }
      }
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
    missedCount += incomeEntries
        .where((e) => e.isPotential && e.date.isBefore(today))
        .length;
    missedCount += expenseEntries
        .where((e) => e.isPotential && e.date.isBefore(today))
        .length;

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
