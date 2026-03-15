import '../../domain/entities/recurring_transaction.dart';

class RecurringTransactionModel extends RecurringTransaction {
  const RecurringTransactionModel({
    required super.id,
    required super.budgetId,
    required super.type,
    required super.amount,
    required super.categoryId,
    required super.description,
    required super.startDate,
    super.endDate,
    required super.interval,
    required super.unit,
  });

  factory RecurringTransactionModel.fromMap(Map<String, dynamic> map) {
    return RecurringTransactionModel(
      id: map['id'] as String,
      budgetId: map['budget_id'] as String? ?? 'default',
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'] as String,
      description: map['description'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String) : null,
      interval: map['recurrence_interval'] as int,
      unit: RecurrenceUnit.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == (map['recurrence_unit'] as String).toUpperCase(),
        orElse: () => RecurrenceUnit.months,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'budget_id': budgetId,
      'type': type,
      'amount': amount,
      'category_id': categoryId,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'recurrence_interval': interval,
      'recurrence_unit': unit.toString().split('.').last.toUpperCase(),
    };
  }

  factory RecurringTransactionModel.fromEntity(RecurringTransaction entity) {
    return RecurringTransactionModel(
      id: entity.id,
      budgetId: entity.budgetId,
      type: entity.type,
      amount: entity.amount,
      categoryId: entity.categoryId,
      description: entity.description,
      startDate: entity.startDate,
      endDate: entity.endDate,
      interval: entity.interval,
      unit: entity.unit,
    );
  }
}
