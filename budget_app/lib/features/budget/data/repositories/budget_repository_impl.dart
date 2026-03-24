import '../../domain/entities/income_entry.dart';
import '../../domain/entities/expense_entry.dart';
import '../../domain/entities/budget_period.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/local_database.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final LocalDatabase _localDatabase;

  BudgetRepositoryImpl(this._localDatabase);

  @override
  Future<void> addIncome(IncomeEntry income) async {
    await _localDatabase.insertIncome(income.toMap());
  }

  @override
  Future<void> updateIncome(IncomeEntry income) async {
    await _localDatabase.updateIncome(income.toMap());
  }

  @override
  Future<void> deleteIncome(String id) async {
    await _localDatabase.deleteIncome(id);
  }

  @override
  Future<void> addExpense(ExpenseEntry expense) async {
    await _localDatabase.insertExpense(expense.toMap());
  }

  @override
  Future<void> updateExpense(ExpenseEntry expense) async {
    await _localDatabase.updateExpense(expense.toMap());
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _localDatabase.deleteExpense(id);
  }

  @override
  Future<List<IncomeEntry>> getAllIncome() async {
    final maps = await _localDatabase.getAllIncome();
    return maps.map((map) => IncomeEntry.fromMap(map)).toList();
  }

  @override
  Future<List<ExpenseEntry>> getAllExpenses() async {
    final maps = await _localDatabase.getAllExpenses();
    return maps.map((map) => ExpenseEntry.fromMap(map)).toList();
  }

  @override
  Future<List<IncomeEntry>> getIncomeForPeriod(BudgetPeriod period) async {
    final maps = await _localDatabase.getIncomeForPeriod(
      period.year,
      period.month,
    );
    return maps.map((map) => IncomeEntry.fromMap(map)).toList();
  }

  @override
  Future<List<ExpenseEntry>> getExpensesForPeriod(BudgetPeriod period) async {
    final maps = await _localDatabase.getExpensesForPeriod(
      period.year,
      period.month,
    );
    return maps.map((map) => ExpenseEntry.fromMap(map)).toList();
  }

  @override
  Future<List<IncomeEntry>> getIncomeForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final maps = await _localDatabase.getIncomeForDateRange(
      start.toIso8601String(),
      end.toIso8601String(),
    );
    return maps.map((map) => IncomeEntry.fromMap(map)).toList();
  }

  @override
  Future<List<ExpenseEntry>> getExpensesForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final maps = await _localDatabase.getExpensesForDateRange(
      start.toIso8601String(),
      end.toIso8601String(),
    );
    return maps.map((map) => ExpenseEntry.fromMap(map)).toList();
  }

  @override
  Future<List<IncomeEntry>> getIncomeBefore(DateTime date) async {
    final maps = await _localDatabase.getIncomeBefore(date.toIso8601String());
    return maps.map((map) => IncomeEntry.fromMap(map)).toList();
  }

  @override
  Future<List<ExpenseEntry>> getExpensesBefore(DateTime date) async {
    final maps = await _localDatabase.getExpensesBefore(date.toIso8601String());
    return maps.map((map) => ExpenseEntry.fromMap(map)).toList();
  }

  @override
  Future<List<IncomeEntry>> getIncomeForBudget(String budgetId) async {
    final maps = await _localDatabase.getIncomeForBudget(budgetId);
    return maps.map((map) => IncomeEntry.fromMap(map)).toList();
  }

  @override
  Future<List<ExpenseEntry>> getExpensesForBudget(String budgetId) async {
    final maps = await _localDatabase.getExpensesForBudget(budgetId);
    return maps.map((map) => ExpenseEntry.fromMap(map)).toList();
  }

  @override
  Future<List<Budget>> getBudgetsForPeriod(BudgetPeriod period) async {
    final maps = await _localDatabase.getBudgetsForPeriod(
      period.year,
      period.month,
    );
    return maps.map<Budget>((map) => BudgetModel.fromMap(map)).toList();
  }

  @override
  Future<Budget?> getBudget(String id) async {
    final map = await _localDatabase.getBudget(id);
    if (map == null) return null;
    return BudgetModel.fromMap(map);
  }

  @override
  Future<void> addBudget(Budget budget) async {
    await _localDatabase.insertBudget(BudgetModel.fromEntity(budget).toMap());
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    await _localDatabase.updateBudget(BudgetModel.fromEntity(budget).toMap());
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _localDatabase.deleteBudget(id);
  }

  @override
  Future<List<Category>> getCategories() async {
    final maps = await _localDatabase.getCategories();
    return maps.map<Category>((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    final maps = await _localDatabase.getCategoriesByType(
      type == CategoryType.income ? 'income' : 'expense',
    );
    return maps.map<Category>((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<void> addCategory(Category category) async {
    await _localDatabase.insertCategory(
      CategoryModel.fromEntity(category).toMap(),
    );
  }

  @override
  Future<void> updateCategory(Category category) async {
    await _localDatabase.updateCategory(
      CategoryModel.fromEntity(category).toMap(),
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _localDatabase.deleteCategory(id);
  }

  @override
  Future<void> reassignAndDeleteCategory(String oldId, String newId) async {
    await _localDatabase.reassignCategory(oldId, newId);
  }

  @override
  Future<List<BudgetPeriod>> getAvailablePeriods() async {
    final maps = await _localDatabase.getAvailablePeriods();
    return maps
        .map(
          (map) => BudgetPeriod(
            year: map['period_year'] as int,
            month: map['period_month'] as int,
          ),
        )
        .toList();
  }

  @override
  Future<void> clearAllBudgets() async {
    await _localDatabase.clearAllBudgets();
  }

  @override
  Future<void> factoryReset() async {
    await _localDatabase.factoryReset();
  }
}
