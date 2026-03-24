import '../entities/loan.dart';
import '../entities/loan_payment.dart';
import '../entities/loan_summary.dart';

abstract class LoanRepository {
  Future<List<Loan>> getLoans();
  Future<Loan?> getLoanById(String id);
  Future<void> saveLoan(Loan loan);
  Future<void> deleteLoan(String id);
  Future<LoanSummary> getLoanSummary();

  Future<List<Loan>> getLoansByDirection(LoanDirection direction);
  Future<List<Loan>> getLoansWithProjectionsEnabled();

  Future<List<LoanPayment>> getPaymentsForLoan(String loanId);
  Future<void> savePayment(LoanPayment payment);
  Future<void> deletePayment(String id);
  Future<double> getTotalPaymentsForLoan(String loanId);
}
