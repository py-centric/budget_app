import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

class FakeIncomeEntry extends Fake implements IncomeEntry {}

class FakeExpenseEntry extends Fake implements ExpenseEntry {}

class FakeBudget extends Fake implements Budget {}

class FakeBudgetPeriod extends Fake implements BudgetPeriod {}

void main() {
  late MockBudgetRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeIncomeEntry());
    registerFallbackValue(FakeExpenseEntry());
    registerFallbackValue(FakeBudget());
    registerFallbackValue(const BudgetPeriod(year: 2024, month: 1));
  });

  setUp(() {
    mockRepository = MockBudgetRepository();
  });

  group('BudgetRepository', () {
    test('getAllIncome should return list of income entries', () async {
      final incomes = [
        IncomeEntry(
          id: '1',
          budgetId: 'b-1',
          amount: 1000.0,
          categoryId: 'cat-1',
          description: 'Salary',
          date: DateTime(2024, 1, 15),
        ),
      ];

      when(
        () => mockRepository.getAllIncome(),
      ).thenAnswer((_) async => incomes);

      final result = await mockRepository.getAllIncome();

      expect(result, incomes);
      expect(result.length, 1);
      expect(result.first.amount, 1000.0);
      verify(() => mockRepository.getAllIncome()).called(1);
    });

    test('getAllExpenses should return list of expense entries', () async {
      final expenses = [
        ExpenseEntry(
          id: '1',
          budgetId: 'b-1',
          amount: 50.0,
          categoryId: 'cat-2',
          description: 'Groceries',
          date: DateTime(2024, 1, 20),
        ),
      ];

      when(
        () => mockRepository.getAllExpenses(),
      ).thenAnswer((_) async => expenses);

      final result = await mockRepository.getAllExpenses();

      expect(result, expenses);
      expect(result.length, 1);
      verify(() => mockRepository.getAllExpenses()).called(1);
    });

    test('getBudgetsForPeriod should return budgets for period', () async {
      final budgets = [
        const Budget(
          id: '1',
          name: 'January 2024',
          periodMonth: 1,
          periodYear: 2024,
        ),
      ];

      when(
        () => mockRepository.getBudgetsForPeriod(any()),
      ).thenAnswer((_) async => budgets);

      final result = await mockRepository.getBudgetsForPeriod(
        const BudgetPeriod(year: 2024, month: 1),
      );

      expect(result, budgets);
      expect(result.length, 1);
    });

    test('getAvailablePeriods should return list of periods', () async {
      final periods = [
        const BudgetPeriod(year: 2024, month: 1),
        const BudgetPeriod(year: 2024, month: 2),
      ];

      when(
        () => mockRepository.getAvailablePeriods(),
      ).thenAnswer((_) async => periods);

      final result = await mockRepository.getAvailablePeriods();

      expect(result, periods);
      expect(result.length, 2);
    });

    test('getCategories should return list of categories', () async {
      final categories = [
        const Category(id: '1', name: 'Salary', type: CategoryType.income),
        const Category(id: '2', name: 'Food', type: CategoryType.expense),
      ];

      when(
        () => mockRepository.getCategories(),
      ).thenAnswer((_) async => categories);

      final result = await mockRepository.getCategories();

      expect(result, categories);
      expect(result.length, 2);
    });

    test('getCategoriesByType should filter by type', () async {
      final incomeCategories = [
        const Category(id: '1', name: 'Salary', type: CategoryType.income),
      ];

      when(
        () => mockRepository.getCategoriesByType(CategoryType.income),
      ).thenAnswer((_) async => incomeCategories);

      final result = await mockRepository.getCategoriesByType(
        CategoryType.income,
      );

      expect(result, incomeCategories);
      expect(result.first.type, CategoryType.income);
    });

    test('addIncome should call repository', () async {
      when(() => mockRepository.addIncome(any())).thenAnswer((_) async {});

      final income = IncomeEntry(
        id: '1',
        budgetId: 'b-1',
        amount: 500.0,
        categoryId: 'cat-1',
        description: 'Bonus',
        date: DateTime(2024, 1, 15),
      );

      await mockRepository.addIncome(income);

      verify(() => mockRepository.addIncome(income)).called(1);
    });

    test('deleteIncome should call repository', () async {
      when(() => mockRepository.deleteIncome(any())).thenAnswer((_) async {});

      await mockRepository.deleteIncome('1');

      verify(() => mockRepository.deleteIncome('1')).called(1);
    });

    test('clearAllBudgets should call repository', () async {
      when(() => mockRepository.clearAllBudgets()).thenAnswer((_) async {});

      await mockRepository.clearAllBudgets();

      verify(() => mockRepository.clearAllBudgets()).called(1);
    });

    test('factoryReset should call repository', () async {
      when(() => mockRepository.factoryReset()).thenAnswer((_) async {});

      await mockRepository.factoryReset();

      verify(() => mockRepository.factoryReset()).called(1);
    });
  });
}
