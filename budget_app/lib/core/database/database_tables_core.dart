class DatabaseTablesCore {
  static const List<String> tables = [
    budgets,
    incomeEntries,
    expenseEntries,
    budgetGoals,
    categories,
    recurringTransactions,
    recurringOverrides,
    savedCalculations,
    emergencyExpenses,
    metadata,
    companyProfiles,
    invoices,
    clients,
    invoiceItems,
    invoicePayments,
    receivedInvoices,
  ];

  static const String budgets = '''
    CREATE TABLE budgets (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      period_month INTEGER NOT NULL,
      period_year INTEGER NOT NULL,
      is_active INTEGER NOT NULL DEFAULT 1,
      currency_code TEXT DEFAULT 'USD',
      target_currency_code TEXT,
      exchange_rate REAL,
      converted_amount REAL,
      type TEXT NOT NULL DEFAULT 'regular',
      target_income REAL,
      source_description TEXT,
      linked_income_id TEXT
    )
  ''';

  static const String incomeEntries = '''
    CREATE TABLE income_entries (
      id TEXT PRIMARY KEY,
      budget_id TEXT NOT NULL,
      amount REAL NOT NULL,
      description TEXT,
      date TEXT NOT NULL,
      period_month INTEGER,
      period_year INTEGER,
      category_id TEXT,
      account_id TEXT,
      is_potential INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (budget_id) REFERENCES budgets (id) ON DELETE CASCADE
    )
  ''';

  static const String expenseEntries = '''
    CREATE TABLE expense_entries (
      id TEXT PRIMARY KEY,
      budget_id TEXT NOT NULL,
      amount REAL NOT NULL,
      description TEXT,
      date TEXT NOT NULL,
      period_month INTEGER,
      period_year INTEGER,
      category_id TEXT,
      account_id TEXT,
      is_potential INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (budget_id) REFERENCES budgets (id) ON DELETE CASCADE
    )
  ''';

  static const String budgetGoals = '''
    CREATE TABLE budget_goals (
      id TEXT PRIMARY KEY,
      budget_id TEXT NOT NULL,
      category_id TEXT NOT NULL,
      amount REAL NOT NULL,
      period_month INTEGER NOT NULL,
      period_year INTEGER NOT NULL,
      FOREIGN KEY (budget_id) REFERENCES budgets (id) ON DELETE CASCADE
    )
  ''';

  static const String categories = '''
    CREATE TABLE categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      icon TEXT,
      type TEXT NOT NULL,
      UNIQUE(name, type)
    )
  ''';

  static const String recurringTransactions = '''
    CREATE TABLE recurring_transactions (
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
  ''';

  static const String recurringOverrides = '''
    CREATE TABLE recurring_overrides (
      id TEXT PRIMARY KEY,
      recurring_transaction_id TEXT NOT NULL,
      target_date TEXT NOT NULL,
      new_amount REAL,
      new_date TEXT,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (recurring_transaction_id) REFERENCES recurring_transactions (id) ON DELETE CASCADE
    )
  ''';

  static const String savedCalculations = '''
    CREATE TABLE IF NOT EXISTS saved_calculations (
      id TEXT PRIMARY KEY,
      type TEXT NOT NULL,
      name TEXT NOT NULL,
      data TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
  ''';

  static const String emergencyExpenses = '''
    CREATE TABLE IF NOT EXISTS emergency_expenses (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      amount REAL NOT NULL DEFAULT 0.0,
      is_suggestion INTEGER NOT NULL,
      category_type TEXT,
      sort_order INTEGER NOT NULL
    )
  ''';

  static const String metadata = '''
    CREATE TABLE IF NOT EXISTS metadata (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''';

  static const String companyProfiles = '''
    CREATE TABLE IF NOT EXISTS company_profiles (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      address TEXT NOT NULL,
      tax_id TEXT,
      logo_path TEXT,
      payment_info TEXT,
      default_vat_rate REAL NOT NULL DEFAULT 0.0,
      bank_name TEXT,
      bank_iban TEXT,
      bank_bic TEXT,
      bank_holder TEXT,
      primary_color INTEGER,
      font_family TEXT,
      logo_on_right INTEGER DEFAULT 0
    )
  ''';

  static const String invoices = '''
    CREATE TABLE IF NOT EXISTS invoices (
      id TEXT PRIMARY KEY,
      profile_id TEXT NOT NULL,
      client_id TEXT,
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
      bank_name TEXT,
      bank_iban TEXT,
      bank_bic TEXT,
      bank_holder TEXT,
      FOREIGN KEY (profile_id) REFERENCES company_profiles (id) ON DELETE CASCADE,
      FOREIGN KEY (client_id) REFERENCES clients (id) ON DELETE SET NULL
    )
  ''';

  static const String clients = '''
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
  ''';

  static const String invoiceItems = '''
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
  ''';

  static const String invoicePayments = '''
    CREATE TABLE IF NOT EXISTS invoice_payments (
      id TEXT PRIMARY KEY,
      invoice_id TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      method TEXT NOT NULL,
      FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE
    )
  ''';

  static const String receivedInvoices = '''
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
  ''';
}
