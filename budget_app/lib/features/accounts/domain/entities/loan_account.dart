import 'package:equatable/equatable.dart';
import 'account.dart';

class LoanAccount extends Equatable {
  final Account account;
  final double originalPrincipal;
  final double currentPrincipal;
  final double interestRateApr;
  final double minimumMonthlyPayment;
  final DateTime originationDate;
  final bool isPaidOff;

  const LoanAccount({
    required this.account,
    required this.originalPrincipal,
    required this.currentPrincipal,
    required this.interestRateApr,
    required this.minimumMonthlyPayment,
    required this.originationDate,
    this.isPaidOff = false,
  });

  LoanAccount copyWith({
    Account? account,
    double? originalPrincipal,
    double? currentPrincipal,
    double? interestRateApr,
    double? minimumMonthlyPayment,
    DateTime? originationDate,
    bool? isPaidOff,
  }) {
    return LoanAccount(
      account: account ?? this.account,
      originalPrincipal: originalPrincipal ?? this.originalPrincipal,
      currentPrincipal: currentPrincipal ?? this.currentPrincipal,
      interestRateApr: interestRateApr ?? this.interestRateApr,
      minimumMonthlyPayment: minimumMonthlyPayment ?? this.minimumMonthlyPayment,
      originationDate: originationDate ?? this.originationDate,
      isPaidOff: isPaidOff ?? this.isPaidOff,
    );
  }

  @override
  List<Object?> get props => [
        account,
        originalPrincipal,
        currentPrincipal,
        interestRateApr,
        minimumMonthlyPayment,
        originationDate,
        isPaidOff,
      ];
}
