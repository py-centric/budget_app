import 'package:equatable/equatable.dart';
import 'account.dart';

enum CompoundingFrequency {
  daily,
  monthly,
  annually;

  static CompoundingFrequency fromString(String value) {
    return CompoundingFrequency.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CompoundingFrequency.monthly,
    );
  }
}

class SavingsAccount extends Equatable {
  final Account account;
  final double interestRateApy;
  final CompoundingFrequency compoundingFrequency;
  final double? targetGoalAmount;
  final double totalContributions;

  const SavingsAccount({
    required this.account,
    required this.interestRateApy,
    this.compoundingFrequency = CompoundingFrequency.monthly,
    this.targetGoalAmount,
    this.totalContributions = 0.0,
  });

  SavingsAccount copyWith({
    Account? account,
    double? interestRateApy,
    CompoundingFrequency? compoundingFrequency,
    double? targetGoalAmount,
    double? totalContributions,
  }) {
    return SavingsAccount(
      account: account ?? this.account,
      interestRateApy: interestRateApy ?? this.interestRateApy,
      compoundingFrequency: compoundingFrequency ?? this.compoundingFrequency,
      targetGoalAmount: targetGoalAmount ?? this.targetGoalAmount,
      totalContributions: totalContributions ?? this.totalContributions,
    );
  }

  @override
  List<Object?> get props => [
        account,
        interestRateApy,
        compoundingFrequency,
        targetGoalAmount,
        totalContributions,
      ];
}
