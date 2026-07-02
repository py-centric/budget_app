import 'package:equatable/equatable.dart';
import 'package:budget_app/features/budget/domain/usecases/calculate_summary.dart';
import '../../domain/entities/category.dart';

/// Base state for the budget feature's UI layer.
abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

class BudgetLoading extends BudgetState {
  const BudgetLoading();
}

/// Consolidated one-shot success state replacing IncomeAdded, ExpenseAdded,
/// EntryDeleted, EntryUpdated, BudgetDeleted, BudgetsCleared, and FactoryResetComplete.
class OperationSuccess extends BudgetState {
  final String? message;
  const OperationSuccess({this.message});
}

class SummaryLoaded extends BudgetState {
  final BudgetSummary summary;

  const SummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class CategoriesLoaded extends BudgetState {
  final List<Category> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class BudgetError extends BudgetState {
  final String message;

  const BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}

class BudgetConverted extends BudgetState {
  final String budgetId;
  final String targetCurrencyCode;
  final double exchangeRate;
  final double convertedAmount;

  const BudgetConverted({
    required this.budgetId,
    required this.targetCurrencyCode,
    required this.exchangeRate,
    required this.convertedAmount,
  });

  @override
  List<Object?> get props => [
    budgetId,
    targetCurrencyCode,
    exchangeRate,
    convertedAmount,
  ];
}
