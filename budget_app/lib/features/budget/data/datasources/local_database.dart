import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:budget_app/core/constants/app_constants.dart';
import 'package:budget_app/core/database/database_schema.dart';
import 'package:budget_app/core/database/database_migrations.dart';
import 'package:budget_app/core/database/daos/budget_dao.dart';
import 'package:budget_app/core/database/daos/transaction_dao.dart';
import 'package:budget_app/core/database/daos/category_dao.dart';
import 'package:budget_app/core/database/daos/account_dao.dart';
import 'package:budget_app/core/database/daos/invoice_dao.dart';
import 'package:budget_app/core/database/daos/loan_dao.dart';
import 'package:budget_app/core/database/daos/savings_dao.dart';
import 'package:budget_app/core/database/daos/reminder_dao.dart';
import 'package:budget_app/core/database/daos/net_worth_dao.dart';
import 'package:budget_app/core/database/daos/credit_card_dao.dart';
import 'package:budget_app/core/database/daos/investment_dao.dart';
import 'package:budget_app/core/database/daos/tag_dao.dart';
import 'package:budget_app/core/database/daos/attachment_dao.dart';
import 'package:budget_app/core/database/daos/template_dao.dart';
import 'package:budget_app/core/database/daos/emergency_fund_dao.dart';
import 'package:budget_app/core/database/daos/financial_tools_dao.dart';

class LocalDatabase {
  static Database? _database;
  static final LocalDatabase instance = LocalDatabase._internal();
  static bool _initialized = false;
  static Completer<Database> _databaseCompleter = Completer<Database>();
  static bool _databaseCompleterUsed = false;

  LocalDatabase._internal();

  @visibleForTesting
  static void setTestDatabase(Database db) {
    _database = db;
    _initialized = true;
    if (!_databaseCompleterUsed) {
      _databaseCompleterUsed = true;
      _databaseCompleter.complete(db);
    }
  }

  @visibleForTesting
  static void resetForTesting() {
    _database = null;
    _initialized = false;
    _databaseCompleterUsed = false;
    _databaseCompleter = Completer<Database>();
  }

