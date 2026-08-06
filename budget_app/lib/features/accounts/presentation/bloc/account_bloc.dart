import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/accounts/domain/repositories/account_repository.dart';
import 'package:budget_app/features/accounts/domain/entities/account_transaction.dart';
import 'package:budget_app/features/accounts/domain/usecases/calculate_net_worth.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_event.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository _accountRepository;

  AccountBloc(this._accountRepository) : super(AccountInitial()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<AddAccount>(_onAddAccount);
    on<UpdateAccount>(_onUpdateAccount);
    on<DeleteAccount>(_onDeleteAccount);
    on<CreateTransfer>(_onCreateTransfer);
    on<CreateLoanAccountEvent>(_onCreateLoanAccount);
    on<CreateSavingsAccountEvent>(_onCreateSavingsAccount);
    on<CreateInvestmentPortfolioEvent>(_onCreateInvestmentPortfolio);
    on<LogAccountTransactionEvent>(_onLogAccountTransaction);
  }

  Future<AccountLoaded> _fetchAccountLoadedState() async {
    final accounts = await _accountRepository.getAllAccounts();
    final loanAccounts = await _accountRepository.getLoanAccounts();
    final savingsAccounts = await _accountRepository.getSavingsAccounts();
    final investmentPortfolios = await _accountRepository.getInvestmentPortfolios();
    final totalBalance = await _accountRepository.getTotalBalance();

    final netWorthSummary = CalculateNetWorth.calculate(
      accounts: accounts,
      loanAccounts: loanAccounts,
    );

    return AccountLoaded(
      accounts: accounts,
      loanAccounts: loanAccounts,
      savingsAccounts: savingsAccounts,
      investmentPortfolios: investmentPortfolios,
      netWorthSummary: netWorthSummary,
      totalBalance: totalBalance,
    );
  }

  Future<void> _onLoadAccounts(
    LoadAccounts event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    try {
      final loadedState = await _fetchAccountLoadedState();
      emit(loadedState);
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onAddAccount(
    AddAccount event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await _accountRepository.createAccount(event.account);
      final loadedState = await _fetchAccountLoadedState();
      emit(loadedState);
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onUpdateAccount(
    UpdateAccount event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await _accountRepository.updateAccount(event.account);
      final loadedState = await _fetchAccountLoadedState();
      emit(loadedState);
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await _accountRepository.deleteAccount(event.accountId);
      final loadedState = await _fetchAccountLoadedState();
      emit(loadedState);
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onCreateTransfer(
    CreateTransfer event,
    Emitter<AccountState> emit,
  ) async {
    try {
      final fromAccount = await _accountRepository.getAccount(
        event.fromAccountId,
      );
      if (fromAccount != null && fromAccount.balance < event.transfer.amount) {
        final loadedState = await _fetchAccountLoadedState();
        emit(
          TransferError(
            message: 'Insufficient balance for transfer',
            accounts: loadedState.accounts,
            totalBalance: loadedState.totalBalance,
          ),
        );
        return;
      }

      await _accountRepository.createTransfer(
        event.transfer,
        event.fromAccountId,
        event.toAccountId,
      );
      final loadedState = await _fetchAccountLoadedState();
      emit(TransferSuccess(accounts: loadedState.accounts, totalBalance: loadedState.totalBalance));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onCreateLoanAccount(
    CreateLoanAccountEvent event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await _accountRepository.saveLoanAccount(event.loanAccount);
      final loadedState = await _fetchAccountLoadedState();
      emit(loadedState);
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onCreateSavingsAccount(
    CreateSavingsAccountEvent event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await _accountRepository.saveSavingsAccount(event.savingsAccount);
      final loadedState = await _fetchAccountLoadedState();
      emit(loadedState);
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onCreateInvestmentPortfolio(
    CreateInvestmentPortfolioEvent event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await _accountRepository.saveInvestmentPortfolio(event.portfolio);
      final loadedState = await _fetchAccountLoadedState();
      emit(loadedState);
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onLogAccountTransaction(
    LogAccountTransactionEvent event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await _accountRepository.addAccountTransaction(event.transaction);

      // Update associated loan or savings balance
      final tx = event.transaction;
      if (tx.type == AccountTransactionType.repayment) {
        final loans = await _accountRepository.getLoanAccounts();
        final loanIndex = loans.indexWhere((l) => l.account.id == tx.accountId);
        if (loanIndex != -1) {
          final loan = loans[loanIndex];
          final newPrincipal = (loan.currentPrincipal - tx.amount).clamp(0.0, double.infinity);
          final updatedLoan = loan.copyWith(
            currentPrincipal: newPrincipal,
            isPaidOff: newPrincipal == 0.0,
            account: loan.account.copyWith(
              balance: -newPrincipal,
              updatedAt: DateTime.now(),
            ),
          );
          await _accountRepository.updateLoanAccount(updatedLoan);
        }
      } else if (tx.type == AccountTransactionType.contribution || tx.type == AccountTransactionType.deposit) {
        final savings = await _accountRepository.getSavingsAccounts();
        final savingsIndex = savings.indexWhere((s) => s.account.id == tx.accountId);
        if (savingsIndex != -1) {
          final sav = savings[savingsIndex];
          final newBalance = sav.account.balance + tx.amount;
          final updatedSav = sav.copyWith(
            totalContributions: sav.totalContributions + tx.amount,
            account: sav.account.copyWith(
              balance: newBalance,
              updatedAt: DateTime.now(),
            ),
          );
          await _accountRepository.updateSavingsAccount(updatedSav);
        }
      }

      final loadedState = await _fetchAccountLoadedState();
      emit(loadedState);
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }
}
