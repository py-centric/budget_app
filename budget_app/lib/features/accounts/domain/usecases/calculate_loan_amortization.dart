import 'package:equatable/equatable.dart';

class MonthlyPaymentBreakdown extends Equatable {
  final int monthNumber;
  final double paymentAmount;
  final double principalPaid;
  final double interestPaid;
  final double remainingBalance;

  const MonthlyPaymentBreakdown({
    required this.monthNumber,
    required this.paymentAmount,
    required this.principalPaid,
    required this.interestPaid,
    required this.remainingBalance,
  });

  @override
  List<Object?> get props => [
        monthNumber,
        paymentAmount,
        principalPaid,
        interestPaid,
        remainingBalance,
      ];
}

class AmortizationSchedule extends Equatable {
  final double monthlyPayment;
  final double totalInterestPaid;
  final int totalMonthsToPayoff;
  final List<MonthlyPaymentBreakdown> schedule;

  const AmortizationSchedule({
    required this.monthlyPayment,
    required this.totalInterestPaid,
    required this.totalMonthsToPayoff,
    required this.schedule,
  });

  @override
  List<Object?> get props => [
        monthlyPayment,
        totalInterestPaid,
        totalMonthsToPayoff,
        schedule,
      ];
}

class LoanAmortizationCalculator {
  static AmortizationSchedule calculate({
    required double principal,
    required double annualInterestRateApr,
    required double monthlyPayment,
  }) {
    if (principal <= 0 || monthlyPayment <= 0) {
      return const AmortizationSchedule(
        monthlyPayment: 0.0,
        totalInterestPaid: 0.0,
        totalMonthsToPayoff: 0,
        schedule: [],
      );
    }

    final monthlyRate = (annualInterestRateApr / 100) / 12;
    var currentBalance = principal;
    var totalInterest = 0.0;
    var month = 0;
    final schedule = <MonthlyPaymentBreakdown>[];

    // Cap at 360 months (30 years) to prevent infinite loops
    while (currentBalance > 0.01 && month < 360) {
      month++;
      final monthlyInterest = currentBalance * monthlyRate;
      var principalPaid = monthlyPayment - monthlyInterest;

      if (principalPaid <= 0) {
        // Payment doesn't cover interest
        break;
      }

      if (principalPaid > currentBalance) {
        principalPaid = currentBalance;
      }

      final actualPayment = principalPaid + monthlyInterest;
      currentBalance -= principalPaid;
      totalInterest += monthlyInterest;

      schedule.add(
        MonthlyPaymentBreakdown(
          monthNumber: month,
          paymentAmount: actualPayment,
          principalPaid: principalPaid,
          interestPaid: monthlyInterest,
          remainingBalance: currentBalance < 0.01 ? 0.0 : currentBalance,
        ),
      );
    }

    return AmortizationSchedule(
      monthlyPayment: monthlyPayment,
      totalInterestPaid: totalInterest,
      totalMonthsToPayoff: month,
      schedule: schedule,
    );
  }
}