  static Future<void> initialize() async {
    if (_initialized) return;

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _initialized = true;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (!_databaseCompleterUsed) {
      _databaseCompleterUsed = true;
      await initialize();
      _database = await _initDatabase();
      _databaseCompleter.complete(_database);
    }

    return _databaseCompleter.future;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: DatabaseSchema.onCreate,
      onUpgrade: DatabaseMigrations.onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Domain DAOs
  late final BudgetDao budgetDao = BudgetDao(() => database);
  late final TransactionDao transactionDao = TransactionDao(() => database);
  late final CategoryDao categoryDao = CategoryDao(() => database);
  late final AccountDao accountDao = AccountDao(() => database);
  late final InvoiceDao invoiceDao = InvoiceDao(() => database);
  late final LoanDao loanDao = LoanDao(() => database);
  late final SavingsDao savingsDao = SavingsDao(() => database);
  late final ReminderDao reminderDao = ReminderDao(() => database);
  late final NetWorthDao netWorthDao = NetWorthDao(() => database);
  late final CreditCardDao creditCardDao = CreditCardDao(() => database);
  late final InvestmentDao investmentDao = InvestmentDao(() => database);
  late final TagDao tagDao = TagDao(() => database);
  late final AttachmentDao attachmentDao = AttachmentDao(() => database);
  late final TemplateDao templateDao = TemplateDao(() => database);
  late final EmergencyFundDao emergencyFundDao = EmergencyFundDao(() => database);
  late final FinancialToolsDao financialToolsDao = FinancialToolsDao(() => database);

  // Category Legacy Forwarding
  Future<int> insertCategory(Map<String, dynamic> category) => categoryDao.insertCategory(category);
  Future<int> updateCategory(Map<String, dynamic> category) => categoryDao.updateCategory(category);
  Future<int> deleteCategory(String id) => categoryDao.deleteCategory(id);
  Future<int> reassignCategory(String oldId, String newId) => categoryDao.reassignCategory(oldId, newId);
  Future<List<Map<String, dynamic>>> getCategories() => categoryDao.getCategories();
  Future<List<Map<String, dynamic>>> getCategoriesByType(String type) => categoryDao.getCategoriesByType(type);

  // Income Legacy Forwarding
  Future<int> insertIncome(Map<String, dynamic> income) => transactionDao.insertIncome(income);
  Future<int> updateIncome(Map<String, dynamic> income) => transactionDao.updateIncome(income);
  Future<int> deleteIncome(String id) => transactionDao.deleteIncome(id);
  Future<List<Map<String, dynamic>>> getAllIncome() => transactionDao.getAllIncome();
  Future<List<Map<String, dynamic>>> getIncomeForPeriod(int y, int m) => transactionDao.getIncomeForPeriod(y, m);
  Future<List<Map<String, dynamic>>> getIncomeForDateRange(String s, String e) => transactionDao.getIncomeForDateRange(s, e);
  Future<List<Map<String, dynamic>>> getIncomeForBudget(String budgetId) => transactionDao.getIncomeForBudget(budgetId);
  Future<List<Map<String, dynamic>>> getIncomeBefore(String date) => transactionDao.getIncomeBefore(date);

  // Expense Legacy Forwarding
  Future<int> insertExpense(Map<String, dynamic> expense) => transactionDao.insertExpense(expense);
  Future<int> updateExpense(Map<String, dynamic> expense) => transactionDao.updateExpense(expense);
  Future<int> deleteExpense(String id) => transactionDao.deleteExpense(id);
  Future<List<Map<String, dynamic>>> getAllExpenses() => transactionDao.getAllExpenses();
  Future<List<Map<String, dynamic>>> getExpensesForPeriod(int y, int m) => transactionDao.getExpensesForPeriod(y, m);
  Future<List<Map<String, dynamic>>> getExpensesForDateRange(String s, String e) => transactionDao.getExpensesForDateRange(s, e);
  Future<List<Map<String, dynamic>>> getExpensesForBudget(String budgetId) => transactionDao.getExpensesForBudget(budgetId);
  Future<List<Map<String, dynamic>>> getExpensesBefore(String date) => transactionDao.getExpensesBefore(date);

  // Budget Legacy Forwarding
  Future<List<Map<String, dynamic>>> getAvailablePeriods() => budgetDao.getAvailablePeriods();
  Future<List<Map<String, dynamic>>> getBudgetsForPeriod(int y, int m) => budgetDao.getBudgetsForPeriod(y, m);
  Future<Map<String, dynamic>?> getBudget(String id) => budgetDao.getBudget(id);
  Future<void> insertBudget(Map<String, dynamic> budget) => budgetDao.insertBudget(budget);
  Future<void> updateBudget(Map<String, dynamic> budget) => budgetDao.updateBudget(budget);
  Future<void> deleteBudget(String id) => budgetDao.deleteBudget(id);
  Future<void> clearAllBudgets() => budgetDao.clearAllBudgets();
  Future<void> factoryReset() => budgetDao.factoryReset();

  // Financial Tools Legacy Forwarding
  Future<int> insertSavedCalculation(Map<String, dynamic> c) => financialToolsDao.insertSavedCalculation(c);
  Future<List<Map<String, dynamic>>> getSavedCalculations() => financialToolsDao.getSavedCalculations();
  Future<int> deleteSavedCalculation(String id) => financialToolsDao.deleteSavedCalculation(id);

  // Emergency Fund & Metadata Legacy Forwarding
  Future<int> insertEmergencyExpense(Map<String, dynamic> e) => emergencyFundDao.insertEmergencyExpense(e);
  Future<int> updateEmergencyExpense(Map<String, dynamic> e) => emergencyFundDao.updateEmergencyExpense(e);
  Future<int> deleteEmergencyExpense(String id) => emergencyFundDao.deleteEmergencyExpense(id);
  Future<List<Map<String, dynamic>>> getEmergencyExpenses() => emergencyFundDao.getEmergencyExpenses();
  Future<double> getAverageSpendingForLastMonths(int count) => emergencyFundDao.getAverageSpendingForLastMonths(count);
  Future<void> setMetadata(String key, String value) => emergencyFundDao.setMetadata(key, value);
  Future<String?> getMetadata(String key) => emergencyFundDao.getMetadata(key);

  // Business Tools Legacy Forwarding
  Future<int> insertCompanyProfile(Map<String, dynamic> p) => invoiceDao.insertCompanyProfile(p);
  Future<int> updateCompanyProfile(Map<String, dynamic> p) => invoiceDao.updateCompanyProfile(p);
  Future<int> deleteCompanyProfile(String id) => invoiceDao.deleteCompanyProfile(id);
  Future<List<Map<String, dynamic>>> getCompanyProfiles() => invoiceDao.getCompanyProfiles();
  Future<int> insertInvoice(Map<String, dynamic> invoice) => invoiceDao.insertInvoice(invoice);
  Future<int> updateInvoice(Map<String, dynamic> invoice) => invoiceDao.updateInvoice(invoice);
  Future<int> deleteInvoice(String id) => invoiceDao.deleteInvoice(id);
  Future<List<Map<String, dynamic>>> getInvoices() => invoiceDao.getInvoices();
  Future<int> insertInvoiceItem(Map<String, dynamic> item) => invoiceDao.insertInvoiceItem(item);
  Future<void> deleteInvoiceItems(String invoiceId) => invoiceDao.deleteInvoiceItems(invoiceId);
  Future<List<Map<String, dynamic>>> getInvoiceItems(String invoiceId) => invoiceDao.getInvoiceItems(invoiceId);
  Future<int> insertInvoicePayment(Map<String, dynamic> payment) => invoiceDao.insertInvoicePayment(payment);
  Future<List<Map<String, dynamic>>> getInvoicePayments(String invoiceId) => invoiceDao.getInvoicePayments(invoiceId);
}
