import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/domain/entities/loan_account.dart';
import 'package:budget_app/features/accounts/domain/entities/savings_account.dart';
import 'package:budget_app/features/accounts/domain/entities/investment_portfolio.dart';
import 'package:budget_app/features/accounts/domain/entities/account_transaction.dart';
import 'package:budget_app/features/accounts/domain/entities/transfer.dart';

abstract class AccountRepository {
  Future<List<Account>> getAllAccounts();
  Future<Account?> getAccount(String id);
  Future<void> createAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String id);
  Future<double> getTotalBalance();
  Future<List<Transfer>> getTransfersForAccount(String accountId);
  Future<void> createTransfer(
    Transfer transfer,
    String fromAccountId,
    String toAccountId,
  );

  // Specialized Accounts
  Future<List<LoanAccount>> getLoanAccounts();
  Future<void> saveLoanAccount(LoanAccount loanAccount);
  Future<void> updateLoanAccount(LoanAccount loanAccount);

  Future<List<SavingsAccount>> getSavingsAccounts();
  Future<void> saveSavingsAccount(SavingsAccount savingsAccount);
  Future<void> updateSavingsAccount(SavingsAccount savingsAccount);

  Future<List<InvestmentPortfolio>> getInvestmentPortfolios();
  Future<void> saveInvestmentPortfolio(InvestmentPortfolio portfolio);
  Future<void> updateInvestmentPortfolio(InvestmentPortfolio portfolio);

  // Transactions
  Future<List<AccountTransaction>> getTransactionsForAccount(String accountId);
  Future<void> addAccountTransaction(AccountTransaction transaction);
}
