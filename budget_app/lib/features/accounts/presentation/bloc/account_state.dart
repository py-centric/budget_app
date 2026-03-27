import 'package:equatable/equatable.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final List<Account> accounts;
  final double totalBalance;

  const AccountLoaded({required this.accounts, required this.totalBalance});

  @override
  List<Object?> get props => [accounts, totalBalance];
}

class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransferSuccess extends AccountState {
  final List<Account> accounts;
  final double totalBalance;

  const TransferSuccess({required this.accounts, required this.totalBalance});

  @override
  List<Object?> get props => [accounts, totalBalance];
}

class TransferError extends AccountState {
  final String message;
  final List<Account> accounts;
  final double totalBalance;

  const TransferError({
    required this.message,
    required this.accounts,
    required this.totalBalance,
  });

  @override
  List<Object?> get props => [message, accounts, totalBalance];
}
