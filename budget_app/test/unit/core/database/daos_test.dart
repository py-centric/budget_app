import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:budget_app/core/database/database_schema.dart';
import 'package:budget_app/features/budget/data/datasources/local_database.dart';
import 'package:budget_app/core/constants/app_constants.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DAO Integration and Facade Tests', () {
    late Database db;
    late LocalDatabase localDatabase;

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

      LocalDatabase.setTestDatabase(db);
      localDatabase = LocalDatabase.instance;
    });

    tearDown(() async {
      LocalDatabase.resetForTesting();
      await db.close();
    });

    test('CategoryDao and Category Forwarding', () async {
      final category = {
        'id': 'cat_custom',
        'name': 'Custom Category',
        'type': 'expense',
        'icon': 'category',
      };

      await localDatabase.insertCategory(category);
      final categories = await localDatabase.getCategories();
      expect(categories.any((c) => c['id'] == 'cat_custom'), isTrue);

      await localDatabase.categoryDao.updateCategory({
        'id': 'cat_custom',
        'name': 'Updated Category',
        'type': 'expense',
        'icon': 'category',
      });
      final updated = await localDatabase.categoryDao.getCategories();
      expect(updated.firstWhere((c) => c['id'] == 'cat_custom')['name'], 'Updated Category');

      await localDatabase.deleteCategory('cat_custom');
      final afterDelete = await localDatabase.getCategories();
      expect(afterDelete.any((c) => c['id'] == 'cat_custom'), isFalse);
    });

    test('TransactionDao and Transaction Forwarding', () async {
      await localDatabase.insertBudget({
        'id': 'budget_test',
        'name': 'Test Budget',
        'period_month': 8,
        'period_year': 2026,
        'is_active': 1,
        'type': 'regular',
      });

      final income = {
        'id': 'inc_1',
        'budget_id': 'budget_test',
        'amount': 5000.0,
        'description': 'Salary',
        'date': '2026-08-01',
        'period_month': 8,
        'period_year': 2026,
        'category_id': 'income_salary',
        'is_potential': 0,
      };

      final expense = {
        'id': 'exp_1',
        'budget_id': 'budget_test',
        'amount': 150.0,
        'description': 'Groceries',
        'date': '2026-08-05',
        'period_month': 8,
        'period_year': 2026,
        'category_id': 'food',
        'is_potential': 0,
      };

      await localDatabase.insertIncome(income);
      await localDatabase.insertExpense(expense);

      final allIncome = await localDatabase.getAllIncome();
      expect(allIncome.any((i) => i['id'] == 'inc_1'), isTrue);

      final allExpenses = await localDatabase.getAllExpenses();
      expect(allExpenses.any((e) => e['id'] == 'exp_1'), isTrue);

      final periodExpenses = await localDatabase.getExpensesForPeriod(2026, 8);
      expect(periodExpenses.length, 1);

      await localDatabase.deleteIncome('inc_1');
      await localDatabase.deleteExpense('exp_1');
      expect((await localDatabase.getAllIncome()).any((i) => i['id'] == 'inc_1'), isFalse);
      expect((await localDatabase.getAllExpenses()).any((e) => e['id'] == 'exp_1'), isFalse);
    });

    test('BudgetDao and Budget Forwarding', () async {
      final budget = {
        'id': 'b_1',
        'name': 'August 2026',
        'period_month': 8,
        'period_year': 2026,
        'is_active': 1,
        'type': 'regular',
      };

      await localDatabase.insertBudget(budget);
      final fetched = await localDatabase.getBudget('b_1');
      expect(fetched?['name'], 'August 2026');

      final periods = await localDatabase.getAvailablePeriods();
      expect(periods.any((p) => p['period_month'] == 8 && p['period_year'] == 2026), isTrue);

      await localDatabase.deleteBudget('b_1');
      expect(await localDatabase.getBudget('b_1'), isNull);
    });

    test('AccountDao operations', () async {
      final account1 = {
        'id': 'acc_1',
        'name': 'Checking',
        'type': 'checking',
        'balance': 1000.0,
        'currency': 'USD',
        'created_at': 1000000,
        'updated_at': 1000000,
      };

      final account2 = {
        'id': 'acc_2',
        'name': 'Savings',
        'type': 'savings',
        'balance': 500.0,
        'currency': 'USD',
        'created_at': 1000000,
        'updated_at': 1000000,
      };

      await localDatabase.accountDao.insertAccount(account1);
      await localDatabase.accountDao.insertAccount(account2);

      expect(await localDatabase.accountDao.getTotalBalance(), 1500.0);

      await localDatabase.accountDao.createTransfer(
        {
          'id': 'tr_1',
          'from_account_id': 'acc_1',
          'to_account_id': 'acc_2',
          'amount': 200.0,
          'date': 1000001,
          'note': 'Savings transfer',
          'created_at': 1000001,
        },
        'acc_1',
        'acc_2',
        200.0,
      );

      final acc1 = await localDatabase.accountDao.getAccount('acc_1');
      final acc2 = await localDatabase.accountDao.getAccount('acc_2');
      expect(acc1?['balance'], 800.0);
      expect(acc2?['balance'], 700.0);
    });

    test('InvoiceDao and Company Profiles', () async {
      final profile = {
        'id': 'prof_1',
        'name': 'Acme Corp',
        'address': '100 Main St',
        'tax_id': 'TX999',
        'default_vat_rate': 20.0,
      };

      await localDatabase.insertCompanyProfile(profile);
      final profiles = await localDatabase.getCompanyProfiles();
      expect(profiles.any((p) => p['id'] == 'prof_1'), isTrue);

      final invoice = {
        'id': 'inv_1',
        'profile_id': 'prof_1',
        'invoice_number': 'INV-001',
        'date': '2026-08-20',
        'client_name': 'Client A',
        'client_details': 'Address A',
        'status': 'pending',
        'sub_total': 100.0,
        'tax_total': 20.0,
        'grand_total': 120.0,
        'balance_due': 120.0,
      };

      await localDatabase.insertInvoice(invoice);
      final invoices = await localDatabase.getInvoices();
      expect(invoices.any((i) => i['id'] == 'inv_1'), isTrue);
    });

    test('EmergencyFundDao and Metadata', () async {
      await localDatabase.setMetadata('test_key', 'test_value');
      expect(await localDatabase.getMetadata('test_key'), 'test_value');

      final expense = {
        'id': 'em_1',
        'name': 'Rent',
        'amount': 1200.0,
        'is_suggestion': 0,
        'category_type': 'housing',
        'sort_order': 1,
      };

      await localDatabase.insertEmergencyExpense(expense);
      final expenses = await localDatabase.getEmergencyExpenses();
      expect(expenses.any((e) => e['id'] == 'em_1'), isTrue);
    });

    test('FinancialToolsDao Saved Calculations', () async {
      final calc = {
        'id': 'calc_1',
        'type': 'loan',
        'name': 'Home Loan',
        'data': '{"rate": 5.0}',
        'created_at': '2026-08-20',
      };

      await localDatabase.insertSavedCalculation(calc);
      final calcs = await localDatabase.getSavedCalculations();
      expect(calcs.any((c) => c['id'] == 'calc_1'), isTrue);
      await localDatabase.deleteSavedCalculation('calc_1');
      expect((await localDatabase.getSavedCalculations()).any((c) => c['id'] == 'calc_1'), isFalse);
    });
  });
}
