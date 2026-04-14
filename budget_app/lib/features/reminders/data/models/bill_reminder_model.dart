import '../../domain/entities/bill_reminder.dart';

class BillReminderModel extends BillReminder {
  const BillReminderModel({
    required super.id,
    required super.recurringTransactionId,
    required super.dueDate,
    required super.daysBeforeDue,
    super.isNotified,
    super.notifiedAt,
    required super.createdAt,
  });

  factory BillReminderModel.fromEntity(BillReminder entity) {
    return BillReminderModel(
      id: entity.id,
      recurringTransactionId: entity.recurringTransactionId,
      dueDate: entity.dueDate,
      daysBeforeDue: entity.daysBeforeDue,
      isNotified: entity.isNotified,
      notifiedAt: entity.notifiedAt,
      createdAt: entity.createdAt,
    );
  }

  factory BillReminderModel.fromMap(Map<String, dynamic> map) {
    return BillReminderModel(
      id: map['id'] as String,
      recurringTransactionId: map['recurring_transaction_id'] as String,
      dueDate: DateTime.parse(map['due_date'] as String),
      daysBeforeDue: map['days_before_due'] as int,
      isNotified: (map['is_notified'] as int) == 1,
      notifiedAt: map['notified_at'] != null
          ? DateTime.parse(map['notified_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recurring_transaction_id': recurringTransactionId,
      'due_date': dueDate.toIso8601String(),
      'days_before_due': daysBeforeDue,
      'is_notified': isNotified ? 1 : 0,
      'notified_at': notifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  BillReminder toEntity() {
    return BillReminder(
      id: id,
      recurringTransactionId: recurringTransactionId,
      dueDate: dueDate,
      daysBeforeDue: daysBeforeDue,
      isNotified: isNotified,
      notifiedAt: notifiedAt,
      createdAt: createdAt,
    );
  }
}
