import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/financial_tools/domain/entities/amortization_point.dart';

void main() {
  group('AmortizationPoint', () {
    test('should create AmortizationPoint with all fields', () {
      const point = AmortizationPoint(
        month: 1,
        principalPaid: 800.0,
        interestPaid: 200.0,
        remainingBalance: 99200.0,
      );

      expect(point.month, 1);
      expect(point.principalPaid, 800.0);
      expect(point.interestPaid, 200.0);
      expect(point.remainingBalance, 99200.0);
    });

    test('props should contain all fields', () {
      const point = AmortizationPoint(
        month: 12,
        principalPaid: 9500.0,
        interestPaid: 1500.0,
        remainingBalance: 5000.0,
      );

      expect(point.props, [12, 9500.0, 1500.0, 5000.0]);
    });

    test('two points with same values should be equal', () {
      const point1 = AmortizationPoint(
        month: 1,
        principalPaid: 100.0,
        interestPaid: 50.0,
        remainingBalance: 9950.0,
      );

      const point2 = AmortizationPoint(
        month: 1,
        principalPaid: 100.0,
        interestPaid: 50.0,
        remainingBalance: 9950.0,
      );

      expect(point1, equals(point2));
    });

    test('two points with different values should not be equal', () {
      const point1 = AmortizationPoint(
        month: 1,
        principalPaid: 100.0,
        interestPaid: 50.0,
        remainingBalance: 9950.0,
      );

      const point2 = AmortizationPoint(
        month: 2,
        principalPaid: 100.0,
        interestPaid: 50.0,
        remainingBalance: 9950.0,
      );

      expect(point1, isNot(equals(point2)));
    });
  });
}
