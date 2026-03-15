import 'package:equatable/equatable.dart';

class BudgetPeriod extends Equatable implements Comparable<BudgetPeriod> {
  final int year;
  final int month;

  const BudgetPeriod({required this.year, required this.month})
      : assert(month >= 1 && month <= 12, 'Month must be between 1 and 12');

  factory BudgetPeriod.current() {
    final now = DateTime.now();
    return BudgetPeriod(year: now.year, month: now.month);
  }

  factory BudgetPeriod.fromDate(DateTime date) {
    return BudgetPeriod(year: date.year, month: date.month);
  }

  BudgetPeriod get previous {
    if (month == 1) {
      return BudgetPeriod(year: year - 1, month: 12);
    }
    return BudgetPeriod(year: year, month: month - 1);
  }

  BudgetPeriod get next {
    if (month == 12) {
      return BudgetPeriod(year: year + 1, month: 1);
    }
    return BudgetPeriod(year: year, month: month + 1);
  }

  bool get isCurrent {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  DateTime get startDate => DateTime(year, month, 1);
  
  DateTime get endDate => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  @override
  List<Object?> get props => [year, month];

  @override
  int compareTo(BudgetPeriod other) {
    if (year != other.year) {
      return year.compareTo(other.year);
    }
    return month.compareTo(other.month);
  }

  @override
  String toString() {
    return '$year-${month.toString().padLeft(2, '0')}';
  }
}
