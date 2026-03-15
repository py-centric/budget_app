import 'dart:math';
import '../entities/amortization_point.dart';
import 'calculate_amortization.dart';

class CalculateCompoundInterest {
  List<AmortizationPoint> call({
    required double initialDeposit,
    required double monthlyContribution,
    required double annualRate,
    required int years,
    InterestType type = InterestType.compound,
  }) {
    if (type == InterestType.simple) {
      return _calculateSimple(initialDeposit, monthlyContribution, annualRate, years);
    }
    return _calculateCompound(initialDeposit, monthlyContribution, annualRate, years);
  }

  List<AmortizationPoint> _calculateSimple(
    double initialDeposit,
    double monthlyContribution,
    double annualRate,
    int years,
  ) {
    final int months = years * 12;
    // Simple interest on principal only
    final double totalInterestOnPrincipal = initialDeposit * (annualRate / 100) * years;
    final double monthlyInterest = totalInterestOnPrincipal / months;
    
    List<AmortizationPoint> schedule = [];
    double currentBalance = initialDeposit;

    for (int i = 1; i <= months; i++) {
      currentBalance += monthlyInterest + monthlyContribution;

      schedule.add(AmortizationPoint(
        month: i,
        principalPaid: monthlyContribution,
        interestPaid: monthlyInterest,
        remainingBalance: currentBalance,
      ));
    }

    return schedule;
  }

  List<AmortizationPoint> _calculateCompound(
    double initialDeposit,
    double monthlyContribution,
    double annualRate,
    int years,
  ) {
    final int months = years * 12;
    final double monthlyRate = annualRate / 12 / 100;
    
    List<AmortizationPoint> schedule = [];
    double currentBalance = initialDeposit;

    for (int i = 1; i <= months; i++) {
      final double interestEarned = currentBalance * monthlyRate;
      currentBalance += interestEarned + monthlyContribution;

      schedule.add(AmortizationPoint(
        month: i,
        principalPaid: monthlyContribution,
        interestPaid: interestEarned,
        remainingBalance: currentBalance,
      ));
    }

    return schedule;
  }

  double calculateFutureValue({
    required double initialDeposit,
    required double monthlyContribution,
    required double annualRate,
    required int years,
    InterestType type = InterestType.compound,
  }) {
    final int months = years * 12;
    
    if (type == InterestType.simple) {
      final double totalInterest = initialDeposit * (annualRate / 100) * years;
      return initialDeposit + totalInterest + (monthlyContribution * months);
    }

    final double monthlyRate = annualRate / 12 / 100;
    if (monthlyRate == 0) return initialDeposit + (monthlyContribution * months);

    final double compoundFactor = pow(1 + monthlyRate, months).toDouble();
    final double futureValuePrincipal = initialDeposit * compoundFactor;
    final double futureValueSeries = monthlyContribution * (compoundFactor - 1) / monthlyRate;

    return futureValuePrincipal + futureValueSeries;
  }
}
