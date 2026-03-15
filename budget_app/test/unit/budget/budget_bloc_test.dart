import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_app/features/budget/domain/usecases/add_income.dart';
import 'package:budget_app/features/budget/domain/usecases/add_expense.dart';
import 'package:budget_app/features/budget/domain/usecases/calculate_summary.dart';
import 'package:budget_app/features/budget/domain/usecases/delete_entry.dart' as usecase;
import 'package:budget_app/features/budget/domain/usecases/update_entry.dart';
import 'package:budget_app/features/budget/domain/usecases/save_recurring_transaction.dart';
import 'package:budget_app/features/budget/domain/usecases/duplicate_budget.dart';
import 'package:budget_app/features/budget/domain/usecases/confirm_potential_transaction.dart';
import 'package:budget_app/features/budget/presentation/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/budget_event.dart';
import 'package:budget_app/features/budget/presentation/budget_state.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}
class MockAddIncome extends Mock implements AddIncome {}
class MockAddExpense extends Mock implements AddExpense {}
class MockCalculateSummary extends Mock implements CalculateSummary {}
class MockDeleteEntry extends Mock implements usecase.DeleteEntry {}
class MockUpdateEntry extends Mock implements UpdateEntry {}
class MockSaveRecurringTransaction extends Mock implements SaveRecurringTransaction {}
class MockDuplicateBudget extends Mock implements DuplicateBudget {}
class MockConfirmPotentialTransaction extends Mock implements ConfirmPotentialTransaction {}

void main() {
  setUpAll(() {
    registerFallbackValue(usecase.EntryType.income);
  });

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
      expect(budgetBloc.state, equals(const BudgetInitial()));
    });

    blocTest<BudgetBloc, BudgetState>(
      'emits [EntryDeleted] when DeleteEntryEvent is added and successful',
      build: () {
        when(() => mockDeleteEntry.call(any(), any())).thenAnswer((_) async {});
        return budgetBloc;
      },
      act: (bloc) => bloc.add(const DeleteEntryEvent('1', EntryType.income)),
      expect: () => [
        const EntryDeleted(),
      ],
      verify: (_) {
        verify(() => mockDeleteEntry.call('1', usecase.EntryType.income)).called(1);
      },
    );

    blocTest<BudgetBloc, BudgetState>(
      'emits [BudgetError] when DeleteEntryEvent fails',
      build: () {
        when(() => mockDeleteEntry.call(any(), any())).thenThrow(Exception('Delete failed'));
        return budgetBloc;
      },
      act: (bloc) => bloc.add(const DeleteEntryEvent('1', EntryType.income)),
      expect: () => [
        const BudgetError('Exception: Delete failed'),
      ],
    );
  });
}
