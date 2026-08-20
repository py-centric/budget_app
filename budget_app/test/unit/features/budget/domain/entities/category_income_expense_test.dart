import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';

void main() {
  group('Category', () {
    test('props are correct', () {
      const cat = Category(id: 'c-1', name: 'Food', type: CategoryType.expense, icon: '🍔');
      expect(cat.props, ['c-1', 'Food', CategoryType.expense, '🍔']);
    });

    test('CategoryType has correct values', () {
      expect(CategoryType.values, [CategoryType.income, CategoryType.expense]);
    });

    test('nullable icon', () {
      const cat = Category(id: 'c-1', name: 'Food', type: CategoryType.expense);
      expect(cat.icon, isNull);
    });

    test('equality works', () {
      const c1 = Category(id: 'c-1', name: 'Food', type: CategoryType.expense);
      const c2 = Category(id: 'c-1', name: 'Food', type: CategoryType.expense);
      expect(c1, equals(c2));
    });
  });

  group('ExpenseEntry', () {
    final date = DateTime(2024, 6, 15);
    final entry = ExpenseEntry(
      id: 'e-1', budgetId: 'b1', amount: 50, categoryId: 'food',
      description: 'Lunch', date: date,
    );

    test('props are correct', () {
      expect(entry.props, [
        'e-1', 'b1', 50, 'food', 'Lunch', date,
        null, null, null, null, null, null, false,
      ]);
    });

    test('copyWith not available - create new entry', () {
      final updated = ExpenseEntry(
        id: 'e-1', budgetId: 'b1', amount: 75, categoryId: 'food',
        description: 'Lunch', date: date,
      );
      expect(updated.amount, 75);
      expect(entry.amount, 50);
    });

    test('default isPotential is false', () {
      final entry = ExpenseEntry(
        id: 'e-1', budgetId: 'b1', amount: 50, categoryId: 'food',
        date: date,
      );
      expect(entry.isPotential, isFalse);
    });

    test('toMap serializes correctly', () {
      final map = entry.toMap();
      expect(map['id'], 'e-1');
      expect(map['budget_id'], 'b1');
      expect(map['amount'], 50);
      expect(map['category_id'], 'food');
      expect(map['description'], 'Lunch');
      expect(map['date'], date.toIso8601String());
      expect(map['is_potential'], 0);
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'id': 'e-1', 'budget_id': 'b1', 'amount': 50.0,
        'category_id': 'food', 'description': 'Lunch',
        'date': date.toIso8601String(),
        'period_month': 6, 'period_year': 2024,
        'is_potential': 0,
      };
      final result = ExpenseEntry.fromMap(map);
      expect(result.id, 'e-1');
      expect(result.amount, 50.0);
      expect(result.description, 'Lunch');
      expect(result.periodMonth, 6);
      expect(result.isPotential, isFalse);
    });

    test('fromMap with legacy category field', () {
      final map = {
        'id': 'e-1', 'budget_id': 'b1', 'amount': 50.0,
        'category': 'food', 'description': null,
        'date': date.toIso8601String(), 'is_potential': 1,
      };
      final result = ExpenseEntry.fromMap(map);
      expect(result.categoryId, 'food');
      expect(result.isPotential, isTrue);
    });

    test('fromMap with null budget_id defaults to default', () {
      final map = {
        'id': 'e-1', 'amount': 50.0, 'category_id': 'food',
        'date': date.toIso8601String(),
      };
      final result = ExpenseEntry.fromMap(map);
      expect(result.budgetId, 'default');
    });

    test('fromMap with null optional fields', () {
      final map = {
        'id': 'e-1', 'budget_id': 'b1', 'amount': 50.0,
        'category_id': 'food', 'date': date.toIso8601String(),
      };
      final result = ExpenseEntry.fromMap(map);
      expect(result.description, isNull);
      expect(result.periodMonth, isNull);
      expect(result.periodYear, isNull);
    });

    test('equality works', () {
      final e2 = ExpenseEntry(
        id: 'e-1', budgetId: 'b1', amount: 50, categoryId: 'food',
        description: 'Lunch', date: date,
      );
      expect(entry, equals(e2));
    });

    test('isPotential entry', () {
      final potential = ExpenseEntry(
        id: 'e-2', budgetId: 'b1', amount: 100, categoryId: 'travel',
        date: date, isPotential: true,
      );
      expect(potential.isPotential, isTrue);
      expect(potential.toMap()['is_potential'], 1);
    });
  });

  group('IncomeEntry', () {
    final date = DateTime(2024, 6, 15);
    final entry = IncomeEntry(
      id: 'i-1', budgetId: 'b1', amount: 3000, description: 'Salary',
      date: date,
    );

    test('props are correct', () {
      expect(entry.props, [
        'i-1', 'b1', 3000, 'Salary', date,
        null, null, null, null, null, null, null, false,
      ]);
    });

    test('default isPotential is false', () {
      final entry = IncomeEntry(
        id: 'i-1', budgetId: 'b1', amount: 3000, date: date,
      );
      expect(entry.isPotential, isFalse);
    });

    test('toMap serializes correctly', () {
      final map = entry.toMap();
      expect(map['id'], 'i-1');
      expect(map['budget_id'], 'b1');
      expect(map['amount'], 3000);
      expect(map['description'], 'Salary');
      expect(map['date'], date.toIso8601String());
      expect(map['is_potential'], 0);
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'id': 'i-1', 'budget_id': 'b1', 'amount': 3000.0,
        'description': 'Salary', 'date': date.toIso8601String(),
        'period_month': 6, 'period_year': 2024,
        'category_id': 'salary', 'is_potential': 0,
      };
      final result = IncomeEntry.fromMap(map);
      expect(result.id, 'i-1');
      expect(result.amount, 3000.0);
      expect(result.description, 'Salary');
      expect(result.categoryId, 'salary');
      expect(result.periodMonth, 6);
    });

    test('fromMap with null budget_id defaults to default', () {
      final map = {
        'id': 'i-1', 'amount': 3000.0,
        'date': date.toIso8601String(),
      };
      final result = IncomeEntry.fromMap(map);
      expect(result.budgetId, 'default');
    });

    test('fromMap with null optional fields', () {
      final map = {
        'id': 'i-1', 'budget_id': 'b1', 'amount': 3000.0,
        'date': date.toIso8601String(),
      };
      final result = IncomeEntry.fromMap(map);
      expect(result.description, isNull);
      expect(result.categoryId, isNull);
      expect(result.isPotential, isFalse);
    });

    test('equality works', () {
      final i2 = IncomeEntry(
        id: 'i-1', budgetId: 'b1', amount: 3000, description: 'Salary',
        date: date,
      );
      expect(entry, equals(i2));
    });

    test('isPotential entry', () {
      final potential = IncomeEntry(
        id: 'i-2', budgetId: 'b1', amount: 500, date: date, isPotential: true,
      );
      expect(potential.isPotential, isTrue);
      expect(potential.toMap()['is_potential'], 1);
    });
  });
}
