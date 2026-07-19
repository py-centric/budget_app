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

  const testDisposableBudget = Budget(
    id: 'disp-1',
    name: 'Equipment Fund',
    periodMonth: 1,
    periodYear: 2024,
    type: BudgetType.disposable,
    targetIncome: 5000.0,
    sourceDescription: 'Freelance payment',
  );

  final testExpenses = [
    ExpenseEntry(
      id: 'exp-1',
      budgetId: 'disp-1',
      amount: 1200.0,
      categoryId: 'cat-1',
      description: 'Desk',
      date: DateTime(2024, 1, 10),
    ),
  ];

  final testIncomes = [
    IncomeEntry(
      id: 'inc-1',
      budgetId: 'budget-1',
      amount: 5000.0,
      categoryId: 'cat-1',
      description: 'Freelance',
      date: DateTime(2024, 1, 1),
    ),
  ];

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

  group('Disposable Budget Events', () {
    group('CreateDisposableBudgetEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits DisposableBudgetCreated and reloads history on success',
        build: () {
          when(() => mockRepository.addBudget(any())).thenAnswer((_) async {});
          when(() => mockRepository.getActiveDisposableBudgets())
              .thenAnswer((_) async => [testDisposableBudget]);
          when(() => mockRepository.getDisposableHistory())
              .thenAnswer((_) async => []);
          when(() => mockRepository.getExpensesForBudget(any()))
              .thenAnswer((_) async => testExpenses);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const CreateDisposableBudgetEvent(
          name: 'Equipment Fund',
          targetIncome: 5000.0,
          sourceDescription: 'Freelance payment',
          periodMonth: 1,
          periodYear: 2024,
        )),
        verify: (_) {
          verify(() => mockRepository.addBudget(any())).called(1);
        },
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError when target income is zero',
        build: () {
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const CreateDisposableBudgetEvent(
          name: 'Bad Budget',
          targetIncome: 0,
          sourceDescription: 'No income',
          periodMonth: 1,
          periodYear: 2024,
        )),
        expect: () => [isA<BudgetError>()],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError when target income is negative',
        build: () {
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const CreateDisposableBudgetEvent(
          name: 'Bad Budget',
          targetIncome: -100,
          sourceDescription: 'Negative',
          periodMonth: 1,
          periodYear: 2024,
        )),
        expect: () => [isA<BudgetError>()],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError when source description exceeds 200 chars',
        build: () {
          return budgetBloc;
        },
        act: (bloc) => bloc.add(CreateDisposableBudgetEvent(
          name: 'Long Desc',
          targetIncome: 1000,
          sourceDescription: 'A' * 201,
          periodMonth: 1,
          periodYear: 2024,
        )),
        expect: () => [isA<BudgetError>()],
      );
    });

    group('UpdateDisposableBudgetEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits DisposableBudgetsLoaded on success',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenAnswer((_) async => testDisposableBudget);
          when(() => mockRepository.updateBudget(any()))
              .thenAnswer((_) async {});
          when(() => mockRepository.getActiveDisposableBudgets())
              .thenAnswer((_) async => [testDisposableBudget]);
          when(() => mockRepository.getDisposableHistory())
              .thenAnswer((_) async => []);
          when(() => mockRepository.getExpensesForBudget(any()))
              .thenAnswer((_) async => testExpenses);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const UpdateDisposableBudgetEvent(
          budgetId: 'disp-1',
          targetIncome: 6000.0,
          sourceDescription: 'Updated source',
        )),
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
    });

    group('DisposeBudgetEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetDisposed and reloads history on success',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenAnswer((_) async => testDisposableBudget);
          when(() => mockRepository.updateBudget(any()))
              .thenAnswer((_) async {});
          when(() => mockRepository.getActiveDisposableBudgets())
              .thenAnswer((_) async => []);
          when(() => mockRepository.getDisposableHistory())
              .thenAnswer((_) async => [
                    testDisposableBudget.copyWith(type: BudgetType.disposed),
                  ]);
          when(() => mockRepository.getExpensesForBudget(any()))
              .thenAnswer((_) async => []);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const DisposeBudgetEvent('disp-1')),
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
        act: (bloc) => bloc.add(const DisposeBudgetEvent('nonexistent')),
        expect: () => [isA<BudgetError>()],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError when budget is not disposable',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenAnswer((_) async => const Budget(
                    id: 'reg-1',
                    name: 'Regular',
                    periodMonth: 1,
                    periodYear: 2024,
                    type: BudgetType.regular,
                  ));
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const DisposeBudgetEvent('reg-1')),
        expect: () => [isA<BudgetError>()],
      );
    });

    group('PersistBudgetEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetPersisted and reloads history on success',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenAnswer((_) async => testDisposableBudget);
          when(() => mockRepository.updateBudget(any()))
              .thenAnswer((_) async {});
          when(() => mockRepository.getActiveDisposableBudgets())
              .thenAnswer((_) async => []);
          when(() => mockRepository.getDisposableHistory())
              .thenAnswer((_) async => [
                    testDisposableBudget.copyWith(type: BudgetType.persisted),
                  ]);
          when(() => mockRepository.getExpensesForBudget(any()))
              .thenAnswer((_) async => []);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const PersistBudgetEvent('disp-1')),
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
        act: (bloc) => bloc.add(const PersistBudgetEvent('nonexistent')),
        expect: () => [isA<BudgetError>()],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError when budget is not disposable',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenAnswer((_) async => const Budget(
                    id: 'reg-1',
                    name: 'Regular',
                    periodMonth: 1,
                    periodYear: 2024,
                    type: BudgetType.regular,
                  ));
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const PersistBudgetEvent('reg-1')),
        expect: () => [isA<BudgetError>()],
      );
    });

    group('LoadDisposableHistoryEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits DisposableBudgetsLoaded with active and history',
        build: () {
          when(() => mockRepository.getActiveDisposableBudgets())
              .thenAnswer((_) async => [testDisposableBudget]);
          when(() => mockRepository.getDisposableHistory())
              .thenAnswer((_) async => [
                    testDisposableBudget.copyWith(type: BudgetType.disposed),
                  ]);
          when(() => mockRepository.getExpensesForBudget(any()))
              .thenAnswer((_) async => testExpenses);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const LoadDisposableHistoryEvent()),
        expect: () => [
          isA<DisposableBudgetsLoaded>()
              .having((s) => s.active.length, 'active length', 1)
              .having((s) => s.history.length, 'history length', 1)
              .having((s) => s.budgetExpenseTotals['disp-1'], 'expense total', 1200.0)
              .having((s) => s.endedBudgetIds, 'ended IDs', isNotEmpty),
        ],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits DisposableBudgetsLoaded with empty lists when no disposable budgets',
        build: () {
          when(() => mockRepository.getActiveDisposableBudgets())
              .thenAnswer((_) async => []);
          when(() => mockRepository.getDisposableHistory())
              .thenAnswer((_) async => []);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const LoadDisposableHistoryEvent()),
        expect: () => [
          isA<DisposableBudgetsLoaded>()
              .having((s) => s.active.length, 'active length', 0)
              .having((s) => s.history.length, 'history length', 0)
              .having((s) => s.budgetExpenseTotals, 'expense totals', isEmpty)
              .having((s) => s.endedBudgetIds, 'ended IDs', isEmpty),
        ],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError on repository failure',
        build: () {
          when(() => mockRepository.getActiveDisposableBudgets())
              .thenThrow(Exception('DB error'));
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const LoadDisposableHistoryEvent()),
        expect: () => [isA<BudgetError>()],
      );
    });

    group('LinkIncomeToBudgetEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits IncomeLinked on success',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenAnswer((_) async => testDisposableBudget);
          when(() => mockRepository.updateBudget(any()))
              .thenAnswer((_) async {});
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const LinkIncomeToBudgetEvent(
          budgetId: 'disp-1',
          incomeTransactionId: 'inc-1',
        )),
        expect: () => [
          isA<IncomeLinked>()
              .having((s) => s.budgetId, 'budgetId', 'disp-1')
              .having((s) => s.transactionId, 'transactionId', 'inc-1'),
        ],
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
        act: (bloc) => bloc.add(const LinkIncomeToBudgetEvent(
          budgetId: 'nonexistent',
          incomeTransactionId: 'inc-1',
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
        act: (bloc) => bloc.add(const LinkIncomeToBudgetEvent(
          budgetId: 'disp-1',
          incomeTransactionId: 'inc-1',
        )),
        expect: () => [isA<BudgetError>()],
      );
    });

    group('UnlinkIncomeFromBudgetEvent', () {
      const disposableWithLink = Budget(
        id: 'disp-2',
        name: 'Linked Budget',
        periodMonth: 1,
        periodYear: 2024,
        type: BudgetType.disposable,
        targetIncome: 3000.0,
        sourceDescription: 'Linked income',
        linkedIncomeId: 'inc-1',
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits IncomeUnlinked on success',
        build: () {
          when(() => mockRepository.getBudget(any()))
              .thenAnswer((_) async => disposableWithLink);
          when(() => mockRepository.updateBudget(any()))
              .thenAnswer((_) async {});
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const UnlinkIncomeFromBudgetEvent('disp-2')),
        expect: () => [isA<IncomeUnlinked>().having((s) => s.budgetId, 'budgetId', 'disp-2')],
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
        act: (bloc) => bloc.add(const UnlinkIncomeFromBudgetEvent('nonexistent')),
        expect: () => [isA<BudgetError>()],
      );
    });

    group('LoadIncomeListEvent', () {
      blocTest<BudgetBloc, BudgetState>(
        'emits IncomeListLoaded with income entries',
        build: () {
          when(() => mockRepository.getAllIncome())
              .thenAnswer((_) async => testIncomes);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const LoadIncomeListEvent()),
        expect: () => [
          isA<IncomeListLoaded>()
              .having((s) => s.incomes.length, 'income count', 1)
              .having((s) => s.incomes.first.amount, 'first income amount', 5000.0),
        ],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits IncomeListLoaded with empty list when no incomes',
        build: () {
          when(() => mockRepository.getAllIncome())
              .thenAnswer((_) async => []);
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const LoadIncomeListEvent()),
        expect: () => [
          isA<IncomeListLoaded>()
              .having((s) => s.incomes.length, 'income count', 0),
        ],
      );

      blocTest<BudgetBloc, BudgetState>(
        'emits BudgetError on repository failure',
        build: () {
          when(() => mockRepository.getAllIncome())
              .thenThrow(Exception('DB error'));
          return budgetBloc;
        },
        act: (bloc) => bloc.add(const LoadIncomeListEvent()),
        expect: () => [isA<BudgetError>()],
      );
    });
  });
}
