import 'package:budget_app/features/budget/domain/entities/recurring_transaction.dart';
import 'package:budget_app/features/budget/domain/entities/recurring_override.dart';

class RecurringInstance {
  final DateTime date;
  final double amount;
  final String description;
  final String categoryId;
  final bool isOverride;
  final String templateId;

  RecurringInstance({
    required this.date,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.isOverride,
    required this.templateId,
  });
}

class RecurrenceCalculator {
  static List<RecurringInstance> getInstancesInRange({
    required RecurringTransaction template,
    required List<RecurringOverride> overrides,
    required DateTime start,
    required DateTime end,
  }) {
    final List<RecurringInstance> instances = [];
    DateTime currentDate = template.startDate;

    // Normalize start and end to remove time components
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);

    while (true) {
      // Check if current instance is within overall template bounds
      if (template.endDate != null && currentDate.isAfter(template.endDate!)) {
        break;
      }

      // Check if current instance is within the requested range
      if (!currentDate.isBefore(normalizedStart) && !currentDate.isAfter(normalizedEnd)) {
        // Look for override for THIS specific target date
        final override = _findOverride(overrides, currentDate);

        if (override == null || !override.isDeleted) {
          instances.add(RecurringInstance(
            date: override?.newDate ?? currentDate,
            amount: override?.newAmount ?? template.amount,
            description: template.description,
            categoryId: template.categoryId,
            isOverride: override != null,
            templateId: template.id,
          ));
        }
      } else if (currentDate.isAfter(normalizedEnd)) {
        // Optimization: if template start is after range end, we can stop early
        // BUT only if interval/unit calculation is strictly additive (which it is)
        break;
      }

      // Move to next occurrence
      currentDate = _getNextDate(currentDate, template.interval, template.unit);
      
      // Safety break to prevent infinite loops if interval is 0 or logic bug
      if (template.interval <= 0) break;
    }

    return instances;
  }

  static RecurringOverride? _findOverride(List<RecurringOverride> overrides, DateTime targetDate) {
    try {
      return overrides.firstWhere((o) => 
        o.targetDate.year == targetDate.year && 
        o.targetDate.month == targetDate.month && 
        o.targetDate.day == targetDate.day
      );
    } catch (_) {
      return null;
    }
  }

  static DateTime _getNextDate(DateTime date, int interval, RecurrenceUnit unit) {
    switch (unit) {
      case RecurrenceUnit.days:
        return date.add(Duration(days: interval));
      case RecurrenceUnit.weeks:
        return date.add(Duration(days: interval * 7));
      case RecurrenceUnit.months:
        // Handle month increment carefully (e.g. Jan 31st + 1 month = Feb 28th/29th)
        int nextYear = date.year;
        int nextMonth = date.month + interval;
        
        while (nextMonth > 12) {
          nextYear++;
          nextMonth -= 12;
        }
        
        // Find last day of target month
        int lastDay = DateTime(nextYear, nextMonth + 1, 0).day;
        int targetDay = date.day > lastDay ? lastDay : date.day;
        
        return DateTime(nextYear, nextMonth, targetDay);
      case RecurrenceUnit.years:
        int nextYear = date.year + interval;
        // Handle leap years (Feb 29th)
        int lastDay = DateTime(nextYear, date.month + 1, 0).day;
        int targetDay = date.day > lastDay ? lastDay : date.day;
        return DateTime(nextYear, date.month, targetDay);
    }
  }
}
