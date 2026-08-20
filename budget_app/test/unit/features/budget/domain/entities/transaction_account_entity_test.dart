import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';

void main() {
  group('Transaction Account Entity Tests', () {
    test('IncomeEntry supports optional accountId and accountName', () {
      final income = IncomeEntry(
        id: 'inc_1',
        budgetId: 'b_1',
        amount: 1500.0,
        description: 'Freelance payment',
        date: DateTime(2026, 4, 1),
        periodMonth: 4,
        periodYear: 2026,
        categoryId: 'cat_salary',
        categoryName: 'Salary',
        categoryIcon: 'work',
        accountId: 'acc_checking',
        accountName: 'Checking Account',
        isPotential: false,
      );

      expect(income.accountId, equals('acc_checking'));
      expect(income.accountName, equals('Checking Account'));

      final map = income.toMap();
      expect(map['account_id'], equals('acc_checking'));

      final fromMap = IncomeEntry.fromMap(const {
        'id': 'inc_1',
        'budget_id': 'b_1',
        'amount': 1500.0,
        'description': 'Freelance payment',
        'date': '2026-04-01T00:00:00.000',
        'period_month': 4,
        'period_year': 2026,
        'category_id': 'cat_salary',
        'category_name': 'Salary',
        'category_icon': 'work',
        'account_id': 'acc_checking',
        'account_name': 'Checking Account',
        'is_potential': 0,
      });

      expect(fromMap.accountId, equals('acc_checking'));
      expect(fromMap.accountName, equals('Checking Account'));
    });

    test('IncomeEntry defaults to null accountId when unassigned', () {
      final income = IncomeEntry(
        id: 'inc_2',
        budgetId: 'b_1',
        amount: 200.0,
        date: DateTime(2026, 4, 2),
      );

      expect(income.accountId, isNull);
      expect(income.accountName, isNull);
      expect(income.toMap()['account_id'], isNull);

      final fromMap = IncomeEntry.fromMap(const {
        'id': 'inc_2',
        'budget_id': 'b_1',
        'amount': 200.0,
        'date': '2026-04-02T00:00:00.000',
      });

      expect(fromMap.accountId, isNull);
      expect(fromMap.accountName, isNull);
    });

    test('ExpenseEntry supports optional accountId and accountName', () {
      final expense = ExpenseEntry(
        id: 'exp_1',
        budgetId: 'b_1',
        amount: 65.0,
        categoryId: 'cat_food',
        description: 'Groceries',
        date: DateTime(2026, 4, 3),
        periodMonth: 4,
        periodYear: 2026,
        categoryName: 'Food',
        categoryIcon: 'restaurant',
        accountId: 'acc_credit',
        accountName: 'Credit Card',
        isPotential: false,
      );

      expect(expense.accountId, equals('acc_credit'));
      expect(expense.accountName, equals('Credit Card'));

      final map = expense.toMap();
      expect(map['account_id'], equals('acc_credit'));

      final fromMap = ExpenseEntry.fromMap(const {
        'id': 'exp_1',
        'budget_id': 'b_1',
        'amount': 65.0,
        'category_id': 'cat_food',
        'description': 'Groceries',
        'date': '2026-04-03T00:00:00.000',
        'period_month': 4,
        'period_year': 2026,
        'category_name': 'Food',
        'category_icon': 'restaurant',
        'account_id': 'acc_credit',
        'account_name': 'Credit Card',
        'is_potential': 0,
      });

      expect(fromMap.accountId, equals('acc_credit'));
      expect(fromMap.accountName, equals('Credit Card'));
    });

    test('ExpenseEntry defaults to null accountId when unassigned', () {
      final expense = ExpenseEntry(
        id: 'exp_2',
        budgetId: 'b_1',
        amount: 15.0,
        categoryId: 'cat_transport',
        date: DateTime(2026, 4, 4),
      );

      expect(expense.accountId, isNull);
      expect(expense.accountName, isNull);
      expect(expense.toMap()['account_id'], isNull);

      final fromMap = ExpenseEntry.fromMap(const {
        'id': 'exp_2',
        'budget_id': 'b_1',
        'amount': 15.0,
        'category_id': 'cat_transport',
        'date': '2026-04-04T00:00:00.000',
      });

      expect(fromMap.accountId, isNull);
      expect(fromMap.accountName, isNull);
    });
  });
}
