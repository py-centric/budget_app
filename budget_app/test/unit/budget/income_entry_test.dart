import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';

void main() {
  group('IncomeEntry', () {
    test('should create IncomeEntry with all required fields', () {
      final income = IncomeEntry(
        id: '1',
        budgetId: 'default',
        amount: 1000.0,
        description: 'Salary',
        date: DateTime(2026, 1, 15),
      );

      expect(income.id, '1');
      expect(income.budgetId, 'default');
      expect(income.amount, 1000.0);
      expect(income.description, 'Salary');
      expect(income.date, DateTime(2026, 1, 15));
    });

    test('should create IncomeEntry with null description', () {
      final income = IncomeEntry(
        id: '1',
        budgetId: 'default',
        amount: 1000.0,
        date: DateTime(2026, 1, 20),
      );

      expect(income.description, isNull);
    });

    test('should convert toMap correctly', () {
      final date = DateTime(2026, 1, 15);
      final income = IncomeEntry(
        id: '1',
        budgetId: 'default',
        amount: 1000.0,
        description: 'Salary',
        date: date,
      );

      final map = income.toMap();

      expect(map['id'], '1');
      expect(map['budget_id'], 'default');
      expect(map['amount'], 1000.0);
      expect(map['description'], 'Salary');
      expect(map['date'], date.toIso8601String());
    });

    test('should create fromMap correctly', () {
      final map = {
        'id': '1',
        'budget_id': 'default',
        'amount': 1000.0,
        'description': 'Salary',
        'date': '2026-01-15T00:00:00.000',
      };

      final income = IncomeEntry.fromMap(map);

      expect(income.id, '1');
      expect(income.budgetId, 'default');
      expect(income.amount, 1000.0);
      expect(income.description, 'Salary');
      expect(income.date, DateTime(2026, 1, 15));
    });

    test('should support equality', () {
      final date = DateTime(2026, 1, 15);
      final income1 = IncomeEntry(
        id: '1',
        budgetId: 'default',
        amount: 1000.0,
        description: 'Salary',
        date: date,
      );
      final income2 = IncomeEntry(
        id: '1',
        budgetId: 'default',
        amount: 1000.0,
        description: 'Salary',
        date: date,
      );

      expect(income1, equals(income2));
    });
  });
}
