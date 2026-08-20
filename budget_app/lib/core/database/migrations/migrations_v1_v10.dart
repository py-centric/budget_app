import 'package:sqflite/sqflite.dart';
import '../database_schema.dart';

class MigrationsV1ToV10 {
  static Future<void> migrate(Database db, int oldVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE income_entries ADD COLUMN period_month INTEGER',
      );
      await db.execute(
        'ALTER TABLE income_entries ADD COLUMN period_year INTEGER',
      );
      await db.execute(
        'CREATE INDEX idx_income_period ON income_entries (period_year, period_month)',
      );

      await db.execute(
        'ALTER TABLE expense_entries ADD COLUMN period_month INTEGER',
      );
      await db.execute(
        'ALTER TABLE expense_entries ADD COLUMN period_year INTEGER',
      );
      await db.execute(
        'CREATE INDEX idx_expense_period ON expense_entries (period_year, period_month)',
      );

      await db.execute('''
        CREATE TABLE budget_goals (
          id TEXT PRIMARY KEY,
          category_id TEXT NOT NULL,
          amount REAL NOT NULL,
          period_month INTEGER NOT NULL,
          period_year INTEGER NOT NULL
        )
      ''');
      await db.execute(
        'CREATE INDEX idx_budget_goals_period ON budget_goals (period_year, period_month)',
      );

      await db.execute(
        "UPDATE income_entries SET period_month = cast(strftime('%m', date) as integer), period_year = cast(strftime('%Y', date) as integer) WHERE period_month IS NULL",
      );
      await db.execute(
        "UPDATE expense_entries SET period_month = cast(strftime('%m', date) as integer), period_year = cast(strftime('%Y', date) as integer) WHERE period_month IS NULL",
      );
    }

    if (oldVersion < 3) {
      await db.execute('ALTER TABLE categories RENAME TO categories_old');
      await db.execute('''
        CREATE TABLE categories (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          icon TEXT,
          type TEXT NOT NULL,
          UNIQUE(name, type)
        )
      ''');

      await db.execute('''
        INSERT INTO categories (id, name, icon, type)
        SELECT id, name, icon, 'expense' FROM categories_old
      ''');
      await db.execute('DROP TABLE categories_old');

      await db.execute(
        'ALTER TABLE income_entries ADD COLUMN category_id TEXT',
      );
      await db.execute(
        'ALTER TABLE expense_entries ADD COLUMN category_id TEXT',
      );

      const defaultIncomeCategories = [
        'Salary',
        'Gift',
        'Interest',
        'Investment',
        'Other',
      ];
      for (final cat in defaultIncomeCategories) {
        await db.insert('categories', {
          'id': 'income_${cat.toLowerCase()}',
          'name': cat,
          'type': 'income',
          'icon': DatabaseSchema.getCategoryIcon(cat),
        });
      }

      await db.execute('''
        UPDATE expense_entries 
        SET category_id = (SELECT id FROM categories WHERE categories.name = expense_entries.category AND categories.type = 'expense')
      ''');

      await db.execute('''
        UPDATE expense_entries 
        SET category_id = 'other' 
        WHERE category_id IS NULL
      ''');

      await db.execute('''
        UPDATE income_entries 
        SET category_id = 'income_other' 
        WHERE category_id IS NULL
      ''');
    }

    if (oldVersion < 4) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_income_date ON income_entries (date)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_expense_date ON expense_entries (date)',
      );
    }

    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE budgets (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          period_month INTEGER NOT NULL,
          period_year INTEGER NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1
        )
      ''');

      final periods = await db.rawQuery('''
        SELECT DISTINCT period_year, period_month FROM income_entries
        UNION
        SELECT DISTINCT period_year, period_month FROM expense_entries
        UNION
        SELECT DISTINCT period_year, period_month FROM budget_goals
      ''');

      for (var period in periods) {
        final year = period['period_year'] as int;
        final month = period['period_month'] as int;
        final budgetId = 'default_${year}_$month';

        await db.insert('budgets', {
          'id': budgetId,
          'name': 'Default Budget',
          'period_year': year,
          'period_month': month,
          'is_active': 1,
        });
      }

      await db.execute('ALTER TABLE income_entries ADD COLUMN budget_id TEXT');
      await db.execute('ALTER TABLE expense_entries ADD COLUMN budget_id TEXT');
      await db.execute('ALTER TABLE budget_goals ADD COLUMN budget_id TEXT');

      await db.execute('''
        UPDATE income_entries 
        SET budget_id = 'default_' || period_year || '_' || period_month
      ''');
      await db.execute('''
        UPDATE expense_entries 
        SET budget_id = 'default_' || period_year || '_' || period_month
      ''');
      await db.execute('''
        UPDATE budget_goals 
        SET budget_id = 'default_' || period_year || '_' || period_month
      ''');
    }

    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS recurring_transactions (
          id TEXT PRIMARY KEY,
          budget_id TEXT NOT NULL,
          type TEXT NOT NULL,
          amount REAL NOT NULL,
          category_id TEXT NOT NULL,
          description TEXT NOT NULL,
          start_date TEXT NOT NULL,
          end_date TEXT,
          recurrence_interval INTEGER NOT NULL,
          recurrence_unit TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS recurring_overrides (
          id TEXT PRIMARY KEY,
          recurring_transaction_id TEXT NOT NULL,
          target_date TEXT NOT NULL,
          new_amount REAL,
          new_date TEXT,
          is_deleted INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (recurring_transaction_id) REFERENCES recurring_transactions (id) ON DELETE CASCADE
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_recurring_overrides_template ON recurring_overrides (recurring_transaction_id)',
      );
    }

    if (oldVersion < 8) {
      await db.execute(
        'ALTER TABLE income_entries ADD COLUMN is_potential INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE expense_entries ADD COLUMN is_potential INTEGER NOT NULL DEFAULT 0',
      );
    }

    if (oldVersion < 9) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS saved_calculations (
          id TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          name TEXT NOT NULL,
          data TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 10) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS emergency_expenses (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          amount REAL NOT NULL DEFAULT 0.0,
          is_suggestion INTEGER NOT NULL,
          category_type TEXT,
          sort_order INTEGER NOT NULL
        )
      ''');
    }
  }
}
