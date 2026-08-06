import 'package:equatable/equatable.dart';

enum AccountTransactionType {
  repayment,
  contribution,
  deposit,
  withdrawal,
  interestEarned,
  interestCharged;

  String get displayName {
    switch (this) {
      case AccountTransactionType.repayment:
        return 'Repayment';
      case AccountTransactionType.contribution:
        return 'Contribution';
      case AccountTransactionType.deposit:
        return 'Deposit';
      case AccountTransactionType.withdrawal:
        return 'Withdrawal';
      case AccountTransactionType.interestEarned:
        return 'Interest Earned';
      case AccountTransactionType.interestCharged:
        return 'Interest Charged';
    }
  }

  static AccountTransactionType fromString(String value) {
    return AccountTransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AccountTransactionType.deposit,
    );
  }
}

class AccountTransaction extends Equatable {
  final String id;
  final String accountId;
  final AccountTransactionType type;
  final double amount;
  final DateTime date;
  final String? note;

  const AccountTransaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.date,
    this.note,
  });

  @override
  List<Object?> get props => [id, accountId, type, amount, date, note];
}
