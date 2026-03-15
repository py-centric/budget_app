import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/financial_tools/domain/usecases/solve_interest_rate.dart';
import 'package:budget_app/features/financial_tools/domain/usecases/convert_rate.dart';

void main() {
  group('InterestRateSolver', () {
    final solver = InterestRateSolver();

    test('should solve for interest rate correctly', () {
      // $10,000 principal, 12 months, $888.49 payment -> should be 12%
      final rate = solver.solve(
        principal: 10000,
        months: 12,
        monthlyPayment: 888.49,
      );
      expect(rate, closeTo(12.0, 0.1));
    });

    test('should return 0 for payment equal to principal/months', () {
      final rate = solver.solve(
        principal: 10000,
        months: 10,
        monthlyPayment: 1000,
      );
      expect(rate, 0.0);
    });
  });

  group('RateConverter', () {
    final converter = RateConverter();

    test('should convert simple to compound correctly', () {
      // 10% simple compounded monthly -> (1 + 0.1/12)^12 - 1 = 10.47%
      final compound = converter.simpleToCompound(simpleRate: 10);
      expect(compound, closeTo(10.47, 0.01));
    });

    test('should convert compound to simple correctly', () {
      final simple = converter.compoundToSimple(compoundRate: 10.47);
      expect(simple, closeTo(10.0, 0.01));
    });
  });
}
