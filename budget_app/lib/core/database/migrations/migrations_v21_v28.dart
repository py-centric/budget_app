import 'package:sqflite/sqflite.dart';

class MigrationsV21ToV28 {
  static Future<void> migrate(Database db, int oldVersion) async {
    if (oldVersion < 21) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_expense_category ON expense_entries (category_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_income_category ON income_entries (category_id)',
      );

      await db.execute('''
        CREATE TABLE expense_entries_new (
          id TEXT PRIMARY KEY,
          budget_id TEXT NOT NULL,
          amount REAL NOT NULL,
          description TEXT,
          date TEXT NOT NULL,
          period_month INTEGER,
          period_year INTEGER,
          category_id TEXT,
          is_potential INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (budget_id) REFERENCES budgets (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        INSERT INTO expense_entries_new
        SELECT id, budget_id, amount, description, date,
               period_month, period_year, category_id, is_potential
        FROM expense_entries
      ''');

      await db.execute('DROP TABLE expense_entries');

      await db.execute(
        'ALTER TABLE expense_entries_new RENAME TO expense_entries',
      );

      await db.execute(
        'CREATE INDEX idx_expense_period ON expense_entries (period_year, period_month)',
      );
      await db.execute(
        'CREATE INDEX idx_expense_date ON expense_entries (date)',
      );
      await db.execute(
        'CREATE INDEX idx_expense_budget ON expense_entries (budget_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_expense_category ON expense_entries (category_id)',
      );
    }

    if (oldVersion < 22) {
      await db.execute(
        "ALTER TABLE budgets ADD COLUMN type TEXT NOT NULL DEFAULT 'regular'",
      );
      await db.execute(
        'ALTER TABLE budgets ADD COLUMN target_income REAL',
      );
      await db.execute(
        'ALTER TABLE budgets ADD COLUMN source_description TEXT',
      );
      await db.execute(
        'ALTER TABLE budgets ADD COLUMN linked_income_id TEXT',
      );
    }

    if (oldVersion < 23) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tags (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          color TEXT,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_tags_name ON tags(name)',
      );

      await db.execute('''
        CREATE TABLE IF NOT EXISTS transaction_tags (
          transaction_id TEXT NOT NULL,
          transaction_type TEXT NOT NULL,
          tag_id TEXT NOT NULL,
          PRIMARY KEY (transaction_id, transaction_type, tag_id),
          FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transaction_tags_tag ON transaction_tags(tag_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transaction_tags_transaction ON transaction_tags(transaction_id, transaction_type)',
      );
    }

    if (oldVersion < 24) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS attachments (
          id TEXT PRIMARY KEY,
          transaction_id TEXT NOT NULL,
          transaction_type TEXT NOT NULL,
          file_path TEXT NOT NULL,
          file_name TEXT NOT NULL,
          file_size INTEGER,
          mime_type TEXT,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_attachments_transaction ON attachments(transaction_id, transaction_type)',
      );
    }

    if (oldVersion < 25) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS budget_templates (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          is_preset INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS budget_template_allocations (
          template_id TEXT NOT NULL,
          category_id TEXT NOT NULL,
          percentage REAL NOT NULL,
          PRIMARY KEY (template_id, category_id),
          FOREIGN KEY (template_id) REFERENCES budget_templates(id) ON DELETE CASCADE
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_template_allocations_template ON budget_template_allocations(template_id)',
      );

      await db.insert('budget_templates', {
        'id': 'preset_50_30_20',
        'name': '50/30/20 Rule',
        'description': '50% needs, 30% wants, 20% savings',
        'is_preset': 1,
        'created_at': DateTime(2024).toIso8601String(),
      });
      await db.insert('budget_templates', {
        'id': 'preset_70_20_10',
        'name': '70/20/10 Rule',
        'description': '70% living expenses, 20% savings, 10% debt',
        'is_preset': 1,
        'created_at': DateTime(2024).toIso8601String(),
      });
      await db.insert('budget_templates', {
        'id': 'preset_zero_based',
        'name': 'Zero-Based',
        'description': 'Every dollar is assigned a job',
        'is_preset': 1,
        'created_at': DateTime(2024).toIso8601String(),
      });
    }

    if (oldVersion < 26) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS net_worth_snapshots (
          id TEXT PRIMARY KEY,
          date TEXT NOT NULL,
          total_assets REAL NOT NULL,
          total_liabilities REAL NOT NULL,
          net_worth REAL NOT NULL
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_net_worth_date ON net_worth_snapshots(date)',
      );
    }

    if (oldVersion < 27) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS credit_cards (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          last_four TEXT,
          credit_limit REAL NOT NULL,
          current_balance REAL DEFAULT 0,
          apr REAL DEFAULT 0,
          billing_day INTEGER,
          payment_due_day INTEGER,
          minimum_payment_percent REAL DEFAULT 2.0,
          last_updated TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS investments (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          ticker TEXT,
          shares REAL NOT NULL DEFAULT 0,
          avg_cost REAL NOT NULL DEFAULT 0,
          current_price REAL NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 28) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS loan_accounts (
          account_id TEXT PRIMARY KEY,
          original_principal REAL NOT NULL,
          current_principal REAL NOT NULL,
          interest_rate_apr REAL NOT NULL,
          minimum_monthly_payment REAL NOT NULL,
          origination_date INTEGER NOT NULL,
          is_paid_off INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS savings_accounts (
          account_id TEXT PRIMARY KEY,
          interest_rate_apy REAL NOT NULL,
          compounding_frequency TEXT NOT NULL DEFAULT 'monthly',
          target_goal_amount REAL,
          total_contributions REAL NOT NULL DEFAULT 0.0,
          FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS investment_portfolios (
          account_id TEXT PRIMARY KEY,
          total_market_value REAL NOT NULL,
          total_deposited REAL NOT NULL DEFAULT 0.0,
          total_withdrawn REAL NOT NULL DEFAULT 0.0,
          target_annual_return_rate REAL NOT NULL DEFAULT 7.0,
          FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS account_transactions (
          id TEXT PRIMARY KEY,
          account_id TEXT NOT NULL,
          transaction_type TEXT NOT NULL,
          amount REAL NOT NULL,
          date INTEGER NOT NULL,
          note TEXT,
          FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_account_transactions_acc ON account_transactions(account_id)',
      );
    }
  }
}
