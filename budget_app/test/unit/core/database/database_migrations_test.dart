import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:budget_app/core/database/database_migrations.dart';
import 'package:budget_app/core/constants/app_constants.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseMigrations Tests', () {
    test('incremental migration from v1 to current version', () async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            // Minimal v1 schema
            await db.execute('''
              CREATE TABLE income_entries (
                id TEXT PRIMARY KEY,
                amount REAL NOT NULL,
                description TEXT,
                date TEXT NOT NULL,
                category TEXT NOT NULL
              )
            ''');
            await db.execute('''
              CREATE TABLE expense_entries (
                id TEXT PRIMARY KEY,
                amount REAL NOT NULL,
                description TEXT,
                date TEXT NOT NULL,
                category TEXT NOT NULL
              )
            ''');
            await db.execute('''
              CREATE TABLE categories (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                icon TEXT
              )
            ''');
          },
        ),
      );

      // Apply migrations from v1 to AppConstants.databaseVersion (28)
      await DatabaseMigrations.onUpgrade(db, 1, AppConstants.databaseVersion);

      // Verify upgraded tables exist (all 35 tables)
      final tablesResult = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
      );
      final tableNames = tablesResult.map((t) => t['name'] as String).toSet();

      final expectedTables = {
        'budgets',
        'income_entries',
        'expense_entries',
        'budget_goals',
        'categories',
        'recurring_transactions',
        'recurring_overrides',
        'saved_calculations',
        'emergency_expenses',
        'metadata',
        'company_profiles',
        'invoices',
        'clients',
        'invoice_items',
        'invoice_payments',
        'received_invoices',
        'accounts',
        'transfers',
        'category_limits',
        'savings_goals',
        'savings_contributions',
        'bill_reminders',
        'transaction_splits',
        'tags',
        'transaction_tags',
        'attachments',
        'budget_templates',
        'budget_template_allocations',
        'net_worth_snapshots',
        'credit_cards',
        'investments',
        'loan_accounts',
        'savings_accounts',
        'investment_portfolios',
        'account_transactions',
      };

      expect(tableNames, containsAll(expectedTables));
      expect(expectedTables.difference(tableNames), isEmpty);

      // Verify preset budget templates were seeded in migration v25
      final templates = await db.query('budget_templates');
      expect(templates.length, greaterThanOrEqualTo(3));

      await db.close();
    });

    test('preserves user data through migration cycle', () async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE income_entries (
                id TEXT PRIMARY KEY,
                amount REAL NOT NULL,
                description TEXT,
                date TEXT NOT NULL,
                category TEXT NOT NULL
              )
            ''');
            await db.execute('''
              CREATE TABLE expense_entries (
                id TEXT PRIMARY KEY,
                amount REAL NOT NULL,
                description TEXT,
                date TEXT NOT NULL,
                category TEXT NOT NULL
              )
            ''');
            await db.execute('''
              CREATE TABLE categories (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                icon TEXT
              )
            ''');

            await db.insert('categories', {'id': 'cat_food', 'name': 'Food', 'icon': 'restaurant'});
            await db.insert('expense_entries', {
              'id': 'exp_1',
              'amount': 45.50,
              'description': 'Groceries',
              'date': '2026-03-15',
              'category': 'Food',
            });
          },
        ),
      );

      await DatabaseMigrations.onUpgrade(db, 1, AppConstants.databaseVersion);

      // Verify expense entry survived migration and received budget_id and period columns
      final expenses = await db.query('expense_entries', where: 'id = ?', whereArgs: ['exp_1']);
      expect(expenses.length, equals(1));
      expect(expenses.first['amount'], equals(45.50));
      expect(expenses.first['description'], equals('Groceries'));
      expect(expenses.first['period_year'], equals(2026));
      expect(expenses.first['period_month'], equals(3));
      expect(expenses.first.containsKey('account_id'), isTrue);
      expect(expenses.first['account_id'], isNull);

      // Verify income entries also have account_id column
      final incomeTableInfo = await db.rawQuery("PRAGMA table_info('income_entries')");
      final incomeColumns = incomeTableInfo.map((c) => c['name'] as String).toList();
      expect(incomeColumns, contains('account_id'));

      await db.close();
    });

    test('direct migration from v28 to v29 adds account_id column', () async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 28,
          onCreate: (db, version) async {
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
                is_potential INTEGER NOT NULL DEFAULT 0
              )
            ''');
            await db.execute('''
              CREATE TABLE expense_entries (
                id TEXT PRIMARY KEY,
                budget_id TEXT NOT NULL,
                amount REAL NOT NULL,
                description TEXT,
                date TEXT NOT NULL,
                period_month INTEGER,
                period_year INTEGER,
                category_id TEXT,
                is_potential INTEGER NOT NULL DEFAULT 0
              )
            ''');
          },
        ),
      );

      await DatabaseMigrations.onUpgrade(db, 28, 29);

      final incomeInfo = await db.rawQuery("PRAGMA table_info('income_entries')");
      final incomeCols = incomeInfo.map((c) => c['name'] as String).toList();
      expect(incomeCols, contains('account_id'));

      final expenseInfo = await db.rawQuery("PRAGMA table_info('expense_entries')");
      final expenseCols = expenseInfo.map((c) => c['name'] as String).toList();
      expect(expenseCols, contains('account_id'));

      await db.close();
    });
  });
}
