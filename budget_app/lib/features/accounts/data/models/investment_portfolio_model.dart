import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/domain/entities/investment_portfolio.dart';

class InvestmentPortfolioModel extends InvestmentPortfolio {
  const InvestmentPortfolioModel({
    required super.account,
    required super.totalMarketValue,
    super.totalDeposited,
    super.totalWithdrawn,
    super.targetAnnualReturnRate,
  });

  factory InvestmentPortfolioModel.fromMap(Account account, Map<String, dynamic> map) {
    return InvestmentPortfolioModel(
      account: account,
      totalMarketValue: (map['total_market_value'] as num).toDouble(),
      totalDeposited: (map['total_deposited'] as num? ?? 0.0).toDouble(),
      totalWithdrawn: (map['total_withdrawn'] as num? ?? 0.0).toDouble(),
      targetAnnualReturnRate: (map['target_annual_return_rate'] as num? ?? 7.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'account_id': account.id,
      'total_market_value': totalMarketValue,
      'total_deposited': totalDeposited,
      'total_withdrawn': totalWithdrawn,
      'target_annual_return_rate': targetAnnualReturnRate,
    };
  }
}
