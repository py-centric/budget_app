import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';

void main() {
  group('ExpenseEntry', () {
    test('should create ExpenseEntry with all required fields', () {
      final expense = ExpenseEntry(
        id: '1',
        budgetId: 'default',
        amount: 50.0,
        categoryId: 'Food',
        description: 'Groceries',
        date: DateTime(2026, 1, 15),
      );

      expect(expense.id, '1');
      expect(expense.budgetId, 'default');
      expect(expense.amount, 50.0);
      expect(expense.categoryId, 'Food');
      expect(expense.description, 'Groceries');
      expect(expense.date, DateTime(2026, 1, 15));
    });

    test('should create ExpenseEntry with null description', () {
      final expense = ExpenseEntry(
        id: '2',
        budgetId: 'default',
        amount: 30.0,
        categoryId: 'Transport',
        date: DateTime(2026, 1, 20),
      );

      expect(expense.description, isNull);
    });

    test('should convert toMap correctly', () {
      final date = DateTime(2026, 1, 15);
      final expense = ExpenseEntry(
        id: '1',
        budgetId: 'default',
        amount: 50.0,
        categoryId: 'Food',
        description: 'Groceries',
        date: date,
      );

      final map = expense.toMap();

      expect(map['id'], '1');
      expect(map['budget_id'], 'default');
      expect(map['amount'], 50.0);
      expect(map['category_id'], 'Food');
      expect(map['description'], 'Groceries');
      expect(map['date'], date.toIso8601String());
    });

    test('should create fromMap correctly', () {
      final map = {
        'id': '1',
        'budget_id': 'default',
        'amount': 50.0,
        'category_id': 'Food',
        'description': 'Groceries',
        'date': '2026-01-15T00:00:00.000',
      };

      final expense = ExpenseEntry.fromMap(map);

      expect(expense.id, '1');
      expect(expense.budgetId, 'default');
      expect(expense.amount, 50.0);
      expect(expense.categoryId, 'Food');
      expect(expense.description, 'Groceries');
      expect(expense.date, DateTime(2026, 1, 15));
    });

    test('should support equality', () {
      final date = DateTime(2026, 1, 15);
      final expense1 = ExpenseEntry(
        id: '1',
        budgetId: 'default',
        amount: 50.0,
        categoryId: 'Food',
        description: 'Groceries',
        date: date,
      );
      final expense2 = ExpenseEntry(
        id: '1',
        budgetId: 'default',
        amount: 50.0,
        categoryId: 'Food',
        description: 'Groceries',
        date: date,
      );

      expect(expense1, equals(expense2));
    });
  });
}
