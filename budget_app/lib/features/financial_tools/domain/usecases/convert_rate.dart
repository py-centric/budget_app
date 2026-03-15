import 'dart:math';

class RateConverter {
  /// Converts Simple Interest Rate to Effective Annual Rate (Compound).
  /// EAR = (1 + r/n)^n - 1
  double simpleToCompound({
    required double simpleRate,
    int compoundingPeriodsPerYear = 12,
  }) {
    final r = simpleRate / 100;
    final n = compoundingPeriodsPerYear;
    return (pow(1 + r / n, n) - 1) * 100;
  }

  /// Converts Effective Annual Rate (Compound) to Simple Interest Rate.
  /// Simple = n * ((1 + EAR)^(1/n) - 1)
  double compoundToSimple({
    required double compoundRate,
    int compoundingPeriodsPerYear = 12,
  }) {
    final ear = compoundRate / 100;
    final n = compoundingPeriodsPerYear;
    return n * (pow(1 + ear, 1 / n) - 1) * 100;
  }

  double calculateSimpleInterestTotal({
    required double principal,
    required double annualRate,
    required double years,
  }) {
    return principal * (annualRate / 100) * years;
  }
}
