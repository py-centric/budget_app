import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/domain/entities/loan_account.dart';

class LoanAccountModel extends LoanAccount {
  const LoanAccountModel({
    required super.account,
    required super.originalPrincipal,
    required super.currentPrincipal,
    required super.interestRateApr,
    required super.minimumMonthlyPayment,
    required super.originationDate,
    super.isPaidOff,
  });

  factory LoanAccountModel.fromMap(Account account, Map<String, dynamic> map) {
    return LoanAccountModel(
      account: account,
      originalPrincipal: (map['original_principal'] as num).toDouble(),
      currentPrincipal: (map['current_principal'] as num).toDouble(),
      interestRateApr: (map['interest_rate_apr'] as num).toDouble(),
      minimumMonthlyPayment: (map['minimum_monthly_payment'] as num).toDouble(),
      originationDate: DateTime.fromMillisecondsSinceEpoch(map['origination_date'] as int),
      isPaidOff: (map['is_paid_off'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'account_id': account.id,
      'original_principal': originalPrincipal,
      'current_principal': currentPrincipal,
      'interest_rate_apr': interestRateApr,
      'minimum_monthly_payment': minimumMonthlyPayment,
      'origination_date': originationDate.millisecondsSinceEpoch,
      'is_paid_off': isPaidOff ? 1 : 0,
    };
  }
}
