import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/accounts/domain/usecases/calculate_savings_growth.dart';

void main() {
  group('SavingsGrowthCalculator', () {
    test('calculates correct savings compound growth over time', () {
      final projection = SavingsGrowthCalculator.calculateProjectedGrowth(
        initialBalance: 1000.0,
        monthlyContribution: 100.0,
        annualInterestRateApy: 5.0,
        durationInMonths: 12,
      );

      expect(projection.totalContributions, equals(2200.0));
      expect(projection.finalBalance, greaterThan(2200.0));
      expect(projection.totalInterestEarned, greaterThan(0.0));
    });

    test('handles 0% APY savings account correctly', () {
      final projection = SavingsGrowthCalculator.calculateProjectedGrowth(
        initialBalance: 500.0,
        monthlyContribution: 50.0,
        annualInterestRateApy: 0.0,
        durationInMonths: 6,
      );

      expect(projection.finalBalance, equals(800.0));
      expect(projection.totalInterestEarned, equals(0.0));
    });
  });
}
