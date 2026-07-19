import 'package:equatable/equatable.dart';
import 'package:budget_app/features/budget/domain/usecases/calculate_summary.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/income_entry.dart';

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

class DisposableBudgetsLoaded extends BudgetState {
  final List<Budget> active;
  final List<Budget> history;
  final Map<String, double> budgetExpenseTotals;
  final Set<String> endedBudgetIds;

  const DisposableBudgetsLoaded({
    required this.active,
    required this.history,
    this.budgetExpenseTotals = const {},
    this.endedBudgetIds = const {},
  });

  @override
  List<Object?> get props => [active, history, budgetExpenseTotals, endedBudgetIds];
}

class DisposableBudgetCreated extends BudgetState {
  final Budget budget;

  const DisposableBudgetCreated(this.budget);

  @override
  List<Object?> get props => [budget];
}

class BudgetDisposed extends BudgetState {
  final String budgetId;

  const BudgetDisposed(this.budgetId);

  @override
  List<Object?> get props => [budgetId];
}

class BudgetPersisted extends BudgetState {
  final String budgetId;

  const BudgetPersisted(this.budgetId);

  @override
  List<Object?> get props => [budgetId];
}

class IncomeLinked extends BudgetState {
  final String budgetId;
  final String transactionId;

  const IncomeLinked({required this.budgetId, required this.transactionId});

  @override
  List<Object?> get props => [budgetId, transactionId];
}

class IncomeUnlinked extends BudgetState {
  final String budgetId;

  const IncomeUnlinked(this.budgetId);

  @override
  List<Object?> get props => [budgetId];
}

class IncomeListLoaded extends BudgetState {
  final List<IncomeEntry> incomes;

  const IncomeListLoaded(this.incomes);

  @override
  List<Object?> get props => [incomes];
}
