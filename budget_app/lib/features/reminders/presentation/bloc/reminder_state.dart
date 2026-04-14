import 'package:equatable/equatable.dart';
import '../../domain/entities/bill_reminder.dart';

abstract class ReminderState extends Equatable {
  const ReminderState();

  @override
  List<Object?> get props => [];
}

class ReminderInitial extends ReminderState {}

class ReminderLoading extends ReminderState {}

class ReminderLoaded extends ReminderState {
  final List<BillReminderWithDetails> reminders;
  final int unreadCount;

  const ReminderLoaded({required this.reminders, required this.unreadCount});

  @override
  List<Object?> get props => [reminders, unreadCount];
}

class ReminderError extends ReminderState {
  final String message;

  const ReminderError(this.message);

  @override
  List<Object?> get props => [message];
}

class BillReminderWithDetails {
  final BillReminder reminder;
  final String? transactionTitle;
  final String? transactionDescription;
  final double? amount;

  const BillReminderWithDetails({
    required this.reminder,
    this.transactionTitle,
    this.transactionDescription,
    this.amount,
  });
}
