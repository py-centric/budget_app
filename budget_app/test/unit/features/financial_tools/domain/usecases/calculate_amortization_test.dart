import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/financial_tools/domain/usecases/calculate_amortization.dart';

void main() {
  late CalculateAmortization calculateAmortization;

  setUp(() {
    calculateAmortization = CalculateAmortization();
  });

  group('Compound Interest', () {
    test('should calculate monthly payment correctly', () {
      // $10,000 at 12% for 1 year
      final payment = calculateAmortization.calculateMonthlyPayment(
        principal: 10000,
        annualRate: 12,
        years: 1,
        type: InterestType.compound,
      );
      expect(payment, closeTo(888.49, 0.01));
    });

    test('should calculate amortization schedule correctly', () {
      final schedule = calculateAmortization(
        principal: 10000,
        annualRate: 12,
        years: 1,
        type: InterestType.compound,
      );
      expect(schedule.length, 12);
      expect(schedule.last.remainingBalance, closeTo(0, 0.01));
    });
  });

  group('Simple Interest', () {
    test('should calculate monthly payment correctly', () {
      // $10,000 at 12% simple for 1 year = $1,200 interest. Total $11,200.
      // $11,200 / 12 = $933.33
      final payment = calculateAmortization.calculateMonthlyPayment(
        principal: 10000,
        annualRate: 12,
        years: 1,
        type: InterestType.simple,
      );
      expect(payment, closeTo(933.33, 0.01));
    });

    test('should calculate schedule correctly', () {
      final schedule = calculateAmortization(
        principal: 10000,
        annualRate: 12,
        years: 1,
        type: InterestType.simple,
      );
      expect(schedule.length, 12);
      expect(schedule.last.remainingBalance, closeTo(0, 0.01));
      // Each month should have 1/12th of total interest
      expect(schedule.first.interestPaid, 100.0);
    });
  });

  group('Reduced Term', () {
    test('should calculate reduced term correctly', () {
      // Standard payment for $10k, 12%, 1yr is $888.49.
      // If we pay $1000, it should be less than 12 months.
      final months = calculateAmortization.calculateReducedTerm(
        principal: 10000,
        annualRate: 12,
        monthlyPayment: 1000,
      );
      expect(months, 11); // Approximately 10.5 months
    });

    test('should handle never paid off scenario', () {
      // $10k at 12% interest is $100/mo interest.
      // If we pay $50, we never pay it off.
      final months = calculateAmortization.calculateReducedTerm(
        principal: 10000,
        annualRate: 12,
        monthlyPayment: 50,
      );
      expect(months, 999);
    });
  });
}
