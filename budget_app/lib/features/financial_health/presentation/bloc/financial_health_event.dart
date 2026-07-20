import 'package:equatable/equatable.dart';
import '../../domain/entities/financial_health_score.dart';

abstract class FinancialHealthEvent extends Equatable {
  const FinancialHealthEvent();
  @override
  List<Object?> get props => [];
}

class CalculateHealthScore extends FinancialHealthEvent {
  final double monthlyIncome;
  final double monthlyExpenses;
  final double totalDebt;
  final double totalSavings;
  const CalculateHealthScore({
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.totalDebt,
    required this.totalSavings,
  });
  @override
  List<Object?> get props => [monthlyIncome, monthlyExpenses, totalDebt, totalSavings];
}
