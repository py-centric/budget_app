import 'package:equatable/equatable.dart';

class BillReminder extends Equatable {
  final String id;
  final String recurringTransactionId;
  final DateTime dueDate;
  final int daysBeforeDue;
  final bool isNotified;
  final DateTime? notifiedAt;
  final DateTime createdAt;

  const BillReminder({
    required this.id,
    required this.recurringTransactionId,
    required this.dueDate,
    required this.daysBeforeDue,
    this.isNotified = false,
    this.notifiedAt,
    required this.createdAt,
  });

  DateTime get reminderDate => dueDate.subtract(Duration(days: daysBeforeDue));

  bool get shouldNotify {
    if (isNotified) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminder = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
    );
    return today.isAtSameMomentAs(reminder) || today.isAfter(reminder);
  }

  BillReminder copyWith({
    String? id,
    String? recurringTransactionId,
    DateTime? dueDate,
    int? daysBeforeDue,
    bool? isNotified,
    DateTime? notifiedAt,
    DateTime? createdAt,
  }) {
    return BillReminder(
      id: id ?? this.id,
      recurringTransactionId:
          recurringTransactionId ?? this.recurringTransactionId,
      dueDate: dueDate ?? this.dueDate,
      daysBeforeDue: daysBeforeDue ?? this.daysBeforeDue,
      isNotified: isNotified ?? this.isNotified,
      notifiedAt: notifiedAt ?? this.notifiedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    recurringTransactionId,
    dueDate,
    daysBeforeDue,
    isNotified,
    notifiedAt,
    createdAt,
  ];
}
