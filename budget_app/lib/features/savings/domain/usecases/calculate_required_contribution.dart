import 'dart:math';

class CalculateRequiredContribution {
  double call({
    required double targetAmount,
    double currentAmount = 0,
    required double annualRate,
    required int years,
    int months = 0,
  }) {
    final totalMonths = years * 12 + months;
    if (totalMonths <= 0) return 0;
    if (targetAmount <= currentAmount) return 0;

    final monthlyRate = annualRate / 12 / 100;

    if (monthlyRate == 0) {
      return (targetAmount - currentAmount) / totalMonths;
    }

    final compoundFactor = pow(1 + monthlyRate, totalMonths).toDouble();
    return (targetAmount - currentAmount * compoundFactor) * monthlyRate /
        (compoundFactor - 1);
  }
}
