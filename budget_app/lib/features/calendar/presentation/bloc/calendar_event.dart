import 'package:equatable/equatable.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class LoadCalendarMonth extends CalendarEvent {
  final int year;
  final int month;

  const LoadCalendarMonth({required this.year, required this.month});

  @override
  List<Object?> get props => [year, month];
}

class SelectCalendarDay extends CalendarEvent {
  final DateTime date;

  const SelectCalendarDay(this.date);

  @override
  List<Object?> get props => [date];
}

class RefreshCalendar extends CalendarEvent {}
