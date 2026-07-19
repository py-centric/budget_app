import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/entities/recurring_transaction.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_app/features/budget/domain/usecases/add_income.dart';
import 'package:budget_app/features/budget/domain/usecases/add_expense.dart';
import 'package:budget_app/features/budget/domain/usecases/calculate_summary.dart';
import 'package:budget_app/features/budget/domain/usecases/delete_entry.dart'
    as delete_entry;
import 'package:budget_app/features/budget/domain/usecases/update_entry.dart';
import 'package:budget_app/features/budget/domain/usecases/duplicate_budget.dart';
import 'package:budget_app/features/budget/domain/usecases/save_recurring_transaction.dart';
import 'package:budget_app/features/budget/domain/usecases/confirm_potential_transaction.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_event.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_state.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}
class MockAddIncome extends Mock implements AddIncome {}
class MockAddExpense extends Mock implements AddExpense {}
class MockCalculateSummary extends Mock implements CalculateSummary {}
class MockDeleteEntry extends Mock implements delete_entry.DeleteEntry {}
class MockUpdateEntry extends Mock implements UpdateEntry {}
class MockSaveRecurringTransaction extends Mock implements SaveRecurringTransaction {}
class MockDuplicateBudget extends Mock implements DuplicateBudget {}
class MockConfirmPotentialTransaction extends Mock implements ConfirmPotentialTransaction {}

class FakeBudgetPeriod extends Fake implements BudgetPeriod {}
class FakeIncomeEntry extends Fake implements IncomeEntry {}
class FakeExpenseEntry extends Fake implements ExpenseEntry {}
class FakeBudget extends Fake implements Budget {}
class FakeRecurringTransaction extends Fake implements RecurringTransaction {}

