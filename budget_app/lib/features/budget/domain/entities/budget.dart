import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final String name;
  final int periodMonth;
  final int periodYear;
  final bool isActive;

  const Budget({
    required this.id,
    required this.name,
    required this.periodMonth,
    required this.periodYear,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, periodMonth, periodYear, isActive];
}
