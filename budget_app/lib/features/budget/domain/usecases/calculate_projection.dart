import '../entities/recurring_transaction.dart';
import '../entities/projection_point.dart';
import '../../data/models/user_settings.dart';
import '../repositories/budget_repository.dart';
import '../repositories/recurring_repository.dart';
import 'package:budget_app/core/utils/date_grouping_utils.dart';
import 'package:budget_app/core/utils/recurrence_calculator.dart';
import '../entities/income_entry.dart';
import '../entities/expense_entry.dart';

class CalculateProjection {
  final BudgetRepository repository;
  final RecurringRepository recurringRepository;

  CalculateProjection(this.repository, this.recurringRepository);

  Future<List<ProjectionPoint>> call({
    required UserSettings settings,
    required bool showActuals,
    required DateTime today,
    String? budgetId,
  }) async {
    // 1. Determine date range
    DateTime startDate;
    DateTime endDate;
    
    // Normalize today to start of day
    final normalizedToday = DateTime(today.year, today.month, today.day);

    switch (settings.defaultProjectionHorizon) {
      case '30_DAYS':
        startDate = showActuals ? normalizedToday.subtract(const Duration(days: 15)) : normalizedToday;
        endDate = normalizedToday.add(const Duration(days: 30));
        break;
      case '90_DAYS':
        startDate = showActuals ? normalizedToday.subtract(const Duration(days: 30)) : normalizedToday;
        endDate = normalizedToday.add(const Duration(days: 90));
        break;
      case 'MONTH':
      default:
        startDate = showActuals ? DateTime(normalizedToday.year, normalizedToday.month, 1) : normalizedToday;
        endDate = DateTime(normalizedToday.year, normalizedToday.month + 1, 0); // Last day of month
        break;
    }

    // 2. Calculate starting balance before startDate
    List<IncomeEntry> filteredPastIncome;
    List<ExpenseEntry> filteredPastExpenses;
    
    if (budgetId != null) {
      final allIncome = await repository.getIncomeForBudget(budgetId);
      final allExpenses = await repository.getExpensesForBudget(budgetId);
      filteredPastIncome = allIncome.where((i) => i.date.isBefore(startDate)).toList();
      filteredPastExpenses = allExpenses.where((e) => e.date.isBefore(startDate)).toList();
    } else {
      filteredPastIncome = await repository.getIncomeBefore(startDate);
      filteredPastExpenses = await repository.getExpensesBefore(startDate);
    }
    
    double startingBalance = 0;
    for (var inc in filteredPastIncome) {
      startingBalance += inc.amount;
    }
    for (var exp in filteredPastExpenses) {
      startingBalance -= exp.amount;
    }

    // 3. Fetch recurring templates and overrides
    List<RecurringTransaction> recurringTemplates = await recurringRepository.getAllRecurringTransactions();
    if (budgetId != null) {
      recurringTemplates = recurringTemplates.where((t) => t.budgetId == budgetId).toList();
    }
    final allOverrides = await recurringRepository.getAllOverrides();

    // 4. Fetch one-off transactions in range
    List<IncomeEntry> rangeIncome;
    List<ExpenseEntry> rangeExpenses;
    
    final rangeEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    if (budgetId != null) {
      final allIncome = await repository.getIncomeForBudget(budgetId);
      final allExpenses = await repository.getExpensesForBudget(budgetId);
      rangeIncome = allIncome.where((i) => !i.date.isBefore(startDate) && !i.date.isAfter(rangeEnd)).toList();
      rangeExpenses = allExpenses.where((e) => !e.date.isBefore(startDate) && !e.date.isAfter(rangeEnd)).toList();
    } else {
      rangeIncome = await repository.getIncomeForDateRange(startDate, rangeEnd);
      rangeExpenses = await repository.getExpensesForDateRange(startDate, rangeEnd);
    }

    // Group one-off transactions by day string "YYYY-MM-DD"
    final Map<String, double> dailyIncomeActual = {};
    final Map<String, double> dailyIncomePotential = {};
    for (var inc in rangeIncome) {
      final key = _dateKey(inc.date);
      if (inc.isPotential) {
        dailyIncomePotential[key] = (dailyIncomePotential[key] ?? 0) + inc.amount;
      } else {
        dailyIncomeActual[key] = (dailyIncomeActual[key] ?? 0) + inc.amount;
      }
    }

    final Map<String, double> dailyExpenseActual = {};
    final Map<String, double> dailyExpensePotential = {};
    for (var exp in rangeExpenses) {
      final key = _dateKey(exp.date);
      if (exp.isPotential) {
        dailyExpensePotential[key] = (dailyExpensePotential[key] ?? 0) + exp.amount;
      } else {
        dailyExpenseActual[key] = (dailyExpenseActual[key] ?? 0) + exp.amount;
      }
    }

    // 5. Pre-calculate all recurring instances in the entire horizon
    final Map<String, List<RecurringInstance>> recurringByDay = {};
    for (final template in recurringTemplates) {
      final instances = RecurrenceCalculator.getInstancesInRange(
        template: template,
        overrides: allOverrides.where((o) => o.recurringTransactionId == template.id).toList(),
        start: startDate,
        end: endDate,
      );
      for (final instance in instances) {
        final key = _dateKey(instance.date);
        recurringByDay.putIfAbsent(key, () => []).add(instance);
      }
    }

    // 6. Build projection points
    final List<ProjectionPoint> points = [];
    double currentActualBalance = startingBalance;
    double currentPotentialBalance = startingBalance;
    DateTime currentDay = startDate;

    while (currentDay.isBefore(endDate) || currentDay.isAtSameMomentAs(endDate)) {
      final key = _dateKey(currentDay);
      
      // One-off net change
      final incActual = dailyIncomeActual[key] ?? 0;
      final expActual = dailyExpenseActual[key] ?? 0;
      final incPotential = dailyIncomePotential[key] ?? 0;
      final expPotential = dailyExpensePotential[key] ?? 0;
      
      double dayNetChangeActual = incActual - expActual;
      double dayNetChangePotential = dayNetChangeActual + (incPotential - expPotential);

      // Recurring net change (Assume all recurring are actual for now, or could be potential)
      final recurringInstances = recurringByDay[key] ?? [];
      for (final instance in recurringInstances) {
        final change = templateType(recurringTemplates, instance.templateId) == 'INCOME' 
            ? instance.amount 
            : -instance.amount;
        dayNetChangeActual += change;
        dayNetChangePotential += change;
      }

      currentActualBalance += dayNetChangeActual;
      currentPotentialBalance += dayNetChangePotential;

      // Check if this day is the end of the week according to settings
      final weekEndingDate = DateGroupingUtils.getWeekEndingDate(currentDay, settings.weekStartDay);
      final isWeekEnding = currentDay.isAtSameMomentAs(weekEndingDate);

      points.add(ProjectionPoint(
        date: currentDay,
        balance: currentActualBalance,
        netChange: dayNetChangeActual,
        actualBalance: currentActualBalance,
        potentialBalance: currentPotentialBalance,
        netChangeActual: dayNetChangeActual,
        netChangePotential: dayNetChangePotential,
        isWeekEnding: isWeekEnding,
        recurringInstances: recurringInstances,
      ));

      currentDay = currentDay.add(const Duration(days: 1));
    }

    return points;
  }

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String templateType(List<RecurringTransaction> templates, String id) {
    return templates.firstWhere((t) => t.id == id).type;
  }
}
