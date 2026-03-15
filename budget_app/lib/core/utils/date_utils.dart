class DateUtilsHelper {
  /// Shifts a date to a target year and month while preserving the day of the month as best as possible.
  /// If the target month has fewer days than the original day (e.g., Jan 31 -> Feb),
  /// it clamps to the last day of the target month (e.g., Feb 28/29).
  static DateTime shiftDateToPeriod(DateTime originalDate, int targetYear, int targetMonth) {
    int targetDay = originalDate.day;
    
    // Find the last day of the target month
    int lastDayOfTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    
    // Clamp the day
    if (targetDay > lastDayOfTargetMonth) {
      targetDay = lastDayOfTargetMonth;
    }

    return DateTime(
      targetYear,
      targetMonth,
      targetDay,
      originalDate.hour,
      originalDate.minute,
      originalDate.second,
      originalDate.millisecond,
      originalDate.microsecond,
    );
  }
}
