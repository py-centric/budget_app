import 'package:equatable/equatable.dart';
import 'package:budget_app/features/emergency_fund/domain/entities/emergency_expense.dart';

enum EmergencyFundStatus { initial, loading, success, failure }

class EmergencyFundState extends Equatable {
  final EmergencyFundStatus status;
  final List<EmergencyExpense> expenses;
  final double totalTarget;
  final double averageMonthlySpending;
  final double calculatedLivingExpenses;
  final String? errorMessage;

  const EmergencyFundState({
    this.status = EmergencyFundStatus.initial,
    this.expenses = const [],
    this.totalTarget = 0.0,
    this.averageMonthlySpending = 0.0,
    this.calculatedLivingExpenses = 0.0,
    this.errorMessage,
  });

  EmergencyFundState copyWith({
    EmergencyFundStatus? status,
    List<EmergencyExpense>? expenses,
    double? totalTarget,
    double? averageMonthlySpending,
    double? calculatedLivingExpenses,
    String? errorMessage,
  }) {
    return EmergencyFundState(
      status: status ?? this.status,
      expenses: expenses ?? this.expenses,
      totalTarget: totalTarget ?? this.totalTarget,
      averageMonthlySpending: averageMonthlySpending ?? this.averageMonthlySpending,
      calculatedLivingExpenses: calculatedLivingExpenses ?? this.calculatedLivingExpenses,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    expenses,
    totalTarget,
    averageMonthlySpending,
    calculatedLivingExpenses,
    errorMessage,
  ];
}