void main() {
  late BudgetBloc budgetBloc;
  late MockBudgetRepository mockRepository;
  late MockAddIncome mockAddIncome;
  late MockAddExpense mockAddExpense;
  late MockCalculateSummary mockCalculateSummary;
  late MockDeleteEntry mockDeleteEntry;
  late MockUpdateEntry mockUpdateEntry;
  late MockSaveRecurringTransaction mockSaveRecurringTransaction;
  late MockDuplicateBudget mockDuplicateBudget;
  late MockConfirmPotentialTransaction mockConfirmPotentialTransaction;

  const testPeriod = BudgetPeriod(year: 2024, month: 1);
  const testBudget = Budget(
    id: 'budget-1',
    name: 'Test Budget',
    periodMonth: 1,
    periodYear: 2024,
    targetCurrencyCode: 'USD',
  );
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
  final testSummary = BudgetSummary(
    totalIncome: 5000.0,
    totalExpenses: 1000.0,
    balance: 4000.0,
    totalPotentialIncome: 5000.0,
    totalPotentialExpenses: 1000.0,
    incomeEntries: [testIncome],
    expenseEntries: [testExpense],
  );

  setUpAll(() {
    registerFallbackValue(FakeBudgetPeriod());
    registerFallbackValue(FakeIncomeEntry());
    registerFallbackValue(FakeExpenseEntry());
    registerFallbackValue(FakeBudget());
    registerFallbackValue(FakeRecurringTransaction());
    registerFallbackValue(delete_entry.EntryType.income);
  });

  setUp(() {
    mockRepository = MockBudgetRepository();
    mockAddIncome = MockAddIncome();
    mockAddExpense = MockAddExpense();
    mockCalculateSummary = MockCalculateSummary();
    mockDeleteEntry = MockDeleteEntry();
    mockUpdateEntry = MockUpdateEntry();
    mockSaveRecurringTransaction = MockSaveRecurringTransaction();
    mockDuplicateBudget = MockDuplicateBudget();
    mockConfirmPotentialTransaction = MockConfirmPotentialTransaction();

    budgetBloc = BudgetBloc(
      repository: mockRepository,
      addIncomeUseCase: mockAddIncome,
      addExpenseUseCase: mockAddExpense,
      calculateSummaryUseCase: mockCalculateSummary,
      deleteEntryUseCase: mockDeleteEntry,
      updateEntryUseCase: mockUpdateEntry,
      saveRecurringTransactionUseCase: mockSaveRecurringTransaction,
      duplicateBudgetUseCase: mockDuplicateBudget,
      confirmPotentialTransactionUseCase: mockConfirmPotentialTransaction,
    );
  });

  tearDown(() {
    budgetBloc.close();
  });

  group('Additional BLoC handlers', () {
    group('ConfirmPotentialTransactionEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits OperationSuccess on success',
        build: () {
          when(() => mockConfirmPotentialTransaction(
            incomeId: any(named: 'incomeId'),
            expenseId: any(named: 'expenseId'),
          )).thenAnswer((_) async {});
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const ConfirmPotentialTransactionEvent(
          incomeId: 'income-1',
        )),
        expect: () => [isA<OperationSuccess>()],
        verify: (_) {
          verify(() => mockConfirmPotentialTransaction(
            incomeId: 'income-1',
            expenseId: null,
          )).called(1);
        },
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError on failure',
        build: () {
          when(() => mockConfirmPotentialTransaction(
            incomeId: any(named: 'incomeId'),
            expenseId: any(named: 'expenseId'),
          )).thenThrow(Exception('Confirm failed'));
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const ConfirmPotentialTransactionEvent(
          incomeId: 'income-1',
        )),
        expect: () => [isA<BudgetError>()],
      );
    });

    group('SaveRecurringTransactionEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetLoading and SummaryLoaded on success',
        build: () {
          when(() => mockSaveRecurringTransaction(any()))
              .thenAnswer((_) async {});
          when(() => mockCalculateSummary(
            period: any(named: 'period'),
            budgetId: any(named: 'budgetId'),
          )).thenAnswer((_) async => testSummary);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(SaveRecurringTransactionEvent(testRecurring)),
        expect: () => [const BudgetLoading(), isA<SummaryLoaded>()],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError on failure',
        build: () {
          when(() => mockSaveRecurringTransaction(any()))
              .thenThrow(Exception('Save failed'));
          return budgetBloc;
        },
        act: (bloc) => bloc.add(SaveRecurringTransactionEvent(testRecurring)),
        expect: () => [isA<BudgetError>()],
      );
    });

    group('LoadCategoriesEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits CategoriesLoaded on success',
        build: () {
          when(() => mockRepository.getCategories())
              .thenAnswer((_) async => [
                const Category(
                  id: 'cat-1',
                  name: 'Food',
                  type: CategoryType.expense,
                  icon: 'restaurant',
                ),
              ]);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const LoadCategoriesEvent()),
        expect: () => [isA<CategoriesLoaded>()],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError on failure',
        build: () {
          when(() => mockRepository.getCategories())
              .thenThrow(Exception('DB error'));
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const LoadCategoriesEvent()),
        expect: () => [isA<BudgetError>()],
      );
    });

    group('DeleteBudgetEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits OperationSuccess on success',
        build: () {
          when(() => mockRepository.deleteBudget(any()))
              .thenAnswer((_) async {});
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const DeleteBudgetEvent('budget-1')),
        expect: () => [isA<OperationSuccess>()],
        verify: (_) {
          verify(() => mockRepository.deleteBudget('budget-1')).called(1);
        },
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError on failure',
        build: () {
          when(() => mockRepository.deleteBudget(any()))
              .thenThrow(Exception('Delete failed'));
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const DeleteBudgetEvent('budget-1')),
        expect: () => [isA<BudgetError>()],
      );
    });

    group('ClearAllBudgetsEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits OperationSuccess on success',
        build: () {
          when(() => mockRepository.clearAllBudgets())
              .thenAnswer((_) async {});
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const ClearAllBudgetsEvent()),
        expect: () => [isA<OperationSuccess>()],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError on failure',
        build: () {
          when(() => mockRepository.clearAllBudgets())
              .thenThrow(Exception('Clear failed'));
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const ClearAllBudgetsEvent()),
        expect: () => [isA<BudgetError>()],
      );
    });

    group('FactoryResetEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits OperationSuccess on success',
        build: () {
          when(() => mockRepository.factoryReset())
              .thenAnswer((_) async {});
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const FactoryResetEvent()),
        expect: () => [isA<OperationSuccess>()],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError on failure',
        build: () {
          when(() => mockRepository.factoryReset())
              .thenThrow(Exception('Reset failed'));
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const FactoryResetEvent()),
        expect: () => [isA<BudgetError>()],
      );
    });

    group('ConvertBudgetEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetConverted on success',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenAnswer((_) async => testBudget);
          when(() => mockRepository.updateBudget(any()))
              .thenAnswer((_) async {});
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const ConvertBudgetEvent(
          budgetId: 'budget-1',
          targetCurrencyCode: 'EUR',
          exchangeRate: 0.85,
        )),
        expect: () => [
          isA<BudgetConverted>()
              .having((s) => s.budgetId, 'budgetId', 'budget-1')
              .having((s) => s.targetCurrencyCode, 'currency', 'EUR')
              .having((s) => s.exchangeRate, 'rate', 0.85),
        ],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError when exchange rate is zero',
        build: () => budgetBloc,
        act: (bloc) => bloc.add(const ConvertBudgetEvent(
          budgetId: 'budget-1',
          targetCurrencyCode: 'EUR',
          exchangeRate: 0,
        )),
        expect: () => [isA<BudgetError>()],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError when exchange rate is negative',
        build: () => budgetBloc,
        act: (bloc) => bloc.add(const ConvertBudgetEvent(
          budgetId: 'budget-1',
          targetCurrencyCode: 'EUR',
          exchangeRate: -1,
        )),
        expect: () => [isA<BudgetError>()],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError when budget not found',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenAnswer((_) async => null);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const ConvertBudgetEvent(
          budgetId: 'nonexistent',
          targetCurrencyCode: 'EUR',
          exchangeRate: 0.85,
        )),
        expect: () => [isA<BudgetError>()],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError on repository failure',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenThrow(Exception('DB error'));
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const ConvertBudgetEvent(
          budgetId: 'budget-1',
          targetCurrencyCode: 'EUR',
          exchangeRate: 0.85,
        )),
        expect: () => [isA<BudgetError>()],
      );
    });

    group('UpdateExchangeRateEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetConverted on success',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenAnswer((_) async => testBudget);
          when(() => mockRepository.updateBudget(any()))
              .thenAnswer((_) async {});
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const UpdateExchangeRateEvent(
          budgetId: 'budget-1',
          exchangeRate: 0.90,
        )),
        expect: () => [isA<BudgetConverted>()],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError when exchange rate is zero',
        build: () => budgetBloc,
        act: (bloc) => bloc.add(const UpdateExchangeRateEvent(
          budgetId: 'budget-1',
          exchangeRate: 0,
        )),
        expect: () => [isA<BudgetError>()],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError when budget not found',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenAnswer((_) async => null);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const UpdateExchangeRateEvent(
          budgetId: 'nonexistent',
          exchangeRate: 0.90,
        )),
        expect: () => [isA<BudgetError>()],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError on repository failure',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenThrow(Exception('DB error'));
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const UpdateExchangeRateEvent(
          budgetId: 'budget-1',
          exchangeRate: 0.90,
        )),
        expect: () => [isA<BudgetError>()],
      );

      blocTest<BudgetBloc, BudgetState>(
        'recalculates convertedAmount with existing rate',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenAnswer((_) async => const Budget(
                    id: 'budget-1',
                    name: 'Test',
                    periodMonth: 1,
                    periodYear: 2024,
                    exchangeRate: 0.85,
                    convertedAmount: 4250.0,
                  ));
          when(() => mockRepository.updateBudget(any()))
              .thenAnswer((_) async {});
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const UpdateExchangeRateEvent(
          budgetId: 'budget-1',
          exchangeRate: 0.90,
        )),
        expect: () => [
          isA<BudgetConverted>()
              .having((s) => s.convertedAmount, 'convertedAmount', closeTo(4500, 1)),
        ],
      );
    });

    group('UpdateDisposableBudgetEvent', () {
      const disposableBudget = Budget(
        id: 'disp-1',
        name: 'Fund',
        periodMonth: 1,
        periodYear: 2024,
        type: BudgetType.disposable,
        targetIncome: 5000.0,
        sourceDescription: 'Freelance',
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits OperationSuccess on success',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenAnswer((_) async => disposableBudget);
          when(() => mockRepository.updateBudget(any()))
              .thenAnswer((_) async {});
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const UpdateDisposableBudgetEvent(
          budgetId: 'disp-1',
          targetIncome: 6000.0,
          sourceDescription: 'Updated',
        )),
        expect: () => [isA<OperationSuccess>()],
        verify: (_) {
          verify(() => mockRepository.updateBudget(any())).called(1);
        },
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError when budget not found',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenAnswer((_) async => null);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const UpdateDisposableBudgetEvent(
          budgetId: 'nonexistent',
          targetIncome: 1000,
        )),
        expect: () => [isA<BudgetError>()],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError when budget is not disposable',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenAnswer((_) async => testBudget);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const UpdateDisposableBudgetEvent(
          budgetId: 'budget-1',
          targetIncome: 1000,
        )),
        expect: () => [isA<BudgetError>()],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError on repository failure',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenThrow(Exception('DB error'));
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const UpdateDisposableBudgetEvent(
          budgetId: 'disp-1',
          targetIncome: 1000,
        )),
        expect: () => [isA<BudgetError>()],
      );
    });
  });
}
