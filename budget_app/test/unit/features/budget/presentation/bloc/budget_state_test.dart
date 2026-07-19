import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/usecases/calculate_summary.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_state.dart';

void main() {
  group('BudgetState props', () {
    group('BudgetInitial', () {
      test('props are empty', () {
        const state = BudgetInitial();
        expect(state.props, isEmpty);
      });

      test('equal states', () {
        expect(const BudgetInitial(), equals(const BudgetInitial()));
      });
    });

    group('BudgetLoading', () {
      test('props are empty', () {
        const state = BudgetLoading();
        expect(state.props, isEmpty);
      });
    });

    group('OperationSuccess', () {
      test('message is accessible', () {
        const state = OperationSuccess(message: 'Done');
        expect(state.message, 'Done');
      });

      test('default message is null', () {
        const state = OperationSuccess();
        expect(state.message, isNull);
      });

      test('props are empty (inherits base)', () {
        const state = OperationSuccess(message: 'Done');
        expect(state.props, isEmpty);
      });
    });

    group('SummaryLoaded', () {
      test('props contain summary', () {
        final summary = BudgetSummary(
          totalIncome: 5000,
          totalExpenses: 1000,
          balance: 4000,
          totalPotentialIncome: 5000,
          totalPotentialExpenses: 1000,
          incomeEntries: [],
          expenseEntries: [],
        );
        final state = SummaryLoaded(summary);
        expect(state.props, [summary]);
      });
    });

    group('CategoriesLoaded', () {
      test('props contain categories', () {
        final categories = [
          const Category(
            id: 'cat-1',
            name: 'Food',
            type: CategoryType.expense,
            icon: 'restaurant',
          ),
        ];
        final state = CategoriesLoaded(categories);
        expect(state.props, [categories]);
      });

      test('equal states', () {
        final cats = [
          const Category(
            id: 'cat-1',
            name: 'Food',
            type: CategoryType.expense,
            icon: 'restaurant',
          ),
        ];
        expect(CategoriesLoaded(cats), equals(CategoriesLoaded(cats)));
      });
    });

    group('BudgetError', () {
      test('props contain message', () {
        const state = BudgetError('Something failed');
        expect(state.props, ['Something failed']);
      });

      test('equal states', () {
        expect(const BudgetError('err'), equals(const BudgetError('err')));
      });

      test('different errors not equal', () {
        expect(const BudgetError('a'), isNot(equals(const BudgetError('b'))));
      });
    });

    group('BudgetConverted', () {
      test('props contain all fields', () {
        const state = BudgetConverted(
          budgetId: 'budget-1',
          targetCurrencyCode: 'EUR',
          exchangeRate: 0.85,
          convertedAmount: 4250.0,
        );
        expect(state.props, ['budget-1', 'EUR', 0.85, 4250.0]);
      });

      test('equal states', () {
        const a = BudgetConverted(
          budgetId: 'budget-1',
          targetCurrencyCode: 'EUR',
          exchangeRate: 0.85,
          convertedAmount: 4250.0,
        );
        const b = BudgetConverted(
          budgetId: 'budget-1',
          targetCurrencyCode: 'EUR',
          exchangeRate: 0.85,
          convertedAmount: 4250.0,
        );
        expect(a, equals(b));
      });
    });

    group('DisposableBudgetsLoaded', () {
      test('props contain all fields', () {
        const state = DisposableBudgetsLoaded(
          active: [],
          history: [],
          budgetExpenseTotals: {'a': 1.0},
          endedBudgetIds: {'b'},
        );
        expect(state.props, [
          [],
          [],
          {'a': 1.0},
          {'b'},
        ]);
      });

      test('default values', () {
        const state = DisposableBudgetsLoaded(active: [], history: []);
        expect(state.budgetExpenseTotals, isEmpty);
        expect(state.endedBudgetIds, isEmpty);
      });
    });

    group('DisposableBudgetCreated', () {
      test('props contain budget', () {
        const budget = Budget(
          id: 'disp-1',
          name: 'Fund',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposable,
        );
        const state = DisposableBudgetCreated(budget);
        expect(state.props, [budget]);
      });
    });

    group('BudgetDisposed', () {
      test('props contain budgetId', () {
        const state = BudgetDisposed('disp-1');
        expect(state.props, ['disp-1']);
      });

      test('equal states', () {
        expect(const BudgetDisposed('a'), equals(const BudgetDisposed('a')));
      });
    });

    group('BudgetPersisted', () {
      test('props contain budgetId', () {
        const state = BudgetPersisted('disp-1');
        expect(state.props, ['disp-1']);
      });
    });

    group('IncomeLinked', () {
      test('props contain budgetId and transactionId', () {
        const state = IncomeLinked(
          budgetId: 'disp-1',
          transactionId: 'inc-1',
        );
        expect(state.props, ['disp-1', 'inc-1']);
      });

      test('equal states', () {
        const a = IncomeLinked(budgetId: 'a', transactionId: 'b');
        const b = IncomeLinked(budgetId: 'a', transactionId: 'b');
        expect(a, equals(b));
      });
    });

    group('IncomeUnlinked', () {
      test('props contain budgetId', () {
        const state = IncomeUnlinked('disp-1');
        expect(state.props, ['disp-1']);
      });
    });

    group('IncomeListLoaded', () {
      test('props contain incomes', () {
        final incomes = [
          IncomeEntry(
            id: 'inc-1',
            budgetId: 'budget-1',
            amount: 5000,
            categoryId: 'cat-1',
            date: DateTime(2024, 1, 1),
          ),
        ];
        final state = IncomeListLoaded(incomes);
        expect(state.props, [incomes]);
      });

      test('empty list', () {
        const state = IncomeListLoaded([]);
        expect(state.props, [[]]);
      });
    });
  });
}
