import 'dart:math';

class InterestRateSolver {
  /// Solves for interest rate `r` given Principal `P`, months `n`, and payment `M`.
  /// Uses Newton-Raphson iteration.
  double solve({
    required double principal,
    required int months,
    required double monthlyPayment,
    double guess = 0.01, // 1% per month guess
  }) {
    if (monthlyPayment <= principal / months) return 0.0;

    double r = guess;
    const double tolerance = 0.0000001;
    const int maxIterations = 100;

    for (int i = 0; i < maxIterations; i++) {
      // Formula: M = P * r * (1+r)^n / ((1+r)^n - 1)
      // We want to solve f(r) = P * r * (1+r)^n - M * ((1+r)^n - 1) = 0
      
      double rn = pow(1 + r, months).toDouble();
      double rnm1 = pow(1 + r, months - 1).toDouble();
      
      double f = principal * r * rn - monthlyPayment * (rn - 1);
      
      // Derivative f'(r)
      double df = principal * (rn + months * r * rnm1) - monthlyPayment * months * rnm1;
      
      double newR = r - f / df;
      
      if ((newR - r).abs() < tolerance) {
        return newR * 12 * 100; // Return annual percentage
      }
      
      r = newR;
    }

    return r * 12 * 100;
  }
}
