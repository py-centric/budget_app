import 'package:equatable/equatable.dart';

enum HealthMetricType { excellent, good, fair, poor }

class FinancialHealthScore extends Equatable {
  final double savingsRate;
  final HealthMetricType savingsRateGrade;
  final double debtToIncomeRatio;
  final HealthMetricType debtToIncomeGrade;
  final double emergencyFundMonths;
  final HealthMetricType emergencyFundGrade;
  final int overallScore;
  final HealthMetricType overallGrade;
  final double totalIncome;
  final double totalExpenses;
  final double totalDebt;
  final double totalSavings;

  const FinancialHealthScore({
    required this.savingsRate,
    required this.savingsRateGrade,
    required this.debtToIncomeRatio,
    required this.debtToIncomeGrade,
    required this.emergencyFundMonths,
    required this.emergencyFundGrade,
    required this.overallScore,
    required this.overallGrade,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalDebt,
    required this.totalSavings,
  });

  @override
  List<Object?> get props => [
        savingsRate, savingsRateGrade,
        debtToIncomeRatio, debtToIncomeGrade,
        emergencyFundMonths, emergencyFundGrade,
        overallScore, overallGrade,
        totalIncome, totalExpenses, totalDebt, totalSavings,
      ];
}
