import 'package:sqflite/sqflite.dart';
import 'package:budget_app/features/budget/data/datasources/local_database.dart';
import 'package:budget_app/features/accounts/data/models/account_model.dart';
import 'package:budget_app/features/accounts/data/models/loan_account_model.dart';
import 'package:budget_app/features/accounts/data/models/savings_account_model.dart';
import 'package:budget_app/features/accounts/data/models/investment_portfolio_model.dart';
import 'package:budget_app/features/accounts/data/models/account_transaction_model.dart';

class AccountLocalDataSource {
  final LocalDatabase _localDb;

  AccountLocalDataSource({LocalDatabase? localDb})
      : _localDb = localDb ?? LocalDatabase.instance;

  Future<Database> get _db => _localDb.database;

  // Base Accounts
  Future<List<AccountModel>> getAccounts() async {
    final db = await _db;
    final maps = await db.query('accounts', orderBy: 'created_at DESC');
    return maps.map(AccountModel.fromMap).toList();
  }

  Future<void> insertAccount(AccountModel account) async {
    final db = await _db;
    await db.insert('accounts', account.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateAccount(AccountModel account) async {
    final db = await _db;
    await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<void> deleteAccount(String id) async {
    final db = await _db;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  // Loan Accounts
  Future<List<LoanAccountModel>> getLoanAccounts() async {
    final db = await _db;
    final accounts = await getAccounts();
    final loanAccounts = <LoanAccountModel>[];

    for (final account in accounts) {
      if (account.type.name == 'loan') {
        final maps = await db.query(
          'loan_accounts',
          where: 'account_id = ?',
          whereArgs: [account.id],
        );
        if (maps.isNotEmpty) {
          loanAccounts.add(LoanAccountModel.fromMap(account, maps.first));
        }
      }
    }
    return loanAccounts;
  }

  Future<void> saveLoanAccount(LoanAccountModel model) async {
    final db = await _db;
    await insertAccount(AccountModel.fromEntity(model.account));
    await db.insert('loan_accounts', model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateLoanAccount(LoanAccountModel model) async {
    final db = await _db;
    await updateAccount(AccountModel.fromEntity(model.account));
    await db.update(
      'loan_accounts',
      model.toMap(),
      where: 'account_id = ?',
      whereArgs: [model.account.id],
    );
  }

  // Savings Accounts
  Future<List<SavingsAccountModel>> getSavingsAccounts() async {
    final db = await _db;
    final accounts = await getAccounts();
    final savingsAccounts = <SavingsAccountModel>[];

    for (final account in accounts) {
      if (account.type.name == 'savings') {
        final maps = await db.query(
          'savings_accounts',
          where: 'account_id = ?',
          whereArgs: [account.id],
        );
        if (maps.isNotEmpty) {
          savingsAccounts.add(SavingsAccountModel.fromMap(account, maps.first));
        }
      }
    }
    return savingsAccounts;
  }

  Future<void> saveSavingsAccount(SavingsAccountModel model) async {
    final db = await _db;
    await insertAccount(AccountModel.fromEntity(model.account));
    await db.insert('savings_accounts', model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateSavingsAccount(SavingsAccountModel model) async {
    final db = await _db;
    await updateAccount(AccountModel.fromEntity(model.account));
    await db.update(
      'savings_accounts',
      model.toMap(),
      where: 'account_id = ?',
      whereArgs: [model.account.id],
    );
  }

  // Investment Portfolios
  Future<List<InvestmentPortfolioModel>> getInvestmentPortfolios() async {
    final db = await _db;
    final accounts = await getAccounts();
    final portfolios = <InvestmentPortfolioModel>[];

    for (final account in accounts) {
      if (account.type.name == 'investment') {
        final maps = await db.query(
          'investment_portfolios',
          where: 'account_id = ?',
          whereArgs: [account.id],
        );
        if (maps.isNotEmpty) {
          portfolios.add(InvestmentPortfolioModel.fromMap(account, maps.first));
        }
      }
    }
    return portfolios;
  }

  Future<void> saveInvestmentPortfolio(InvestmentPortfolioModel model) async {
    final db = await _db;
    await insertAccount(AccountModel.fromEntity(model.account));
    await db.insert('investment_portfolios', model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateInvestmentPortfolio(InvestmentPortfolioModel model) async {
    final db = await _db;
    await updateAccount(AccountModel.fromEntity(model.account));
    await db.update(
      'investment_portfolios',
      model.toMap(),
      where: 'account_id = ?',
      whereArgs: [model.account.id],
    );
  }

  // Transactions
  Future<List<AccountTransactionModel>> getTransactionsForAccount(String accountId) async {
    final db = await _db;
    final maps = await db.query(
      'account_transactions',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
    );
    return maps.map(AccountTransactionModel.fromMap).toList();
  }

  Future<void> insertTransaction(AccountTransactionModel tx) async {
    final db = await _db;
    await db.insert('account_transactions', tx.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
