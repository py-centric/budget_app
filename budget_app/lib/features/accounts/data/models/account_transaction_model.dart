import 'package:budget_app/features/accounts/domain/entities/account_transaction.dart';

class AccountTransactionModel extends AccountTransaction {
  const AccountTransactionModel({
    required super.id,
    required super.accountId,
    required super.type,
    required super.amount,
    required super.date,
    super.note,
  });

  factory AccountTransactionModel.fromMap(Map<String, dynamic> map) {
    return AccountTransactionModel(
      id: map['id'] as String,
      accountId: map['account_id'] as String,
      type: AccountTransactionType.fromString(map['transaction_type'] as String),
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'transaction_type': type.name,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'note': note,
    };
  }

  factory AccountTransactionModel.fromEntity(AccountTransaction tx) {
    return AccountTransactionModel(
      id: tx.id,
      accountId: tx.accountId,
      type: tx.type,
      amount: tx.amount,
      date: tx.date,
      note: tx.note,
    );
  }
}
