import 'package:equatable/equatable.dart';
import '../../domain/entities/calendar_event.dart';

/// Re-export domain entity so state consumers can use it.
export '../../domain/entities/calendar_event.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {}

class CalendarLoading extends CalendarState {}

class CalendarLoaded extends CalendarState {
  final int year;
  final int month;
  final Map<DateTime, List<CalendarEvent>> transactionsByDate;
  final Map<DateTime, double> runningBalances;
  final Map<DateTime, double> endOfDayBalances;
  final DateTime? selectedDate;
  final List<CalendarEvent> selectedDayTransactions;
  final double monthStartBalance;
  final double monthEndBalance;

  const CalendarLoaded({
    required this.year,
    required this.month,
    required this.transactionsByDate,
    required this.runningBalances,
    required this.endOfDayBalances,
    this.selectedDate,
    required this.selectedDayTransactions,
    required this.monthStartBalance,
    required this.monthEndBalance,
  });

  @override
  List<Object?> get props => [
    year,
    month,
    transactionsByDate,
    runningBalances,
    endOfDayBalances,
    selectedDate,
    selectedDayTransactions,
    monthStartBalance,
    monthEndBalance,
  ];
}

class CalendarError extends CalendarState {
  final String message;

  const CalendarError(this.message);

  @override
  List<Object?> get props => [message];
}
