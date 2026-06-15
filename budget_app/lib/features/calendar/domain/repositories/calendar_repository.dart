import '../entities/calendar_event.dart';

/// Repository interface for calendar data access.
/// Implementations wrap budget feature calls to provide calendar-specific
/// data without exposing the full BudgetRepository.
abstract class CalendarRepository {
  /// Fetches all expenses and incomes for the given year/month.
  /// Returns a list of [CalendarEvent] with date, amount, and category info.
  Future<List<CalendarEvent>> getEventsForMonth(int year, int month);

  /// Fetches all expenses before a given date.
  Future<List<CalendarEvent>> getExpensesBefore(DateTime date);

  /// Fetches all incomes before a given date.
  Future<List<CalendarEvent>> getIncomesBefore(DateTime date);
}
