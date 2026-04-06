import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/usecases/confirm_potential_transaction.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

class FakeIncomeEntry extends Fake implements IncomeEntry {}

class FakeExpenseEntry extends Fake implements ExpenseEntry {}

void main() {
  late ConfirmPotentialTransaction usecase;
  late MockBudgetRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeIncomeEntry());
    registerFallbackValue(FakeExpenseEntry());
  });

  setUp(() {
    mockRepository = MockBudgetRepository();
    usecase = ConfirmPotentialTransaction(mockRepository);
  });

  group('ConfirmPotentialTransaction', () {
    test('should confirm income transaction', () async {
      final income = IncomeEntry(
        id: '1',
        budgetId: 'b-1',
        amount: 100.0,
        categoryId: 'cat-1',
        description: 'Potential Income',
        date: DateTime(2024, 1, 15),
        periodMonth: 1,
        periodYear: 2024,
        isPotential: true,
      );

      when(
        () => mockRepository.getAllIncome(),
      ).thenAnswer((_) async => [income]);
      when(() => mockRepository.updateIncome(any())).thenAnswer((_) async {});

      await usecase.call(incomeId: '1');

      verify(() => mockRepository.getAllIncome()).called(1);
      verify(() => mockRepository.updateIncome(any())).called(1);
    });

    test('should confirm expense transaction', () async {
      final expense = ExpenseEntry(
        id: '1',
        budgetId: 'b-1',
        amount: 50.0,
        categoryId: 'cat-2',
        description: 'Potential Expense',
        date: DateTime(2024, 1, 20),
        periodMonth: 1,
        periodYear: 2024,
        isPotential: true,
      );

      when(
        () => mockRepository.getAllExpenses(),
      ).thenAnswer((_) async => [expense]);
      when(() => mockRepository.updateExpense(any())).thenAnswer((_) async {});

      await usecase.call(expenseId: '1');

      verify(() => mockRepository.getAllExpenses()).called(1);
      verify(() => mockRepository.updateExpense(any())).called(1);
    });

    test('should set isPotential to false when confirming income', () async {
      final income = IncomeEntry(
        id: '1',
        budgetId: 'b-1',
        amount: 100.0,
        categoryId: 'cat-1',
        description: 'Test',
        date: DateTime(2024, 1, 15),
        periodMonth: 1,
        periodYear: 2024,
        isPotential: true,
      );

      IncomeEntry? capturedIncome;

      when(
        () => mockRepository.getAllIncome(),
      ).thenAnswer((_) async => [income]);
      when(() => mockRepository.updateIncome(any())).thenAnswer((
        invocation,
      ) async {
        capturedIncome = invocation.positionalArguments[0] as IncomeEntry;
      });

      await usecase.call(incomeId: '1');

      expect(capturedIncome!.isPotential, false);
    });

    test('should set isPotential to false when confirming expense', () async {
      final expense = ExpenseEntry(
        id: '1',
        budgetId: 'b-1',
        amount: 50.0,
        categoryId: 'cat-2',
        description: 'Test',
        date: DateTime(2024, 1, 20),
        periodMonth: 1,
        periodYear: 2024,
        isPotential: true,
      );

      ExpenseEntry? capturedExpense;

      when(
        () => mockRepository.getAllExpenses(),
      ).thenAnswer((_) async => [expense]);
      when(() => mockRepository.updateExpense(any())).thenAnswer((
        invocation,
      ) async {
        capturedExpense = invocation.positionalArguments[0] as ExpenseEntry;
      });

      await usecase.call(expenseId: '1');

      expect(capturedExpense!.isPotential, false);
    });
  });
}
