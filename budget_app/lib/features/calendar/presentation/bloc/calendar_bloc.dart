import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/budget/domain/usecases/get_calendar_data.dart';
import 'calendar_event.dart' as events;
import 'calendar_state.dart';

class CalendarBloc extends Bloc<events.CalendarEvent, CalendarState> {
  final GetCalendarData _getCalendarData;

  int? _currentYear;
  int? _currentMonth;

  CalendarBloc({required GetCalendarData getCalendarData})
    : _getCalendarData = getCalendarData,
      super(CalendarInitial()) {
    on<events.LoadCalendarMonth>(_onLoadCalendarMonth);
    on<events.SelectCalendarDay>(_onSelectCalendarDay);
    on<events.RefreshCalendar>(_onRefreshCalendar);
  }

  Future<void> _onLoadCalendarMonth(
    events.LoadCalendarMonth event,
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
    events.SelectCalendarDay event,
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
    events.RefreshCalendar event,
    Emitter<CalendarState> emit,
  ) async {
    if (_currentYear != null && _currentMonth != null) {
      add(events.LoadCalendarMonth(year: _currentYear!, month: _currentMonth!));
    }
  }

  Future<CalendarLoaded> _calculateMonthData(int year, int month) async {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    final monthData = await _getCalendarData.forMonth(year, month);

    final allTransactions = <CalendarEvent>[];
    final categories = monthData.categories;

    for (final income in monthData.incomes) {
      allTransactions.add(
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
    for (final expense in monthData.expenses) {
      allTransactions.add(
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

    final transactionsByDate = <DateTime, List<CalendarEvent>>{};
    for (final transaction in allTransactions) {
      final normalizedDate = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      transactionsByDate.putIfAbsent(normalizedDate, () => []);
      transactionsByDate[normalizedDate]!.add(transaction);
    }

    // Compute running balances
    final runningBalances = <DateTime, double>{};
    final endOfDayBalances = <DateTime, double>{};

    double runningTotal = 0;
    for (int day = 1; day <= lastDay.day; day++) {
      final currentDate = DateTime(year, month, day);

      if (day == 1) {
        runningTotal = await _computeStartingBalance(year, month);
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
      selectedDayTransactions: const [],
      monthStartBalance: monthStartBalance,
      monthEndBalance: monthEndBalance,
    );
  }

  Future<double> _computeStartingBalance(int year, int month) async {
    final firstDay = DateTime(year, month, 1);
    final expensesBefore = await _getCalendarData.getExpensesBefore(firstDay);
    final incomesBefore = await _getCalendarData.getIncomesBefore(firstDay);

    double total = 0;
    for (final e in expensesBefore) {
      total -= e.amount;
    }
    for (final i in incomesBefore) {
      total += i.amount;
    }
    return total;
  }

  String? _getCategoryName(dynamic categoryId, List<dynamic> categories) {
    if (categoryId == null) return null;
    try {
      final category = categories.firstWhere((c) => c.id == categoryId);
      return category.name;
    } catch (_) {
      return null;
    }
  }

  String? _getCategoryIcon(dynamic categoryId, List<dynamic> categories) {
    if (categoryId == null) return null;
    try {
      final category = categories.firstWhere((c) => c.id == categoryId);
      return category.icon;
    } catch (_) {
      return null;
    }
  }
}
