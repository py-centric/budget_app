import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../domain/entities/income_entry.dart';
import '../domain/entities/expense_entry.dart';
import '../domain/entities/budget_period.dart';
import '../domain/repositories/budget_repository.dart';
import '../domain/usecases/add_income.dart';
import '../domain/usecases/add_expense.dart';
import '../domain/usecases/calculate_summary.dart';
import '../domain/usecases/delete_entry.dart' as usecase;
import '../domain/usecases/update_entry.dart';
import '../domain/usecases/duplicate_budget.dart';
import '../domain/usecases/save_recurring_transaction.dart';
import '../domain/usecases/confirm_potential_transaction.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository repository;
  final AddIncome addIncomeUseCase;
  final AddExpense addExpenseUseCase;
  final CalculateSummary calculateSummaryUseCase;
  final usecase.DeleteEntry deleteEntryUseCase;
  final UpdateEntry updateEntryUseCase;
  final SaveRecurringTransaction saveRecurringTransactionUseCase;
  final DuplicateBudget duplicateBudgetUseCase;
  final ConfirmPotentialTransaction confirmPotentialTransactionUseCase;
  final Uuid _uuid = const Uuid();

  BudgetBloc({
    required this.repository,
    required this.addIncomeUseCase,
    required this.addExpenseUseCase,
    required this.calculateSummaryUseCase,
    required this.deleteEntryUseCase,
    required this.updateEntryUseCase,
    required this.saveRecurringTransactionUseCase,
    required this.duplicateBudgetUseCase,
    required this.confirmPotentialTransactionUseCase,
  }) : super(const BudgetInitial()) {
    on<AddIncomeEvent>(_onAddIncome);
    on<AddExpenseEvent>(_onAddExpense);
    on<LoadSummaryEvent>(_onLoadSummary);
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<DeleteEntryEvent>(_onDeleteEntry);
    on<UpdateIncomeEvent>(_onUpdateIncome);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<SaveRecurringTransactionEvent>(_onSaveRecurringTransaction);
    on<DuplicateBudgetEvent>(_onDuplicateBudget);
    on<ConfirmPotentialTransactionEvent>(_onConfirmPotentialTransaction);
    on<DeleteBudgetEvent>(_onDeleteBudget);
    on<ClearAllBudgetsEvent>(_onClearAllBudgets);
    on<FactoryResetEvent>(_onFactoryReset);
    on<ConvertBudgetEvent>(_onConvertBudget);
    on<UpdateExchangeRateEvent>(_onUpdateExchangeRate);
  }

  Future<void> _onConfirmPotentialTransaction(
    ConfirmPotentialTransactionEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await confirmPotentialTransactionUseCase(
        incomeId: event.incomeId,
        expenseId: event.expenseId,
      );
      emit(const EntryUpdated()); // Or a new state if preferred
      // Refresh summary
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onDuplicateBudget(
    DuplicateBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      emit(const BudgetLoading());
      await duplicateBudgetUseCase(
        sourceBudget: event.sourceBudget,
        targetPeriod: event.targetPeriod,
        newName: event.newName,
        includeTransactions: event.includeTransactions,
      );
      // Once duplicated, we might want to reload available periods,
      // but that is handled by NavigationBloc. Here we just emit a success state.
      // Alternatively, we can just load the summary for the new period.
      add(LoadSummaryEvent(period: event.targetPeriod));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onSaveRecurringTransaction(
    SaveRecurringTransactionEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await saveRecurringTransactionUseCase(event.recurring);
      // Optional: emit a specific state if needed, or just reload summary
      add(
        LoadSummaryEvent(
          period: BudgetPeriod.fromDate(event.recurring.startDate),
        ),
      );
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onAddIncome(
    AddIncomeEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      final income = IncomeEntry(
        id: event.id.isEmpty ? _uuid.v4() : event.id,
        budgetId: event.budgetId,
        amount: event.amount,
        categoryId: event.categoryId,
        description: event.description,
        date: event.date,
        isPotential: event.isPotential,
      );
      await addIncomeUseCase(income);
      emit(const IncomeAdded());
      add(
        LoadSummaryEvent(
          period: BudgetPeriod.fromDate(event.date),
          budgetId: event.budgetId,
        ),
      );
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      final expense = ExpenseEntry(
        id: event.id.isEmpty ? _uuid.v4() : event.id,
        budgetId: event.budgetId,
        amount: event.amount,
        categoryId: event.category,
        description: event.description,
        date: event.date,
        isPotential: event.isPotential,
      );
      await addExpenseUseCase(expense);
      emit(const ExpenseAdded());
      add(
        LoadSummaryEvent(
          period: BudgetPeriod.fromDate(event.date),
          budgetId: event.budgetId,
        ),
      );
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onLoadSummary(
    LoadSummaryEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(const BudgetLoading());
    try {
      final summary = await calculateSummaryUseCase(
        period: event.period,
        budgetId: event.budgetId,
      );
      emit(SummaryLoaded(summary));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      final categories = await repository.getCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onDeleteEntry(
    DeleteEntryEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await deleteEntryUseCase(
        event.id,
        event.type == EntryType.income
            ? usecase.EntryType.income
            : usecase.EntryType.expense,
      );
      emit(const EntryDeleted()); // Trigger reload in UI
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onUpdateIncome(
    UpdateIncomeEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await updateEntryUseCase(income: event.income);
      emit(const EntryUpdated());
      add(
        LoadSummaryEvent(
          period: BudgetPeriod.fromDate(event.income.date),
          budgetId: event.income.budgetId,
        ),
      );
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpenseEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await updateEntryUseCase(expense: event.expense);
      emit(const EntryUpdated());
      add(
        LoadSummaryEvent(
          period: BudgetPeriod.fromDate(event.expense.date),
          budgetId: event.expense.budgetId,
        ),
      );
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onDeleteBudget(
    DeleteBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await repository.deleteBudget(event.budgetId);
      emit(const BudgetDeleted());
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onClearAllBudgets(
    ClearAllBudgetsEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await repository.clearAllBudgets();
      emit(const BudgetsCleared());
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onFactoryReset(
    FactoryResetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await repository.factoryReset();
      emit(const FactoryResetComplete());
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onConvertBudget(
    ConvertBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      if (event.exchangeRate <= 0) {
        emit(const BudgetError('Exchange rate must be greater than zero'));
        return;
      }

      final budget = await repository.getBudget(event.budgetId);
      if (budget == null) {
        emit(const BudgetError('Budget not found'));
        return;
      }

      final updatedBudget = budget.copyWith(
        targetCurrencyCode: event.targetCurrencyCode,
        exchangeRate: event.exchangeRate,
        convertedAmount: null,
      );

      await repository.updateBudget(updatedBudget);

      emit(
        BudgetConverted(
          budgetId: event.budgetId,
          targetCurrencyCode: event.targetCurrencyCode,
          exchangeRate: event.exchangeRate,
          convertedAmount: 0,
        ),
      );
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onUpdateExchangeRate(
    UpdateExchangeRateEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      if (event.exchangeRate <= 0) {
        emit(const BudgetError('Exchange rate must be greater than zero'));
        return;
      }

      final budget = await repository.getBudget(event.budgetId);
      if (budget == null) {
        emit(const BudgetError('Budget not found'));
        return;
      }

      final convertedAmount =
          budget.convertedAmount != null && budget.exchangeRate != null
          ? budget.convertedAmount! * event.exchangeRate / budget.exchangeRate!
          : null;

      final updatedBudget = budget.copyWith(
        exchangeRate: event.exchangeRate,
        convertedAmount: convertedAmount,
      );

      await repository.updateBudget(updatedBudget);

      emit(
        BudgetConverted(
          budgetId: event.budgetId,
          targetCurrencyCode: budget.targetCurrencyCode ?? '',
          exchangeRate: event.exchangeRate,
          convertedAmount: convertedAmount ?? 0,
        ),
      );
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }
}
