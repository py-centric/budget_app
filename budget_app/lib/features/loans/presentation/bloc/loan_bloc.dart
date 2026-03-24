import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/loans/domain/repositories/loan_repository.dart';
import 'package:budget_app/features/loans/presentation/bloc/loan_event.dart';
import 'package:budget_app/features/loans/presentation/bloc/loan_state.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final LoanRepository _loanRepository;

  LoanBloc(this._loanRepository) : super(const LoanInitial()) {
    on<LoadLoans>(_onLoadLoans);
    on<AddLoan>(_onAddLoan);
    on<UpdateLoan>(_onUpdateLoan);
    on<DeleteLoan>(_onDeleteLoan);
    on<AddPayment>(_onAddPayment);
    on<DeletePayment>(_onDeletePayment);
    on<LoadLoanSummary>(_onLoadLoanSummary);
    on<LoadLoanPayments>(_onLoadLoanPayments);
  }

  Future<void> _onLoadLoans(LoadLoans event, Emitter<LoanState> emit) async {
    emit(const LoanLoading());
    try {
      final loans = await _loanRepository.getLoans();
      final summary = await _loanRepository.getLoanSummary();
      emit(LoanLoaded(loans: loans, summary: summary));
    } catch (e) {
      emit(LoanError(e.toString()));
    }
  }

  Future<void> _onAddLoan(AddLoan event, Emitter<LoanState> emit) async {
    try {
      await _loanRepository.saveLoan(event.loan);
      final loans = await _loanRepository.getLoans();
      final summary = await _loanRepository.getLoanSummary();
      emit(LoanLoaded(loans: loans, summary: summary));
    } catch (e) {
      emit(LoanError(e.toString()));
    }
  }

  Future<void> _onUpdateLoan(UpdateLoan event, Emitter<LoanState> emit) async {
    try {
      await _loanRepository.saveLoan(event.loan);
      final loans = await _loanRepository.getLoans();
      final summary = await _loanRepository.getLoanSummary();
      emit(LoanLoaded(loans: loans, summary: summary));
    } catch (e) {
      emit(LoanError(e.toString()));
    }
  }

  Future<void> _onDeleteLoan(DeleteLoan event, Emitter<LoanState> emit) async {
    try {
      await _loanRepository.deleteLoan(event.id);
      final loans = await _loanRepository.getLoans();
      final summary = await _loanRepository.getLoanSummary();
      emit(LoanLoaded(loans: loans, summary: summary));
    } catch (e) {
      emit(LoanError(e.toString()));
    }
  }

  Future<void> _onAddPayment(AddPayment event, Emitter<LoanState> emit) async {
    try {
      await _loanRepository.savePayment(event.payment);
      final loans = await _loanRepository.getLoans();
      final summary = await _loanRepository.getLoanSummary();

      final currentState = state;
      if (currentState is LoanLoaded && currentState.currentLoanId != null) {
        final payments = await _loanRepository.getPaymentsForLoan(
          currentState.currentLoanId!,
        );
        emit(
          LoanLoaded(
            loans: loans,
            summary: summary,
            currentPayments: payments,
            currentLoanId: currentState.currentLoanId,
          ),
        );
      } else {
        emit(LoanLoaded(loans: loans, summary: summary));
      }
    } catch (e) {
      emit(LoanError(e.toString()));
    }
  }

  Future<void> _onDeletePayment(
    DeletePayment event,
    Emitter<LoanState> emit,
  ) async {
    try {
      await _loanRepository.deletePayment(event.id);
      final loans = await _loanRepository.getLoans();
      final summary = await _loanRepository.getLoanSummary();

      final payments = await _loanRepository.getPaymentsForLoan(event.loanId);
      emit(
        LoanLoaded(
          loans: loans,
          summary: summary,
          currentPayments: payments,
          currentLoanId: event.loanId,
        ),
      );
    } catch (e) {
      emit(LoanError(e.toString()));
    }
  }

  Future<void> _onLoadLoanSummary(
    LoadLoanSummary event,
    Emitter<LoanState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is LoanLoaded) {
        final summary = await _loanRepository.getLoanSummary();
        emit(currentState.copyWith(summary: summary));
      }
    } catch (e) {
      emit(LoanError(e.toString()));
    }
  }

  Future<void> _onLoadLoanPayments(
    LoadLoanPayments event,
    Emitter<LoanState> emit,
  ) async {
    try {
      final payments = await _loanRepository.getPaymentsForLoan(event.loanId);
      final currentState = state;
      if (currentState is LoanLoaded) {
        emit(
          currentState.copyWith(
            currentPayments: payments,
            currentLoanId: event.loanId,
          ),
        );
      }
    } catch (e) {
      emit(LoanError(e.toString()));
    }
  }
}
