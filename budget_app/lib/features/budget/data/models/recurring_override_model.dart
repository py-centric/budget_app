import '../../domain/entities/recurring_override.dart';

class RecurringOverrideModel extends RecurringOverride {
  const RecurringOverrideModel({
    required super.id,
    required super.recurringTransactionId,
    required super.targetDate,
    super.newAmount,
    super.newDate,
    super.isDeleted,
  });

  factory RecurringOverrideModel.fromMap(Map<String, dynamic> map) {
    return RecurringOverrideModel(
      id: map['id'] as String,
      recurringTransactionId: map['recurring_transaction_id'] as String,
      targetDate: DateTime.parse(map['target_date'] as String),
      newAmount: map['new_amount'] != null ? (map['new_amount'] as num).toDouble() : null,
      newDate: map['new_date'] != null ? DateTime.parse(map['new_date'] as String) : null,
      isDeleted: (map['is_deleted'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recurring_transaction_id': recurringTransactionId,
      'target_date': targetDate.toIso8601String(),
      'new_amount': newAmount,
      'new_date': newDate?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory RecurringOverrideModel.fromEntity(RecurringOverride entity) {
    return RecurringOverrideModel(
      id: entity.id,
      recurringTransactionId: entity.recurringTransactionId,
      targetDate: entity.targetDate,
      newAmount: entity.newAmount,
      newDate: entity.newDate,
      isDeleted: entity.isDeleted,
    );
  }
}
