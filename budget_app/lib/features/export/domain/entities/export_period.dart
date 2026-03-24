enum ExportPeriod { currentMonth, customRange, allTime }

extension ExportPeriodExtension on ExportPeriod {
  String get displayName {
    switch (this) {
      case ExportPeriod.currentMonth:
        return 'Current Month';
      case ExportPeriod.customRange:
        return 'Custom Range';
      case ExportPeriod.allTime:
        return 'All Time';
    }
  }
}
