import 'package:equatable/equatable.dart';
import 'package:budget_app/features/budget/domain/usecases/calculate_summary.dart';
import '../domain/entities/category.dart';

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

class IncomeAdded extends BudgetState {
  const IncomeAdded();
}

class ExpenseAdded extends BudgetState {
  const ExpenseAdded();
}

class EntryDeleted extends BudgetState {
  const EntryDeleted();
}

class EntryUpdated extends BudgetState {
  const EntryUpdated();
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

class BudgetDeleted extends BudgetState {
  const BudgetDeleted();
}

class BudgetsCleared extends BudgetState {
  const BudgetsCleared();
}

class FactoryResetComplete extends BudgetState {
  const FactoryResetComplete();
}
