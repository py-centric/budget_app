import 'package:budget_app/features/accounts/data/datasources/account_local_datasource.dart';
import 'package:budget_app/features/accounts/data/models/account_model.dart';
import 'package:budget_app/features/accounts/data/models/loan_account_model.dart';
import 'package:budget_app/features/accounts/data/models/savings_account_model.dart';
import 'package:budget_app/features/accounts/data/models/investment_portfolio_model.dart';
import 'package:budget_app/features/accounts/data/models/account_transaction_model.dart';
import 'package:budget_app/features/accounts/data/models/transfer_model.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/domain/entities/loan_account.dart';
import 'package:budget_app/features/accounts/domain/entities/savings_account.dart';
import 'package:budget_app/features/accounts/domain/entities/investment_portfolio.dart';
import 'package:budget_app/features/accounts/domain/entities/account_transaction.dart';
import 'package:budget_app/features/accounts/domain/entities/transfer.dart';
import 'package:budget_app/features/accounts/domain/repositories/account_repository.dart';
import 'package:budget_app/features/budget/data/datasources/local_database.dart';

class AccountRepositoryImpl implements AccountRepository {
  final LocalDatabase _localDatabase;
  final AccountLocalDataSource _dataSource;

  AccountRepositoryImpl(LocalDatabase localDatabase, {AccountLocalDataSource? dataSource})
      : _localDatabase = localDatabase,
        _dataSource = dataSource ?? AccountLocalDataSource(localDb: localDatabase);

  @override
  Future<List<Account>> getAllAccounts() async {
    return _dataSource.getAccounts();
  }

