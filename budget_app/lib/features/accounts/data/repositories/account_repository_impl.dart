import 'package:budget_app/features/accounts/data/models/account_model.dart';
import 'package:budget_app/features/accounts/data/models/transfer_model.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/domain/entities/transfer.dart';
import 'package:budget_app/features/accounts/domain/repositories/account_repository.dart';
import 'package:budget_app/features/budget/data/datasources/local_database.dart';

class AccountRepositoryImpl implements AccountRepository {
  final LocalDatabase _localDatabase;

  AccountRepositoryImpl(this._localDatabase);

  @override
  Future<List<Account>> getAllAccounts() async {
    final db = await _localDatabase.database;
    final maps = await db.query('accounts', orderBy: 'name ASC');
    return maps.map((map) => AccountModel.fromMap(map)).toList();
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
    final db = await _localDatabase.database;
    await db.insert('accounts', AccountModel.fromEntity(account).toMap());
  }

  @override
  Future<void> updateAccount(Account account) async {
    final db = await _localDatabase.database;
    await db.update(
      'accounts',
      AccountModel.fromEntity(account).toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  @override
  Future<void> deleteAccount(String id) async {
    final db = await _localDatabase.database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
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
    return maps.map((map) => TransferModel.fromMap(map)).toList();
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
}
