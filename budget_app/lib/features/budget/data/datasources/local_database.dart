import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:budget_app/core/constants/app_constants.dart';

class LocalDatabase {
  static Database? _database;
  static final LocalDatabase instance = LocalDatabase._internal();
  static bool _initialized = false;

  LocalDatabase._internal();

  static Future<void> initialize() async {
    if (_initialized) return;

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      // Initialize FFI
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _initialized = true;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    await initialize();
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE income_entries ADD COLUMN period_month INTEGER');
      await db.execute('ALTER TABLE income_entries ADD COLUMN period_year INTEGER');
      await db.execute('CREATE INDEX idx_income_period ON income_entries (period_year, period_month)');

      await db.execute('ALTER TABLE expense_entries ADD COLUMN period_month INTEGER');
      await db.execute('ALTER TABLE expense_entries ADD COLUMN period_year INTEGER');
      await db.execute('CREATE INDEX idx_expense_period ON expense_entries (period_year, period_month)');

      await db.execute('''
        CREATE TABLE budget_goals (
          id TEXT PRIMARY KEY,
          category_id TEXT NOT NULL,
          amount REAL NOT NULL,
          period_month INTEGER NOT NULL,
          period_year INTEGER NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX idx_budget_goals_period ON budget_goals (period_year, period_month)');

      // Backfill data based on date
      await db.execute("UPDATE income_entries SET period_month = cast(strftime('%m', date) as integer), period_year = cast(strftime('%Y', date) as integer) WHERE period_month IS NULL");
      await db.execute("UPDATE expense_entries SET period_month = cast(strftime('%m', date) as integer), period_year = cast(strftime('%Y', date) as integer) WHERE period_month IS NULL");
    }

    if (oldVersion < 3) {
      // Recreate categories table to change constraints (SQLite doesn't support DROP/ALTER CONSTRAINT)
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

      // Copy existing categories, assuming they were all 'expense' type
      await db.execute('''
        INSERT INTO categories (id, name, icon, type)
        SELECT id, name, icon, 'expense' FROM categories_old
      ''');
      await db.execute('DROP TABLE categories_old');
      
      // Update income_entries and expense_entries to include category_id
      await db.execute('ALTER TABLE income_entries ADD COLUMN category_id TEXT');
      await db.execute('ALTER TABLE expense_entries ADD COLUMN category_id TEXT');

      // Add default income categories
      final defaultIncomeCategories = ['Salary', 'Gift', 'Interest', 'Investment', 'Other'];
      for (final cat in defaultIncomeCategories) {
        await db.insert('categories', {
          'id': 'income_${cat.toLowerCase()}',
          'name': cat,
          'type': 'income',
          'icon': _getCategoryIcon(cat),
        });
      }

      // Migrate existing expense entries from 'category' (text) to 'category_id'
      // We assume the old 'category' matches the name in the categories table
      await db.execute('''
        UPDATE expense_entries 
        SET category_id = (SELECT id FROM categories WHERE categories.name = expense_entries.category AND categories.type = "expense")
      ''');

      // Set a default category for any entries that couldn't be matched
      await db.execute('''
        UPDATE expense_entries 
        SET category_id = "other" 
        WHERE category_id IS NULL
      ''');
      
      await db.execute('''
        UPDATE income_entries 
        SET category_id = "income_other" 
        WHERE category_id IS NULL
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('CREATE INDEX IF NOT EXISTS idx_income_date ON income_entries (date)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_expense_date ON expense_entries (date)');
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

      // Create default budgets for existing periods
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
      await db.execute('CREATE INDEX IF NOT EXISTS idx_recurring_overrides_template ON recurring_overrides (recurring_transaction_id)');
    }
    if (oldVersion < 8) {
      await db.execute('ALTER TABLE income_entries ADD COLUMN is_potential INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE expense_entries ADD COLUMN is_potential INTEGER NOT NULL DEFAULT 0');
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
      await db.execute('ALTER TABLE company_profiles ADD COLUMN bank_name TEXT');
      await db.execute('ALTER TABLE company_profiles ADD COLUMN bank_iban TEXT');
      await db.execute('ALTER TABLE company_profiles ADD COLUMN bank_bic TEXT');
      await db.execute('ALTER TABLE company_profiles ADD COLUMN bank_holder TEXT');
      await db.execute('ALTER TABLE company_profiles ADD COLUMN primary_color INTEGER');
      await db.execute('ALTER TABLE company_profiles ADD COLUMN font_family TEXT');
      await db.execute('ALTER TABLE company_profiles ADD COLUMN logo_on_right INTEGER DEFAULT 0');

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
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        period_month INTEGER NOT NULL,
        period_year INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');
    
    await db.execute('''
      CREATE TABLE income_entries (
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
    await db.execute('CREATE INDEX idx_income_period ON income_entries (period_year, period_month)');
    await db.execute('CREATE INDEX idx_income_date ON income_entries (date)');
    await db.execute('CREATE INDEX idx_income_budget ON income_entries (budget_id)');

    await db.execute('''
      CREATE TABLE expense_entries (
        id TEXT PRIMARY KEY,
        budget_id TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        period_month INTEGER,
        period_year INTEGER,
        category_id TEXT,
        is_potential INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (budget_id) REFERENCES budgets (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_expense_period ON expense_entries (period_year, period_month)');
    await db.execute('CREATE INDEX idx_expense_date ON expense_entries (date)');
    await db.execute('CREATE INDEX idx_expense_budget ON expense_entries (budget_id)');

    await db.execute('''
      CREATE TABLE budget_goals (
        id TEXT PRIMARY KEY,
        budget_id TEXT NOT NULL,
        category_id TEXT NOT NULL,
        amount REAL NOT NULL,
        period_month INTEGER NOT NULL,
        period_year INTEGER NOT NULL,
        FOREIGN KEY (budget_id) REFERENCES budgets (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_budget_goals_period ON budget_goals (period_year, period_month)');
    await db.execute('CREATE INDEX idx_budget_goals_budget ON budget_goals (budget_id)');


    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT,
        type TEXT NOT NULL,
        UNIQUE(name, type)
      )
    ''');

    // Add default expense categories
    for (final category in AppConstants.defaultCategories) {
      await db.insert('categories', {
        'id': category.toLowerCase(),
        'name': category,
        'type': 'expense',
        'icon': _getCategoryIcon(category),
      });
    }

    // Add default income categories
    final defaultIncomeCategories = ['Salary', 'Gift', 'Interest', 'Investment', 'Other'];
    for (final cat in defaultIncomeCategories) {
      await db.insert('categories', {
        'id': 'income_${cat.toLowerCase()}',
        'name': cat,
        'type': 'income',
        'icon': _getCategoryIcon(cat),
      });
    }

    await db.execute('''
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
    ''');

    await db.execute('''
      CREATE TABLE recurring_overrides (
        id TEXT PRIMARY KEY,
        recurring_transaction_id TEXT NOT NULL,
        target_date TEXT NOT NULL,
        new_amount REAL,
        new_date TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (recurring_transaction_id) REFERENCES recurring_transactions (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_recurring_overrides_template ON recurring_overrides (recurring_transaction_id)');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS saved_calculations (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        name TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

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

    await db.execute('''
      CREATE TABLE IF NOT EXISTS metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
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
    ''');

    await db.execute('''
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
    ''');

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

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return 'restaurant';
      case 'transport':
        return 'directions_car';
      case 'utilities':
        return 'lightbulb';
      case 'entertainment':
        return 'movie';
      case 'shopping':
        return 'shopping_bag';
      case 'health':
        return 'local_hospital';
      case 'education':
        return 'school';
      default:
        return 'category';
    }
  }

  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.insert('categories', category);
  }

  Future<int> updateCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.update(
      'categories',
      category,
      where: 'id = ?',
      whereArgs: [category['id']],
    );
  }

  Future<int> deleteCategory(String id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> reassignCategory(String oldId, String newId) async {
    final db = await database;
    return await db.transaction((txn) async {
      await txn.update(
        'income_entries',
        {'category_id': newId},
        where: 'category_id = ?',
        whereArgs: [oldId],
      );
      await txn.update(
        'expense_entries',
        {'category_id': newId},
        where: 'category_id = ?',
        whereArgs: [oldId],
      );
      return await txn.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [oldId],
      );
    });
  }

  Future<int> insertIncome(Map<String, dynamic> income) async {
    final db = await database;
    return await db.insert('income_entries', income);
  }

  Future<int> updateIncome(Map<String, dynamic> income) async {
    final db = await database;
    return await db.update(
      'income_entries',
      income,
      where: 'id = ?',
      whereArgs: [income['id']],
    );
  }

  Future<int> deleteIncome(String id) async {
    final db = await database;
    return await db.delete(
      'income_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertExpense(Map<String, dynamic> expense) async {
    final db = await database;
    return await db.insert('expense_entries', expense);
  }

  Future<int> updateExpense(Map<String, dynamic> expense) async {
    final db = await database;
    return await db.update(
      'expense_entries',
      expense,
      where: 'id = ?',
      whereArgs: [expense['id']],
    );
  }

  Future<int> deleteExpense(String id) async {
    final db = await database;
    return await db.delete(
      'expense_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllIncome() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT income_entries.*, categories.name as category_name, categories.icon as category_icon
      FROM income_entries
      LEFT JOIN categories ON income_entries.category_id = categories.id
      ORDER BY date DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getIncomeForPeriod(int year, int month) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT income_entries.*, categories.name as category_name, categories.icon as category_icon
      FROM income_entries
      LEFT JOIN categories ON income_entries.category_id = categories.id
      WHERE period_year = ? AND period_month = ?
      ORDER BY date DESC
    ''', [year, month]);
  }

  Future<List<Map<String, dynamic>>> getIncomeForDateRange(String startDate, String endDate) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT income_entries.*, categories.name as category_name, categories.icon as category_icon
      FROM income_entries
      LEFT JOIN categories ON income_entries.category_id = categories.id
      WHERE date >= ? AND date <= ?
      ORDER BY date DESC
    ''', [startDate, endDate]);
  }

  Future<List<Map<String, dynamic>>> getIncomeForBudget(String budgetId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT income_entries.*, categories.name as category_name, categories.icon as category_icon
      FROM income_entries
      LEFT JOIN categories ON income_entries.category_id = categories.id
      WHERE budget_id = ?
      ORDER BY date DESC
    ''', [budgetId]);
  }

  Future<List<Map<String, dynamic>>> getIncomeBefore(String date) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT income_entries.*, categories.name as category_name, categories.icon as category_icon
      FROM income_entries
      LEFT JOIN categories ON income_entries.category_id = categories.id
      WHERE date < ?
    ''', [date]);
  }

  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT expense_entries.*, categories.name as category_name, categories.icon as category_icon
      FROM expense_entries
      LEFT JOIN categories ON expense_entries.category_id = categories.id
      ORDER BY date DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getExpensesForPeriod(int year, int month) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT expense_entries.*, categories.name as category_name, categories.icon as category_icon
      FROM expense_entries
      LEFT JOIN categories ON expense_entries.category_id = categories.id
      WHERE period_year = ? AND period_month = ?
      ORDER BY date DESC
    ''', [year, month]);
  }

