import 'package:equatable/equatable.dart';
import '../../domain/entities/bill_reminder.dart';

abstract class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

class LoadReminders extends ReminderEvent {}

class LoadUpcomingReminders extends ReminderEvent {
  final int days;

  const LoadUpcomingReminders({this.days = 7});

  @override
  List<Object?> get props => [days];
}

class CreateReminder extends ReminderEvent {
  final String recurringTransactionId;
  final DateTime dueDate;
  final int daysBeforeDue;

  const CreateReminder({
    required this.recurringTransactionId,
    required this.dueDate,
    required this.daysBeforeDue,
  });

  @override
  List<Object?> get props => [recurringTransactionId, dueDate, daysBeforeDue];
}

class UpdateReminder extends ReminderEvent {
  final BillReminder reminder;

  const UpdateReminder(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class DeleteReminder extends ReminderEvent {
  final String reminderId;

  const DeleteReminder(this.reminderId);

  @override
  List<Object?> get props => [reminderId];
}

class DeleteRemindersForTransaction extends ReminderEvent {
  final String transactionId;

  const DeleteRemindersForTransaction(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class CheckAndSendReminders extends ReminderEvent {}

class MarkReminderAsNotified extends ReminderEvent {
  final String reminderId;

  const MarkReminderAsNotified(this.reminderId);

  @override
  List<Object?> get props => [reminderId];
}

class RefreshReminders extends ReminderEvent {}
