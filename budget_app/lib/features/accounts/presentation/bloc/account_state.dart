import 'package:equatable/equatable.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/domain/entities/loan_account.dart';
import 'package:budget_app/features/accounts/domain/entities/savings_account.dart';
import 'package:budget_app/features/accounts/domain/entities/investment_portfolio.dart';
import 'package:budget_app/features/accounts/domain/usecases/calculate_net_worth.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final List<Account> accounts;
  final List<LoanAccount> loanAccounts;
  final List<SavingsAccount> savingsAccounts;
  final List<InvestmentPortfolio> investmentPortfolios;
  final NetWorthSummary netWorthSummary;
  final double totalBalance;

  const AccountLoaded({
    required this.accounts,
    this.loanAccounts = const [],
    this.savingsAccounts = const [],
    this.investmentPortfolios = const [],
    this.netWorthSummary = const NetWorthSummary(
      totalAssets: 0.0,
      totalLiabilities: 0.0,
      netWorth: 0.0,
    ),
    required this.totalBalance,
  });

  @override
  List<Object?> get props => [
        accounts,
        loanAccounts,
        savingsAccounts,
        investmentPortfolios,
        netWorthSummary,
        totalBalance,
      ];
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
