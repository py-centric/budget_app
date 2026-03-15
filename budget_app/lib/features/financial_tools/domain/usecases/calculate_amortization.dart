import 'dart:math';
import '../entities/amortization_point.dart';

enum InterestType { simple, compound }

class CalculateAmortization {
  List<AmortizationPoint> call({
    required double principal,
    required double annualRate,
    required int years,
    InterestType type = InterestType.compound,
  }) {
    if (type == InterestType.simple) {
      return _calculateSimple(principal, annualRate, years);
    }
    return _calculateCompound(principal, annualRate, years);
  }

  List<AmortizationPoint> _calculateSimple(double principal, double annualRate, int years) {
    final int months = years * 12;
    final double totalInterest = principal * (annualRate / 100) * years;
    final double monthlyInterest = totalInterest / months;
    final double monthlyPrincipal = principal / months;

    List<AmortizationPoint> schedule = [];
    double currentBalance = principal;

    for (int i = 1; i <= months; i++) {
      currentBalance -= monthlyPrincipal;
      schedule.add(AmortizationPoint(
        month: i,
        principalPaid: monthlyPrincipal,
        interestPaid: monthlyInterest,
        remainingBalance: max(0, currentBalance),
      ));
    }
    return schedule;
  }

  List<AmortizationPoint> _calculateCompound(double principal, double annualRate, int years) {
    final int months = years * 12;
    final double monthlyRate = annualRate / 12 / 100;
    
    if (monthlyRate == 0) {
      return List.generate(months, (index) {
        final month = index + 1;
        final repayment = principal / months;
        return AmortizationPoint(
          month: month,
          principalPaid: repayment,
          interestPaid: 0,
          remainingBalance: principal - (repayment * month),
        );
      });
    }

    final double monthlyPayment = (principal * monthlyRate * pow(1 + monthlyRate, months)) /
        (pow(1 + monthlyRate, months) - 1);

    List<AmortizationPoint> schedule = [];
    double currentBalance = principal;

    for (int i = 1; i <= months; i++) {
      final double interestPaid = currentBalance * monthlyRate;
      final double principalPaid = monthlyPayment - interestPaid;
      currentBalance -= principalPaid;

      schedule.add(AmortizationPoint(
        month: i,
        principalPaid: principalPaid,
        interestPaid: interestPaid,
        remainingBalance: max(0, currentBalance),
      ));
    }

    return schedule;
  }

  double calculateMonthlyPayment({
    required double principal,
    required double annualRate,
    required int years,
    InterestType type = InterestType.compound,
  }) {
    final int months = years * 12;
    if (type == InterestType.simple) {
      final double totalInterest = principal * (annualRate / 100) * years;
      return (principal + totalInterest) / months;
    }

    final double monthlyRate = annualRate / 12 / 100;
    if (monthlyRate == 0) return principal / months;

    return (principal * monthlyRate * pow(1 + monthlyRate, months)) /
        (pow(1 + monthlyRate, months) - 1);
  }

  int calculateReducedTerm({
    required double principal,
    required double annualRate,
    required double monthlyPayment,
  }) {
    final double monthlyRate = annualRate / 12 / 100;
    if (monthlyRate == 0) return (principal / monthlyPayment).ceil();

    // Formula: n = -log(1 - (r*P)/M) / log(1 + r)
    try {
      final double inner = 1 - (monthlyRate * principal / monthlyPayment);
      if (inner <= 0) return 999; // Never paid off at this rate
      final double n = -log(inner) / log(1 + monthlyRate);
      return n.ceil();
    } catch (_) {
      return 999;
    }
  }
}
