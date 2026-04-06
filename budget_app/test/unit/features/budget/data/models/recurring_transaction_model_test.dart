import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/data/models/recurring_transaction_model.dart';
import 'package:budget_app/features/budget/domain/entities/recurring_transaction.dart';

void main() {
  group('RecurringTransactionModel', () {
    test('should create RecurringTransactionModel with required fields', () {
      final model = RecurringTransactionModel(
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

      expect(model.id, '1');
      expect(model.budgetId, 'budget-1');
      expect(model.type, 'INCOME');
      expect(model.amount, 1000.0);
    });

    test('should create RecurringTransactionModel fromMap', () {
      final map = {
        'id': '1',
        'budget_id': 'budget-1',
        'type': 'EXPENSE',
        'amount': 500.0,
        'category_id': 'cat-2',
        'description': 'Rent',
        'start_date': '2024-01-01T00:00:00.000',
        'end_date': '2024-12-31T00:00:00.000',
        'recurrence_interval': 1,
        'recurrence_unit': 'MONTHS',
      };

      final model = RecurringTransactionModel.fromMap(map);

      expect(model.id, '1');
      expect(model.budgetId, 'budget-1');
      expect(model.type, 'EXPENSE');
      expect(model.amount, 500.0);
      expect(model.categoryId, 'cat-2');
      expect(model.description, 'Rent');
      expect(model.startDate, DateTime(2024, 1, 1));
      expect(model.endDate, DateTime(2024, 12, 31));
      expect(model.interval, 1);
      expect(model.unit, RecurrenceUnit.months);
    });

    test('should handle null budget_id in fromMap', () {
      final map = {
        'id': '1',
        'type': 'INCOME',
        'amount': 100.0,
        'category_id': 'cat-1',
        'description': 'Test',
        'start_date': '2024-01-01T00:00:00.000',
        'recurrence_interval': 1,
        'recurrence_unit': 'WEEKS',
      };

      final model = RecurringTransactionModel.fromMap(map);

      expect(model.budgetId, 'default');
    });

    test('toMap should return correct map', () {
      final model = RecurringTransactionModel(
        id: '1',
        budgetId: 'budget-1',
        type: 'INCOME',
        amount: 1000.0,
        categoryId: 'cat-1',
        description: 'Salary',
        startDate: DateTime(2024, 1, 1),
        interval: 2,
        unit: RecurrenceUnit.weeks,
      );

      final map = model.toMap();

      expect(map['id'], '1');
      expect(map['budget_id'], 'budget-1');
      expect(map['type'], 'INCOME');
      expect(map['amount'], 1000.0);
      expect(map['recurrence_interval'], 2);
      expect(map['recurrence_unit'], 'WEEKS');
    });

    test('fromEntity should create model from entity', () {
      final entity = RecurringTransaction(
        id: '1',
        budgetId: 'b-1',
        type: 'EXPENSE',
        amount: 200.0,
        categoryId: 'c-1',
        description: 'Test',
        startDate: DateTime(2024, 1, 1),
        interval: 1,
        unit: RecurrenceUnit.years,
      );

      final model = RecurringTransactionModel.fromEntity(entity);

      expect(model.id, '1');
      expect(model.budgetId, 'b-1');
      expect(model.type, 'EXPENSE');
      expect(model.amount, 200.0);
      expect(model.unit, RecurrenceUnit.years);
    });

    test(
      'RecurringTransactionModel should be a subtype of RecurringTransaction',
      () {
        final model = RecurringTransactionModel(
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

        expect(model, isA<RecurringTransaction>());
      },
    );
  });
}
