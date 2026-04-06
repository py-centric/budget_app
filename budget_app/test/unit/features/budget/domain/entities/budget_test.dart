import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';

void main() {
  group('Budget', () {
    test('should create Budget with required fields', () {
      const budget = Budget(
        id: '1',
        name: 'January 2024',
        periodMonth: 1,
        periodYear: 2024,
      );

      expect(budget.id, '1');
      expect(budget.name, 'January 2024');
      expect(budget.periodMonth, 1);
      expect(budget.periodYear, 2024);
      expect(budget.isActive, true);
      expect(budget.currencyCode, isNull);
    });

    test('should create Budget with all fields', () {
      const budget = Budget(
        id: '1',
        name: 'January 2024',
        periodMonth: 1,
        periodYear: 2024,
        isActive: false,
        currencyCode: 'USD',
        targetCurrencyCode: 'EUR',
        exchangeRate: 0.85,
        convertedAmount: 8500.0,
      );

      expect(budget.id, '1');
      expect(budget.name, 'January 2024');
      expect(budget.isActive, false);
      expect(budget.currencyCode, 'USD');
      expect(budget.targetCurrencyCode, 'EUR');
      expect(budget.exchangeRate, 0.85);
      expect(budget.convertedAmount, 8500.0);
    });

    test('copyWith should create a copy with updated fields', () {
      const original = Budget(
        id: '1',
        name: 'Original Budget',
        periodMonth: 1,
        periodYear: 2024,
      );

      final copied = original.copyWith(name: 'New Budget', isActive: false);

      expect(copied.id, '1');
      expect(copied.name, 'New Budget');
      expect(copied.periodMonth, 1);
      expect(copied.isActive, false);
    });

    test('props should contain all fields', () {
      const budget = Budget(
        id: '1',
        name: 'Test Budget',
        periodMonth: 6,
        periodYear: 2024,
        isActive: true,
        currencyCode: 'GBP',
      );

      expect(budget.props, [
        '1',
        'Test Budget',
        6,
        2024,
        true,
        'GBP',
        null,
        null,
        null,
      ]);
    });

    test('two budgets with same values should be equal', () {
      const budget1 = Budget(
        id: '1',
        name: 'Test',
        periodMonth: 1,
        periodYear: 2024,
      );

      const budget2 = Budget(
        id: '1',
        name: 'Test',
        periodMonth: 1,
        periodYear: 2024,
      );

      expect(budget1, equals(budget2));
    });

    test('two budgets with different values should not be equal', () {
      const budget1 = Budget(
        id: '1',
        name: 'Budget A',
        periodMonth: 1,
        periodYear: 2024,
      );

      const budget2 = Budget(
        id: '2',
        name: 'Budget B',
        periodMonth: 2,
        periodYear: 2024,
      );

      expect(budget1, isNot(equals(budget2)));
    });
  });
}
