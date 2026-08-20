class DatabaseTablesAdvanced {
  static const List<String> tables = [
    accounts,
    transfers,
    categoryLimits,
    savingsGoals,
    savingsContributions,
    billReminders,
    transactionSplits,
    tags,
    transactionTags,
    attachments,
    budgetTemplates,
    budgetTemplateAllocations,
    netWorthSnapshots,
    creditCards,
    investments,
    loanAccounts,
    savingsAccounts,
    investmentPortfolios,
    accountTransactions,
  ];

  static const String accounts = '''
    CREATE TABLE IF NOT EXISTS accounts (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      balance REAL NOT NULL DEFAULT 0.0,
      currency TEXT NOT NULL DEFAULT 'USD',
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''';

  static const String transfers = '''
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
  ''';

  static const String categoryLimits = '''
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
  ''';

  static const String savingsGoals = '''
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
  ''';

  static const String savingsContributions = '''
    CREATE TABLE IF NOT EXISTS savings_contributions (
      id TEXT PRIMARY KEY,
      goal_id TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      note TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (goal_id) REFERENCES savings_goals(id) ON DELETE CASCADE
    )
  ''';

  static const String billReminders = '''
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
  ''';

  static const String transactionSplits = '''
    CREATE TABLE IF NOT EXISTS transaction_splits (
      id TEXT PRIMARY KEY,
      parent_transaction_id TEXT NOT NULL,
      parent_transaction_type TEXT NOT NULL,
      category_id TEXT NOT NULL,
      amount REAL NOT NULL,
      note TEXT,
      created_at TEXT NOT NULL
    )
  ''';

  static const String tags = '''
    CREATE TABLE IF NOT EXISTS tags (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      color TEXT,
      created_at TEXT NOT NULL
    )
  ''';

  static const String transactionTags = '''
    CREATE TABLE IF NOT EXISTS transaction_tags (
      transaction_id TEXT NOT NULL,
      transaction_type TEXT NOT NULL,
      tag_id TEXT NOT NULL,
      PRIMARY KEY (transaction_id, transaction_type, tag_id),
      FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
    )
  ''';

  static const String attachments = '''
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
  ''';

  static const String budgetTemplates = '''
    CREATE TABLE IF NOT EXISTS budget_templates (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      is_preset INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL
    )
  ''';

  static const String budgetTemplateAllocations = '''
    CREATE TABLE IF NOT EXISTS budget_template_allocations (
      template_id TEXT NOT NULL,
      category_id TEXT NOT NULL,
      percentage REAL NOT NULL,
      PRIMARY KEY (template_id, category_id),
      FOREIGN KEY (template_id) REFERENCES budget_templates(id) ON DELETE CASCADE
    )
  ''';

  static const String netWorthSnapshots = '''
    CREATE TABLE IF NOT EXISTS net_worth_snapshots (
      id TEXT PRIMARY KEY,
      date TEXT NOT NULL,
      total_assets REAL NOT NULL,
      total_liabilities REAL NOT NULL,
      net_worth REAL NOT NULL
    )
  ''';

  static const String creditCards = '''
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
  ''';

  static const String investments = '''
    CREATE TABLE IF NOT EXISTS investments (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      ticker TEXT,
      shares REAL NOT NULL DEFAULT 0,
      avg_cost REAL NOT NULL DEFAULT 0,
      current_price REAL NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL
    )
  ''';

  static const String loanAccounts = '''
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
  ''';

  static const String savingsAccounts = '''
    CREATE TABLE IF NOT EXISTS savings_accounts (
      account_id TEXT PRIMARY KEY,
      interest_rate_apy REAL NOT NULL,
      compounding_frequency TEXT NOT NULL DEFAULT 'monthly',
      target_goal_amount REAL,
      total_contributions REAL NOT NULL DEFAULT 0.0,
      FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
    )
  ''';

  static const String investmentPortfolios = '''
    CREATE TABLE IF NOT EXISTS investment_portfolios (
      account_id TEXT PRIMARY KEY,
      total_market_value REAL NOT NULL,
      total_deposited REAL NOT NULL DEFAULT 0.0,
      total_withdrawn REAL NOT NULL DEFAULT 0.0,
      target_annual_return_rate REAL NOT NULL DEFAULT 7.0,
      FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
    )
  ''';

  static const String accountTransactions = '''
    CREATE TABLE IF NOT EXISTS account_transactions (
      id TEXT PRIMARY KEY,
      account_id TEXT NOT NULL,
      transaction_type TEXT NOT NULL,
      amount REAL NOT NULL,
      date INTEGER NOT NULL,
      note TEXT,
      FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
    )
  ''';
}
