import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/accounts/domain/usecases/calculate_loan_amortization.dart';

void main() {
  group('LoanAmortizationCalculator', () {
    test('calculates correct payoff months and interest for simple loan', () {
      final schedule = LoanAmortizationCalculator.calculate(
        principal: 1000.0,
        annualInterestRateApr: 12.0, // 1% per month
        monthlyPayment: 200.0,
      );

      expect(schedule.totalMonthsToPayoff, equals(6));
      expect(schedule.totalInterestPaid, greaterThan(0));
      expect(schedule.schedule.last.remainingBalance, equals(0.0));
    });

    test('handles 0% interest loans correctly', () {
      final schedule = LoanAmortizationCalculator.calculate(
        principal: 1000.0,
        annualInterestRateApr: 0.0,
        monthlyPayment: 250.0,
      );

      expect(schedule.totalMonthsToPayoff, equals(4));
      expect(schedule.totalInterestPaid, equals(0.0));
    });

    test('returns empty schedule for non-positive input', () {
      final schedule = LoanAmortizationCalculator.calculate(
        principal: 0.0,
        annualInterestRateApr: 5.0,
        monthlyPayment: 100.0,
      );

      expect(schedule.totalMonthsToPayoff, equals(0));
      expect(schedule.schedule, isEmpty);
    });
  });
}
