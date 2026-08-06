import 'package:equatable/equatable.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/domain/entities/loan_account.dart';

class NetWorthSummary extends Equatable {
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;

  const NetWorthSummary({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
  });

  @override
  List<Object?> get props => [totalAssets, totalLiabilities, netWorth];
}

class CalculateNetWorth {
  static NetWorthSummary calculate({
    required List<Account> accounts,
    required List<LoanAccount> loanAccounts,
  }) {
    var assets = 0.0;
    var liabilities = 0.0;

    for (final account in accounts) {
      if (account.type == AccountType.loan) {
        // Handled via loanAccounts list for accurate remaining principal
        continue;
      }
      assets += account.balance;
    }

    for (final loan in loanAccounts) {
      liabilities += loan.currentPrincipal;
    }

    return NetWorthSummary(
      totalAssets: assets,
      totalLiabilities: liabilities,
      netWorth: assets - liabilities,
    );
  }
}
