import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/emergency_fund/domain/repositories/emergency_fund_repository.dart';
import 'package:budget_app/features/emergency_fund/domain/entities/emergency_expense.dart';
import 'package:uuid/uuid.dart';
import 'emergency_fund_event.dart';
import 'emergency_fund_state.dart';

class EmergencyFundBloc extends Bloc<EmergencyFundEvent, EmergencyFundState> {
  final EmergencyFundRepository _repository;
  StreamSubscription<double>? _totalTargetSubscription;

  EmergencyFundBloc(this._repository) : super(const EmergencyFundState()) {
    on<LoadEmergencyFund>(_onLoadEmergencyFund);
    on<UpdateExpenseAmount>(_onUpdateExpenseAmount);
    on<AddCustomExpense>(_onAddCustomExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<CalculateLivingExpenses>(_onCalculateLivingExpenses);

    _totalTargetSubscription = _repository.watchTotalTarget().listen((total) {
      add(LoadEmergencyFund());
    });
  }

  Future<void> _onLoadEmergencyFund(
    LoadEmergencyFund event,
    Emitter<EmergencyFundState> emit,
  ) async {
    if (state.status == EmergencyFundStatus.initial) {
      emit(state.copyWith(status: EmergencyFundStatus.loading));
    }
    
    try {
      final expenses = await _repository.getExpenses();
      final average = await _repository.getAverageMonthlySpending();
      final total = expenses.fold<double>(0, (sum, item) => sum + item.amount);
      
      emit(state.copyWith(
        status: EmergencyFundStatus.success,
        expenses: expenses,
        averageMonthlySpending: average,
        totalTarget: total,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EmergencyFundStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateExpenseAmount(
    UpdateExpenseAmount event,
    Emitter<EmergencyFundState> emit,
  ) async {
    try {
      final expense = state.expenses.firstWhere((e) => e.id == event.id);
      final updatedExpense = expense.copyWith(amount: event.amount);
      await _repository.saveExpense(updatedExpense);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _onAddCustomExpense(
    AddCustomExpense event,
    Emitter<EmergencyFundState> emit,
  ) async {
    try {
      // Check if an expense with the same categoryType already exists
      if (event.categoryType != null) {
        final existingIndex = state.expenses.indexWhere((e) => e.categoryType == event.categoryType);
        if (existingIndex != -1) {
          final existing = state.expenses[existingIndex];
          final updated = existing.copyWith(
            name: event.name,
            amount: event.amount,
          );
          await _repository.saveExpense(updated);
          return;
        }
      }

      final newExpense = EmergencyExpense(
        id: const Uuid().v4(),
        name: event.name,
        amount: event.amount,
        isSuggestion: false,
        categoryType: event.categoryType,
        sortOrder: state.expenses.length,
      );
      await _repository.saveExpense(newExpense);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<EmergencyFundState> emit,
  ) async {
    try {
      await _repository.deleteExpense(event.id);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _onCalculateLivingExpenses(
    CalculateLivingExpenses event,
    Emitter<EmergencyFundState> emit,
  ) async {
    final average = await _repository.getAverageMonthlySpending();
    final total = average * event.months;
    emit(state.copyWith(
      averageMonthlySpending: average,
      calculatedLivingExpenses: total,
    ));
  }

  @override
  Future<void> close() {
    _totalTargetSubscription?.cancel();
    return super.close();
  }
}
