import 'package:equatable/equatable.dart';
import 'package:budget_app/features/loans/domain/entities/loan.dart';
import 'package:budget_app/features/loans/domain/entities/loan_payment.dart';
import 'package:budget_app/features/loans/domain/entities/loan_summary.dart';

abstract class LoanState extends Equatable {
  const LoanState();

  @override
  List<Object?> get props => [];
}

class LoanInitial extends LoanState {
  const LoanInitial();
}

class LoanLoading extends LoanState {
  const LoanLoading();
}

class LoanLoaded extends LoanState {
  final List<Loan> loans;
  final LoanSummary? summary;
  final List<LoanPayment>? currentPayments;
  final String? currentLoanId;

  const LoanLoaded({
    required this.loans,
    this.summary,
    this.currentPayments,
    this.currentLoanId,
  });

  LoanLoaded copyWith({
    List<Loan>? loans,
    LoanSummary? summary,
    List<LoanPayment>? currentPayments,
    String? currentLoanId,
  }) {
    return LoanLoaded(
      loans: loans ?? this.loans,
      summary: summary ?? this.summary,
      currentPayments: currentPayments ?? this.currentPayments,
      currentLoanId: currentLoanId ?? this.currentLoanId,
    );
  }

  @override
  List<Object?> get props => [loans, summary, currentPayments, currentLoanId];
}

class LoanError extends LoanState {
  final String message;

  const LoanError(this.message);

  @override
  List<Object?> get props => [message];
}
