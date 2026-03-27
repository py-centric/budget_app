import 'package:budget_app/features/accounts/domain/entities/account.dart';
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
}
