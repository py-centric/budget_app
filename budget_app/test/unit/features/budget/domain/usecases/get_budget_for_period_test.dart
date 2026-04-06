import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/usecases/get_budget_for_period.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

class FakeBudgetPeriod extends Fake implements BudgetPeriod {}

void main() {
  late GetBudgetForPeriod usecase;
  late MockBudgetRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(const BudgetPeriod(year: 2024, month: 1));
  });

  setUp(() {
    mockRepository = MockBudgetRepository();
    usecase = GetBudgetForPeriod(mockRepository);
  });

  group('GetBudgetForPeriod', () {
    test('should return budget data for period', () async {
      final incomes = [
        IncomeEntry(
          id: '1',
          budgetId: 'b-1',
          amount: 1000.0,
          categoryId: 'cat-1',
          description: 'Salary',
          date: DateTime(2024, 1, 15),
          periodMonth: 1,
          periodYear: 2024,
        ),
      ];

      final expenses = [
        ExpenseEntry(
          id: '1',
          budgetId: 'b-1',
          amount: 300.0,
          categoryId: 'cat-2',
          description: 'Rent',
          date: DateTime(2024, 1, 20),
          periodMonth: 1,
          periodYear: 2024,
        ),
      ];

      when(
        () => mockRepository.getIncomeForPeriod(any()),
      ).thenAnswer((_) async => incomes);
      when(
        () => mockRepository.getExpensesForPeriod(any()),
      ).thenAnswer((_) async => expenses);

      final result = await usecase.call(
        const BudgetPeriod(year: 2024, month: 1),
      );

      expect(result.incomes.length, 1);
      expect(result.expenses.length, 1);
      expect(result.totalIncome, 1000.0);
      expect(result.totalExpenses, 300.0);
      expect(result.balance, 700.0);
    });

    test('should calculate correct totals with multiple entries', () async {
      final incomes = [
        IncomeEntry(
          id: '1',
          budgetId: 'b-1',
          amount: 1000.0,
          categoryId: 'cat-1',
          description: 'Salary',
          date: DateTime(2024, 1, 15),
          periodMonth: 1,
          periodYear: 2024,
        ),
        IncomeEntry(
          id: '2',
          budgetId: 'b-1',
          amount: 500.0,
          categoryId: 'cat-2',
          description: 'Bonus',
          date: DateTime(2024, 1, 20),
          periodMonth: 1,
          periodYear: 2024,
        ),
      ];

      final expenses = [
        ExpenseEntry(
          id: '1',
          budgetId: 'b-1',
          amount: 300.0,
          categoryId: 'cat-3',
          description: 'Rent',
          date: DateTime(2024, 1, 5),
          periodMonth: 1,
          periodYear: 2024,
        ),
        ExpenseEntry(
          id: '2',
          budgetId: 'b-1',
          amount: 150.0,
          categoryId: 'cat-4',
          description: 'Food',
          date: DateTime(2024, 1, 10),
          periodMonth: 1,
          periodYear: 2024,
        ),
      ];

      when(
        () => mockRepository.getIncomeForPeriod(any()),
      ).thenAnswer((_) async => incomes);
      when(
        () => mockRepository.getExpensesForPeriod(any()),
      ).thenAnswer((_) async => expenses);

      final result = await usecase.call(
        const BudgetPeriod(year: 2024, month: 1),
      );

      expect(result.totalIncome, 1500.0);
      expect(result.totalExpenses, 450.0);
      expect(result.balance, 1050.0);
    });

    test('should handle empty lists', () async {
      when(
        () => mockRepository.getIncomeForPeriod(any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockRepository.getExpensesForPeriod(any()),
      ).thenAnswer((_) async => []);

      final result = await usecase.call(
        const BudgetPeriod(year: 2024, month: 1),
      );

      expect(result.incomes, isEmpty);
      expect(result.expenses, isEmpty);
      expect(result.totalIncome, 0.0);
      expect(result.totalExpenses, 0.0);
      expect(result.balance, 0.0);
    });
  });

  group('GetBudgetForPeriodResult', () {
    test('should calculate negative balance correctly', () {
      final result = GetBudgetForPeriodResult(
        incomes: [],
        expenses: [
          ExpenseEntry(
            id: '1',
            budgetId: 'b-1',
            amount: 500.0,
            categoryId: 'cat-1',
            description: 'Expense',
            date: DateTime(2024, 1, 1),
            periodMonth: 1,
            periodYear: 2024,
          ),
        ],
      );

      expect(result.balance, -500.0);
    });
  });
}
