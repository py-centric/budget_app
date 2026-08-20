import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:budget_app/core/database/database_schema.dart';
import 'package:budget_app/core/database/daos/transaction_dao.dart';
import 'package:budget_app/core/database/daos/budget_dao.dart';
import 'package:budget_app/core/constants/app_constants.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('TransactionDao Account Joins Tests', () {
    late Database db;
    late TransactionDao transactionDao;
    late BudgetDao budgetDao;

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
      transactionDao = TransactionDao(() async => db);
      budgetDao = BudgetDao(() async => db);

      // Create a test budget
      await budgetDao.insertBudget({
        'id': 'b_2026_04',
        'name': 'April 2026',
        'period_month': 4,
        'period_year': 2026,
        'is_active': 1,
        'currency_code': 'USD',
        'type': 'regular',
      });

      // Create test accounts
      await db.insert('accounts', {
        'id': 'acc_main',
        'name': 'Primary Checking',
        'type': 'checking',
        'balance': 2500.0,
        'currency': 'USD',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      await db.insert('accounts', {
        'id': 'acc_card',
        'name': 'Rewards Credit Card',
        'type': 'credit_card',
        'balance': -150.0,
        'currency': 'USD',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
    });

    tearDown(() async {
      await db.close();
    });

    test('insert and fetch income with assigned account joins account_name', () async {
      await transactionDao.insertIncome({
        'id': 'inc_test_1',
        'budget_id': 'b_2026_04',
        'amount': 3000.0,
        'description': 'Salary Direct Deposit',
        'date': '2026-04-01T09:00:00.000',
        'period_month': 4,
        'period_year': 2026,
        'category_id': 'cat_salary',
        'account_id': 'acc_main',
        'is_potential': 0,
      });

      final incomes = await transactionDao.getIncomeForPeriod(2026, 4);
      expect(incomes.length, equals(1));
      expect(incomes.first['id'], equals('inc_test_1'));
      expect(incomes.first['account_id'], equals('acc_main'));
      expect(incomes.first['account_name'], equals('Primary Checking'));
    });

    test('insert and fetch expense with assigned account joins account_name', () async {
      await transactionDao.insertExpense({
        'id': 'exp_test_1',
        'budget_id': 'b_2026_04',
        'amount': 120.0,
        'description': 'Dinner with friends',
        'date': '2026-04-02T19:30:00.000',
        'period_month': 4,
        'period_year': 2026,
        'category_id': 'cat_food',
        'account_id': 'acc_card',
        'is_potential': 0,
      });

      final expenses = await transactionDao.getExpensesForPeriod(2026, 4);
      expect(expenses.length, equals(1));
      expect(expenses.first['id'], equals('exp_test_1'));
      expect(expenses.first['account_id'], equals('acc_card'));
      expect(expenses.first['account_name'], equals('Rewards Credit Card'));
    });

    test('unassigned transactions return null account_id and account_name', () async {
      await transactionDao.insertExpense({
        'id': 'exp_unassigned',
        'budget_id': 'b_2026_04',
        'amount': 10.0,
        'description': 'Coffee cash',
        'date': '2026-04-03T10:00:00.000',
        'period_month': 4,
        'period_year': 2026,
        'category_id': 'cat_food',
        'account_id': null,
        'is_potential': 0,
      });

      final expenses = await transactionDao.getExpensesForPeriod(2026, 4);
      expect(expenses.length, equals(1));
      expect(expenses.first['account_id'], isNull);
      expect(expenses.first['account_name'], isNull);
    });
  });
}
