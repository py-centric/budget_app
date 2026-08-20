import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/entities/recurring_transaction.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_event.dart';

void main() {
  const testBudget = Budget(
    id: 'budget-1',
    name: 'Test Budget',
    periodMonth: 1,
    periodYear: 2024,
  );
  const testPeriod = BudgetPeriod(year: 2024, month: 1);
  final testIncome = IncomeEntry(
    id: 'income-1',
    budgetId: 'budget-1',
    amount: 5000.0,
    categoryId: 'cat-1',
    description: 'Salary',
    date: DateTime(2024, 1, 15),
  );
  final testExpense = ExpenseEntry(
    id: 'expense-1',
    budgetId: 'budget-1',
    amount: 1000.0,
    categoryId: 'cat-2',
    description: 'Rent',
    date: DateTime(2024, 1, 1),
  );
  final testRecurring = RecurringTransaction(
    id: 'rec-1',
    budgetId: 'budget-1',
    type: 'EXPENSE',
    amount: 100.0,
    categoryId: 'cat-1',
    description: 'Netflix',
    startDate: DateTime(2024, 1, 1),
    interval: 1,
    unit: RecurrenceUnit.months,
  );

  group('BudgetEvent props', () {
    test('BudgetEvent base class has empty props', () {
      const event = LoadSummaryEvent();
      expect(event.props, [null, null]);
    });

    group('DuplicateBudgetEvent', () {
      test('props contain all fields', () {
        const event = DuplicateBudgetEvent(
          sourceBudget: testBudget,
          targetPeriod: testPeriod,
          newName: 'Copy',
          includeTransactions: true,
        );
        expect(event.props, [testBudget, testPeriod, 'Copy', true]);
      });

      test('equal events have same props', () {
        const a = DuplicateBudgetEvent(
          sourceBudget: testBudget,
          targetPeriod: testPeriod,
          newName: 'Copy',
        );
        const b = DuplicateBudgetEvent(
          sourceBudget: testBudget,
          targetPeriod: testPeriod,
          newName: 'Copy',
        );
        expect(a, equals(b));
      });

      test('different events are not equal', () {
        const a = DuplicateBudgetEvent(
          sourceBudget: testBudget,
          targetPeriod: testPeriod,
          newName: 'Copy A',
        );
        const b = DuplicateBudgetEvent(
          sourceBudget: testBudget,
          targetPeriod: testPeriod,
          newName: 'Copy B',
        );
        expect(a, isNot(equals(b)));
      });
    });

    group('AddIncomeEvent', () {
      test('props contain all fields', () {
        final event = AddIncomeEvent(
          id: 'income-1',
          budgetId: 'budget-1',
          amount: 5000.0,
          categoryId: 'cat-1',
          description: 'Salary',
          date: DateTime(2024, 1, 15),
          isPotential: true,
        );
        expect(event.props, [
          'income-1',
          'budget-1',
          5000.0,
          'cat-1',
          'Salary',
          DateTime(2024, 1, 15),
          null,
          true,
        ]);
      });

      test('equal events', () {
        final a = AddIncomeEvent(
          id: 'income-1',
          budgetId: 'budget-1',
          amount: 5000.0,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 15),
        );
        final b = AddIncomeEvent(
          id: 'income-1',
          budgetId: 'budget-1',
          amount: 5000.0,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 15),
        );
        expect(a, equals(b));
      });
    });

    group('AddExpenseEvent', () {
      test('props contain all fields', () {
        final event = AddExpenseEvent(
          id: 'expense-1',
          budgetId: 'budget-1',
          amount: 1000.0,
          category: 'cat-2',
          description: 'Rent',
          date: DateTime(2024, 1, 1),
          isPotential: false,
        );
        expect(event.props, [
          'expense-1',
          'budget-1',
          1000.0,
          'cat-2',
          'Rent',
          DateTime(2024, 1, 1),
          null,
          false,
        ]);
      });
    });

    group('LoadSummaryEvent', () {
      test('props contain period and budgetId', () {
        const event = LoadSummaryEvent(
          period: testPeriod,
          budgetId: 'budget-1',
        );
        expect(event.props, [testPeriod, 'budget-1']);
      });

      test('default props are null', () {
        const event = LoadSummaryEvent();
        expect(event.props, [null, null]);
      });
    });

    group('DeleteEntryEvent', () {
      test('props contain id and type', () {
        const event = DeleteEntryEvent('income-1', EntryType.income);
        expect(event.props, ['income-1', EntryType.income]);
      });

      test('expense type', () {
        const event = DeleteEntryEvent('expense-1', EntryType.expense);
        expect(event.type, EntryType.expense);
      });
    });

    group('UpdateIncomeEvent', () {
      test('props contain income', () {
        final event = UpdateIncomeEvent(testIncome);
        expect(event.props, [testIncome]);
      });

      test('equal events', () {
        expect(UpdateIncomeEvent(testIncome), equals(UpdateIncomeEvent(testIncome)));
      });
    });

    group('UpdateExpenseEvent', () {
      test('props contain expense', () {
        final event = UpdateExpenseEvent(testExpense);
        expect(event.props, [testExpense]);
      });
    });

    group('SaveRecurringTransactionEvent', () {
      test('props contain recurring', () {
        final event = SaveRecurringTransactionEvent(testRecurring);
        expect(event.props, [testRecurring]);
      });
    });

    group('ConfirmPotentialTransactionEvent', () {
      test('props contain incomeId and expenseId', () {
        const event = ConfirmPotentialTransactionEvent(
          incomeId: 'income-1',
          expenseId: 'expense-1',
        );
        expect(event.props, ['income-1', 'expense-1']);
      });

      test('default props are null', () {
        const event = ConfirmPotentialTransactionEvent();
        expect(event.props, [null, null]);
      });
    });

    group('DeleteBudgetEvent', () {
      test('props contain budgetId', () {
        const event = DeleteBudgetEvent('budget-1');
        expect(event.props, ['budget-1']);
      });
    });

    group('ClearAllBudgetsEvent', () {
      test('props are empty', () {
        const event = ClearAllBudgetsEvent();
        expect(event.props, isEmpty);
      });
    });

    group('FactoryResetEvent', () {
      test('props are empty', () {
        const event = FactoryResetEvent();
        expect(event.props, isEmpty);
      });
    });

    group('ConvertBudgetEvent', () {
      test('props contain all fields', () {
        const event = ConvertBudgetEvent(
          budgetId: 'budget-1',
          targetCurrencyCode: 'EUR',
          exchangeRate: 0.85,
        );
        expect(event.props, ['budget-1', 'EUR', 0.85]);
      });

      test('equal events', () {
        const a = ConvertBudgetEvent(
          budgetId: 'budget-1',
          targetCurrencyCode: 'EUR',
          exchangeRate: 0.85,
        );
        const b = ConvertBudgetEvent(
          budgetId: 'budget-1',
          targetCurrencyCode: 'EUR',
          exchangeRate: 0.85,
        );
        expect(a, equals(b));
      });
    });

    group('UpdateExchangeRateEvent', () {
      test('props contain budgetId and exchangeRate', () {
        const event = UpdateExchangeRateEvent(
          budgetId: 'budget-1',
          exchangeRate: 0.90,
        );
        expect(event.props, ['budget-1', 0.90]);
      });
    });

    group('CreateDisposableBudgetEvent', () {
      test('props contain all fields', () {
        const event = CreateDisposableBudgetEvent(
          name: 'Equipment Fund',
          targetIncome: 5000.0,
          sourceDescription: 'Freelance',
          periodMonth: 1,
          periodYear: 2024,
          linkedIncomeId: 'income-1',
        );
        expect(event.props, [
          'Equipment Fund',
          5000.0,
          'Freelance',
          1,
          2024,
          'income-1',
        ]);
      });

      test('equal events', () {
        const a = CreateDisposableBudgetEvent(
          name: 'Equipment Fund',
          targetIncome: 5000.0,
          sourceDescription: 'Freelance',
          periodMonth: 1,
          periodYear: 2024,
        );
        const b = CreateDisposableBudgetEvent(
          name: 'Equipment Fund',
          targetIncome: 5000.0,
          sourceDescription: 'Freelance',
          periodMonth: 1,
          periodYear: 2024,
        );
        expect(a, equals(b));
      });

      test('different events are not equal', () {
        const a = CreateDisposableBudgetEvent(
          name: 'Fund A',
          targetIncome: 5000.0,
          sourceDescription: 'Freelance',
          periodMonth: 1,
          periodYear: 2024,
        );
        const b = CreateDisposableBudgetEvent(
          name: 'Fund B',
          targetIncome: 5000.0,
          sourceDescription: 'Freelance',
          periodMonth: 1,
          periodYear: 2024,
        );
        expect(a, isNot(equals(b)));
      });
    });

    group('UpdateDisposableBudgetEvent', () {
      test('props contain all fields', () {
        const event = UpdateDisposableBudgetEvent(
          budgetId: 'disp-1',
          targetIncome: 6000.0,
          sourceDescription: 'Updated',
        );
        expect(event.props, ['disp-1', 6000.0, 'Updated']);
      });

      test('null optional fields', () {
        const event = UpdateDisposableBudgetEvent(budgetId: 'disp-1');
        expect(event.props, ['disp-1', null, null]);
      });
    });

    group('DisposeBudgetEvent', () {
      test('props contain budgetId', () {
        const event = DisposeBudgetEvent('disp-1');
        expect(event.props, ['disp-1']);
      });
    });

    group('PersistBudgetEvent', () {
      test('props contain budgetId', () {
        const event = PersistBudgetEvent('disp-1');
        expect(event.props, ['disp-1']);
      });
    });

    group('LoadDisposableHistoryEvent', () {
      test('props are empty', () {
        const event = LoadDisposableHistoryEvent();
        expect(event.props, isEmpty);
      });
    });

    group('LinkIncomeToBudgetEvent', () {
      test('props contain budgetId and incomeTransactionId', () {
        const event = LinkIncomeToBudgetEvent(
          budgetId: 'disp-1',
          incomeTransactionId: 'inc-1',
        );
        expect(event.props, ['disp-1', 'inc-1']);
      });
    });

    group('UnlinkIncomeFromBudgetEvent', () {
      test('props contain budgetId', () {
        const event = UnlinkIncomeFromBudgetEvent('disp-1');
        expect(event.props, ['disp-1']);
      });
    });

    group('LoadIncomeListEvent', () {
      test('props are empty', () {
        const event = LoadIncomeListEvent();
        expect(event.props, isEmpty);
      });
    });
  });
}
