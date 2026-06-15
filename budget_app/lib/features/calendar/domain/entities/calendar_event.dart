import 'package:equatable/equatable.dart';

/// A single financial transaction displayed in the calendar view.
class CalendarEvent extends Equatable {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final bool isExpense;
  final String? categoryName;
  final String? categoryIcon;

  const CalendarEvent({
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
