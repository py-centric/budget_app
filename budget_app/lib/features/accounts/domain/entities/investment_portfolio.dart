import 'package:equatable/equatable.dart';
import 'account.dart';

class InvestmentPortfolio extends Equatable {
  final Account account;
  final double totalMarketValue;
  final double totalDeposited;
  final double totalWithdrawn;
  final double targetAnnualReturnRate;

  const InvestmentPortfolio({
    required this.account,
    required this.totalMarketValue,
    this.totalDeposited = 0.0,
    this.totalWithdrawn = 0.0,
    this.targetAnnualReturnRate = 7.0,
  });

  InvestmentPortfolio copyWith({
    Account? account,
    double? totalMarketValue,
    double? totalDeposited,
    double? totalWithdrawn,
    double? targetAnnualReturnRate,
  }) {
    return InvestmentPortfolio(
      account: account ?? this.account,
      totalMarketValue: totalMarketValue ?? this.totalMarketValue,
      totalDeposited: totalDeposited ?? this.totalDeposited,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      targetAnnualReturnRate: targetAnnualReturnRate ?? this.targetAnnualReturnRate,
    );
  }

  @override
  List<Object?> get props => [
        account,
        totalMarketValue,
        totalDeposited,
        totalWithdrawn,
        targetAnnualReturnRate,
      ];
}
