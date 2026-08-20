import 'base_dao.dart';

class BudgetDao extends BaseDao {
  BudgetDao(super.getDb);

  Future<List<Map<String, dynamic>>> getAvailablePeriods() async {
    final database = await db;
    return await database.rawQuery('''
      SELECT DISTINCT period_year, period_month FROM budgets
      ORDER BY period_year DESC, period_month DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getBudgetsForPeriod(
    int year,
    int month,
  ) async {
    final database = await db;
    return await database.query(
      'budgets',
      where: 'period_year = ? AND period_month = ?',
      whereArgs: [year, month],
    );
  }

  Future<Map<String, dynamic>?> getBudget(String id) async {
    final database = await db;
    final maps = await database.query('budgets', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<void> insertBudget(Map<String, dynamic> budget) async {
    final database = await db;
    await database.insert('budgets', budget);
  }

  Future<void> updateBudget(Map<String, dynamic> budget) async {
    final database = await db;
    await database.update(
      'budgets',
      budget,
      where: 'id = ?',
      whereArgs: [budget['id']],
    );
  }

  Future<void> deleteBudget(String id) async {
    final database = await db;
    await database.delete('income_entries', where: 'budget_id = ?', whereArgs: [id]);
    await database.delete('expense_entries', where: 'budget_id = ?', whereArgs: [id]);
    await database.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllBudgets() async {
    final database = await db;
    await database.delete('income_entries');
    await database.delete('expense_entries');
    await database.delete('budgets');
  }

  Future<List<Map<String, dynamic>>> getDisposableHistory() async {
    final database = await db;
    return await database.query(
      'budgets',
      where: 'type IN (?, ?)',
      whereArgs: ['disposed', 'persisted'],
      orderBy: 'period_year DESC, period_month DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getActiveDisposableBudgets() async {
    final database = await db;
    return await database.query(
      'budgets',
      where: 'type = ?',
      whereArgs: ['disposable'],
      orderBy: 'period_year DESC, period_month DESC',
    );
  }

  Future<void> factoryReset() async {
    final database = await db;
    await database.transaction((txn) async {
      // Delete in dependency order: child tables first, then parents.
      // Disable FK checks briefly to avoid ordering issues, then re-enable.
      await txn.execute('PRAGMA foreign_keys = OFF');

      try {
        // Child tables (no dependents)
        await txn.delete('recurring_overrides');
        await txn.delete('bill_reminders');
        await txn.delete('savings_contributions');
        await txn.delete('transaction_splits');
        await txn.delete('transfers');
        await txn.delete('invoice_items');
        await txn.delete('invoice_payments');
        await txn.delete('budget_goals');
        await txn.delete('income_entries');
        await txn.delete('expense_entries');
        await txn.delete('category_limits');
        await txn.delete('transaction_tags');
        await txn.delete('attachments');
        await txn.delete('budget_template_allocations');
        await txn.delete('account_transactions');
        await txn.delete('loan_accounts');
        await txn.delete('savings_accounts');
        await txn.delete('investment_portfolios');

        // Parent / leaf tables
        await txn.delete('recurring_transactions');
        await txn.delete('savings_goals');
        await txn.delete('categories');
        await txn.delete('budgets');
        await txn.delete('accounts');
        await txn.delete('invoices');
        await txn.delete('clients');
        await txn.delete('company_profiles');
        await txn.delete('received_invoices');
        await txn.delete('saved_calculations');
        await txn.delete('emergency_expenses');
        await txn.delete('metadata');
        await txn.delete('tags');
        await txn.delete('budget_templates');
        await txn.delete('net_worth_snapshots');
        await txn.delete('credit_cards');
        await txn.delete('investments');
      } finally {
        await txn.execute('PRAGMA foreign_keys = ON');
      }
    });
  }

  // Category Limits
  Future<List<Map<String, dynamic>>> getLimitsForBudget(String budgetId) async {
    final database = await db;
    return await database.query(
      'category_limits',
      where: 'budget_id = ?',
      whereArgs: [budgetId],
    );
  }

  Future<Map<String, dynamic>?> getLimitForCategory(
    String categoryId,
    String budgetId,
  ) async {
    final database = await db;
    final maps = await database.query(
      'category_limits',
      where: 'category_id = ? AND budget_id = ?',
      whereArgs: [categoryId, budgetId],
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<void> saveLimit(Map<String, dynamic> limit, String budgetId) async {
    final database = await db;
    final map = Map<String, dynamic>.from(limit);
    map['budget_id'] = budgetId;

    final existing = await database.query(
      'category_limits',
      where: 'category_id = ? AND budget_id = ?',
      whereArgs: [limit['category_id'], budgetId],
    );

    if (existing.isEmpty) {
      await database.insert('category_limits', map);
    } else {
      await database.update(
        'category_limits',
        map,
        where: 'id = ?',
        whereArgs: [limit['id']],
      );
    }
  }

  Future<void> deleteLimit(String limitId) async {
    final database = await db;
    await database.delete('category_limits', where: 'id = ?', whereArgs: [limitId]);
  }

  Future<double> getSpentAmountForCategory(
    String categoryId,
    int year,
    int month,
  ) async {
    final database = await db;

    final incomeResult = await database.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM income_entries
      WHERE category_id = ? AND period_year = ? AND period_month = ? AND is_potential = 0
    ''',
      [categoryId, year, month],
    );

    final expenseResult = await database.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM expense_entries
      WHERE category_id = ? AND period_year = ? AND period_month = ? AND is_potential = 0
    ''',
      [categoryId, year, month],
    );

    final incomeTotal =
        (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final expenseTotal =
        (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return expenseTotal - incomeTotal;
  }
}
