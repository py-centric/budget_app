import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/usecases/get_calendar_data.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';

class MockBudgetRepository implements BudgetRepository {
  List<IncomeEntry> incomes = [];
  List<ExpenseEntry> expenses = [];
  List<Category> categories = [];

  @override
  Future<List<IncomeEntry>> getAllIncome() async => incomes;

  @override
  Future<List<ExpenseEntry>> getAllExpenses() async => expenses;

  @override
  Future<List<Category>> getCategories() async => categories;

  @override
  Future<List<ExpenseEntry>> getExpensesBefore(DateTime date) async =>
      expenses.where((e) => e.date.isBefore(date)).toList();

  @override
  Future<List<IncomeEntry>> getIncomeBefore(DateTime date) async =>
      incomes.where((i) => i.date.isBefore(date)).toList();

  // Stubs for unused methods
  @override
  Future<void> addIncome(IncomeEntry income) async {}

  @override
  Future<void> updateIncome(IncomeEntry income) async {}

  @override
  Future<void> deleteIncome(String id) async {}

  @override
  Future<void> addExpense(ExpenseEntry expense) async {}

  @override
  Future<void> updateExpense(ExpenseEntry expense) async {}

  @override
  Future<void> deleteExpense(String id) async {}

  @override
  Future<List<IncomeEntry>> getIncomeForPeriod(BudgetPeriod period) async => [];

  @override
  Future<List<ExpenseEntry>> getExpensesForPeriod(BudgetPeriod period) async => [];

  @override
  Future<List<IncomeEntry>> getIncomeForDateRange(DateTime start, DateTime end) async => [];

  @override
  Future<List<ExpenseEntry>> getExpensesForDateRange(DateTime start, DateTime end) async => [];

  @override
  Future<List<IncomeEntry>> getIncomeForBudget(String budgetId) async => [];

  @override
  Future<List<ExpenseEntry>> getExpensesForBudget(String budgetId) async => [];

  @override
  Future<List<Budget>> getBudgetsForPeriod(BudgetPeriod period) async => [];

  @override
  Future<Budget?> getBudget(String id) async => null;

  @override
  Future<void> addBudget(Budget budget) async {}

  @override
  Future<void> updateBudget(Budget budget) async {}

  @override
  Future<void> deleteBudget(String id) async {}

  @override
  Future<List<Category>> getCategoriesByType(CategoryType type) async => [];

  @override
  Future<void> addCategory(Category category) async {}

  @override
  Future<void> updateCategory(Category category) async {}

  @override
  Future<void> deleteCategory(String id) async {}

  @override
  Future<void> reassignAndDeleteCategory(String oldId, String newId) async {}

  @override
  Future<List<BudgetPeriod>> getAvailablePeriods() async => [];

  @override
  Future<List<Budget>> getDisposableHistory() async => [];

  @override
  Future<List<Budget>> getActiveDisposableBudgets() async => [];

  @override
  Future<void> clearAllBudgets() async {}

  @override
  Future<void> factoryReset() async {}
}

void main() {
  late MockBudgetRepository mockRepo;
  late GetCalendarData useCase;

  setUp(() {
    mockRepo = MockBudgetRepository();
    useCase = GetCalendarData(mockRepo);
  });

  group('GetCalendarData', () {
    test('forMonth returns data for the correct month', () async {
      mockRepo.incomes = [
        IncomeEntry(
          id: 'i-1', budgetId: 'b1', amount: 3000,
          date: DateTime(2024, 6, 15),
        ),
        IncomeEntry(
          id: 'i-2', budgetId: 'b1', amount: 1000,
          date: DateTime(2024, 4, 20),
        ),
      ];
      mockRepo.expenses = [
        ExpenseEntry(
          id: 'e-1', budgetId: 'b1', amount: 200, categoryId: 'food',
          date: DateTime(2024, 6, 10),
        ),
        ExpenseEntry(
          id: 'e-2', budgetId: 'b1', amount: 50, categoryId: 'food',
          date: DateTime(2024, 8, 1),
        ),
      ];
      mockRepo.categories = [
        const Category(id: 'food', name: 'Food', type: CategoryType.expense),
      ];

      final result = await useCase.forMonth(2024, 6);

      expect(result.incomes.length, 1);
      expect(result.expenses.length, 1);
      expect(result.categories.length, 1);
      expect(result.incomes.first.amount, 3000);
      expect(result.expenses.first.amount, 200);
    });

    test('forMonth with no data returns empty lists', () async {
      final result = await useCase.forMonth(2024, 1);
      expect(result.incomes, isEmpty);
      expect(result.expenses, isEmpty);
      expect(result.categories, isEmpty);
    });

    test('getTotalExpensesBefore sums correctly', () async {
      mockRepo.expenses = [
        ExpenseEntry(
          id: 'e-1', budgetId: 'b1', amount: 100, categoryId: 'food',
          date: DateTime(2024, 5, 10),
        ),
        ExpenseEntry(
          id: 'e-2', budgetId: 'b1', amount: 200, categoryId: 'food',
          date: DateTime(2024, 6, 10),
        ),
      ];

      final total = await useCase.getTotalExpensesBefore(DateTime(2024, 6, 1));
      expect(total, 100);
    });

    test('getTotalIncomesBefore sums correctly', () async {
      mockRepo.incomes = [
        IncomeEntry(
          id: 'i-1', budgetId: 'b1', amount: 3000,
          date: DateTime(2024, 5, 15),
        ),
        IncomeEntry(
          id: 'i-2', budgetId: 'b1', amount: 3000,
          date: DateTime(2024, 6, 15),
        ),
      ];

      final total = await useCase.getTotalIncomesBefore(DateTime(2024, 6, 1));
      expect(total, 3000);
    });

    test('getExpensesBefore returns filtered list', () async {
      mockRepo.expenses = [
        ExpenseEntry(
          id: 'e-1', budgetId: 'b1', amount: 100, categoryId: 'food',
          date: DateTime(2024, 5, 10),
        ),
        ExpenseEntry(
          id: 'e-2', budgetId: 'b1', amount: 200, categoryId: 'food',
          date: DateTime(2024, 6, 10),
        ),
      ];

      final result = await useCase.getExpensesBefore(DateTime(2024, 6, 1));
      expect(result.length, 1);
      expect(result.first.id, 'e-1');
    });

    test('getIncomesBefore returns filtered list', () async {
      mockRepo.incomes = [
        IncomeEntry(
          id: 'i-1', budgetId: 'b1', amount: 3000,
          date: DateTime(2024, 5, 15),
        ),
        IncomeEntry(
          id: 'i-2', budgetId: 'b1', amount: 3000,
          date: DateTime(2024, 6, 15),
        ),
      ];

      final result = await useCase.getIncomesBefore(DateTime(2024, 6, 1));
      expect(result.length, 1);
      expect(result.first.id, 'i-1');
    });
  });

  group('CalendarMonthData', () {
    test('fields are correct', () {
      const data = CalendarMonthData(incomes: [], expenses: [], categories: []);
      expect(data.incomes, isEmpty);
      expect(data.expenses, isEmpty);
      expect(data.categories, isEmpty);
    });
  });
}
