import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/recurring_transaction.dart';

void main() {
  group('RecurringTransaction', () {
    test('should create RecurringTransaction with required fields', () {
      final transaction = RecurringTransaction(
        id: '1',
        budgetId: 'budget-1',
        type: 'INCOME',
        amount: 1000.0,
        categoryId: 'cat-1',
        description: 'Monthly Salary',
        startDate: DateTime(2024, 1, 1),
        interval: 1,
        unit: RecurrenceUnit.months,
      );

      expect(transaction.id, '1');
      expect(transaction.budgetId, 'budget-1');
      expect(transaction.type, 'INCOME');
      expect(transaction.amount, 1000.0);
      expect(transaction.categoryId, 'cat-1');
      expect(transaction.description, 'Monthly Salary');
      expect(transaction.startDate, DateTime(2024, 1, 1));
      expect(transaction.endDate, isNull);
      expect(transaction.interval, 1);
      expect(transaction.unit, RecurrenceUnit.months);
    });

    test('should create RecurringTransaction with all fields', () {
      final transaction = RecurringTransaction(
        id: '1',
        budgetId: 'budget-1',
        type: 'EXPENSE',
        amount: 500.0,
        categoryId: 'cat-2',
        description: 'Rent',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        interval: 1,
        unit: RecurrenceUnit.months,
      );

      expect(transaction.type, 'EXPENSE');
      expect(transaction.endDate, DateTime(2024, 12, 31));
    });

    test('RecurrenceUnit enum should have correct values', () {
      expect(RecurrenceUnit.values.length, 4);
      expect(RecurrenceUnit.days.index, 0);
      expect(RecurrenceUnit.weeks.index, 1);
      expect(RecurrenceUnit.months.index, 2);
      expect(RecurrenceUnit.years.index, 3);
    });

    test('props should contain all fields', () {
      final transaction = RecurringTransaction(
        id: '1',
        budgetId: 'b-1',
        type: 'INCOME',
        amount: 100.0,
        categoryId: 'c-1',
        description: 'Test',
        startDate: DateTime(2024, 1, 1),
        interval: 2,
        unit: RecurrenceUnit.weeks,
      );

      expect(transaction.props.length, 10);
      expect(transaction.props[0], '1');
      expect(transaction.props[1], 'b-1');
      expect(transaction.props[2], 'INCOME');
    });

    test('two transactions with same values should be equal', () {
      final t1 = RecurringTransaction(
        id: '1',
        budgetId: 'b-1',
        type: 'INCOME',
        amount: 100.0,
        categoryId: 'c-1',
        description: 'Test',
        startDate: DateTime(2024, 1, 1),
        interval: 1,
        unit: RecurrenceUnit.months,
      );

      final t2 = RecurringTransaction(
        id: '1',
        budgetId: 'b-1',
        type: 'INCOME',
        amount: 100.0,
        categoryId: 'c-1',
        description: 'Test',
        startDate: DateTime(2024, 1, 1),
        interval: 1,
        unit: RecurrenceUnit.months,
      );

      expect(t1, equals(t2));
    });
  });
}
