import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:budget_app/core/database/database_schema.dart';
import 'package:budget_app/core/constants/app_constants.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseSchema Tests', () {
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: AppConstants.databaseVersion,
          onCreate: DatabaseSchema.onCreate,
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
          },
        ),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('creates all 35 tables on fresh database installation', () async {
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
    });

    test('creates all 29 indices on fresh database installation', () async {
      final indicesResult = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name NOT LIKE 'sqlite_%' ORDER BY name",
      );
      final indexNames = indicesResult.map((i) => i['name'] as String).toSet();

      final expectedIndices = {
        'idx_income_period',
        'idx_income_date',
        'idx_income_budget',
        'idx_income_category',
        'idx_income_account',
        'idx_expense_period',
        'idx_expense_date',
        'idx_expense_budget',
        'idx_expense_category',
        'idx_expense_account',
        'idx_budget_goals_period',
        'idx_budget_goals_budget',
        'idx_recurring_overrides_template',
        'idx_transfers_from',
        'idx_transfers_to',
        'idx_category_limits_budget',
        'idx_category_limits_category',
        'idx_savings_contributions_goal',
        'idx_bill_reminders_transaction',
        'idx_bill_reminders_due_date',
        'idx_transaction_splits_parent',
        'idx_transaction_splits_category',
        'idx_tags_name',
        'idx_transaction_tags_tag',
        'idx_transaction_tags_transaction',
        'idx_attachments_transaction',
        'idx_template_allocations_template',
        'idx_net_worth_date',
        'idx_account_transactions_acc',
      };

      expect(indexNames, containsAll(expectedIndices));
    });

    test('seeds default expense and income categories', () async {
      final categories = await db.query('categories');
      expect(categories, isNotEmpty);

      final names = categories.map((c) => c['name'] as String).toList();
      expect(names, contains('Salary'));
      expect(names, contains('Food'));
      expect(names, contains('Transport'));
    });
  });
}
