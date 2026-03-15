class DateGroupingUtils {
  /// Returns the week ending date (inclusive) for a given date based on the week start day.
  /// [weekStartDay] corresponds to DateTime.monday (1) through DateTime.sunday (7).
  static DateTime getWeekEndingDate(DateTime date, int weekStartDay) {
    int offset = (date.weekday - weekStartDay) % 7;
    if (offset < 0) offset += 7;
    final startOfDay = DateTime(date.year, date.month, date.day);
    return startOfDay.add(Duration(days: 6 - offset));
  }
}
