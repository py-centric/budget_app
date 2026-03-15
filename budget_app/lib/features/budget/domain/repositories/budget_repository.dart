import '../entities/income_entry.dart';
import '../entities/expense_entry.dart';
import '../entities/budget_period.dart';
import '../entities/category.dart';
import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<void> addIncome(IncomeEntry income);
  Future<void> updateIncome(IncomeEntry income);
  Future<void> deleteIncome(String id);
  
  Future<void> addExpense(ExpenseEntry expense);
  Future<void> updateExpense(ExpenseEntry expense);
  Future<void> deleteExpense(String id);

  Future<List<IncomeEntry>> getAllIncome();
  Future<List<ExpenseEntry>> getAllExpenses();
  Future<List<IncomeEntry>> getIncomeForPeriod(BudgetPeriod period);
  Future<List<ExpenseEntry>> getExpensesForPeriod(BudgetPeriod period);
  Future<List<IncomeEntry>> getIncomeForDateRange(DateTime start, DateTime end);
  Future<List<ExpenseEntry>> getExpensesForDateRange(DateTime start, DateTime end);
  Future<List<IncomeEntry>> getIncomeBefore(DateTime date);
  Future<List<ExpenseEntry>> getExpensesBefore(DateTime date);
  
  // Budget specific methods
  Future<List<IncomeEntry>> getIncomeForBudget(String budgetId);
  Future<List<ExpenseEntry>> getExpensesForBudget(String budgetId);
  Future<List<Budget>> getBudgetsForPeriod(BudgetPeriod period);
  Future<Budget?> getBudget(String id);
  Future<void> addBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(String id);
  
  Future<List<Category>> getCategories();
  Future<List<Category>> getCategoriesByType(CategoryType type);
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<void> reassignAndDeleteCategory(String oldId, String newId);

  Future<List<BudgetPeriod>> getAvailablePeriods();
}
