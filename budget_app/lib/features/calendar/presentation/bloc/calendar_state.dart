import 'package:equatable/equatable.dart';

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
  final Map<DateTime, List<CalendarTransaction>> transactionsByDate;
  final Map<DateTime, double> runningBalances;
  final Map<DateTime, double> endOfDayBalances;
  final DateTime? selectedDate;
  final List<CalendarTransaction> selectedDayTransactions;
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

class CalendarTransaction extends Equatable {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final bool isExpense;
  final String? categoryName;
  final String? categoryIcon;

  const CalendarTransaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.isExpense,
    this.categoryName,
    this.categoryIcon,
  });

  @override
  List<Object?> get props => [
    id,
    amount,
    description,
    date,
    isExpense,
    categoryName,
    categoryIcon,
  ];
}
