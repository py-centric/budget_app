import 'package:equatable/equatable.dart';
import '../domain/entities/budget_period.dart';
import '../domain/entities/income_entry.dart';
import '../domain/entities/expense_entry.dart';
import '../domain/entities/recurring_transaction.dart';

import '../domain/entities/budget.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class DuplicateBudgetEvent extends BudgetEvent {
  final Budget sourceBudget;
  final BudgetPeriod targetPeriod;
  final String newName;
  final bool includeTransactions;

  const DuplicateBudgetEvent({
    required this.sourceBudget,
    required this.targetPeriod,
    required this.newName,
    this.includeTransactions = false,
  });

  @override
  List<Object?> get props => [
    sourceBudget,
    targetPeriod,
    newName,
    includeTransactions,
  ];
}

class AddIncomeEvent extends BudgetEvent {
  final String id;
  final String budgetId;
  final double amount;
  final String categoryId;
  final String? description;
  final DateTime date;
  final bool isPotential;

  const AddIncomeEvent({
    required this.id,
    required this.budgetId,
    required this.amount,
    required this.categoryId,
    this.description,
    required this.date,
    this.isPotential = false,
  });

  @override
  List<Object?> get props => [
    id,
    budgetId,
    amount,
    categoryId,
    description,
    date,
    isPotential,
  ];
}

class AddExpenseEvent extends BudgetEvent {
  final String id;
  final String budgetId;
  final double amount;
  final String category;
  final String? description;
  final DateTime date;
  final bool isPotential;

  const AddExpenseEvent({
    required this.id,
    required this.budgetId,
    required this.amount,
    required this.category,
    this.description,
    required this.date,
    this.isPotential = false,
  });

  @override
  List<Object?> get props => [
    id,
    budgetId,
    amount,
    category,
    description,
    date,
    isPotential,
  ];
}

class LoadSummaryEvent extends BudgetEvent {
  final BudgetPeriod? period;
  final String? budgetId;

  const LoadSummaryEvent({this.period, this.budgetId});

  @override
  List<Object?> get props => [period, budgetId];
}

class LoadCategoriesEvent extends BudgetEvent {
  const LoadCategoriesEvent();
}

class DeleteEntryEvent extends BudgetEvent {
  final String id;
  final EntryType type;

  const DeleteEntryEvent(this.id, this.type);

  @override
  List<Object?> get props => [id, type];
}

enum EntryType { income, expense }

class UpdateIncomeEvent extends BudgetEvent {
  final IncomeEntry income;

  const UpdateIncomeEvent(this.income);

  @override
  List<Object?> get props => [income];
}

class UpdateExpenseEvent extends BudgetEvent {
  final ExpenseEntry expense;

  const UpdateExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

class SaveRecurringTransactionEvent extends BudgetEvent {
  final RecurringTransaction recurring;

  const SaveRecurringTransactionEvent(this.recurring);

  @override
  List<Object?> get props => [recurring];
}

class ConfirmPotentialTransactionEvent extends BudgetEvent {
  final String? incomeId;
  final String? expenseId;

  const ConfirmPotentialTransactionEvent({this.incomeId, this.expenseId});

  @override
  List<Object?> get props => [incomeId, expenseId];
}

class DeleteBudgetEvent extends BudgetEvent {
  final String budgetId;

  const DeleteBudgetEvent(this.budgetId);

  @override
  List<Object?> get props => [budgetId];
}

class ClearAllBudgetsEvent extends BudgetEvent {
  const ClearAllBudgetsEvent();
}

class FactoryResetEvent extends BudgetEvent {
  const FactoryResetEvent();
}