  @override
  Future<Account?> getAccount(String id) async {
    final db = await _localDatabase.database;
    final maps = await db.query('accounts', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return AccountModel.fromMap(maps.first);
  }

  @override
  Future<void> createAccount(Account account) async {
    await _dataSource.insertAccount(AccountModel.fromEntity(account));
  }

  @override
  Future<void> updateAccount(Account account) async {
    await _dataSource.updateAccount(AccountModel.fromEntity(account));
  }

  @override
  Future<void> deleteAccount(String id) async {
    await _dataSource.deleteAccount(id);
  }

  @override
  Future<double> getTotalBalance() async {
    final db = await _localDatabase.database;
    final result = await db.rawQuery(
      'SELECT SUM(balance) as total FROM accounts',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  @override
  Future<List<Transfer>> getTransfersForAccount(String accountId) async {
    final db = await _localDatabase.database;
    final maps = await db.query(
      'transfers',
      where: 'from_account_id = ? OR to_account_id = ?',
      whereArgs: [accountId, accountId],
      orderBy: 'date DESC',
    );
    return maps.map(TransferModel.fromMap).toList();
  }

  @override
  Future<void> createTransfer(
    Transfer transfer,
    String fromAccountId,
    String toAccountId,
  ) async {
    final db = await _localDatabase.database;
    await db.transaction((txn) async {
      await txn.insert('transfers', TransferModel.fromEntity(transfer).toMap());

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
        final fromAccount = AccountModel.fromMap(fromAccountMaps.first);
        final toAccount = AccountModel.fromMap(toAccountMaps.first);

        final updatedFrom = fromAccount.copyWith(
          balance: fromAccount.balance - transfer.amount,
          updatedAt: DateTime.now(),
        );
        final updatedTo = toAccount.copyWith(
          balance: toAccount.balance + transfer.amount,
          updatedAt: DateTime.now(),
        );

        await txn.update(
          'accounts',
          AccountModel.fromEntity(updatedFrom).toMap(),
          where: 'id = ?',
          whereArgs: [fromAccountId],
        );
        await txn.update(
          'accounts',
          AccountModel.fromEntity(updatedTo).toMap(),
          where: 'id = ?',
          whereArgs: [toAccountId],
        );
      }
    });
  }

  @override
  Future<List<LoanAccount>> getLoanAccounts() async {
    return _dataSource.getLoanAccounts();
  }

  @override
  Future<void> saveLoanAccount(LoanAccount loanAccount) async {
    final model = LoanAccountModel(
      account: loanAccount.account,
      originalPrincipal: loanAccount.originalPrincipal,
      currentPrincipal: loanAccount.currentPrincipal,
      interestRateApr: loanAccount.interestRateApr,
      minimumMonthlyPayment: loanAccount.minimumMonthlyPayment,
      originationDate: loanAccount.originationDate,
      isPaidOff: loanAccount.isPaidOff,
    );
    await _dataSource.saveLoanAccount(model);
  }

  @override
  Future<void> updateLoanAccount(LoanAccount loanAccount) async {
    final model = LoanAccountModel(
      account: loanAccount.account,
      originalPrincipal: loanAccount.originalPrincipal,
      currentPrincipal: loanAccount.currentPrincipal,
      interestRateApr: loanAccount.interestRateApr,
      minimumMonthlyPayment: loanAccount.minimumMonthlyPayment,
      originationDate: loanAccount.originationDate,
      isPaidOff: loanAccount.isPaidOff,
    );
    await _dataSource.updateLoanAccount(model);
  }

  @override
  Future<List<SavingsAccount>> getSavingsAccounts() async {
    return _dataSource.getSavingsAccounts();
  }

  @override
  Future<void> saveSavingsAccount(SavingsAccount savingsAccount) async {
    final model = SavingsAccountModel(
      account: savingsAccount.account,
      interestRateApy: savingsAccount.interestRateApy,
      compoundingFrequency: savingsAccount.compoundingFrequency,
      targetGoalAmount: savingsAccount.targetGoalAmount,
      totalContributions: savingsAccount.totalContributions,
    );
    await _dataSource.saveSavingsAccount(model);
  }

  @override
  Future<void> updateSavingsAccount(SavingsAccount savingsAccount) async {
    final model = SavingsAccountModel(
      account: savingsAccount.account,
      interestRateApy: savingsAccount.interestRateApy,
      compoundingFrequency: savingsAccount.compoundingFrequency,
      targetGoalAmount: savingsAccount.targetGoalAmount,
      totalContributions: savingsAccount.totalContributions,
    );
    await _dataSource.updateSavingsAccount(model);
  }

  @override
  Future<List<InvestmentPortfolio>> getInvestmentPortfolios() async {
    return _dataSource.getInvestmentPortfolios();
  }

  @override
  Future<void> saveInvestmentPortfolio(InvestmentPortfolio portfolio) async {
    final model = InvestmentPortfolioModel(
      account: portfolio.account,
      totalMarketValue: portfolio.totalMarketValue,
      totalDeposited: portfolio.totalDeposited,
      totalWithdrawn: portfolio.totalWithdrawn,
      targetAnnualReturnRate: portfolio.targetAnnualReturnRate,
    );
    await _dataSource.saveInvestmentPortfolio(model);
  }

  @override
  Future<void> updateInvestmentPortfolio(InvestmentPortfolio portfolio) async {
    final model = InvestmentPortfolioModel(
      account: portfolio.account,
      totalMarketValue: portfolio.totalMarketValue,
      totalDeposited: portfolio.totalDeposited,
      totalWithdrawn: portfolio.totalWithdrawn,
      targetAnnualReturnRate: portfolio.targetAnnualReturnRate,
    );
    await _dataSource.updateInvestmentPortfolio(model);
  }

  @override
  Future<List<AccountTransaction>> getTransactionsForAccount(String accountId) async {
    return _dataSource.getTransactionsForAccount(accountId);
  }

  @override
  Future<void> addAccountTransaction(AccountTransaction transaction) async {
    final model = AccountTransactionModel.fromEntity(transaction);
    await _dataSource.insertTransaction(model);
  }
}
