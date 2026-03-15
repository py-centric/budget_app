import 'package:equatable/equatable.dart';

class AmortizationPoint extends Equatable {
  final int month;
  final double principalPaid;
  final double interestPaid;
  final double remainingBalance;

  const AmortizationPoint({
    required this.month,
    required this.principalPaid,
    required this.interestPaid,
    required this.remainingBalance,
  });

  @override
  List<Object?> get props => [month, principalPaid, interestPaid, remainingBalance];
}
