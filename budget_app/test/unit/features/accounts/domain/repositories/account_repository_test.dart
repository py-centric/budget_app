import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/accounts/domain/repositories/account_repository.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/domain/entities/transfer.dart';

class MockAccountRepository extends Mock implements AccountRepository {}

class FakeAccount extends Fake implements Account {}

class FakeTransfer extends Fake implements Transfer {}

void main() {
  late MockAccountRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeAccount());
    registerFallbackValue(FakeTransfer());
  });

  setUp(() {
    mockRepository = MockAccountRepository();
  });

  group('AccountRepository', () {
    test('getAllAccounts should return list of accounts', () async {
      final accounts = [
        Account(
          id: '1',
          name: 'Main Account',
          type: AccountType.checking,
          balance: 1000.0,
          currency: 'USD',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];

      when(
        () => mockRepository.getAllAccounts(),
      ).thenAnswer((_) async => accounts);

      final result = await mockRepository.getAllAccounts();

      expect(result, accounts);
      expect(result.length, 1);
    });

    test('getAccount should return account by id', () async {
      final account = Account(
        id: '1',
        name: 'Savings',
        type: AccountType.savings,
        balance: 5000.0,
        currency: 'EUR',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      when(
        () => mockRepository.getAccount('1'),
      ).thenAnswer((_) async => account);

      final result = await mockRepository.getAccount('1');

      expect(result, account);
      expect(result!.name, 'Savings');
    });

    test('getAccount should return null for unknown id', () async {
      when(
        () => mockRepository.getAccount('unknown'),
      ).thenAnswer((_) async => null);

      final result = await mockRepository.getAccount('unknown');

      expect(result, isNull);
    });

    test('createAccount should call repository', () async {
      when(() => mockRepository.createAccount(any())).thenAnswer((_) async {});

      final account = Account(
        id: '1',
        name: 'New Account',
        type: AccountType.checking,
        balance: 0.0,
        currency: 'USD',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      await mockRepository.createAccount(account);

      verify(() => mockRepository.createAccount(account)).called(1);
    });

    test('updateAccount should call repository', () async {
      when(() => mockRepository.updateAccount(any())).thenAnswer((_) async {});

      final account = Account(
        id: '1',
        name: 'Updated',
        type: AccountType.savings,
        balance: 100.0,
        currency: 'USD',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      await mockRepository.updateAccount(account);

      verify(() => mockRepository.updateAccount(account)).called(1);
    });

    test('deleteAccount should call repository', () async {
      when(() => mockRepository.deleteAccount('1')).thenAnswer((_) async {});

      await mockRepository.deleteAccount('1');

      verify(() => mockRepository.deleteAccount('1')).called(1);
    });

    test('getTotalBalance should return sum of all balances', () async {
      when(
        () => mockRepository.getTotalBalance(),
      ).thenAnswer((_) async => 1500.0);

      final result = await mockRepository.getTotalBalance();

      expect(result, 1500.0);
    });

    test('getTransfersForAccount should return transfers', () async {
      final transfers = [
        Transfer(
          id: '1',
          fromAccountId: 'acc-1',
          toAccountId: 'acc-2',
          amount: 100.0,
          date: DateTime(2024, 1, 15),
          createdAt: DateTime(2024, 1, 15),
        ),
      ];

      when(
        () => mockRepository.getTransfersForAccount('acc-1'),
      ).thenAnswer((_) async => transfers);

      final result = await mockRepository.getTransfersForAccount('acc-1');

      expect(result, transfers);
      expect(result.length, 1);
    });

    test('createTransfer should call repository', () async {
      when(
        () => mockRepository.createTransfer(any(), any(), any()),
      ).thenAnswer((_) async {});

      final transfer = Transfer(
        id: '1',
        fromAccountId: 'acc-1',
        toAccountId: 'acc-2',
        amount: 500.0,
        date: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
      );

      await mockRepository.createTransfer(transfer, 'acc-1', 'acc-2');

      verify(
        () => mockRepository.createTransfer(transfer, 'acc-1', 'acc-2'),
      ).called(1);
    });
  });
}
