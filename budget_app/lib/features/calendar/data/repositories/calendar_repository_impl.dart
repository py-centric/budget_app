import '../../../budget/domain/entities/category.dart';
import '../../../budget/domain/repositories/budget_repository.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';

/// Implementation of [CalendarRepository] that delegates to the budget
/// feature's [BudgetRepository] to fetch income/expense data and categories.
class CalendarRepositoryImpl implements CalendarRepository {
  final BudgetRepository _budgetRepository;

  CalendarRepositoryImpl(this._budgetRepository);

  @override
  Future<List<CalendarEvent>> getEventsForMonth(int year, int month) async {
    final allIncomes = await _budgetRepository.getAllIncome();
    final allExpenses = await _budgetRepository.getAllExpenses();
    final categories = await _budgetRepository.getCategories();

    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 0, 23, 59, 59);

    final monthIncomes = allIncomes.where((i) {
      return i.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
          i.date.isBefore(monthEnd.add(const Duration(days: 1)));
    }).toList();

    final monthExpenses = allExpenses.where((e) {
      return e.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
          e.date.isBefore(monthEnd.add(const Duration(days: 1)));
    }).toList();

    final events = <CalendarEvent>[];
    for (final income in monthIncomes) {
      events.add(
        CalendarEvent(
          id: income.id,
          amount: income.amount,
          description: income.description ?? 'Income',
          date: income.date,
          isExpense: false,
          categoryName: _getCategoryName(income.categoryId, categories),
          categoryIcon: _getCategoryIcon(income.categoryId, categories),
        ),
      );
    }
    for (final expense in monthExpenses) {
      events.add(
        CalendarEvent(
          id: expense.id,
          amount: expense.amount,
          description: expense.description ?? 'Expense',
          date: expense.date,
          isExpense: true,
          categoryName: _getCategoryName(expense.categoryId, categories),
          categoryIcon: _getCategoryIcon(expense.categoryId, categories),
        ),
      );
    }

    return events;
  }

  @override
  Future<List<CalendarEvent>> getExpensesBefore(DateTime date) async {
    final allExpenses = await _budgetRepository.getAllExpenses();
    final categories = await _budgetRepository.getCategories();

    return allExpenses
        .where((e) => e.date.isBefore(date))
        .map(
          (e) => CalendarEvent(
            id: e.id,
            amount: e.amount,
            description: e.description ?? 'Expense',
            date: e.date,
            isExpense: true,
            categoryName: _getCategoryName(e.categoryId, categories),
            categoryIcon: _getCategoryIcon(e.categoryId, categories),
          ),
        )
        .toList();
  }

  @override
  Future<List<CalendarEvent>> getIncomesBefore(DateTime date) async {
    final allIncomes = await _budgetRepository.getAllIncome();
    final categories = await _budgetRepository.getCategories();

    return allIncomes
        .where((i) => i.date.isBefore(date))
        .map(
          (i) => CalendarEvent(
            id: i.id,
            amount: i.amount,
            description: i.description ?? 'Income',
            date: i.date,
            isExpense: false,
            categoryName: _getCategoryName(i.categoryId, categories),
            categoryIcon: _getCategoryIcon(i.categoryId, categories),
          ),
        )
        .toList();
  }

  String? _getCategoryName(String? categoryId, List<Category> categories) {
    if (categoryId == null) return null;
    try {
      final category = categories.firstWhere((c) => c.id == categoryId);
      return category.name;
    } catch (_) {
      return null;
    }
  }

  String? _getCategoryIcon(String? categoryId, List<Category> categories) {
    if (categoryId == null) return null;
    try {
      final category = categories.firstWhere((c) => c.id == categoryId);
      return category.icon;
    } catch (_) {
      return null;
    }
  }
}
