import 'package:sqflite/sqflite.dart';
import 'base_dao.dart';

class TransactionDao extends BaseDao {
  TransactionDao(super.getDb);

  Future<int> insertIncome(Map<String, dynamic> income) async {
    final database = await db;
    return await database.insert('income_entries', income);
  }

  Future<int> updateIncome(Map<String, dynamic> income) async {
    final database = await db;
    return await database.update(
      'income_entries',
      income,
      where: 'id = ?',
      whereArgs: [income['id']],
    );
  }

  Future<int> deleteIncome(String id) async {
    final database = await db;
    return await database.delete('income_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertExpense(Map<String, dynamic> expense) async {
    final database = await db;
    return await database.insert('expense_entries', expense);
  }

  Future<int> updateExpense(Map<String, dynamic> expense) async {
    final database = await db;
    return await database.update(
      'expense_entries',
      expense,
      where: 'id = ?',
      whereArgs: [expense['id']],
    );
  }

  Future<int> deleteExpense(String id) async {
    final database = await db;
    return await database.delete('expense_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllIncome() async {
    final database = await db;
    return await database.rawQuery('''
      SELECT income_entries.*, categories.name as category_name, categories.icon as category_icon, accounts.name as account_name
      FROM income_entries
      LEFT JOIN categories ON income_entries.category_id = categories.id
      LEFT JOIN accounts ON income_entries.account_id = accounts.id
      ORDER BY date DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getIncomeForPeriod(
    int year,
    int month,
  ) async {
    final database = await db;
    return await database.rawQuery(
      '''
      SELECT income_entries.*, categories.name as category_name, categories.icon as category_icon, accounts.name as account_name
      FROM income_entries
      LEFT JOIN categories ON income_entries.category_id = categories.id
      LEFT JOIN accounts ON income_entries.account_id = accounts.id
      WHERE period_year = ? AND period_month = ?
      ORDER BY date DESC
    ''',
      [year, month],
    );
  }

  Future<List<Map<String, dynamic>>> getIncomeForDateRange(
    String startDate,
    String endDate,
  ) async {
    final database = await db;
    return await database.rawQuery(
      '''
      SELECT income_entries.*, categories.name as category_name, categories.icon as category_icon, accounts.name as account_name
      FROM income_entries
      LEFT JOIN categories ON income_entries.category_id = categories.id
      LEFT JOIN accounts ON income_entries.account_id = accounts.id
      WHERE date >= ? AND date <= ?
      ORDER BY date DESC
    ''',
      [startDate, endDate],
    );
  }

  Future<List<Map<String, dynamic>>> getIncomeForBudget(String budgetId) async {
    final database = await db;
    return await database.rawQuery(
      '''
      SELECT income_entries.*, categories.name as category_name, categories.icon as category_icon, accounts.name as account_name
      FROM income_entries
      LEFT JOIN categories ON income_entries.category_id = categories.id
      LEFT JOIN accounts ON income_entries.account_id = accounts.id
      WHERE budget_id = ?
      ORDER BY date DESC
    ''',
      [budgetId],
    );
  }

  Future<List<Map<String, dynamic>>> getIncomeBefore(String date) async {
    final database = await db;
    return await database.rawQuery(
      '''
      SELECT income_entries.*, categories.name as category_name, categories.icon as category_icon, accounts.name as account_name
      FROM income_entries
      LEFT JOIN categories ON income_entries.category_id = categories.id
      LEFT JOIN accounts ON income_entries.account_id = accounts.id
      WHERE date < ?
    ''',
      [date],
    );
  }

  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    final database = await db;
    return await database.rawQuery('''
      SELECT expense_entries.*, categories.name as category_name, categories.icon as category_icon, accounts.name as account_name
      FROM expense_entries
      LEFT JOIN categories ON expense_entries.category_id = categories.id
      LEFT JOIN accounts ON expense_entries.account_id = accounts.id
      ORDER BY date DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getExpensesForPeriod(
    int year,
    int month,
  ) async {
    final database = await db;
    return await database.rawQuery(
      '''
      SELECT expense_entries.*, categories.name as category_name, categories.icon as category_icon, accounts.name as account_name
      FROM expense_entries
      LEFT JOIN categories ON expense_entries.category_id = categories.id
      LEFT JOIN accounts ON expense_entries.account_id = accounts.id
      WHERE period_year = ? AND period_month = ?
      ORDER BY date DESC
    ''',
      [year, month],
    );
  }

  Future<List<Map<String, dynamic>>> getExpensesForDateRange(
    String startDate,
    String endDate,
  ) async {
    final database = await db;
    return await database.rawQuery(
      '''
      SELECT expense_entries.*, categories.name as category_name, categories.icon as category_icon, accounts.name as account_name
      FROM expense_entries
      LEFT JOIN categories ON expense_entries.category_id = categories.id
      LEFT JOIN accounts ON expense_entries.account_id = accounts.id
      WHERE date >= ? AND date <= ?
      ORDER BY date DESC
    ''',
      [startDate, endDate],
    );
  }

  Future<List<Map<String, dynamic>>> getExpensesForBudget(
    String budgetId,
  ) async {
    final database = await db;
    return await database.rawQuery(
      '''
      SELECT expense_entries.*, categories.name as category_name, categories.icon as category_icon, accounts.name as account_name
      FROM expense_entries
      LEFT JOIN categories ON expense_entries.category_id = categories.id
      LEFT JOIN accounts ON expense_entries.account_id = accounts.id
      WHERE budget_id = ?
      ORDER BY date DESC
    ''',
      [budgetId],
    );
  }

  Future<List<Map<String, dynamic>>> getExpensesBefore(String date) async {
    final database = await db;
    return await database.rawQuery(
      '''
      SELECT expense_entries.*, categories.name as category_name, categories.icon as category_icon, accounts.name as account_name
      FROM expense_entries
      LEFT JOIN categories ON expense_entries.category_id = categories.id
      LEFT JOIN accounts ON expense_entries.account_id = accounts.id
      WHERE date < ?
    ''',
      [date],
    );
  }

  // Recurring Transactions
  Future<void> saveRecurringTransaction(Map<String, dynamic> recurring) async {
    final database = await db;
    await database.insert(
      'recurring_transactions',
      recurring,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteRecurringTransaction(String id) async {
    final database = await db;
    await database.delete('recurring_transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllRecurringTransactions() async {
    final database = await db;
    return await database.query('recurring_transactions');
  }

  Future<Map<String, dynamic>?> getRecurringTransactionById(String id) async {
    final database = await db;
    final maps = await database.query(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  // Recurring Overrides
  Future<void> saveRecurringOverride(Map<String, dynamic> override) async {
    final database = await db;
    await database.insert(
      'recurring_overrides',
      override,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteRecurringOverride(String id) async {
    final database = await db;
    await database.delete('recurring_overrides', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getOverridesForTemplate(
    String templateId,
  ) async {
    final database = await db;
    return await database.query(
      'recurring_overrides',
      where: 'recurring_transaction_id = ?',
      whereArgs: [templateId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllOverrides() async {
    final database = await db;
    return await database.query('recurring_overrides');
  }

  // Transaction Splits
  Future<List<Map<String, dynamic>>> getSplitsForTransaction(
    String parentId,
  ) async {
    final database = await db;
    return await database.query(
      'transaction_splits',
      where: 'parent_transaction_id = ?',
      whereArgs: [parentId],
      orderBy: 'created_at ASC',
    );
  }

  Future<void> saveSplit(Map<String, dynamic> split) async {
    final database = await db;
    await database.insert(
      'transaction_splits',
      split,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSplit(String id) async {
    final database = await db;
    await database.delete('transaction_splits', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteSplitsForTransaction(String parentId) async {
    final database = await db;
    await database.delete(
      'transaction_splits',
      where: 'parent_transaction_id = ?',
      whereArgs: [parentId],
    );
  }

  Future<double> getTotalSplitAmount(String parentId) async {
    final database = await db;
    final result = await database.rawQuery(
      'SELECT SUM(amount) as total FROM transaction_splits WHERE parent_transaction_id = ?',
      [parentId],
    );
    if (result.isEmpty || result.first['total'] == null) {
      return 0;
    }
    return (result.first['total'] as num).toDouble();
  }

  Future<bool> hasSplits(String parentId) async {
    final database = await db;
    final result = await database.rawQuery(
      'SELECT COUNT(*) as count FROM transaction_splits WHERE parent_transaction_id = ?',
      [parentId],
    );
    if (result.isEmpty) return false;
    return (result.first['count'] as int) > 0;
  }
}
