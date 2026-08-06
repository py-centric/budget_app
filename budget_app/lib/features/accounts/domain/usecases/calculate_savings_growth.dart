import 'package:equatable/equatable.dart';
import 'dart:math';

class SavingsProjection extends Equatable {
  final double finalBalance;
  final double totalContributions;
  final double totalInterestEarned;

  const SavingsProjection({
    required this.finalBalance,
    required this.totalContributions,
    required this.totalInterestEarned,
  });

  @override
  List<Object?> get props => [
        finalBalance,
        totalContributions,
        totalInterestEarned,
      ];
}

class SavingsGrowthCalculator {
  static SavingsProjection calculateProjectedGrowth({
    required double initialBalance,
    required double monthlyContribution,
    required double annualInterestRateApy,
    required int durationInMonths,
  }) {
    if (initialBalance < 0 || durationInMonths <= 0) {
      return SavingsProjection(
        finalBalance: max(0.0, initialBalance),
        totalContributions: 0.0,
        totalInterestEarned: 0.0,
      );
    }

    final monthlyRate = (annualInterestRateApy / 100) / 12;
    var currentBalance = initialBalance;
    var totalContrib = initialBalance;

    for (var m = 1; m <= durationInMonths; m++) {
      currentBalance += monthlyContribution;
      totalContrib += monthlyContribution;
      final interestThisMonth = currentBalance * monthlyRate;
      currentBalance += interestThisMonth;
    }

    final interestEarned = currentBalance - totalContrib;

    return SavingsProjection(
      finalBalance: currentBalance,
      totalContributions: totalContrib,
      totalInterestEarned: max(0.0, interestEarned),
    );
  }
}
