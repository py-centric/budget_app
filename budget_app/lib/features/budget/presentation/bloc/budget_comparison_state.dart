import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_comparison.dart';

abstract class BudgetComparisonState extends Equatable {
  const BudgetComparisonState();

  @override
  List<Object?> get props => [];
}

class BudgetComparisonInitial extends BudgetComparisonState {}

class BudgetComparisonLoading extends BudgetComparisonState {}

class BudgetComparisonLoaded extends BudgetComparisonState {
  final List<BudgetComparison> comparisons;
  final BudgetComparisonSummary summary;
  final int year;
  final int month;

  const BudgetComparisonLoaded({
    required this.comparisons,
    required this.summary,
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [comparisons, summary, year, month];
}

class BudgetComparisonError extends BudgetComparisonState {
  final String message;

  const BudgetComparisonError(this.message);

  @override
  List<Object?> get props => [message];
}
