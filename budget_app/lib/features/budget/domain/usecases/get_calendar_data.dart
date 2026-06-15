import '../entities/category.dart';
import '../entities/expense_entry.dart';
import '../entities/income_entry.dart';
import '../repositories/budget_repository.dart';

/// Result type bundling the data needed by the calendar feature.
class CalendarMonthData {
  final List<IncomeEntry> incomes;
  final List<ExpenseEntry> expenses;
  final List<Category> categories;

  const CalendarMonthData({
    required this.incomes,
    required this.expenses,
    required this.categories,
  });
}

/// Use case/adapter that wraps [BudgetRepository] calls for the calendar
/// feature, preventing the calendar presentation layer from depending
/// directly on the budget data layer.
class GetCalendarData {
  final BudgetRepository _repository;

  GetCalendarData(this._repository);

  /// Fetches all incomes, expenses, and categories for the given month.
  Future<CalendarMonthData> forMonth(int year, int month) async {
    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 0, 23, 59, 59);

    final allIncomes = await _repository.getAllIncome();
    final allExpenses = await _repository.getAllExpenses();
    final categories = await _repository.getCategories();

    final monthIncomes = allIncomes.where((i) {
      return i.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
          i.date.isBefore(monthEnd.add(const Duration(days: 1)));
    }).toList();

    final monthExpenses = allExpenses.where((e) {
      return e.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
          e.date.isBefore(monthEnd.add(const Duration(days: 1)));
    }).toList();

    return CalendarMonthData(
      incomes: monthIncomes,
      expenses: monthExpenses,
      categories: categories,
    );
  }

  /// Returns total expense amounts before [date].
  Future<double> getTotalExpensesBefore(DateTime date) async {
    final expenses = await _repository.getExpensesBefore(date);
    return expenses.fold<double>(0, (sum, e) => sum + e.amount);
  }

  /// Returns total income amounts before [date].
  Future<double> getTotalIncomesBefore(DateTime date) async {
    final incomes = await _repository.getIncomeBefore(date);
    return incomes.fold<double>(0, (sum, i) => sum + i.amount);
  }

  /// Returns all expenses before [date] as a list for the calendar bloc.
  Future<List<ExpenseEntry>> getExpensesBefore(DateTime date) async {
    return await _repository.getExpensesBefore(date);
  }

  /// Returns all incomes before [date] as a list for the calendar bloc.
  Future<List<IncomeEntry>> getIncomesBefore(DateTime date) async {
    return await _repository.getIncomeBefore(date);
  }
}
