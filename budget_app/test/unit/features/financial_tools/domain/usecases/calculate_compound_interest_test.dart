import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/financial_tools/domain/usecases/calculate_compound_interest.dart';
import 'package:budget_app/features/financial_tools/domain/usecases/calculate_amortization.dart';

void main() {
  late CalculateCompoundInterest calculateCompoundInterest;

  setUp(() {
    calculateCompoundInterest = CalculateCompoundInterest();
  });

  group('Compound Interest (Savings)', () {
    test('should calculate future value correctly', () {
      // $1,000 initial, $100 monthly, 10% for 5 years
      final value = calculateCompoundInterest.calculateFutureValue(
        initialDeposit: 1000,
        monthlyContribution: 100,
        annualRate: 10,
        years: 5,
        type: InterestType.compound,
      );
      expect(value, closeTo(9389.01, 1.0));
    });

    test('should calculate schedule correctly', () {
      final schedule = calculateCompoundInterest(
        initialDeposit: 1000,
        monthlyContribution: 100,
        annualRate: 10,
        years: 5,
        type: InterestType.compound,
      );
      expect(schedule.length, 60);
      expect(schedule.last.remainingBalance, closeTo(9389.01, 1.0));
    });
  });

  group('Simple Interest (Savings)', () {
    test('should calculate future value correctly', () {
      // $1,000 initial, $100 monthly, 10% simple for 5 years
      // Simple interest only on the $1,000 principal = $1,000 * 0.1 * 5 = $500.
      // Total principal saved = $1,000 + ($100 * 60) = $7,000.
      // Total = $7,500.
      final value = calculateCompoundInterest.calculateFutureValue(
        initialDeposit: 1000,
        monthlyContribution: 100,
        annualRate: 10,
        years: 5,
        type: InterestType.simple,
      );
      expect(value, 7500.0);
    });
  });
}
