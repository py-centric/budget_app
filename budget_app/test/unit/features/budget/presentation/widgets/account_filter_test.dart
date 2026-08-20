import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/presentation/widgets/filter_models.dart';
import 'package:budget_app/features/budget/presentation/widgets/filter_utils.dart';

void main() {
  group('AccountFilter Unit Tests', () {
    test('AccountFilter matches correctly when inactive', () {
      const filter = AccountFilter();
      expect(filter.isActive, isFalse);
      expect(filter.matches('acc_1'), isTrue);
      expect(filter.matches(null), isTrue);
    });

    test('AccountFilter matches only selected accounts when active', () {
      const filter = AccountFilter(selectedAccountIds: {'acc_1', 'acc_2'});
      expect(filter.isActive, isTrue);
      expect(filter.matches('acc_1'), isTrue);
      expect(filter.matches('acc_2'), isTrue);
      expect(filter.matches('acc_3'), isFalse);
      expect(filter.matches(null), isFalse);
    });

    test('AccountFilter matches unassigned transactions when includeUnassigned is true', () {
      const filter = AccountFilter(
        selectedAccountIds: {'acc_1'},
        includeUnassigned: true,
      );
      expect(filter.isActive, isTrue);
      expect(filter.matches('acc_1'), isTrue);
      expect(filter.matches('acc_2'), isFalse);
      expect(filter.matches(null), isTrue);
    });

    test('AccountFilter matches only unassigned when selectedAccountIds is empty but includeUnassigned is true', () {
      const filter = AccountFilter(includeUnassigned: true);
      expect(filter.isActive, isTrue);
      expect(filter.matches(null), isTrue);
      expect(filter.matches('acc_1'), isFalse);
    });

    test('toggleAccount adds and removes account IDs', () {
      var filter = const AccountFilter();
      filter = filter.toggleAccount('acc_1');
      expect(filter.selectedAccountIds, contains('acc_1'));
      expect(filter.isActive, isTrue);

      filter = filter.toggleAccount('acc_1');
      expect(filter.selectedAccountIds, isEmpty);
      expect(filter.isActive, isFalse);
    });

    test('toggleUnassigned toggles unassigned flag', () {
      var filter = const AccountFilter();
      filter = filter.toggleUnassigned();
      expect(filter.includeUnassigned, isTrue);
      expect(filter.isActive, isTrue);

      filter = filter.toggleUnassigned();
      expect(filter.includeUnassigned, isFalse);
      expect(filter.isActive, isFalse);
    });
  });

  group('FilterUtils Account Matching Tests', () {
    final income1 = IncomeEntry(
      id: 'inc_1',
      budgetId: 'b_1',
      amount: 100.0,
      date: DateTime(2026, 4, 1),
      accountId: 'acc_1',
    );
    final income2 = IncomeEntry(
      id: 'inc_2',
      budgetId: 'b_1',
      amount: 200.0,
      date: DateTime(2026, 4, 2),
      accountId: 'acc_2',
    );
    final incomeUnassigned = IncomeEntry(
      id: 'inc_3',
      budgetId: 'b_1',
      amount: 300.0,
      date: DateTime(2026, 4, 3),
      accountId: null,
    );

    final expense1 = ExpenseEntry(
      id: 'exp_1',
      budgetId: 'b_1',
      amount: 50.0,
      categoryId: 'cat_1',
      date: DateTime(2026, 4, 1),
      accountId: 'acc_1',
    );
    final expense2 = ExpenseEntry(
      id: 'exp_2',
      budgetId: 'b_1',
      amount: 75.0,
      categoryId: 'cat_1',
      date: DateTime(2026, 4, 2),
      accountId: 'acc_2',
    );
    final expenseUnassigned = ExpenseEntry(
      id: 'exp_3',
      budgetId: 'b_1',
      amount: 120.0,
      categoryId: 'cat_1',
      date: DateTime(2026, 4, 3),
      accountId: null,
    );

    test('filterIncomeEntries returns all when accountFilter is inactive', () {
      const state = FilterState();
      final result = filterIncomeEntries([income1, income2, incomeUnassigned], state);
      expect(result.length, equals(3));
    });

    test('filterIncomeEntries filters by selected accounts and unassigned', () {
      final state = const FilterState().copyWith(
        accountFilter: const AccountFilter(
          selectedAccountIds: {'acc_1'},
          includeUnassigned: true,
        ),
      );
      final result = filterIncomeEntries([income1, income2, incomeUnassigned], state);
      expect(result.length, equals(2));
      expect(result.map((e) => e.id), containsAll(['inc_1', 'inc_3']));
    });

    test('filterExpenseEntries filters by selected accounts', () {
      final state = const FilterState().copyWith(
        accountFilter: const AccountFilter(
          selectedAccountIds: {'acc_2'},
        ),
      );
      final result = filterExpenseEntries([expense1, expense2, expenseUnassigned], state);
      expect(result.length, equals(1));
      expect(result.first.id, equals('exp_2'));
    });
  });
}
