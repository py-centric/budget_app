import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/financial_health/domain/entities/financial_health_score.dart';

void main() {
  group('FinancialHealthScore', () {
    final score = FinancialHealthScore(
      savingsRate: 20.0,
      savingsRateGrade: HealthMetricType.good,
      debtToIncomeRatio: 15.0,
      debtToIncomeGrade: HealthMetricType.excellent,
      emergencyFundMonths: 6.0,
      emergencyFundGrade: HealthMetricType.good,
      overallScore: 82,
      overallGrade: HealthMetricType.good,
      totalIncome: 100000,
      totalExpenses: 80000,
      totalDebt: 25000,
      totalSavings: 20000,
    );

    test('props are correct', () {
      expect(score.props, [
        20.0, HealthMetricType.good,
        15.0, HealthMetricType.excellent,
        6.0, HealthMetricType.good,
        82, HealthMetricType.good,
        100000, 80000, 25000, 20000,
      ]);
    });

    test('equality works', () {
      final score2 = FinancialHealthScore(
        savingsRate: 20.0,
        savingsRateGrade: HealthMetricType.good,
        debtToIncomeRatio: 15.0,
        debtToIncomeGrade: HealthMetricType.excellent,
        emergencyFundMonths: 6.0,
        emergencyFundGrade: HealthMetricType.good,
        overallScore: 82,
        overallGrade: HealthMetricType.good,
        totalIncome: 100000,
        totalExpenses: 80000,
        totalDebt: 25000,
        totalSavings: 20000,
      );
      expect(score, equals(score2));
    });

    test('inequality with different score', () {
      final score2 = FinancialHealthScore(
        savingsRate: 20.0,
        savingsRateGrade: HealthMetricType.good,
        debtToIncomeRatio: 15.0,
        debtToIncomeGrade: HealthMetricType.excellent,
        emergencyFundMonths: 6.0,
        emergencyFundGrade: HealthMetricType.good,
        overallScore: 90,
        overallGrade: HealthMetricType.excellent,
        totalIncome: 100000,
        totalExpenses: 80000,
        totalDebt: 25000,
        totalSavings: 20000,
      );
      expect(score, isNot(equals(score2)));
    });

    test('HealthMetricType has correct values', () {
      expect(HealthMetricType.values.length, 4);
      expect(HealthMetricType.values, contains(HealthMetricType.excellent));
      expect(HealthMetricType.values, contains(HealthMetricType.good));
      expect(HealthMetricType.values, contains(HealthMetricType.fair));
      expect(HealthMetricType.values, contains(HealthMetricType.poor));
    });
  });
}
