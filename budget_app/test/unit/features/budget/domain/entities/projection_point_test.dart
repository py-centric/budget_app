import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/projection_point.dart';

void main() {
  group('ProjectionPoint', () {
    test('should create with required fields', () {
      final point = ProjectionPoint(
        date: DateTime(2024, 6, 1),
        balance: 2000.0,
        netChange: 500.0,
        actualBalance: 2000.0,
        potentialBalance: 2500.0,
        netChangeActual: 500.0,
        netChangePotential: 1000.0,
        isWeekEnding: false,
      );

      expect(point.date, DateTime(2024, 6, 1));
      expect(point.balance, 2000.0);
      expect(point.actualBalance, 2000.0);
      expect(point.potentialBalance, 2500.0);
    });

    test('should detect negative balance', () {
      final point = ProjectionPoint(
        date: DateTime(2024, 6, 1),
        balance: -500.0,
        netChange: -500.0,
        actualBalance: -500.0,
        potentialBalance: -200.0,
        netChangeActual: -500.0,
        netChangePotential: -200.0,
        isWeekEnding: false,
      );

      expect(point.isNegative, true);
      expect(point.isPotentialNegative, true);
    });

    test('should detect positive balance', () {
      final point = ProjectionPoint(
        date: DateTime(2024, 6, 1),
        balance: 1000.0,
        netChange: 200.0,
        actualBalance: 1000.0,
        potentialBalance: 1200.0,
        netChangeActual: 200.0,
        netChangePotential: 400.0,
        isWeekEnding: false,
      );

      expect(point.isNegative, false);
      expect(point.isPotentialNegative, false);
    });
  });
}
