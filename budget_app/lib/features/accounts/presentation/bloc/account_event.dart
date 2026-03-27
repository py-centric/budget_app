import 'package:equatable/equatable.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/domain/entities/transfer.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccounts extends AccountEvent {}

class AddAccount extends AccountEvent {
  final Account account;

  const AddAccount(this.account);

  @override
  List<Object?> get props => [account];
}

class UpdateAccount extends AccountEvent {
  final Account account;

  const UpdateAccount(this.account);

  @override
  List<Object?> get props => [account];
}

class DeleteAccount extends AccountEvent {
  final String accountId;

  const DeleteAccount(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class CreateTransfer extends AccountEvent {
  final Transfer transfer;
  final String fromAccountId;
  final String toAccountId;

  const CreateTransfer({
    required this.transfer,
    required this.fromAccountId,
    required this.toAccountId,
  });

  @override
  List<Object?> get props => [transfer, fromAccountId, toAccountId];
}
