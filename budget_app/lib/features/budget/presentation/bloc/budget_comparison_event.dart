import 'package:equatable/equatable.dart';

abstract class BudgetComparisonEvent extends Equatable {
  const BudgetComparisonEvent();

  @override
  List<Object?> get props => [];
}

class LoadBudgetComparison extends BudgetComparisonEvent {
  final String budgetId;
  final int year;
  final int month;

  const LoadBudgetComparison({
    required this.budgetId,
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [budgetId, year, month];
}

class RefreshBudgetComparison extends BudgetComparisonEvent {}
