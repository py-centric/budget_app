import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/financial_tools/domain/entities/saved_calculation.dart';

void main() {
  group('SavedCalculation', () {
    test('should create SavedCalculation with all fields', () {
      final calc = SavedCalculation(
        id: '1',
        type: 'loan',
        name: 'My Loan',
        data: {'principal': 100000, 'rate': 5.0, 'term': 360},
        createdAt: DateTime(2024, 1, 15),
      );

      expect(calc.id, '1');
      expect(calc.type, 'loan');
      expect(calc.name, 'My Loan');
      expect(calc.data['principal'], 100000);
      expect(calc.data['rate'], 5.0);
      expect(calc.createdAt, DateTime(2024, 1, 15));
    });

    test('props should contain all fields', () {
      final calc = SavedCalculation(
        id: '2',
        type: 'savings',
        name: 'Emergency Fund',
        data: {'monthly': 500},
        createdAt: DateTime(2024, 3, 1),
      );

      expect(calc.props.length, 5);
      expect(calc.props[0], '2');
      expect(calc.props[1], 'savings');
      expect(calc.props[2], 'Emergency Fund');
    });

    test('two calculations with same values should be equal', () {
      final calc1 = SavedCalculation(
        id: '1',
        type: 'loan',
        name: 'Test',
        data: {},
        createdAt: DateTime(2024, 1, 1),
      );

      final calc2 = SavedCalculation(
        id: '1',
        type: 'loan',
        name: 'Test',
        data: {},
        createdAt: DateTime(2024, 1, 1),
      );

      expect(calc1, equals(calc2));
    });

    test('two calculations with different values should not be equal', () {
      final calc1 = SavedCalculation(
        id: '1',
        type: 'loan',
        name: 'Test 1',
        data: {},
        createdAt: DateTime(2024, 1, 1),
      );

      final calc2 = SavedCalculation(
        id: '2',
        type: 'loan',
        name: 'Test 2',
        data: {},
        createdAt: DateTime(2024, 1, 1),
      );

      expect(calc1, isNot(equals(calc2)));
    });
  });
}
