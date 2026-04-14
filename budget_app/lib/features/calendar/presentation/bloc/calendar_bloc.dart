import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final BudgetRepository _budgetRepository;

  int? _currentYear;
  int? _currentMonth;

  CalendarBloc({required BudgetRepository budgetRepository})
    : _budgetRepository = budgetRepository,
      super(CalendarInitial()) {
    on<LoadCalendarMonth>(_onLoadCalendarMonth);
    on<SelectCalendarDay>(_onSelectCalendarDay);
    on<RefreshCalendar>(_onRefreshCalendar);
  }

  Future<void> _onLoadCalendarMonth(
    LoadCalendarMonth event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    try {
      _currentYear = event.year;
      _currentMonth = event.month;

      final data = await _calculateMonthData(event.year, event.month);

      emit(data);
    } catch (e) {
      emit(CalendarError(e.toString()));
    }
  }

  Future<void> _onSelectCalendarDay(
    SelectCalendarDay event,
    Emitter<CalendarState> emit,
  ) async {
    final currentState = state;
    if (currentState is CalendarLoaded) {
      final normalizedDate = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );

      final transactions =
          currentState.transactionsByDate[normalizedDate] ?? [];

      emit(
        CalendarLoaded(
          year: currentState.year,
          month: currentState.month,
          transactionsByDate: currentState.transactionsByDate,
          runningBalances: currentState.runningBalances,
          endOfDayBalances: currentState.endOfDayBalances,
          selectedDate: normalizedDate,
          selectedDayTransactions: transactions,
          monthStartBalance: currentState.monthStartBalance,
          monthEndBalance: currentState.monthEndBalance,
        ),
      );
    }
  }

  Future<void> _onRefreshCalendar(
    RefreshCalendar event,
    Emitter<CalendarState> emit,
  ) async {
    if (_currentYear != null && _currentMonth != null) {
      add(LoadCalendarMonth(year: _currentYear!, month: _currentMonth!));
    }
  }

  Future<CalendarLoaded> _calculateMonthData(int year, int month) async {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month, lastDay.day, 23, 59, 59);

    final allIncomes = await _budgetRepository.getAllIncome();
    final allExpenses = await _budgetRepository.getAllExpenses();
    final categories = await _budgetRepository.getCategories();

    final monthIncomes = allIncomes.where((i) {
      return i.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
          i.date.isBefore(monthEnd.add(const Duration(days: 1)));
    }).toList();

    final monthExpenses = allExpenses.where((e) {
      return e.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
          e.date.isBefore(monthEnd.add(const Duration(days: 1)));
    }).toList();

    final allTransactions = <CalendarTransaction>[];
    for (final income in monthIncomes) {
      allTransactions.add(
        CalendarTransaction(
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
      allTransactions.add(
        CalendarTransaction(
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

    final transactionsByDate = <DateTime, List<CalendarTransaction>>{};
    for (final transaction in allTransactions) {
      final normalizedDate = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      transactionsByDate.putIfAbsent(normalizedDate, () => []);
      transactionsByDate[normalizedDate]!.add(transaction);
    }

    final runningBalances = <DateTime, double>{};
    final endOfDayBalances = <DateTime, double>{};

    double runningTotal = 0;
    for (int day = 1; day <= lastDay.day; day++) {
      final currentDate = DateTime(year, month, day);

      if (day == 1) {
        final monthIncomesBefore = allIncomes.where(
          (i) => i.date.isBefore(firstDay),
        );
        final monthExpensesBefore = allExpenses.where(
          (e) => e.date.isBefore(firstDay),
        );
        runningTotal =
            monthIncomesBefore.fold<double>(0, (sum, i) => sum + i.amount) -
            monthExpensesBefore.fold<double>(0, (sum, e) => sum + e.amount);
      }

      runningBalances[currentDate] = runningTotal;

      final dayTransactions = transactionsByDate[currentDate] ?? [];
      for (final transaction in dayTransactions) {
        if (transaction.isExpense) {
          runningTotal -= transaction.amount;
        } else {
          runningTotal += transaction.amount;
        }
      }

      endOfDayBalances[currentDate] = runningTotal;
    }

    final monthStartBalance = runningBalances[firstDay] ?? 0;
    final monthEndBalance = runningTotal;

    return CalendarLoaded(
      year: year,
      month: month,
      transactionsByDate: transactionsByDate,
      runningBalances: runningBalances,
      endOfDayBalances: endOfDayBalances,
      selectedDate: null,
      selectedDayTransactions: [],
      monthStartBalance: monthStartBalance,
      monthEndBalance: monthEndBalance,
    );
  }

  String? _getCategoryName(String? categoryId, List<dynamic> categories) {
    if (categoryId == null) return null;
    try {
      final category = categories.firstWhere((c) => c.id == categoryId);
      return category.name;
    } catch (_) {
      return null;
    }
  }

  String? _getCategoryIcon(String? categoryId, List<dynamic> categories) {
    if (categoryId == null) return null;
    try {
      final category = categories.firstWhere((c) => c.id == categoryId);
      return category.icon;
    } catch (_) {
      return null;
    }
  }
}
