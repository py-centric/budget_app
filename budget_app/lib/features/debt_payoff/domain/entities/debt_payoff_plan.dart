import 'package:equatable/equatable.dart';

enum PayoffStrategy { snowball, avalanche, custom }

class DebtPayoffPlan extends Equatable {
  final PayoffStrategy strategy;
  final List<DebtPayoffItem> debts;
  final double monthlyPayment;
  final int totalMonths;
  final double totalInterest;
  final double totalPaid;

  const DebtPayoffPlan({
    required this.strategy,
    required this.debts,
    required this.monthlyPayment,
    required this.totalMonths,
    required this.totalInterest,
    required this.totalPaid,
  });

  @override
  List<Object?> get props => [strategy, debts, monthlyPayment, totalMonths, totalInterest, totalPaid];
}

class DebtPayoffItem extends Equatable {
  final String name;
  final double balance;
  final double apr;
  final double minimumPayment;
  final int payoffOrder;
  final int monthsToPayoff;
  final double interestPaid;

  const DebtPayoffItem({
    required this.name,
    required this.balance,
    required this.apr,
    required this.minimumPayment,
    required this.payoffOrder,
    required this.monthsToPayoff,
    required this.interestPaid,
  });

  @override
  List<Object?> get props => [name, balance, apr, minimumPayment, payoffOrder, monthsToPayoff, interestPaid];
}
