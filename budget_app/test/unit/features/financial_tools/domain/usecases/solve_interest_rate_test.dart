import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/financial_tools/domain/usecases/solve_interest_rate.dart';

void main() {
  late InterestRateSolver solver;

  setUp(() {
    solver = InterestRateSolver();
  });

  group('InterestRateSolver', () {
    test('solve should return 0 when payment is too low', () {
      final result = solver.solve(
        principal: 10000.0,
        months: 12,
        monthlyPayment: 500.0, // Too low - would never pay off
      );

      expect(result, 0.0);
    });

    test('solve should calculate approximate rate correctly', () {
      // $10,000 loan, 12 months, ~$860/month = ~5% annual rate
      final result = solver.solve(
        principal: 10000.0,
        months: 12,
        monthlyPayment: 856.0,
      );

      expect(result, closeTo(5.0, 1.0));
    });

    test('solve should handle longer terms', () {
      // $10,000 loan, 60 months, ~$212/month = ~10% annual rate
      final result = solver.solve(
        principal: 10000.0,
        months: 60,
        monthlyPayment: 212.0,
      );

      expect(result, closeTo(10.0, 3.0));
    });

    test('solve should use custom guess', () {
      final result = solver.solve(
        principal: 10000.0,
        months: 12,
        monthlyPayment: 856.0,
        guess: 0.005,
      );

      expect(result, greaterThan(0));
    });

    test('solve should converge within max iterations', () {
      final result = solver.solve(
        principal: 10000.0,
        months: 24,
        monthlyPayment: 450.0,
      );

      expect(result, greaterThan(0));
    });
  });
}
