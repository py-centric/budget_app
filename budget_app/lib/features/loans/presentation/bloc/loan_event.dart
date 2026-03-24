import 'package:equatable/equatable.dart';
import 'package:budget_app/features/loans/domain/entities/loan.dart';
import 'package:budget_app/features/loans/domain/entities/loan_payment.dart';

abstract class LoanEvent extends Equatable {
  const LoanEvent();

  @override
  List<Object?> get props => [];
}

class LoadLoans extends LoanEvent {
  const LoadLoans();
}

class AddLoan extends LoanEvent {
  final Loan loan;

  const AddLoan(this.loan);

  @override
  List<Object?> get props => [loan];
}

class UpdateLoan extends LoanEvent {
  final Loan loan;

  const UpdateLoan(this.loan);

  @override
  List<Object?> get props => [loan];
}

class DeleteLoan extends LoanEvent {
  final String id;

  const DeleteLoan(this.id);

  @override
  List<Object?> get props => [id];
}

class AddPayment extends LoanEvent {
  final LoanPayment payment;

  const AddPayment(this.payment);

  @override
  List<Object?> get props => [payment];
}

class DeletePayment extends LoanEvent {
  final String id;
  final String loanId;

  const DeletePayment(this.id, this.loanId);

  @override
  List<Object?> get props => [id, loanId];
}

class LoadLoanSummary extends LoanEvent {
  const LoadLoanSummary();
}

class LoadLoanPayments extends LoanEvent {
  final String loanId;

  const LoadLoanPayments(this.loanId);

  @override
  List<Object?> get props => [loanId];
}
