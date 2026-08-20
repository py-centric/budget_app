import 'package:sqflite/sqflite.dart';
import 'base_dao.dart';

class AccountDao extends BaseDao {
  AccountDao(super.getDb);

  Future<List<Map<String, dynamic>>> getAccounts() async {
    final database = await db;
    return await database.query('accounts', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getAccount(String id) async {
    final database = await db;
    final maps = await database.query('accounts', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<void> insertAccount(Map<String, dynamic> account) async {
    final database = await db;
    await database.insert(
      'accounts',
      account,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAccount(Map<String, dynamic> account) async {
    final database = await db;
    await database.update(
      'accounts',
      account,
      where: 'id = ?',
      whereArgs: [account['id']],
    );
  }

  Future<void> deleteAccount(String id) async {
    final database = await db;
    await database.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalBalance() async {
    final database = await db;
    final result = await database.rawQuery('SELECT SUM(balance) as total FROM accounts');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<List<Map<String, dynamic>>> getTransfersForAccount(String accountId) async {
    final database = await db;
    return await database.query(
      'transfers',
      where: 'from_account_id = ? OR to_account_id = ?',
      whereArgs: [accountId, accountId],
      orderBy: 'date DESC',
    );
  }

  Future<void> createTransfer(
    Map<String, dynamic> transfer,
    String fromAccountId,
    String toAccountId,
    double amount,
  ) async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.insert('transfers', transfer);

      final fromAccountMaps = await txn.query(
        'accounts',
        where: 'id = ?',
        whereArgs: [fromAccountId],
      );
      final toAccountMaps = await txn.query(
        'accounts',
        where: 'id = ?',
        whereArgs: [toAccountId],
      );

      if (fromAccountMaps.isNotEmpty && toAccountMaps.isNotEmpty) {
        final fromBalance = (fromAccountMaps.first['balance'] as num).toDouble();
        final toBalance = (toAccountMaps.first['balance'] as num).toDouble();

        await txn.update(
          'accounts',
          {'balance': fromBalance - amount, 'updated_at': DateTime.now().millisecondsSinceEpoch},
          where: 'id = ?',
          whereArgs: [fromAccountId],
        );

        await txn.update(
          'accounts',
          {'balance': toBalance + amount, 'updated_at': DateTime.now().millisecondsSinceEpoch},
          where: 'id = ?',
          whereArgs: [toAccountId],
        );
      }
    });
  }

  // Loan Accounts
  Future<List<Map<String, dynamic>>> getLoanAccounts(String accountId) async {
    final database = await db;
    return await database.query(
      'loan_accounts',
      where: 'account_id = ?',
      whereArgs: [accountId],
    );
  }

  Future<void> saveLoanAccount(Map<String, dynamic> accountData, Map<String, dynamic> loanData) async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.insert('accounts', accountData, conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.insert('loan_accounts', loanData, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> updateLoanAccount(Map<String, dynamic> accountData, Map<String, dynamic> loanData) async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.update('accounts', accountData, where: 'id = ?', whereArgs: [accountData['id']]);
      await txn.update('loan_accounts', loanData, where: 'account_id = ?', whereArgs: [loanData['account_id']]);
    });
  }

  // Savings Accounts
  Future<List<Map<String, dynamic>>> getSavingsAccounts(String accountId) async {
    final database = await db;
    return await database.query(
      'savings_accounts',
      where: 'account_id = ?',
      whereArgs: [accountId],
    );
  }

  Future<void> saveSavingsAccount(Map<String, dynamic> accountData, Map<String, dynamic> savingsData) async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.insert('accounts', accountData, conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.insert('savings_accounts', savingsData, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> updateSavingsAccount(Map<String, dynamic> accountData, Map<String, dynamic> savingsData) async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.update('accounts', accountData, where: 'id = ?', whereArgs: [accountData['id']]);
      await txn.update('savings_accounts', savingsData, where: 'account_id = ?', whereArgs: [savingsData['account_id']]);
    });
  }

  // Investment Portfolios
  Future<List<Map<String, dynamic>>> getInvestmentPortfolios(String accountId) async {
    final database = await db;
    return await database.query(
      'investment_portfolios',
      where: 'account_id = ?',
      whereArgs: [accountId],
    );
  }

  Future<void> saveInvestmentPortfolio(Map<String, dynamic> accountData, Map<String, dynamic> portfolioData) async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.insert('accounts', accountData, conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.insert('investment_portfolios', portfolioData, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> updateInvestmentPortfolio(Map<String, dynamic> accountData, Map<String, dynamic> portfolioData) async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.update('accounts', accountData, where: 'id = ?', whereArgs: [accountData['id']]);
      await txn.update('investment_portfolios', portfolioData, where: 'account_id = ?', whereArgs: [portfolioData['account_id']]);
    });
  }

  // Account Transactions
  Future<List<Map<String, dynamic>>> getAccountTransactions(String accountId) async {
    final database = await db;
    return await database.query(
      'account_transactions',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
    );
  }

  Future<void> saveAccountTransaction(Map<String, dynamic> transaction) async {
    final database = await db;
    await database.insert(
      'account_transactions',
      transaction,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteAccountTransaction(String id) async {
    final database = await db;
    await database.delete('account_transactions', where: 'id = ?', whereArgs: [id]);
  }
}
