import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
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
import 'package:budget_app/features/budget/presentation/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/budget_event.dart';
import 'package:budget_app/features/budget/presentation/budget_state.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

class MockAddIncome extends Mock implements AddIncome {}

class MockAddExpense extends Mock implements AddExpense {}

class MockCalculateSummary extends Mock implements CalculateSummary {}

class MockDeleteEntry extends Mock implements delete_entry.DeleteEntry {}

class MockUpdateEntry extends Mock implements UpdateEntry {}

class MockSaveRecurringTransaction extends Mock
    implements SaveRecurringTransaction {}

class MockDuplicateBudget extends Mock implements DuplicateBudget {}

class MockConfirmPotentialTransaction extends Mock
    implements ConfirmPotentialTransaction {}

class FakeBudgetPeriod extends Fake implements BudgetPeriod {}

class FakeIncomeEntry extends Fake implements IncomeEntry {}

class FakeExpenseEntry extends Fake implements ExpenseEntry {}

class FakeBudget extends Fake implements Budget {}

class FakeBudgetSummary extends Fake implements BudgetSummary {}

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

  final testPeriod = BudgetPeriod(year: 2024, month: 1);
  final testBudget = Budget(
    id: 'budget-1',
    name: 'Test Budget',
    periodMonth: 1,
    periodYear: 2024,
  );
  final testIncomeEntry = IncomeEntry(
    id: 'income-1',
    budgetId: 'budget-1',
    amount: 5000.0,
    categoryId: 'cat-1',
    description: 'Salary',
    date: DateTime(2024, 1, 15),
  );
  final testExpenseEntry = ExpenseEntry(
    id: 'expense-1',
    budgetId: 'budget-1',
    amount: 1000.0,
    categoryId: 'cat-2',
    description: 'Rent',
    date: DateTime(2024, 1, 1),
  );
  final testSummary = BudgetSummary(
    totalIncome: 5000.0,
    totalExpenses: 1000.0,
    balance: 4000.0,
    totalPotentialIncome: 5000.0,
    totalPotentialExpenses: 1000.0,
    incomeEntries: [testIncomeEntry],
    expenseEntries: [testExpenseEntry],
  );

  setUpAll(() {
    registerFallbackValue(FakeBudgetPeriod());
    registerFallbackValue(FakeIncomeEntry());
    registerFallbackValue(FakeExpenseEntry());
    registerFallbackValue(FakeBudget());
    registerFallbackValue(FakeBudgetSummary());
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

  group('BudgetBloc', () {
    test('initial state is BudgetInitial', () {
      expect(budgetBloc.state, const BudgetInitial());
    });

    group('LoadSummaryEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits [BudgetLoading, SummaryLoaded] on success',
        build: () {
          when(
            () => mockCalculateSummary(
              period: any(named: 'period'),
              budgetId: any(named: 'budgetId'),
            ),
          ).thenAnswer((_) async => testSummary);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(LoadSummaryEvent(period: testPeriod)),
        expect: () => [
          const BudgetLoading(),
          SummaryLoaded(testSummary),
        ],
        verify: (_) {
          verify(
            () => mockCalculateSummary(
              period: any(named: 'period'),
              budgetId: any(named: 'budgetId'),
            ),
          ).called(1);
        },
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits [BudgetLoading, BudgetError] on failure',
        build: () {
          when(
            () => mockCalculateSummary(
              period: any(named: 'period'),
              budgetId: any(named: 'budgetId'),
            ),
          ).thenThrow(Exception('Failed to load summary'));
          return budgetBloc;
        },
        act: (bloc) => bloc.add(LoadSummaryEvent(period: testPeriod)),
        expect: () => [
          const BudgetLoading(),
          isA<BudgetError>(),
        ],
      );
    });

    group('AddIncomeEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits [IncomeAdded, BudgetLoading, SummaryLoaded] on success',
        build: () {
          when(() => mockAddIncome(any())).thenAnswer((_) async {});
          when(
            () => mockCalculateSummary(
              period: any(named: 'period'),
              budgetId: any(named: 'budgetId'),
            ),
          ).thenAnswer((_) async => testSummary);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(
          AddIncomeEvent(
            id: '',
            budgetId: 'budget-1',
            amount: 5000.0,
            categoryId: 'cat-1',
            description: 'Salary',
            date: DateTime(2024, 1, 15),
          ),
        ),
        expect: () => [
          const IncomeAdded(),
          const BudgetLoading(),
          SummaryLoaded(testSummary),
        ],
        verify: (_) {
          verify(() => mockAddIncome(any())).called(1);
          verify(
            () => mockCalculateSummary(
              period: any(named: 'period'),
              budgetId: any(named: 'budgetId'),
            ),
          ).called(1);
        },
      );
    });

    group('AddExpenseEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits [ExpenseAdded, BudgetLoading, SummaryLoaded] on success',
        build: () {
          when(() => mockAddExpense(any())).thenAnswer((_) async {});
          when(
            () => mockCalculateSummary(
              period: any(named: 'period'),
              budgetId: any(named: 'budgetId'),
            ),
          ).thenAnswer((_) async => testSummary);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(
          AddExpenseEvent(
            id: '',
            budgetId: 'budget-1',
            amount: 1000.0,
            category: 'cat-2',
            description: 'Rent',
            date: DateTime(2024, 1, 1),
          ),
        ),
        expect: () => [
          const ExpenseAdded(),
          const BudgetLoading(),
          SummaryLoaded(testSummary),
        ],
        verify: (_) {
          verify(() => mockAddExpense(any())).called(1);
          verify(
            () => mockCalculateSummary(
              period: any(named: 'period'),
              budgetId: any(named: 'budgetId'),
            ),
          ).called(1);
        },
      );
    });

    group('DeleteEntryEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits [EntryDeleted] on success',
        build: () {
          when(() => mockDeleteEntry(any(), any())).thenAnswer((_) async {});
          return budgetBloc;
        },
        act: (bloc) => bloc.add(
          DeleteEntryEvent('income-1', EntryType.income),
        ),
        expect: () => [
          const EntryDeleted(),
        ],
        verify: (_) {
          verify(() => mockDeleteEntry(any(), any())).called(1);
        },
      );
    });

    group('UpdateIncomeEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits [EntryUpdated, BudgetLoading, SummaryLoaded] on success',
        build: () {
          when(
            () => mockUpdateEntry(
              income: any(named: 'income'),
              expense: any(named: 'expense'),
            ),
          ).thenAnswer((_) async {});
          when(
            () => mockCalculateSummary(
              period: any(named: 'period'),
              budgetId: any(named: 'budgetId'),
            ),
          ).thenAnswer((_) async => testSummary);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(UpdateIncomeEvent(testIncomeEntry)),
        expect: () => [
          const EntryUpdated(),
          const BudgetLoading(),
          SummaryLoaded(testSummary),
        ],
        verify: (_) {
          verify(
            () => mockUpdateEntry(
              income: any(named: 'income'),
              expense: any(named: 'expense'),
            ),
          ).called(1);
          verify(
            () => mockCalculateSummary(
              period: any(named: 'period'),
              budgetId: any(named: 'budgetId'),
            ),
          ).called(1);
        },
      );
    });

    group('DuplicateBudgetEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits [BudgetLoading, SummaryLoaded] on success',
        build: () {
          when(
            () => mockDuplicateBudget(
              sourceBudget: any(named: 'sourceBudget'),
              targetPeriod: any(named: 'targetPeriod'),
              newName: any(named: 'newName'),
              includeTransactions: any(named: 'includeTransactions'),
            ),
          ).thenAnswer((_) async => testBudget);
          when(
            () => mockCalculateSummary(
              period: any(named: 'period'),
              budgetId: any(named: 'budgetId'),
            ),
          ).thenAnswer((_) async => testSummary);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(
          DuplicateBudgetEvent(
            sourceBudget: testBudget,
            targetPeriod: testPeriod,
            newName: 'Copy of Test Budget',
          ),
        ),
        expect: () => [
          const BudgetLoading(),
          SummaryLoaded(testSummary),
        ],
        verify: (_) {
          verify(
            () => mockDuplicateBudget(
              sourceBudget: any(named: 'sourceBudget'),
              targetPeriod: any(named: 'targetPeriod'),
              newName: any(named: 'newName'),
              includeTransactions: any(named: 'includeTransactions'),
            ),
          ).called(1);
          verify(
            () => mockCalculateSummary(
              period: any(named: 'period'),
              budgetId: any(named: 'budgetId'),
            ),
          ).called(1);
        },
      );
    });
  });
}
