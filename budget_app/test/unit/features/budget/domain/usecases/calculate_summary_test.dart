import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/usecases/calculate_summary.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_app/features/budget/domain/repositories/recurring_repository.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/domain/entities/recurring_transaction.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

class MockRecurringRepository extends Mock implements RecurringRepository {}

class FakeBudgetPeriod extends Fake implements BudgetPeriod {}

void main() {
  late CalculateSummary usecase;
  late MockBudgetRepository mockRepository;
  late MockRecurringRepository mockRecurringRepository;

  setUpAll(() {
    registerFallbackValue(const BudgetPeriod(year: 2024, month: 1));
    registerFallbackValue(
      RecurringTransaction(
        id: 'test',
        budgetId: 'test',
        type: 'INCOME',
        amount: 100,
        categoryId: 'cat',
        description: 'test',
        startDate: DateTime.now(),
        interval: 1,
        unit: RecurrenceUnit.months,
      ),
    );
  });

  setUp(() {
    mockRepository = MockBudgetRepository();
    mockRecurringRepository = MockRecurringRepository();
    usecase = CalculateSummary(
      mockRepository,
      recurringRepository: mockRecurringRepository,
    );

    // Default stubs for recurring repository to avoid null errors
    when(
      () => mockRecurringRepository.getAllRecurringTransactions(),
    ).thenAnswer((_) async => []);
    when(
      () => mockRecurringRepository.getAllOverrides(),
    ).thenAnswer((_) async => []);
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

    test('should include recurring transactions in summary', () async {
      final incomes = <IncomeEntry>[];
      final expenses = <ExpenseEntry>[];
      final recurringTemplates = [
        RecurringTransaction(
          id: 'rec-1',
          budgetId: 'b-1',
          type: 'INCOME',
          amount: 500.0,
          categoryId: 'cat-1',
          description: 'Monthly salary',
          startDate: DateTime(2024, 1, 1),
          interval: 1,
          unit: RecurrenceUnit.months,
        ),
      ];

      when(
        () => mockRepository.getAllIncome(),
      ).thenAnswer((_) async => incomes);
      when(
        () => mockRepository.getAllExpenses(),
      ).thenAnswer((_) async => expenses);
      when(
        () => mockRecurringRepository.getAllRecurringTransactions(),
      ).thenAnswer((_) async => recurringTemplates);
      when(
        () => mockRecurringRepository.getAllOverrides(),
      ).thenAnswer((_) async => []);

      final result = await usecase.call();

      expect(result.incomeEntries.length, greaterThan(0));
      expect(result.totalPotentialIncome, greaterThan(0));
    });

    test('should filter recurring by budgetId', () async {
      final incomes = <IncomeEntry>[];
      final expenses = <ExpenseEntry>[];
      final recurringTemplates = [
        RecurringTransaction(
          id: 'rec-1',
          budgetId: 'b-1',
          type: 'INCOME',
          amount: 500.0,
          categoryId: 'cat-1',
          description: 'Monthly salary',
          startDate: DateTime(2024, 1, 1),
          interval: 1,
          unit: RecurrenceUnit.months,
        ),
        RecurringTransaction(
          id: 'rec-2',
          budgetId: 'b-2',
          type: 'INCOME',
          amount: 1000.0,
          categoryId: 'cat-1',
          description: 'Other income',
          startDate: DateTime(2024, 1, 1),
          interval: 1,
          unit: RecurrenceUnit.months,
        ),
      ];

      when(
        () => mockRepository.getIncomeForBudget('b-1'),
      ).thenAnswer((_) async => incomes);
      when(
        () => mockRepository.getExpensesForBudget('b-1'),
      ).thenAnswer((_) async => expenses);
      when(
        () => mockRecurringRepository.getAllRecurringTransactions(),
      ).thenAnswer((_) async => recurringTemplates);
      when(
        () => mockRecurringRepository.getAllOverrides(),
      ).thenAnswer((_) async => []);

      final result = await usecase.call(budgetId: 'b-1');

      final recurringIncome = result.incomeEntries.where(
        (e) => e.id == 'rec-1',
      );
      expect(recurringIncome.isNotEmpty, true);
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
