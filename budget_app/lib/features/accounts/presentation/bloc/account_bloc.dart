import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/accounts/domain/repositories/account_repository.dart';
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
  }

  Future<void> _onLoadAccounts(
    LoadAccounts event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    try {
      final accounts = await _accountRepository.getAllAccounts();
      final totalBalance = await _accountRepository.getTotalBalance();
      emit(AccountLoaded(accounts: accounts, totalBalance: totalBalance));
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
      final accounts = await _accountRepository.getAllAccounts();
      final totalBalance = await _accountRepository.getTotalBalance();
      emit(AccountLoaded(accounts: accounts, totalBalance: totalBalance));
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
      final accounts = await _accountRepository.getAllAccounts();
      final totalBalance = await _accountRepository.getTotalBalance();
      emit(AccountLoaded(accounts: accounts, totalBalance: totalBalance));
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
      final accounts = await _accountRepository.getAllAccounts();
      final totalBalance = await _accountRepository.getTotalBalance();
      emit(AccountLoaded(accounts: accounts, totalBalance: totalBalance));
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
        final accounts = await _accountRepository.getAllAccounts();
        final totalBalance = await _accountRepository.getTotalBalance();
        emit(
          TransferError(
            message: 'Insufficient balance for transfer',
            accounts: accounts,
            totalBalance: totalBalance,
          ),
        );
        return;
      }

      await _accountRepository.createTransfer(
        event.transfer,
        event.fromAccountId,
        event.toAccountId,
      );
      final accounts = await _accountRepository.getAllAccounts();
      final totalBalance = await _accountRepository.getTotalBalance();
      emit(TransferSuccess(accounts: accounts, totalBalance: totalBalance));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }
}
