import 'package:equatable/equatable.dart';

enum RecurrenceUnit { days, weeks, months, years }

class RecurringTransaction extends Equatable {
  final String id;
  final String budgetId;
  final String type; // 'INCOME' or 'EXPENSE'
  final double amount;
  final String categoryId;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final int interval;
  final RecurrenceUnit unit;

  const RecurringTransaction({
    required this.id,
    required this.budgetId,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.interval,
    required this.unit,
  });

  @override
  List<Object?> get props => [
        id,
        budgetId,
        type,
        amount,
        categoryId,
        description,
        startDate,
        endDate,
        interval,
        unit,
      ];
}
