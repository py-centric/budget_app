import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/usecases/calculate_summary.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

class FakeBudgetPeriod extends Fake implements BudgetPeriod {}

void main() {
  late CalculateSummary usecase;
  late MockBudgetRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(const BudgetPeriod(year: 2024, month: 1));
  });

  setUp(() {
    mockRepository = MockBudgetRepository();
    usecase = CalculateSummary(mockRepository);
  });

  group('CalculateSummary', () {
    test('should calculate summary with all income and expenses', () async {
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
          isPotential: false,
        ),
      ];

      final expenses = [
        ExpenseEntry(
          id: '1',
          budgetId: 'b-1',
          amount: 300.0,
          categoryId: 'cat-2',
          description: 'Rent',
          date: DateTime(2024, 1, 5),
          periodMonth: 1,
          periodYear: 2024,
          isPotential: false,
        ),
      ];

      when(
        () => mockRepository.getAllIncome(),
      ).thenAnswer((_) async => incomes);
      when(
        () => mockRepository.getAllExpenses(),
      ).thenAnswer((_) async => expenses);

      final result = await usecase.call();

      expect(result.totalIncome, 1000.0);
      expect(result.totalExpenses, 300.0);
      expect(result.balance, 700.0);
    });

    test('should calculate summary for specific period', () async {
      final incomes = [
        IncomeEntry(
          id: '1',
          budgetId: 'b-1',
          amount: 2000.0,
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
          amount: 500.0,
          categoryId: 'cat-2',
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
        period: const BudgetPeriod(year: 2024, month: 1),
      );

      expect(result.totalIncome, 2000.0);
      expect(result.totalExpenses, 500.0);
    });

    test('should filter out potential transactions from totals', () async {
      final incomes = [
        IncomeEntry(
          id: '1',
          budgetId: 'b-1',
          amount: 1000.0,
          categoryId: 'cat-1',
          description: 'Actual Income',
          date: DateTime(2024, 1, 15),
          periodMonth: 1,
          periodYear: 2024,
          isPotential: false,
        ),
        IncomeEntry(
          id: '2',
          budgetId: 'b-1',
          amount: 500.0,
          categoryId: 'cat-1',
          description: 'Potential Income',
          date: DateTime(2024, 1, 20),
          periodMonth: 1,
          periodYear: 2024,
          isPotential: true,
        ),
      ];

      when(
        () => mockRepository.getAllIncome(),
      ).thenAnswer((_) async => incomes);
      when(() => mockRepository.getAllExpenses()).thenAnswer((_) async => []);

      final result = await usecase.call();

      expect(result.totalIncome, 1000.0);
      expect(result.totalPotentialIncome, 1500.0);
    });

    test('should count missed potential transactions', () async {
      final pastDate = DateTime.now().subtract(const Duration(days: 10));
      final incomes = [
        IncomeEntry(
          id: '1',
          budgetId: 'b-1',
          amount: 100.0,
          categoryId: 'cat-1',
          description: 'Missed Income',
          date: pastDate,
          periodMonth: pastDate.month,
          periodYear: pastDate.year,
          isPotential: true,
        ),
      ];

      when(
        () => mockRepository.getAllIncome(),
      ).thenAnswer((_) async => incomes);
      when(() => mockRepository.getAllExpenses()).thenAnswer((_) async => []);

      final result = await usecase.call();

      expect(result.missedPotentialCount, 1);
    });

    test('should handle empty lists', () async {
      when(() => mockRepository.getAllIncome()).thenAnswer((_) async => []);
      when(() => mockRepository.getAllExpenses()).thenAnswer((_) async => []);

      final result = await usecase.call();

      expect(result.totalIncome, 0.0);
      expect(result.totalExpenses, 0.0);
      expect(result.balance, 0.0);
    });
  });

  group('BudgetSummary', () {
    test('should create BudgetSummary with all fields', () {
      const summary = BudgetSummary(
        totalIncome: 1000.0,
        totalExpenses: 300.0,
        balance: 700.0,
        totalPotentialIncome: 1500.0,
        totalPotentialExpenses: 500.0,
        incomeEntries: [],
        expenseEntries: [],
        missedPotentialCount: 2,
      );

      expect(summary.totalIncome, 1000.0);
      expect(summary.balance, 700.0);
      expect(summary.missedPotentialCount, 2);
    });
  });
}
