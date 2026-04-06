import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/domain/entities/transfer.dart';
import 'package:budget_app/features/accounts/domain/repositories/account_repository.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_event.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_state.dart';

class MockAccountRepository extends Mock implements AccountRepository {}

class FakeAccount extends Fake implements Account {}

class FakeTransfer extends Fake implements Transfer {}

void main() {
  late AccountBloc accountBloc;
  late MockAccountRepository mockRepository;

  final testAccount = Account(
    id: '1',
    name: 'Test Account',
    type: AccountType.checking,
    balance: 1000.0,
    currency: 'USD',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final testAccounts = [testAccount];

  setUpAll(() {
    registerFallbackValue(FakeAccount());
    registerFallbackValue(FakeTransfer());
  });

  setUp(() {
    mockRepository = MockAccountRepository();
    accountBloc = AccountBloc(mockRepository);
  });

  tearDown(() {
    accountBloc.close();
  });

  group('AccountBloc', () {
    test('initial state is AccountInitial', () {
      expect(accountBloc.state, AccountInitial());
    });

    group('LoadAccounts', () {
      blocTest<AccountBloc, AccountState>(
        'emits [AccountLoading, AccountLoaded] when LoadAccounts is added',
        build: () {
          when(
            () => mockRepository.getAllAccounts(),
          ).thenAnswer((_) async => testAccounts);
          when(
            () => mockRepository.getTotalBalance(),
          ).thenAnswer((_) async => 1000.0);
          return accountBloc;
        },
        act: (bloc) => bloc.add(LoadAccounts()),
        expect: () => [
          AccountLoading(),
          AccountLoaded(accounts: testAccounts, totalBalance: 1000.0),
        ],
      );

      blocTest<AccountBloc, AccountState>(
        'emits [AccountLoading, AccountError] when LoadAccounts fails',
        build: () {
          when(
            () => mockRepository.getAllAccounts(),
          ).thenThrow(Exception('Database error'));
          return accountBloc;
        },
        act: (bloc) => bloc.add(LoadAccounts()),
        expect: () => [AccountLoading(), isA<AccountError>()],
      );
    });

    group('AddAccount', () {
      blocTest<AccountBloc, AccountState>(
        'emits [AccountLoaded] when AddAccount succeeds',
        build: () {
          when(
            () => mockRepository.createAccount(any()),
          ).thenAnswer((_) async {});
          when(
            () => mockRepository.getAllAccounts(),
          ).thenAnswer((_) async => testAccounts);
          when(
            () => mockRepository.getTotalBalance(),
          ).thenAnswer((_) async => 1000.0);
          return accountBloc;
        },
        act: (bloc) => bloc.add(AddAccount(testAccount)),
        expect: () => [
          AccountLoaded(accounts: testAccounts, totalBalance: 1000.0),
        ],
      );
    });

    group('DeleteAccount', () {
      blocTest<AccountBloc, AccountState>(
        'emits [AccountLoaded] when DeleteAccount succeeds',
        build: () {
          when(
            () => mockRepository.deleteAccount(any()),
          ).thenAnswer((_) async {});
          when(
            () => mockRepository.getAllAccounts(),
          ).thenAnswer((_) async => []);
          when(
            () => mockRepository.getTotalBalance(),
          ).thenAnswer((_) async => 0.0);
          return accountBloc;
        },
        act: (bloc) => bloc.add(const DeleteAccount('1')),
        expect: () => [AccountLoaded(accounts: const [], totalBalance: 0.0)],
      );
    });

    group('CreateTransfer', () {
      final testTransfer = Transfer(
        id: 't1',
        fromAccountId: '1',
        toAccountId: '2',
        amount: 100.0,
        date: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
      );

      blocTest<AccountBloc, AccountState>(
        'emits [TransferSuccess] when CreateTransfer succeeds',
        build: () {
          when(
            () => mockRepository.getAccount(any()),
          ).thenAnswer((_) async => testAccount);
          when(
            () => mockRepository.createTransfer(any(), any(), any()),
          ).thenAnswer((_) async {});
          when(
            () => mockRepository.getAllAccounts(),
          ).thenAnswer((_) async => testAccounts);
          when(
            () => mockRepository.getTotalBalance(),
          ).thenAnswer((_) async => 1000.0);
          return accountBloc;
        },
        act: (bloc) => bloc.add(
          CreateTransfer(
            transfer: testTransfer,
            fromAccountId: '1',
            toAccountId: '2',
          ),
        ),
        expect: () => [isA<TransferSuccess>()],
      );

      blocTest<AccountBloc, AccountState>(
        'emits [TransferError] when insufficient balance',
        build: () {
          final lowBalanceAccount = Account(
            id: '1',
            name: 'Test',
            type: AccountType.checking,
            balance: 50.0,
            currency: 'USD',
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          );
          when(
            () => mockRepository.getAccount(any()),
          ).thenAnswer((_) async => lowBalanceAccount);
          when(
            () => mockRepository.getAllAccounts(),
          ).thenAnswer((_) async => testAccounts);
          when(
            () => mockRepository.getTotalBalance(),
          ).thenAnswer((_) async => 1000.0);
          return accountBloc;
        },
        act: (bloc) => bloc.add(
          CreateTransfer(
            transfer: testTransfer,
            fromAccountId: '1',
            toAccountId: '2',
          ),
        ),
        expect: () => [isA<TransferError>()],
      );
    });
  });
}
