import 'package:sqflite/sqflite.dart';

class MigrationsV11ToV20 {
  static Future<void> migrate(Database db, int oldVersion) async {
    if (oldVersion < 11) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS metadata (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 12) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS company_profiles (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          address TEXT NOT NULL,
          tax_id TEXT,
          logo_path TEXT,
          payment_info TEXT,
          default_vat_rate REAL NOT NULL DEFAULT 0.0
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS invoices (
          id TEXT PRIMARY KEY,
          profile_id TEXT NOT NULL,
          invoice_number TEXT NOT NULL,
          date TEXT NOT NULL,
          client_name TEXT NOT NULL,
          client_details TEXT NOT NULL,
          status TEXT NOT NULL,
          sub_total REAL NOT NULL,
          tax_total REAL NOT NULL,
          grand_total REAL NOT NULL,
          notes TEXT,
          balance_due REAL NOT NULL,
          FOREIGN KEY (profile_id) REFERENCES company_profiles (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS invoice_items (
          id TEXT PRIMARY KEY,
          invoice_id TEXT NOT NULL,
          description TEXT NOT NULL,
          quantity REAL NOT NULL,
          rate REAL NOT NULL,
          tax_rate REAL NOT NULL,
          total REAL NOT NULL,
          FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS invoice_payments (
          id TEXT PRIMARY KEY,
          invoice_id TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          method TEXT NOT NULL,
          FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 13) {
      await db.execute(
        'ALTER TABLE company_profiles ADD COLUMN bank_name TEXT',
      );
      await db.execute(
        'ALTER TABLE company_profiles ADD COLUMN bank_iban TEXT',
      );
      await db.execute('ALTER TABLE company_profiles ADD COLUMN bank_bic TEXT');
      await db.execute(
        'ALTER TABLE company_profiles ADD COLUMN bank_holder TEXT',
      );
      await db.execute(
        'ALTER TABLE company_profiles ADD COLUMN primary_color INTEGER',
      );
      await db.execute(
        'ALTER TABLE company_profiles ADD COLUMN font_family TEXT',
      );
      await db.execute(
        'ALTER TABLE company_profiles ADD COLUMN logo_on_right INTEGER DEFAULT 0',
      );

      await db.execute('ALTER TABLE invoices ADD COLUMN bank_name TEXT');
      await db.execute('ALTER TABLE invoices ADD COLUMN bank_iban TEXT');
      await db.execute('ALTER TABLE invoices ADD COLUMN bank_bic TEXT');
      await db.execute('ALTER TABLE invoices ADD COLUMN bank_holder TEXT');
    }

    if (oldVersion < 14) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS clients (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          address TEXT NOT NULL,
          tax_id TEXT,
          primary_contact TEXT,
          email TEXT,
          phone TEXT,
          website TEXT,
          industry TEXT,
          notes TEXT
        )
      ''');
      await db.execute('ALTER TABLE invoices ADD COLUMN client_id TEXT');
    }

    if (oldVersion < 15) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS received_invoices (
          id TEXT PRIMARY KEY,
          vendor_name TEXT NOT NULL,
          invoice_number TEXT,
          date TEXT NOT NULL,
          due_date TEXT,
          amount REAL NOT NULL,
          tax_amount REAL NOT NULL,
          status TEXT NOT NULL,
          balance_due REAL NOT NULL,
          notes TEXT
        )
      ''');
    }

    if (oldVersion < 16) {
      await db.execute(
        'ALTER TABLE budgets ADD COLUMN currency_code TEXT DEFAULT \'USD\'',
      );
      await db.execute(
        'ALTER TABLE budgets ADD COLUMN target_currency_code TEXT',
      );
      await db.execute('ALTER TABLE budgets ADD COLUMN exchange_rate REAL');
      await db.execute('ALTER TABLE budgets ADD COLUMN converted_amount REAL');
    }

    if (oldVersion < 17) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS accounts (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          balance REAL NOT NULL DEFAULT 0.0,
          currency TEXT NOT NULL DEFAULT 'USD',
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS transfers (
          id TEXT PRIMARY KEY,
          from_account_id TEXT NOT NULL,
          to_account_id TEXT NOT NULL,
          amount REAL NOT NULL,
          date INTEGER NOT NULL,
          note TEXT,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (from_account_id) REFERENCES accounts(id) ON DELETE CASCADE,
          FOREIGN KEY (to_account_id) REFERENCES accounts(id) ON DELETE CASCADE
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transfers_from ON transfers (from_account_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transfers_to ON transfers (to_account_id)',
      );
    }

    if (oldVersion < 18) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS category_limits (
          id TEXT PRIMARY KEY,
          budget_id TEXT NOT NULL,
          category_id TEXT NOT NULL,
          amount REAL NOT NULL,
          period TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (budget_id) REFERENCES budgets(id) ON DELETE CASCADE,
          FOREIGN KEY (category_id) REFERENCES categories(id)
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_category_limits_budget ON category_limits(budget_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_category_limits_category ON category_limits(category_id)',
      );

      await db.execute('''
        CREATE TABLE IF NOT EXISTS savings_goals (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          target_amount REAL NOT NULL,
          current_amount REAL DEFAULT 0,
          deadline TEXT,
          linked_category_id TEXT,
          icon TEXT,
          color TEXT,
          is_completed INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (linked_category_id) REFERENCES categories(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS savings_contributions (
          id TEXT PRIMARY KEY,
          goal_id TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          note TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY (goal_id) REFERENCES savings_goals(id) ON DELETE CASCADE
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_savings_contributions_goal ON savings_contributions(goal_id)',
      );
    }

    if (oldVersion < 19) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bill_reminders (
          id TEXT PRIMARY KEY,
          recurring_transaction_id TEXT NOT NULL,
          due_date TEXT NOT NULL,
          days_before_due INTEGER NOT NULL DEFAULT 3,
          is_notified INTEGER DEFAULT 0,
          notified_at TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY (recurring_transaction_id) REFERENCES recurring_transactions(id) ON DELETE CASCADE
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_bill_reminders_transaction ON bill_reminders(recurring_transaction_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_bill_reminders_due_date ON bill_reminders(due_date)',
      );
    }

    if (oldVersion < 20) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS transaction_splits (
          id TEXT PRIMARY KEY,
          parent_transaction_id TEXT NOT NULL,
          parent_transaction_type TEXT NOT NULL,
          category_id TEXT NOT NULL,
          amount REAL NOT NULL,
          note TEXT,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transaction_splits_parent ON transaction_splits(parent_transaction_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transaction_splits_category ON transaction_splits(category_id)',
      );
    }
  }
}