  Future<List<Map<String, dynamic>>> getExpensesForDateRange(String startDate, String endDate) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT expense_entries.*, categories.name as category_name, categories.icon as category_icon
      FROM expense_entries
      LEFT JOIN categories ON expense_entries.category_id = categories.id
      WHERE date >= ? AND date <= ?
      ORDER BY date DESC
    ''', [startDate, endDate]);
  }

  Future<List<Map<String, dynamic>>> getExpensesForBudget(String budgetId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT expense_entries.*, categories.name as category_name, categories.icon as category_icon
      FROM expense_entries
      LEFT JOIN categories ON expense_entries.category_id = categories.id
      WHERE budget_id = ?
      ORDER BY date DESC
    ''', [budgetId]);
  }

  Future<List<Map<String, dynamic>>> getExpensesBefore(String date) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT expense_entries.*, categories.name as category_name, categories.icon as category_icon
      FROM expense_entries
      LEFT JOIN categories ON expense_entries.category_id = categories.id
      WHERE date < ?
    ''', [date]);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  Future<List<Map<String, dynamic>>> getCategoriesByType(String type) async {
    final db = await database;
    return await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );
  }

  Future<List<Map<String, dynamic>>> getAvailablePeriods() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT DISTINCT period_year, period_month FROM budgets
      ORDER BY period_year DESC, period_month DESC
    ''');
    return result;
  }
  
  Future<List<Map<String, dynamic>>> getBudgetsForPeriod(int year, int month) async {
    final db = await database;
    return await db.query(
      'budgets',
      where: 'period_year = ? AND period_month = ?',
      whereArgs: [year, month],
    );
  }
  
  Future<Map<String, dynamic>?> getBudget(String id) async {
    final db = await database;
    final maps = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }
  
  Future<void> insertBudget(Map<String, dynamic> budget) async {
    final db = await database;
    await db.insert('budgets', budget);
  }
  
  Future<void> updateBudget(Map<String, dynamic> budget) async {
    final db = await database;
    await db.update('budgets', budget, where: 'id = ?', whereArgs: [budget['id']]);
  }
  
  Future<void> deleteBudget(String id) async {
    final db = await database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // Saved Calculations
  Future<int> insertSavedCalculation(Map<String, dynamic> calculation) async {
    final db = await database;
    return await db.insert('saved_calculations', calculation);
  }

  Future<List<Map<String, dynamic>>> getSavedCalculations() async {
    final db = await database;
    return await db.query('saved_calculations', orderBy: 'created_at DESC');
  }

  Future<int> deleteSavedCalculation(String id) async {
    final db = await database;
    return await db.delete('saved_calculations', where: 'id = ?', whereArgs: [id]);
  }

  // Emergency Expenses
  Future<int> insertEmergencyExpense(Map<String, dynamic> expense) async {
    final db = await database;
    return await db.insert('emergency_expenses', expense);
  }

  Future<int> updateEmergencyExpense(Map<String, dynamic> expense) async {
    final db = await database;
    return await db.update(
      'emergency_expenses',
      expense,
      where: 'id = ?',
      whereArgs: [expense['id']],
    );
  }

  Future<int> deleteEmergencyExpense(String id) async {
    final db = await database;
    return await db.delete('emergency_expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getEmergencyExpenses() async {
    final db = await database;
    return await db.query('emergency_expenses', orderBy: 'sort_order ASC');
  }

  Future<double> getAverageSpendingForLastMonths(int count) async {
    final db = await database;
    // Get distinct periods from expense_entries
    final periods = await db.rawQuery('''
      SELECT DISTINCT period_year, period_month 
      FROM expense_entries 
      ORDER BY period_year DESC, period_month DESC 
      LIMIT ?
    ''', [count]);

    if (periods.isEmpty) return 0.0;

    double total = 0.0;
    for (var period in periods) {
      final year = period['period_year'];
      final month = period['period_month'];
      final sumResult = await db.rawQuery('''
        SELECT SUM(amount) as total 
        FROM expense_entries 
        WHERE period_year = ? AND period_month = ? AND is_potential = 0
      ''', [year, month]);
      total += (sumResult.first['total'] as num?)?.toDouble() ?? 0.0;
    }

    return total / periods.length;
  }

  // Metadata
  Future<void> setMetadata(String key, String value) async {
    final db = await database;
    await db.insert(
      'metadata',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getMetadata(String key) async {
    final db = await database;
    final result = await db.query(
      'metadata',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) return null;
    return result.first['value'] as String?;
  }

  // Business Tools Methods
  Future<int> insertCompanyProfile(Map<String, dynamic> profile) async {
    final db = await database;
    return await db.insert('company_profiles', profile);
  }

  Future<int> updateCompanyProfile(Map<String, dynamic> profile) async {
    final db = await database;
    return await db.update('company_profiles', profile, where: 'id = ?', whereArgs: [profile['id']]);
  }

  Future<int> deleteCompanyProfile(String id) async {
    final db = await database;
    return await db.delete('company_profiles', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getCompanyProfiles() async {
    final db = await database;
    return await db.query('company_profiles');
  }

  Future<int> insertInvoice(Map<String, dynamic> invoice) async {
    final db = await database;
    return await db.insert('invoices', invoice);
  }

  Future<int> updateInvoice(Map<String, dynamic> invoice) async {
    final db = await database;
    return await db.update('invoices', invoice, where: 'id = ?', whereArgs: [invoice['id']]);
  }

  Future<int> deleteInvoice(String id) async {
    final db = await database;
    return await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getInvoices() async {
    final db = await database;
    return await db.query('invoices', orderBy: 'date DESC');
  }

  Future<int> insertInvoiceItem(Map<String, dynamic> item) async {
    final db = await database;
    return await db.insert('invoice_items', item);
  }

  Future<void> deleteInvoiceItems(String invoiceId) async {
    final db = await database;
    await db.delete('invoice_items', where: 'invoice_id = ?', whereArgs: [invoiceId]);
  }

  Future<List<Map<String, dynamic>>> getInvoiceItems(String invoiceId) async {
    final db = await database;
    return await db.query('invoice_items', where: 'invoice_id = ?', whereArgs: [invoiceId]);
  }

  Future<int> insertInvoicePayment(Map<String, dynamic> payment) async {
    final db = await database;
    return await db.insert('invoice_payments', payment);
  }

  Future<List<Map<String, dynamic>>> getInvoicePayments(String invoiceId) async {
    final db = await database;
    return await db.query('invoice_payments', where: 'invoice_id = ?', whereArgs: [invoiceId], orderBy: 'date DESC');
  }
}
