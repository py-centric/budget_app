import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/domain/entities/savings_account.dart';

class SavingsAccountModel extends SavingsAccount {
  const SavingsAccountModel({
    required super.account,
    required super.interestRateApy,
    super.compoundingFrequency,
    super.targetGoalAmount,
    super.totalContributions,
  });

  factory SavingsAccountModel.fromMap(Account account, Map<String, dynamic> map) {
    return SavingsAccountModel(
      account: account,
      interestRateApy: (map['interest_rate_apy'] as num).toDouble(),
      compoundingFrequency: CompoundingFrequency.fromString(map['compounding_frequency'] as String? ?? 'monthly'),
      targetGoalAmount: map['target_goal_amount'] != null ? (map['target_goal_amount'] as num).toDouble() : null,
      totalContributions: (map['total_contributions'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'account_id': account.id,
      'interest_rate_apy': interestRateApy,
      'compounding_frequency': compoundingFrequency.name,
      'target_goal_amount': targetGoalAmount,
      'total_contributions': totalContributions,
    };
  }
}
